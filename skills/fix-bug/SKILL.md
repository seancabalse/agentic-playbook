---
name: fix-bug
description: "Fix a defect: reproduce it, write a failing test, find the root cause, fix it and record the lesson. Use for each bug."
argument-hint: "[ticket id or symptom]"
---

# Fix a bug

Bug: $ARGUMENTS

1. **Reproduce first, in a worktree.** Get the exact steps, environment and evidence (error text, logs, ids, timestamps). Start from what the user did and saw, not from an internal error or a guess about the code. Create a worktree from the affected branch (`reproduce-in-worktree`) so the investigation never disturbs the working checkout, and reproduce it there. If you can't, say what you tried and gather more evidence before changing code.
2. **Find the root cause, not the symptom.** Read the code path end to end. Check the library's behaviour in its source or docs for the installed version. Then:
   - **Separate three facts**: the *trigger* (the input or event that starts the fault), the *masking condition* (the state, timing, cache, configuration or path that hides or exposes it), and the *symptom* (what the user sees). A masking condition can explain why the bug appears only sometimes without being its cause. Mark each fact *verified* or *likely*.
   - **Compare with a path that works.** Find the earliest point where the failing path and a working one diverge: inputs, state, dependencies, timing. Read the history (blame, commits, migrations) when it explains the divergence. A recent nearby change isn't the cause without evidence.
   - **Confirm with the smallest counterfactual** before fixing: change one condition that should flip the result if your explanation is right (a log line, a minimal repro, a toggle), and record what happened.
   - **Try to prove yourself wrong.** Name the observation that would falsify your explanation, and check it. Keep contradictory results; don't explain them away.

   The cause is confirmed when it explains both the failure and the path that works. Note anything else the cause affects.
3. **Write a failing test** that reproduces it at the lowest layer that can show it: unit, then DB/policy, then integration. Run it and watch it fail for the right reason. If no automated test can capture it (platform lifecycle, device-only), write down the manual repro steps that will prove the fix.
4. **Fix minimally.** Change only what the cause requires. Don't refactor nearby code. If the fix needs a product decision, ask.
5. **Verify**: the new test passes, the full suite passes, and the original repro no longer fails in the real app. Also check the neighbouring cases the cause touched.
6. **Record**:
   - The ticket: cause (verified) with its trigger and any masking condition, fix, and how it was verified. File new tickets for related problems you found.
   - A runbook "Traps already hit" row if a tool or platform behaved surprisingly.
   - An `AGENTS.md` rule if the bug came from a rule that wasn't written down (for example "dates from the API are parsed in the shared time module").
7. **Before you hand off to a person**, the reproduction, the root cause and an attempted fix exist in the worktree, with the checks run there. Ask a person only for what you can't do: a product decision, a credential, a device. Then bring the fix back from the worktree branch and finish with `ship-pr`.

Never claim a cause you didn't verify: say "likely" and why.
