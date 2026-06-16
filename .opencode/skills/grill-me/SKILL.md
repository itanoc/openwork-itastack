---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me to reach a shared understanding of this plan — but apply the 80/20 rule. Spend your questions on the vital few decisions that determine most of the outcome: the ones that are hard to reverse, that other decisions hang off of, or where getting it wrong is expensive. Skip the trivial many.

Before each question, ask yourself: "Does this decision meaningfully change the plan, or am I just walking a branch for completeness?" If the branch is low-stakes, easily reversible, or has an obvious default, state your recommended default in one line and move on — do not turn it into a question. Prune branches that don't change what we build.

Resolve dependencies in order — settle a foundational decision before the ones that depend on it — but only descend into a sub-branch when the answer would actually shift the design. For each real question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

Stop when the remaining open questions are all low-stakes detail. At that point, say so and summarize the defaults you're assuming for the rest rather than continuing to grill.

If a question can be answered by exploring the codebase, explore the codebase instead. If it can be answered by web search (library docs, API behavior, current best practices), search the web instead.
