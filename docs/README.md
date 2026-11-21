# Project documentation

Start with [project status](project-status.md) for current decisions, open
items and completed work. Use the documents below for detail; proposals and
historical audits do not override the status record.

| Category | Document | Purpose |
| --- | --- | --- |
| Guide | [Historical programming](guides/historical-programming.md) | CSV inputs, R generation, generated output, and Shiny workflow |
| Guide | [Poster collection](posters.md) | Local poster generation, overrides and generated site data |
| Plan | [Implementation guide](plans/implementation-guide.md) | Steps and files for open, deferred, and ongoing work |
| Proposal | [Website improvement ideas](proposals/website-improvement-ideas.md) | Feature proposals, provider references, and poster planning |
| Proposal | [Methodology data analysis](proposals/methodology-data-analysis.md) | Dated data snapshot and possible additions to the methodology article |
| History | [Phase 1 audit](logs/phase_1_know_the_project.md) | Dated project inventory and decisions from the audit |
| History | [Phase 2 audit](logs/phase_2_check_the_functioning.md) | Dated checks of site behavior and generated output |

## Documentation rules

- The project status is authoritative for current state. The implementation
  guide gives recommended steps but does not change item status.
- Proposals are not approved implementation plans unless the status record says
  so. Data figures in proposal notes are dated snapshots; recalculate before
  relying on them.
- Audit logs preserve what was observed at the time. Consult the current status
  before treating a logged finding as open.
- Generated historical programming pages and charts are documented in the
  guide; update their source CSVs and R scripts rather than editing generated
  output by hand.
