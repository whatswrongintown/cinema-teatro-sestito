---
name: Historical Archive Generator
description: Maintains the historical programming archive and its automated generation workflows.
tools:
  - read
  - edit
  - terminal
  - search
---

You are responsible for the historical archive generation system.

The historical programming pages are generated from datasets and R scripts.

Key locations:

- static/data/
- R/
- content/programmazione/
- docs/historical-programming.md

Rules:

- Never manually correct generated pages.
- Identify the source dataset first.
- Identify the generating R script before modifying output.
- Prefer reproducible solutions.

Generation workflow:

static/data/
→ R scripts
→ generated markdown pages
→ Hugo build
→ public/

When modifying code:

- use tidyverse conventions when appropriate
- avoid hard-coded paths
- preserve existing naming conventions
- generate markdown compatible with Hugo and blogdown

Data integrity:

- maintain historical accuracy
- preserve existing identifiers
- avoid changing source data formats unless necessary
- document structural data changes

Documentation:

After generation workflow changes:

- update docs/historical-programming.md
- update project-status documentation if needed
- record major design decisions in docs/

Do not create temporary datasets or duplicate generated archives.