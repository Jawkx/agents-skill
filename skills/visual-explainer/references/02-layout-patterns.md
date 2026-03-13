# Layout Patterns

Choose the rendering approach that makes the information easiest to read.

## Base HTML Shell

Start from a minimal shell and keep the file self-contained.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Descriptive title</title>
  <style>
    :root {
      --bg: #f7f4ef;
      --surface: #fffdf8;
      --border: rgba(0, 0, 0, 0.1);
      --text: #201a16;
      --text-dim: #655b52;
      --accent: #0f766e;
      --accent-2: #b45309;
    }
    * { box-sizing: border-box; }
    body { margin: 0; background: var(--bg); color: var(--text); }
  </style>
</head>
<body></body>
</html>
```

## Pick The Right Structure

- `Mermaid`: Use when edge routing matters: flowcharts, sequence diagrams, state machines, ER diagrams, class diagrams, and mind maps.
- `CSS cards and grid`: Use for text-heavy architecture overviews, implementation plans, and recap pages.
- `Hybrid`: Use a small Mermaid overview plus detailed HTML cards when the topology matters but the node content is too dense for Mermaid.
- `HTML table`: Use for comparisons, audits, coverage matrices, and fact-check claim tables.
- `Timeline`: Use for recent activity, rollout plans, or chronological narratives.
- `Dashboard`: Use KPI cards, small charts, and status indicators for metrics-heavy summaries.
- `Slides`: Use full-height sections only when the user asked for presentation format.

## Page Anatomy

Most pages should have:

1. A strong opening section with the core insight.
2. A compact summary or KPI strip.
3. One or more main explanatory sections.
4. Reference sections for details, tables, or file maps.

If the page has four or more major sections, add lightweight navigation near the top or in a sticky sidebar.

## Common Patterns

- Use a hero section for the takeaway, not boilerplate intro text.
- Use cards when a section contains short, separate ideas.
- Use `<details>` for bulky reference material that should not dominate the first screen.
- Use `<pre><code>` with `white-space: pre-wrap` for code snippets so long lines wrap instead of overflowing.
- Use `min-width: 0` on grid and flex children so content can shrink correctly.

## Tables

- Use a real `<table>`, not a grid pretending to be one.
- Use sticky headers for long tables.
- Let text-heavy columns wrap naturally.
- Right-align numeric columns.
- Use small badges or tinted cells for status instead of emoji.

## Mermaid

- Keep diagrams readable before trying to make them clever.
- Prefer top-down layouts for complex diagrams.
- Use custom theme variables or CSS overrides so Mermaid matches the page palette.
- If the diagram is large, place it in a scroll-safe or zoom-friendly container.

## Optional Libraries

- Use Mermaid when diagrams need automatic layout.
- Use Chart.js only when a real chart is materially better than a table or sparkline.
- Avoid external dependencies that are decorative but not necessary.
