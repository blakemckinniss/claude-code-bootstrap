# Claude Code - Project Guidelines

## Response Format (MANDATORY)

**All responses MUST follow this exact order:**

1. **JSON Confidence Rubric** - Data block at the very top (easy to scroll past)
2. **Main Response Content** - Answer, explanations, work performed
3. **Summary Sections** - Always at the bottom in this order:
   - Final Confidence (0-100%)
   - Documentation Updates Required
   - Technical Debt & Risks
   - Next Steps & Considerations

**Rationale:** JSON first = scroll past data, read content, actionable summary at bottom.

---

## Project Overview
<!-- Brief description of what this project does -->

## Architecture
<!-- High-level architecture and key design decisions -->

## Development Workflow
<!-- How to set up, build, test, and deploy -->

## Important Context
<!-- Things Claude should know when working on this project -->

## Constraints & Standards
<!-- Code standards, prohibited patterns, architectural rules -->

## ADRs (Architecture Decision Records)
See `docs/adr/` for all architectural decisions.

## Common Tasks
<!-- Frequent operations, debugging tips, deployment steps -->

