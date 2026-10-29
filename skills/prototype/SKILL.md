---
name: prototype
description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
metadata:
  credits:
    - skill: prototype
      author: Matt Pocock
      url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/prototype/SKILL.md"
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

## Pick a branch

Identify which question is being answered, using the user's prompt, the surrounding code, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → [LOGIC.md](LOGIC.md). Build a single shareable HTML file (free-play buttons plus tabbed guided walkthroughs) that pushes the state machine through cases that are hard to reason about on paper, and that a non-developer can drive.
- **"What should this look like?"** → [UI.md](UI.md). Generate several radically different UI variations on a single route, switchable via a URL search param and a floating bottom bar.
- **"How should this sound or move?"** (video, audio, motion) → render each variant and put them all on one shareable HTML comparison page. Change one thing per variant where you can, and state exactly what differs between them.

The two branches produce very different artifacts, so getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (a backend module → logic; a page or component → UI) and state the assumption at the top of the prototype.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Locate the prototype code close to where it will actually be used (next to the module or page it's prototyping for) so context is obvious, but name it so a casual reader can see it's a prototype, not production. For throwaway UI routes, obey whatever routing convention the project already uses; don't invent a new top-level structure.
2. **Trivial to run.** A UI prototype starts from one command in the project's task runner: `pnpm <name>`, `python <path>`, `bun <path>`, etc. A logic demo is a single HTML file the user double-clicks. Either way, no thinking required to start it.
3. **No persistence by default.** State lives in memory. Persistence is the thing the prototype is _checking_, not something it should depend on. If the question explicitly involves a database, hit a scratch DB or a local file with a clear "PROTOTYPE, wipe me" name.
4. **Skip the polish.** No tests, no error handling beyond what makes the prototype _runnable_, no abstractions. The point is to learn something fast.
5. **Surface the state.** After every action (logic) or on every variant switch (UI), print or render the full relevant state so the user can see what changed.
6. **Show it in the chat.** Hand the prototype over as screenshots inside the chat, one per variant or walkthrough step, not as a link to open. A `localhost` URL or a path on your machine points at nothing on the user's machine, so never make it the only way to see the prototype. Embed the images so they render where the user reads them: if the host has a tool that renders HTML into the chat (T3 Code's `html_render`), inline the images into that page as data URIs instead of pointing at file paths, which the chat may not be able to load. Put the screenshots and the question about them in the **last message of your turn**: anything you post after it (a follow-up, a reply to a stop hook) pushes them into the collapsed work log. Ask in the message text under the images, never in a question dialog that covers them. The file or URL can follow as an extra for a user who wants to click around.
7. **Capture it when done.** Fold any validated decision into the real code, unless the prototype serves a planning map (wayfinder), where the decision only gets recorded. Then capture the prototype itself as a **primary source**: commit it to a throwaway branch, out of main (commit with `[skip ci]` in the message and push with `--no-verify`: it never merges, so neither the repo's gate nor CI applies), and leave a context pointer to that branch on the implementation issue. Capture the answer too (the verdict and the question it settled) in the issue or a commit. The main branch keeps only the validated decision.
