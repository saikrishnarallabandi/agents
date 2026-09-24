# LaTeX venue styles

Official, unmodified style files distributed by the venues, plus a minimal
paper skeleton. The `paper-writer` agent copies the style file it needs next
to its draft rather than inventing a template — this directory is where it
copies *from*.

| Directory | Venue | Files |
|---|---|---|
| `neurips/` | NeurIPS 2025 | `neurips_2025.sty` |
| `aaai/` | AAAI 2027 | `aaai2027.sty`, `aaai2027.bst` |
| `acl/` | *ACL (ACL/EMNLP/NAACL) | `acl.sty`, `acl_natbib.bst` |

`template.tex` is a bare seven-section skeleton wired to the NeurIPS style by
default — swap the `\usepackage` line for your venue (see the comments at the
top of the file). The agent fills it in; you do not write prose in it by hand.

Page limits and checklists change yearly — the agent looks them up at drafting
time rather than trusting anything hardcoded here.
