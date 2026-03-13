---
name: visual-explainer
description: Generate self-contained HTML pages that visually explain code, systems, plans, diffs, and structured technical information. Use when the user asks for an architecture overview, workflow diagram, implementation plan, diff review, project recap, fact check against code, slide-style presentation, or any dense comparison or table that would be easier to understand in a browser than in plain text.
---

# Visual Explainer

Generate a polished single-file HTML artifact when plain text would be hard to scan, compare, or visualize. Favor browser-first explanations with real hierarchy, readable tables, and diagrams that remain useful after the chat ends.

## Workflow

1. Decide whether the task actually needs HTML. Read [references/01-routing.md](references/01-routing.md).
2. Choose the rendering approach and page anatomy from [references/02-layout-patterns.md](references/02-layout-patterns.md).
3. Pick a deliberate visual direction from [references/03-visual-style.md](references/03-visual-style.md) before writing CSS.
4. If the task is a diagram, implementation plan, or slide deck, read [references/04-diagrams-and-plans.md](references/04-diagrams-and-plans.md).
5. If the task is a diff review, plan review, project recap, or fact-check, read [references/05-reviews-and-recaps.md](references/05-reviews-and-recaps.md).
6. Before delivering, run [references/06-quality-checks.md](references/06-quality-checks.md).

## Output Rules

- Produce a single self-contained `.html` file with inline CSS and only minimal optional CDN dependencies.
- Prefer a stable workspace-local path such as `.artifacts/visual-explainer/<slug>.html`; if that is not appropriate, use another user-visible local path. Always tell the user the exact file path.
- Open the file if the environment clearly supports it. Otherwise, provide the path and a short note on how to open it.
- Use semantic HTML, responsive layout, accessible contrast, and natural text wrapping.
- Prefer real HTML tables over ASCII tables for dense structured data.
- Keep prose concise; the page should carry the explanation.
- Verify every factual claim against source material before rendering it.

## Boundaries

- If the user wants raw Mermaid syntax, plain Markdown, or a terse answer, do not force HTML.
- If the task is building a real application UI rather than a static explainer artifact, prefer `frontend-design`.
- If the output is primarily Mermaid source, prefer `mermaid-diagrams`.

## Reference Map

- Routing and artifact selection: [references/01-routing.md](references/01-routing.md)
- Layout and rendering patterns: [references/02-layout-patterns.md](references/02-layout-patterns.md)
- Visual direction and anti-slop rules: [references/03-visual-style.md](references/03-visual-style.md)
- Diagram, plan, and slide workflows: [references/04-diagrams-and-plans.md](references/04-diagrams-and-plans.md)
- Review, recap, and fact-check workflows: [references/05-reviews-and-recaps.md](references/05-reviews-and-recaps.md)
- Final QA checklist: [references/06-quality-checks.md](references/06-quality-checks.md)
