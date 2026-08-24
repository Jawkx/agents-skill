---
name: teach-code
description: Teach the user how a coding change works, then quiz them until they can explain and apply it. Use after implementing, debugging, reviewing, or discussing code when the user says "teach me," "quiz me," "grill me on this code," wants a walkthrough, or wants to learn alongside the work in the current session.
---

# Teach code

Teach from the code and decisions in the current session. This is a short, interactive lesson, not a separate course. Generate one self-contained HTML lesson for the current topic, but do not turn the repository into a teaching workspace.

## Ground the lesson

Before teaching:

1. Review the user's goal and the implementation discussed in this session.
2. Inspect the relevant diff, files, tests, and documentation when needed. Do not rely on a remembered or generic version of the code.
3. Identify the smallest useful lesson. Focus on one to three ideas that explain how the change works and transfer to future work.
4. If the requested focus is unclear, ask one short question about what they most want to understand. Otherwise, begin.

If the implementation has a bug or a misleading design, say so plainly. Do not teach a false explanation to defend the existing work. Keep teaching separate from further implementation unless the user asks for changes.

## Generate the lesson page

Create one self-contained HTML file for each teaching invocation.

- Save it in the project root. Use the Git root when one exists, otherwise use the current working directory.
- Name it `<topic>-code-lesson.html` with a short lowercase topic slug. If that path exists, use a numbered suffix rather than overwriting it.
- Keep all HTML, CSS, and JavaScript in that one file. Do not create assets, lesson directories, learning records, or other support files.
- Never stage or commit the generated page. Do not edit `.gitignore` unless the user asks.
- Use a readable, responsive layout with accessible markup, visible focus states, and support for light and dark color schemes. Keep the design restrained.
- Include the problem, execution or data flow, key ideas, relevant code excerpts, file and symbol references, and the important tradeoff.
- Include a short interactive self-check quiz. Prefer open-ended questions with a textarea and a button that reveals a model answer. Do not pretend JavaScript can judge free-form reasoning.
- Reveal answers only after the learner chooses to view them. Present quiz questions progressively when practical.
- Do not include secrets, credentials, private environment values, or large source dumps.

Open the generated page for the user when the environment provides a safe local open command. Tell the user the exact path either way.

## Explain first

Build the HTML page around a concise walkthrough in this order:

1. Restate the problem the code solves.
2. Trace the important control flow or data flow through named files and symbols.
3. Explain the key coding ideas in plain language.
4. Point out the important tradeoff or alternative, if one affected the implementation.

Use short code excerpts only when they make the explanation clearer. Tie every claim to the actual code. Do not narrate every line, dump the entire diff, or front-load a generic lecture.

After opening the page, give the user a brief orientation in chat. Then begin the conversational quiz.

## Quiz one question at a time

After the walkthrough, quiz the user interactively.

- Ask exactly one question per turn, then wait for the answer.
- Prefer open-ended recall. Do not use multiple choice unless the user asks for it.
- Do not repeat the page's quiz questions verbatim. Use the chat to probe the same ideas from a different angle.
- Start with understanding, then move to reasoning and transfer. A useful sequence is: explain what happens, predict what changes in an edge case, then apply the idea to a small variation.
- Do not reveal the answer inside the question or give hints before the user's first attempt.
- Judge the reasoning, not the wording.
- After each answer, say what was correct, fix the specific gap, and ask the next question at an appropriate difficulty.
- If the answer shows confusion, re-explain only that part with a smaller example, then try a different question.
- If the answer is strong, increase the difficulty rather than repeating the same fact.

Do not use the structured question tool for knowledge checks. Its choices weaken recall practice. Plain conversation is better here.

## Finish with proof of understanding

End with one brief teach-back or coding exercise. The user should explain the design in their own words, predict behavior, debug a small scenario, or sketch a related change.

Stop when they can both explain the core idea and apply it once. Close with a short summary of what they demonstrated and any single point worth revisiting. Do not keep grilling after they have shown understanding, and respect requests to pause or stop.
