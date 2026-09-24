# research-agents

A small kit of AI agents for doing research: drafting papers, surveying prior
art, and a write → review → fix loop for code. Each agent is a single Markdown
file — YAML frontmatter (name, description, scope) plus a system prompt that
encodes a working method, not just a persona.

These are extracted from a daily-use setup. They are deliberately opinionated:
each one exists to prevent a specific failure mode its author kept seeing.

## The agents

| Agent | What it does | Use it when |
|---|---|---|
| `paper-writer` | Drafts a research paper section by section on a fixed seven-section skeleton — and tries to **kill the central claim** (kill checklist, claim ledger) before writing it up. Done = a compiled PDF with zero errors. | Conference submissions (ACL/EMNLP, NeurIPS, ICLR, ICML, Interspeech, ICASSP) or internal reports shaped like a paper. |
| `lit-reviewer` | Fans out over papers, docs, and codebases for a scoped question and returns a **primary-source-verified** brief: what exists, what it actually claims, the gap left for you. Read-only. | Before proposing or building anything research-shaped; also the scoop-check step inside `paper-writer`. |
| `coder` | The implementer in a write → review → fix loop. Reads the actual code first, fixes root causes, returns files changed + how to exercise them + tests actually run. | Any code change worth reviewing. |
| `code-reviewer` | Adversarial reviewer in a **fresh context** that never saw the code being written. Runs the tests, tries to break the error paths, returns a hard `PASS` / `CHANGES_REQUIRED` verdict. Read-only — it never edits; the coder applies fixes. | The review step of the loop. |

Two rules define `paper-writer`'s character and are worth knowing before you use
it: **every claim in the introduction must be discharged by a named section**
(it builds a claim ledger and checks each row), and **the limitations section
is written before the abstract** — if the claim doesn't survive its own
threats section, it writes a different paper.

## Use with Claude Code

Copy the files in `agents/claude/` to your subagent directory:

```bash
# user-level (all projects)
cp agents/claude/*.md ~/.claude/agents/

# or project-level (this repo only)
mkdir -p .claude/agents && cp agents/claude/*.md .claude/agents/
```

Invoke them with the Task tool (`subagent_type: "paper-writer"`, etc.), or
slash-command them if your setup maps agents that way. `paper-writer` will
call `lit-reviewer` on its own for the scoop check; `coder` and `code-reviewer`
are designed to be orchestrated as a loop (coder → reviewer → coder with the
blocking findings → …).

## Use with GitHub Copilot (VS Code)

Copilot's custom agents live in `.agent.md` files. Ports of `paper-writer` and
`lit-reviewer` are in `agents/copilot/` — the same instructions, with the
Claude-only frontmatter (`tools:`, `model:`) removed:

```bash
# per-repo
mkdir -p .github/agents && cp agents/copilot/*.agent.md .github/agents/

# or globally for all workspaces
mkdir -p ~/.copilot/agents && cp agents/copilot/*.agent.md ~/.copilot/agents/
```

Then open Copilot Chat, switch the agent picker from "Agent" to
`paper-writer` (or `lit-reviewer`), and prompt it. Give `paper-writer` the
central claim, the key results, and the target venue; when it reaches the
scoop-check step, switch the picker to `lit-reviewer` and hand it the scoped
question. (`coder`/`code-reviewer` have no Copilot ports yet — contributions
welcome.)

Prerequisite for the compile step: a LaTeX distribution with `pdflatex`
(TeX Live, MiKTeX). The agent shells out to build the PDF; approve the first
terminal run when VS Code asks.

## The paper workflow

1. **Scope the claim.** One refutable sentence. If you have several, you have
   several papers.
2. **Scoop check.** Run `lit-reviewer` on the claim *before* drafting. If it's
   published, your contribution is the gap.
3. **Draft.** Run `paper-writer` with claim + results + venue. It runs the kill
   checklist, writes limitations before the abstract, and compiles.
4. **Verify.** Read the claim ledger and the kill-checklist report in its final
   message. Anything it marked unverified is yours to check.

## `latex/`

Official, unmodified venue style files (`neurips/`, `aaai/`, `acl/`) plus a
minimal `template.tex` skeleton with the seven sections. The agent copies the
style it needs next to its draft — this directory is where it copies *from*.
See `latex/README.md`.

## Safety notes

- `paper-writer` defaults to **internal**: it places the `.tex`/`.pdf` and
  stops. It will not push to a public remote or submit anywhere on its own.
- `lit-reviewer` and `code-reviewer` are read-only by instruction.
- Never state a number a subagent reported without verifying it at the primary
  source. A subagent summary is a lead.

## Provenance

Extracted September 2026 from a working Claude Code setup (`~/.claude/agents/`
on the author's machine); the Copilot versions are faithful ports. Venue style
files are the official distributions, unmodified. Nothing here contains private
data — the method is the product.
