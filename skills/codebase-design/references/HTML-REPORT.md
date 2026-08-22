# Architecture report format

Use this format only as part of the architecture-improvement workflow.

## Output

Create one HTML file in the system temporary directory. Tailwind and Mermaid may load from CDNs. Keep the document static apart from Mermaid rendering.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Architecture review for {{repository}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900">
    <main class="mx-auto max-w-5xl space-y-12 px-6 py-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Show repository name, date, and a compact legend:

- Solid box: module
- Dashed line: seam
- Red arrow: leaked knowledge
- Thick dark box: deep module

Start with the candidates. Avoid an introduction paragraph.

## Candidate card

Each card contains:

- Short title naming the deepening
- Recommendation badge
- Dependency-category badge
- Monospaced file list
- Side-by-side before and after diagrams
- One-sentence problem
- One-sentence direction
- Short benefit bullets using locality, leverage, interface, and test language

Keep prose sparse. The diagram should carry the explanation.

## Diagram choices

Choose the form that best explains the evidence:

- Mermaid flowchart for dependencies and call flow
- Mermaid sequence diagram for repeated coordination or round trips
- Hand-built boxes when showing one deep module with faded internals
- Horizontal cross-section for several shallow pass-through modules
- Mass diagram when interface size nearly matches implementation size
- Call-graph collapse when many public calls become internal behavior

Keep diagrams around 320 pixels tall so the comparison fits without excessive scrolling.

## Visual style

Use generous whitespace and one restrained accent color. Reserve red for leaked knowledge and amber for uncertainty. Avoid dashboard decoration that does not explain the architecture.

## Top recommendation

End with one larger card containing:

- Candidate name
- One sentence explaining why it should go first
- A link back to its candidate card
