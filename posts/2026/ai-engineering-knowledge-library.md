---
title: "AI Engineering 0.5.0: A Knowledge Library Built for Reuse"
description: "Reworking our engineering framework into composable skills and focused guides, then comparing it with 0.4.1 through real planning, Rust implementation and code audits."
tags: [ai, rust, software-engineering]
published_date: 2026-09-05 12:00:00 -0600
is_draft: false
data:
  author: Duncan McGreggor
  math: false
---

The work preparing AI Engineering 0.5.0 began with a fairly ordinary complaint: our `docs/` directory had become confusing. Some files explained the repository. Others were the material the repository existed to provide. Framework instructions, language knowledge, operational guides and reusable templates had accumulated in places that made sense when they arrived, but were becoming harder to explain as a whole.

I wanted `docs/` to mean documentation *about* the materials, and `knowledge/` to contain the materials themselves. That would give end users a sensible route into a growing library. It would also let us write a README that introduced the project without trying to carry half of it.

Following that distinction through the repository led to more substantial work: identifying independently useful skills, separating them from the framework that composes them, splitting long documents into focused guides, making ownership and version history consistent, and checking that references still worked for someone using a downloaded package.

By the time we had finished the main reworking, the repository was considerably easier to navigate. I also wanted evidence that the framework still worked. These files influence how assistants plan projects, implement software, verify results and audit code. A tidier directory tree would be poor compensation for weakening any of that.

So I ran a small comparison: the 0.4.1 framework and the pre-0.5.0 candidate, each guiding a real Rust project through planning, implementation and a final code audit. The assessment found no material regression in the newer condition. It also found encouraging differences in planning organisation, implementation structure and the usefulness of the audit reports.

That was a relief. The qualification matters, too: this was one paired trial, with imperfect controls and some mixed results. What it gave us was a concrete reason to keep the reorganisation, and a much better view of what to investigate next.

## Giving the Library an Understandable Shape

