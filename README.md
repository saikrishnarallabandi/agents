# agents

A collection of AI agent definitions — single Markdown files that turn a
general-purpose agent into a specialist. Each one is YAML frontmatter (name,
description, scope) plus a system prompt encoding a working method: the job it
does, the failure mode it exists to prevent, how it works, and what it returns.

They're organized by domain, with both platform formats side by side:

- `agents/<domain>/<name>.md` — Claude Code subagent format
- `agents/<domain>/<name>.agent.md` — GitHub Copilot custom-agent format (VS Code)

The two formats carry the same instructions; only the frontmatter differs.

## Catalog

### research

| Agent | What it does |
|---|---|
| `paper-writer` | Drafts a research paper section by section on a fixed seven-section skeleton — and tries to **kill the central claim** (kill checklist, claim ledger) before writing it up. Done = a compiled PDF with zero errors. Venues: ACL/EMNLP, NeurIPS, ICLR, ICML, Interspeech, ICASSP. |
| `lit-reviewer` | Fans out over papers, docs, and codebases for a scoped question and returns a **primary-source-verified** brief: what exists, what it actually claims, the gap left for you. Read-only. Use before proposing anything research-shaped — and as the scoop-check step inside `paper-writer`. |

Two rules define `paper-writer`'s character: **every claim in the introduction
must be discharged by a named section** (it builds a claim ledger and checks
each row), and **the limitations section is written before the abstract** — if
the claim doesn't survive its own threats section, it writes a different paper.

### coding

| Agent | What it does |
|---|---|
| `coder` | The implementer in a write → review → fix loop. Reads the actual code first, fixes root causes only, returns files changed + how to exercise them + tests actually run. |
| `code-reviewer` | Adversarial reviewer in a **fresh context** that never saw the code being written. Runs the tests, tries to break the error paths, returns a hard `PASS` / `CHANGES_REQUIRED` verdict. Read-only — it never edits; the coder applies fixes. |

## Install

**Claude Code** — copy the `.md` files to your subagent directory:

```bash
cp agents/*/*.md ~/.claude/agents/          # user-level, all projects
# or: mkdir -p .claude/agents && cp agents/*/*.md .claude/agents/   # this repo only
```

Invoke via the Task tool (`subagent_type: "paper-writer"`, …). `paper-writer`
calls `lit-reviewer` on its own for the scoop check; `coder` and
`code-reviewer` are designed to be orchestrated as a loop
(coder → reviewer → coder with the blocking findings → …).

**GitHub Copilot (VS Code)** — copy the `.agent.md` files:

```bash
mkdir -p .github/agents && cp agents/*/*.agent.md .github/agents/   # per-repo
# or: mkdir -p ~/.copilot/agents && cp agents/*/*.agent.md ~/.copilot/agents/  # global
```

Then open Copilot Chat, switch the agent picker from "Agent" to the agent you
want, and prompt it. (Copilot ports only exist where the instructions are
model-agnostic prose — currently the two research agents.)

Prerequisite for the paper compile step: a LaTeX distribution with `pdflatex`
(TeX Live, MiKTeX). The agent shells out to build the PDF; approve the first
terminal run when VS Code asks.

## latex/

Official, unmodified venue style files (`neurips/`, `aaai/`, `acl/`) plus a
minimal `template.tex` skeleton with the seven sections `paper-writer` uses.
The agent copies the style it needs next to its draft — this directory is where
it copies *from*. See `latex/README.md`.

## Adding an agent

1. Write `<name>.md` in Claude format: `name`/`description`/`tools` frontmatter,
   then the method. Name the failure mode it prevents.
2. If the instructions are model-agnostic prose, add the `<name>.agent.md`
   Copilot port: drop `tools:`/`model:`, add `argument-hint:`, keep the body.
   Frontmatter must be the first lines of the file.
3. File both under `agents/<domain>/` and add a row to the catalog above.

## Safety notes

- `paper-writer` defaults to **internal**: it places the `.tex`/`.pdf` and
  stops. It will not push to a public remote or submit anywhere on its own.
- `lit-reviewer` and `code-reviewer` are read-only by instruction.
- Never state a number a subagent reported without verifying it at the primary
  source. A subagent summary is a lead.

## Provenance

Extracted September 2026 from a working Claude Code setup; the Copilot versions
are faithful ports. Venue style files are the official distributions,
unmodified. Nothing here contains private data — the method is the product.
