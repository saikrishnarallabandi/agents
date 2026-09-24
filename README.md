# agents

A collection of AI agent definitions — single Markdown files that turn a
general-purpose agent into a specialist. Each one is YAML frontmatter (name,
description, scope) plus a system prompt encoding a working method: the job it
does, the failure mode it exists to prevent, how it works, and what it returns.

They're organized by domain, with both platform formats side by side:

- `agents/<domain>/<name>.md` — Claude Code subagent format
- `agents/<domain>/<name>.agent.md` — GitHub Copilot custom-agent format (VS Code)

The two formats carry the same instructions; only the frontmatter differs.

## Quickstart

```bash
git clone https://github.com/saikrishnarallabandi/agents.git
cd agents && ./install.sh
```

That's it. The script copies the Claude definitions to `~/.claude/agents/` and
the Copilot ones to `~/.copilot/agents/`. Flags: `--claude-only`,
`--copilot-only`. It only copies — never deletes anything.

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

## Using the agents

**Claude Code** — after `./install.sh`, invoke via the Task tool, e.g.
`subagent_type: "paper-writer"`. `paper-writer` calls `lit-reviewer` on its own
for the scoop check; `coder` and `code-reviewer` are designed to be
orchestrated as a loop (coder → reviewer → coder with the blocking
findings → …).

**GitHub Copilot (VS Code)** — after `./install.sh`, open Copilot Chat and pick
the agent from the agent dropdown. Give `paper-writer` the central claim, the
key results, and the target venue; when it reaches the scoop-check step,
switch the picker to `lit-reviewer` and hand it the scoped question. (Copilot
ports only exist where the instructions are model-agnostic prose — currently
the two research agents.)

Prerequisite for the paper compile step: a LaTeX distribution with `pdflatex`
(TeX Live, MiKTeX). The agent shells out to build the PDF; approve the first
terminal run when VS Code asks.

Prefer a per-project install instead of global? Copy the files by hand:
`.md` → `.claude/agents/`, `.agent.md` → `.github/agents/`.

## latex/

Official, unmodified venue style files (`neurips/`, `aaai/`, `acl/`) plus a
minimal `template.tex` skeleton with the seven sections `paper-writer` uses.
`install.sh` copies this tree to `~/.agents/latex/`, which is where
`paper-writer` looks first — so the styles travel with the install and the
agent never has to hunt for the repo checkout. See `latex/README.md`.

## Contributing

**Adding an agent:**

1. Write `<name>.md` in Claude format: `name`/`description`/`tools` frontmatter,
   then the method. Name the failure mode it prevents.
2. If the instructions are model-agnostic prose, add the `<name>.agent.md`
   Copilot port: drop `tools:`/`model:`, add `argument-hint:`, keep the body.
   Frontmatter must be the first lines of the file.
3. File both under `agents/<domain>/` and add a row to the catalog above.

**Evals** (planned): each agent should ship with a small eval set — input
fixtures plus expected verdicts — and a runner, so prompt edits are measurable
instead of vibes. Contributors run them; users never need to touch them.

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
