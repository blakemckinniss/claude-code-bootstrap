#!/bin/bash
# PreToolUse hook that suggests Chrome DevTools MCP for debugging tasks
# when Playwright MCP is about to be used

set -euo pipefail

# Graceful degradation: Check dependencies
command -v jq >/dev/null 2>&1 || exit 0

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool name and input using jq
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')

# =============================================================================
# Chrome DevTools MCP Suggestion System
# =============================================================================
# Detects when Playwright MCP tools are used for debugging and suggests
# Chrome DevTools MCP as a better alternative.
#
# Philosophy: Advisory-only, non-blocking. Empowers Claude without restrictions.
# =============================================================================

# Strong debugging signals - tools almost exclusively for debugging
case "$TOOL_NAME" in
  "mcp__playwright__playwright_get_visible_html")
    # Getting HTML is almost always for inspection, not automation
    jq -n \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "allow",
          permissionDecisionReason: "💡 **Chrome DevTools MCP Suggestion**\n\nYou'\''re using Playwright to get page HTML for inspection.\n\n**Consider Chrome DevTools MCP instead:**\n• `take_snapshot` - Accessibility tree (faster, structured, includes element UIDs)\n• `list_console_messages` - Check for client-side errors and logs\n• `get_network_request` - Inspect network activity\n\n**Why Chrome DevTools MCP?**\n• Faster than retrieving full HTML\n• Structured data easier to parse\n• Includes console logs and network requests\n• Better for debugging and inspection\n\n**When to use Playwright:** Test automation, cross-browser testing, CI/CD"
        }
      }'
    exit 0
    ;;

  "mcp__playwright__playwright_console_logs")
    # Console logs are debugging-specific
    jq -n \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "allow",
          permissionDecisionReason: "💡 **Chrome DevTools MCP Suggestion**\n\nYou'\''re using Playwright for console logs.\n\n**Consider Chrome DevTools MCP instead:**\n• `list_console_messages` - More detailed console inspection\n• Filter by type (error, warning, log, info, debug)\n• Access full message context and stack traces\n• Better pagination and search capabilities\n\n**Chrome DevTools MCP provides:**\n• Real-time console monitoring\n• Message filtering and search\n• Full error stack traces\n• Better performance for log-heavy applications"
        }
      }'
    exit 0
    ;;

  "mcp__playwright__playwright_evaluate")
    # Check if this is inspection (debugging) vs manipulation (automation)
    SCRIPT=$(echo "$TOOL_INPUT" | jq -r '.script // .function // ""')

    # Heuristic: Simple read-only queries are likely debugging
    # Look for patterns like: document.*, window.*, element property access
    # Exclude: Setting values (=), method calls that modify state

    # Strong debugging signals:
    # - Reading document/window properties: document.title, window.location
    # - Element inspection: el.innerText, el.getAttribute
    # - Variable inspection: return myVar

    if echo "$SCRIPT" | grep -qE '(document\.|window\.|location\.|innerText|textContent|getAttribute|querySelector)' && \
       ! echo "$SCRIPT" | grep -qE '(\s=\s|\.click\(|\.submit\(|\.focus\(|addEventListener)'; then
      jq -n \
        '{
          hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "allow",
            permissionDecisionReason: "💡 **Chrome DevTools MCP Suggestion**\n\nYou'\''re using Playwright to evaluate JavaScript for inspection.\n\n**Consider Chrome DevTools MCP instead:**\n• `evaluate_script` - Same functionality with better debugging context\n• Direct access to DevTools console for interactive testing\n• Better error messages and stack traces\n• Can inspect elements with UIDs from `take_snapshot`\n\n**Chrome DevTools MCP advantages:**\n• Integrated with DevTools Elements panel\n• Can evaluate in context of inspected elements\n• Better error reporting for failed evaluations\n• Console history and autocomplete\n\n**When to use Playwright:** Test automation requiring state manipulation, complex multi-step scenarios"
          }
        }'
      exit 0
    fi
    ;;
esac

# Conditional debugging signals - depends on parameters
case "$TOOL_NAME" in
  "mcp__playwright__playwright_screenshot")
    # Heuristic: Screenshots for debugging typically don't have descriptive paths
    PATH_VALUE=$(echo "$TOOL_INPUT" | jq -r '.name // .path // ""')

    # Strong debugging signals only (avoid false positives for test automation)
    # - Empty/missing path (temporary screenshot)
    # - Contains "debug" or "temp" or "inspect" (but NOT test-case/test-report)
    # - Very generic names like "screen.png", "page.png"

    # Exclude test artifacts (reports/, test-case-, test-report-, etc.)
    if echo "$PATH_VALUE" | grep -qiE '(report|test-case|test-report|artifact|ci-cd)'; then
      # This is test automation, not debugging - don't suggest
      exit 0
    fi

    # Now check for debugging signals
    if [ -z "$PATH_VALUE" ] || \
       echo "$PATH_VALUE" | grep -qiE '(debug|temp|inspect|check)' || \
       echo "$PATH_VALUE" | grep -qE '^(screen|page|snapshot)\.png$'; then
      jq -n \
        --arg path "$PATH_VALUE" \
        '{
          hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "allow",
            permissionDecisionReason: "💡 **Chrome DevTools MCP Suggestion**\n\nYou'\''re taking a screenshot (\($path)) for visual inspection.\n\n**Consider Chrome DevTools MCP instead:**\n• `take_snapshot` - Structured page view without rendering image (faster)\n• `take_screenshot` - Often faster via CDP when needed\n• `list_console_messages` - Check for JavaScript errors\n• `get_network_request` - Inspect network activity affecting page\n\n**Why start with `take_snapshot`?**\n• Text-based, faster than image rendering\n• Includes element UIDs for precise interaction\n• Shows accessibility tree structure\n• Can always take screenshot if needed\n\n**When to use Playwright:** Test artifacts, CI/CD reports, cross-browser visual testing"
          }
        }'
      exit 0
    fi
    ;;

  "mcp__playwright__playwright_navigate")
    # Check if this is exploratory navigation (vs targeted test navigation)
    # Look at transcript to see if this is part of debugging workflow
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

    if [ -f "$TRANSCRIPT_PATH" ]; then
      # Check recent context for debugging keywords
      RECENT_CONTEXT=$(tail -n 5 "$TRANSCRIPT_PATH" | jq -r '.message.content // ""' 2>/dev/null || echo "")

      if echo "$RECENT_CONTEXT" | grep -qiE '\b(debug|inspect|check|investigate|analyze|examine)\b'; then
        jq -n \
          '{
            hookSpecificOutput: {
              hookEventName: "PreToolUse",
              permissionDecision: "allow",
              permissionDecisionReason: "💡 **Chrome DevTools MCP Suggestion**\n\nYou'\''re navigating to debug/inspect a page.\n\n**Consider Chrome DevTools MCP workflow:**\n1. `navigate_page` - Navigate to URL\n2. `take_snapshot` - Get accessibility tree (fast, structured)\n3. `list_console_messages` - Check for errors/warnings\n4. `get_network_request` - Inspect API calls and responses\n5. `take_screenshot` - Visual confirmation if needed\n\n**Chrome DevTools MCP advantages:**\n• Full DevTools interface via MCP\n• Real-time console and network monitoring\n• Performance profiling capabilities\n• Element inspection with computed styles\n\n**When to use Playwright:** Test automation, multi-page workflows, cross-browser testing"
            }
          }'
        exit 0
      fi
    fi
    ;;
esac

# No debugging patterns detected - allow normal flow
exit 0
