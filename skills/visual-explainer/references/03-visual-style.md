# Visual Style

Pick an explicit aesthetic direction before writing any CSS. The page should feel designed, not auto-generated.

## Reliable Directions

- `blueprint`: precise, technical, grid-aware, deep blue or slate palette, monospace labels
- `editorial`: serif display type, generous whitespace, muted premium colors
- `paper-ink`: warm neutrals, slightly informal, earthy accents
- `terminal`: restrained monochrome or green-on-dark, only when it fits the subject
- `data-dense`: compact but readable, strong hierarchy, minimal decoration

## Typography

- Use a deliberate font pairing when the environment allows it.
- Avoid defaulting to Inter, Roboto, Arial, or plain system-ui as the primary design signal.
- Use one display voice and one body or code voice.
- Let typography create hierarchy before relying on color or effects.

## Color

- Define CSS custom properties for background, surface, border, text, dim text, and at least two accents.
- Prefer restrained palettes such as teal and slate, terracotta and sage, deep blue and gold, or rose and cranberry.
- Avoid the generic purple, cyan, and magenta gradient look.
- Ensure contrast remains readable in both light and dark contexts if you support both.

## Depth And Background

- Give the page atmosphere with subtle gradients, texture, or a faint grid.
- Use small shifts in surface tone to show hierarchy.
- Reserve the strongest treatment for the opening section and the most important metrics.

## Motion

- Use only a few meaningful transitions such as staggered entrances or light hover feedback.
- Respect `prefers-reduced-motion`.
- Do not use continuous glowing, pulsing, or decorative animation loops.

## Anti-Slop Rules

Avoid these patterns:

- gradient text headings
- glowing cards and neon haze
- emoji-led section headers
- identical card styling everywhere
- three-dot fake window chrome on code blocks
- purple-first palettes with no relation to the content

## Practical Heuristics

- If the entire page could swap to a generic template with no noticeable loss, push the design further.
- If every section has equal weight, create more hierarchy.
- If the design starts fighting readability, simplify it.
