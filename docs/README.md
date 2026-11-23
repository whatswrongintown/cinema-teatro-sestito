# Project documentation

Start with [project status](project-status.md) for current decisions, open
items, completed work and the plan to move the site to Hugo only. Assistant
instructions are in [CLAUDE.md](../CLAUDE.md). Use the documents below for detail;
proposals do not override the status record.

| Category | Document | Purpose |
| --- | --- | --- |
| Guide | [Historical programming](guides/historical-programming.md) | CSV inputs, Hugo-built tables, dashboard and PDF workflows |
| Guide | [Poster collection](posters.md) | Local poster generation, overrides and generated site data |
| Plan | [Implementation guide](plans/implementation-guide.md) | Steps for the Hugo-only migration and other open or deferred work |
| Proposal | [Website improvement ideas](proposals/website-improvement-ideas.md) | Feature proposals and provider references |
| Proposal | [Methodology data analysis](proposals/methodology-data-analysis.md) | Dated data snapshot and possible additions to the methodology article |

## Documentation rules

- The project status is authoritative for current state. The implementation
  guide gives recommended steps but does not change item status.
- Proposals are not approved implementation plans unless the status record says
  so. Data figures in proposal notes are dated snapshots; recalculate before
  relying on them.
- Generated historical programming pages and charts are documented in the
  guide; update their source CSVs and generators rather than editing generated
  output by hand.
- When a migration item replaces an R workflow, update or remove its guide in
  the same change. Removed documents stay available in Git history.
