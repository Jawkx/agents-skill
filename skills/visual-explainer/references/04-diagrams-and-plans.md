# Diagrams And Plans

Use these workflows when the output centers on system understanding, proposed changes, or presentation-style storytelling.

## Architecture And System Diagrams

Gather:

- audience and level of detail
- key modules, actors, or states
- important edges and data flow
- unknowns that must be marked as assumptions

Common sections:

1. Core takeaway or scope statement
2. Main diagram
3. Module cards or component details
4. Interfaces, data flow, or callouts
5. Risks, assumptions, or next steps

Use Mermaid for topology-focused diagrams. Use a hybrid page when the relationships are simple but each component needs rich explanation.

## Visual Implementation Plans

Show the move from current state to target state.

Gather:

- the current design and constraints
- the proposed changes
- blast radius, test impact, docs impact, and ordering risks

Common sections:

1. Problem and proposed approach
2. Current-state architecture
3. Planned-state architecture
4. Change-by-change breakdown
5. Risks, assumptions, and sequencing
6. Suggested verification steps

Use side-by-side panels only when both sides remain readable on narrow screens.

## Slide Decks

Use slide format only when the user explicitly asks for slides or a presentation.

- Each slide should fit one viewport height.
- Compose a narrative arc instead of dumping sections mechanically.
- Cover all important content; do not drop key decisions just to keep the deck short.
- Vary compositions so consecutive slides do not feel identical.
- Keep text shorter and larger than in a scroll page.

Useful slide sequence:

1. Title and context
2. Why this matters
3. System or plan overview
4. Deep-dive slides
5. Risks or tradeoffs
6. Closing recommendation or next step