The [AI Engineering repository](https://github.com/billosys/ai-engineering) contains both domain guidance and the collaboration framework I use for sustained engineering work with LLMs. Domain skills supply knowledge about Rust, C++, Erlang/OTP and other languages and tools. The framework supplies the working practices around that knowledge: planning, verification, testing, auditing, coordination and contribution.

The new top-level division is straightforward:

| Location | What belongs there |
| --- | --- |
| `README.md` | Orientation: what the repository provides and where to begin. |
| `docs/` | Explanations for people using or maintaining the library. |
| `knowledge/` | Skill entrypoints, derived guidance, source material and reusable support assets. |
| `protocols/` | Protocol specifications and their distribution materials. |

The focused documentation now covers the skill library, the collaboration framework, the anatomy of the knowledge library, building and installing, protocols and contributing. A reader can learn what something is before opening the instructions that an assistant will actually use.

Inside `knowledge/`, each component owns its material. A skill entrypoint lives at the component root. Longer explanations live under `guides/`; copyable forms live under `templates/`; worked examples have an `examples/` home when needed. Source and provenance material can remain available without being mistaken for the primary instructions.

For example, the code-auditing component now has this shape:

```text
knowledge/code-auditing/
  SKILL.md
  version-history.md
  guides/
    01-audit-scope-and-map.md
    02-findings-and-severity.md
    03-scale-aware-auditing.md
    04-modernization-synthesis.md
    05-audit-to-hardening-handoff.md
```

Those filenames describe decisions an auditor needs to make. The entrypoint explains when to load the component and routes to the relevant guide. Someone commissioning a diagnosis-only review can start with scope and the audit map. Someone assessing a report can load findings and severity. Turning the findings into subsequent work has its own explicit handoff.

Consistency makes those routes easier to predict across components. It also makes the ownership of a change easier to identify. Each framework component keeps its version in `SKILL.md` and its change history in a sibling `version-history.md`. A change to a template or an example is recorded with the component, rather than in whichever guide happened to contain a history section first.

## Composing Skills Without Requiring the Whole Framework

The reorganisation needed a vocabulary that would survive beyond our existing folder names. We had to distinguish what a skill teaches from how it combines other material.

We settled on two separate questions. *Kind* describes the work: domain and tooling knowledge, an operational discipline, or a method. *Topology* describes composition: whether a skill has one coherent primary reason to load it, or whether its purpose includes selecting, sequencing and coordinating other loadable parts.

Rust is our example of an atomic domain/tooling skill. That does not mean Rust is simple, or that its guidance fits in one file. It means that "I am working in Rust" is a coherent reason to load it. Its internal breadth does not automatically make it a composer of independent skills.

The collaboration framework is our obvious composite example. Coordinating several disciplines is part of what it does. It establishes the collaborative posture and quality expectations, then provides routes into engineering methods, project management, work verification, testing, code auditing, agent coordination and contribution style.

This distinction gives someone outside the project more choices. You might want our audit discipline while keeping your own planning process. You might want help preparing an upstream contribution without loading the framework's project lifecycle. Or you might want the whole framework alongside a language skill for a sustained implementation effort.

The component entrypoints support those narrower uses. Their scope and dependencies are explicit enough to inspect before adopting them. Language guidance is loaded separately, according to the task. The framework does not implicitly pull every domain pack into a session.

There is a practical distribution distinction here. Independently useful components do not all have separately released zip packages. The collaboration-framework bundle includes its component entrypoints and supporting guides. The library's documentation distinguishes that composed package from the narrower source routes and from separately packaged skills. A directory called a "skill" should not leave users guessing what they can actually install.

We also kept protocol distributions distinct. The Composite Cognition Dispatch Protocol, CCDP, has its own package and validation process. It is not installed as though it were another assistant skill. Similarly, the planned concept-card method remains explicitly planned until its implementation and package exist.

## Splitting Documents Without Losing the Method

The original framework documents had accumulated substantial explanations of posture, engineering practice and operational discipline. They were useful documents. They were also asking an assistant to read a great deal of material when it needed to refresh one particular part of the method.

Selective loading was a significant reason for the split. During a verification pass, an assistant may need the distinction between a reported result and independently reproduced evidence. That should be directly accessible. The surrounding framework remains available when the task calls for it.

We split the collaboration posture material into four numbered guides: posture and ethics, structural pulls, collaborative rights, and the component route table. Engineering methods became six guides covering the overview, knowledge substrate, process rigour, operational routing, component boundaries, and source/package/release gates.

The same work extended through the operational components. Agent coordination now separates the decision to delegate from preparing a context packet, integrating results and recognising anti-patterns. Work verification separates ledger discipline, evidence strength, row closure, silent-drop checks and independent verification. Testing and contribution style have similarly focused routes. Project management retains its numbered guides, with its worked example under `examples/` and its guide index named `README.md`.

These were semantic splits. Moving paragraphs into smaller files meant deciding which guide owned a rule, what context the rule required, and where another guide should refer to it. The composer still had to lead an assistant through a coherent method. Templates that served as reusable support assets needed to retain that function.

This part took more persistence than the initial directory move. Twice, I had to bring us back to accepted plans for renaming and splitting material that had survived an earlier pass largely intact. The work completed so far was useful, but it did not satisfy the original selective-loading objective.

We made the remedy explicit: agree the destination guide files before implementation, name the splits in the acceptance ledger, and verify their disposition at the end. The old live routes needed to disappear, the new guides needed to be present, and the surrounding references and packages needed to agree. We also tightened the wording around our "Expedited Mode" so that its specific handoff and commit instructions could not be interpreted as permission to reduce scope or weaken review.

That experience helped clarify the acceptance test for the reorganisation. Counting files would establish that the split happened. Reviewing their responsibilities and routes was necessary to establish whether the resulting guides were still usable.

I expect focused loading to reduce unnecessary context and make a refresh easier. We have not measured token savings or retrieval latency in this trial. The concrete change is that the smaller routes now exist, have meaningful names and can be loaded independently where their dependencies permit it.

## Reuse Has to Survive Leaving the Repository

Third-party use exposed another contract: a link that works in the source checkout may fail in an extracted package.

The old top-level framework `SKILL.md` moved to `knowledge/collaboration-framework/SKILL.md`. Its generated package still presents `collaboration-framework/SKILL.md` as the entrypoint. Maintaining that distinction required updates to package file lists, staging behaviour and references. Moving source files alone would have left consumers with an incomplete migration.

We added package-context validation for Markdown paths. The check examines generated skill zips and distinguishes bundled references from source-clone references, provenance paths, examples and external URLs. Where a package-local link was broken, repairing the link was the first response. Remaining exceptions were kept explicit and narrow.

Validation also included inspecting package contents and installing into temporary directories. That checked what a consumer would receive: expected roots, usable skill entrypoints, the split guides and preserved templates. CCDP had separate shape, README and path checks for its protocol package.

The final guide-decomposition validation recorded zero hard package-path failures. It also retained warnings and three explicit exceptions; a passing gate did not mean every reference had become a bundled, automatically verified dependency. That distinction belongs in the evidence.

For an integrator, this work is part of the usability of the library. A component needs a discoverable entrypoint, identifiable supporting material, clear dependencies and references that make sense in the delivery format. Otherwise, adopting it requires reconstructing the environment in which it was written.

## Testing the Reworked Framework on Real Work

After the reorganisation, I wanted to compare behaviour with the 0.4.1 baseline. The question was whether the newer framework could still guide planning, implementation and auditing effectively, with any indications of improvement treated as a bonus.

I chose a deliberately small compiler exercise: implement a transpiler in Rust from a tiny Lykn-inspired syntax to a tiny subset of C++17. Integer bindings, printing and arithmetic were enough to produce a parser, an abstract syntax tree, code generation, diagnostics, a command-line interface, tests and generated examples.

Full Lykn compatibility, JavaScript semantics, C++ classes, templates, multi-file output and the rest of a serious compiler project were outside the brief. I wanted enough code for a meaningful audit without accidentally commissioning another language implementation.

Each condition received a copy of the same project prompt with its own explicit framework path and workspace. The instructions required supporting framework files to come from that same version, rather than an installed or remembered copy. The implementation phase allowed the same specified Rust and C++ guidance and Lykn reference material.

The work used our usual separation of responsibilities. A CDC session handled planning and review. A CC session implemented a bounded slice and reported its changes and validation. I passed reports between them; the CDC checked the evidence and either requested another iteration or closed the slice. A project contained arcs, and arcs contained slices small enough to implement and verify.

The sessions were allowed to plan the work differently. The older condition used two slices for its second arc; the newer used one, having completed more language functionality earlier. Comparing "Arc 02" by name alone would therefore have been misleading. We inspected the plans and aligned the eventual stopping point around comparable implemented capability and readiness for audit.

Once both had reached that boundary, each CDC received the same read-only self-audit procedure. It required an audit map, concrete findings, file-and-line evidence, validation results, clean checks, limitations and a handoff for possible hardening.

The no-repair rule was particularly useful. The implementations and their remaining defects were the evidence we wanted to compare. Repairing them during the audit would have changed that evidence before assessment. Both trial projects eventually closed after their audits, with findings preserved. Their definition of done was completion of the implementation-and-audit experiment, not production readiness for the transpilers.

## What the Comparison Showed

Both conditions produced working Rust implementations and closure evidence. Both passed their recorded Rust formatting, test and lint checks, and both ultimately demonstrated generated C++ examples that compiled and ran. The older framework continued to provide a usable planning and verification process.

The newer condition produced a more consistently organised project. Planning and implementation were easier to distinguish. Valid and invalid fixtures, generated examples, CLI tests and diagnostic tests were easier to find. Its review packets made the relationship between implementation claims and verification evidence clearer.

Some differences also reached the behaviour of the generated programs:

| Observation | 0.4.1 condition | Pre-0.5.0 condition |
| --- | --- | --- |
| C++ keyword used as a binding name | Accepted a case that generated invalid C++. | Rejected keyword identifiers. |
| Division by a direct literal zero | Generated the division expression. | Rejected the input with a diagnostic. |
| Missing input file | Error omitted the file path. | Error included the file path. |
| Test and fixture organisation | Coherent, with more behaviour tests concentrated in the library file. | More clearly separated fixtures, CLI tests, diagnostic checks and transpilation tests. |
| Audit reporting of clean checks | Used the negative-findings section to summarise defects. | Recorded concrete checks where no issue was found. |

These observations are more useful than simply counting audit findings. The newer implementation had already prevented or narrowed some defects before the audit began. Finding fewer bugs in that code would not, by itself, indicate a weaker audit.

The assessment also credited the older condition's conservative scope boundaries and its recovery from an early test-isolation failure. The newer condition initially bundled more capability into its first arc, which could have become scope pressure. In this run, it subsequently narrowed the second arc to the remaining work. That adaptation mattered more than the number of slices.

Across the completed trial, the assessment's verdict was `main-slightly-improved`: no material overall regression demonstrated, with circumstantial evidence of improvement in planning, implementation organisation, validation evidence and audit-report usability.

There was a specific audit miss. Both implementations used Rust's `print!` at the output boundary, where [a failed write can cause a panic](https://doc.rust-lang.org/std/macro.print.html#panics). The older condition's audit identified the broken-pipe panic issue; the newer condition's audit missed it. The newer report found other residual problems, including a subtler generated-identifier issue, but it did not dominate the older report on every useful observation.

The conclusion I take from this is that the reworked framework held up through the exercise, and that several of the differences favour the organisation we had been trying to establish. The missed issue remains evidence to carry forward.

### A Glimpse of the Tiny Language

For a look at what the sessions built, here is the newer condition's happy-path fixture:

```lisp
(let x 1)
(let y (+ x 2))
(print (* y 3))
```

`let` introduces a binding, arithmetic uses prefix notation, and `print` writes an integer followed by a newline. The Rust transpiler turns that little program into this complete C++17 source file:

```cpp
#include <iostream>

int main() {
    const int x{1};
    const int y{(x + 2)};
    std::cout << (y * 3) << "\n";
    return 0;
}
```

Compile and run it, and the output is `9`. You can follow the translation almost expression by expression: prefix arithmetic becomes parenthesised infix arithmetic, bindings become local variables, and printing becomes a standard stream operation.

The older condition's full-subset fixture exercises more nesting:

```lisp
(let a 20)
(let b (+ a 2))
(let c (- b 5))
(let d (* c (/ 8 4)))
(print (+ d 1))
(print (/ (* b c) 3))
```

This one prints `35` and `124` on separate lines. All values are integers, so the final division of `374` by `3` discards the fractional part. These are actual fixtures from the two projects, using the deliberately small Lykn-inspired syntax agreed for the trial. They show the bindings, expression trees and output behaviour the Rust implementations had to handle; they do not define an extension to the full Lykn language.

## How Much Confidence That Earns

This was one task with one run per condition. The framework versions differed in both content and organisation, so the trial cannot isolate the effect of smaller guides from clearer rules, new validation practices or other changes. The two implementations differed, and their authors audited their own work. Operator interventions also differed as the projects progressed.

The source-isolation controls were imperfect. The older audit checked memory despite its restriction. The newer audit read C++ and Lykn guidance despite the audit phase's narrower allowed-reference boundary, and its project-close report recorded an accidental opening of the installed framework. Those deviations limit how cleanly we can attribute behaviour to the assigned version.

The assessment was performed outside the two execution sessions, by the assistant helping me coordinate the experiment. That assistant had also helped design the prompt and rubric, and had participated in the framework reworking. It was a useful additional review of the runs, but it was neither blind nor wholly independent of the work being evaluated.

LLM run-to-run variation is a plausible explanation for individual misses. This trial cannot establish how much of any difference comes from that variation. Repeated runs, tighter isolation and audits of a common fixed codebase would help distinguish it from a systematic change in behaviour.

I am therefore comfortable saying that we found no obvious overall regression in this exercise. I am also comfortable saying that the newer condition gave us better organised and more readily assessable work. A general claim that splitting Markdown files improves model performance would go beyond the evidence.

## A Library Other People Can Build With

The reorganisation has value we can inspect directly. Documentation has a clear purpose. Components have identifiable owners and entrypoints. Long material has focused routes. Versions and histories have predictable homes. Generated packages are checked in the context in which people will consume them.

For someone adopting the repository, those changes reduce the amount of local history needed to use it. You can begin with the documentation, choose a whole framework or a narrower discipline, and load the relevant domain guidance alongside it. You can also see which material is independently packaged and which belongs to a composed bundle.

The experiment itself has already contributed a reusable component: `scientific-methods`, now added during the 0.5.0 work. It provides focused guidance and templates for controlled comparisons, experiment protocols, evaluation rubrics, evidence capture and threats to validity. It is separately packaged, with a route from the collaboration framework when the work becomes an inquiry. That addition captures what we learned about conducting comparisons; it is not evidence that the new skill caused the earlier trial results.

What interests me about the trial is the possible connection between the two kinds of improvement. Clear ownership and selective loading make a library easier to use. Clear planning, fixtures and evidence make a project easier to review. In the newer condition, both were visible together. We have a plausible reason to investigate that relationship further, without needing to turn this first result into a universal claim.

For this release cycle, the practical result is enough to be pleased about: a more consistent, composable knowledge library, a framework that held up under a real implementation-and-audit exercise, and evidence that its organisation may be helping the work it guides. I can now spend more time explaining what people can do with the materials, because the materials finally have a shape I can explain.
