# Principles of a software factory

The rules we follow, learned by building one, M0 to M11. Each has its reason
and where we learned it. The how (scripts, settings) is in the
[playbooks](../kit/playbooks/); the full stories are in the
[learning notes](learning-notes.md); every term is in the
[concept index](concepts.md).

## 1. Reach: limit what an agent can break

1. **Give the smallest world that does the job.** Every permission is a
   way to cause damage. A device-only app instead of the live database; no
   shell for a reviewer. *(M0, M5, M9)*
2. **Smallest world, but complete.** Give a role every permission its job
   needs, up front. A missing one makes an agent stop, or worse, look for
   another way. *(M9, M10)*
3. **The box decides, not the words.** A hook that reads command text can be
   talked around; a secret that isn't in the agent's world can't be reached.
   Proven with a pair: reachable outside the box, blocked inside. *(Isolation)*
4. **A box is only as good as its weakest wall.** Probe every wall, both ways;
   the Mac sandbox looked complete until the probe found the keychain.
   *(Isolation)*
5. **Trust is earned, per area, and can be lost.** Read-only first, then
   small changes, then features, each rung proven by a record (5 PRs in a
   row with no correction). One serious slip drops that area one rung.
   *(M6)*
6. **Some things stay human on every rung:** merging, repo settings,
   deploying, the live database, secrets, installing software. *(M6)*

## 2. Knowledge: write it down, once, and keep it true

7. **Files are the truth, not memory.** Agents forget everything between
   sessions. What isn't in a file doesn't exist for the next agent,
   including instructions given only in chat. *(M4, M8)*
8. **One fact, one place.** A copy is a fact nobody updates. Link instead.
   *(M4, M7, M8)*
9. **Mark guesses.** A wrong fact is worse than a missing one. Evidence is
   not proof: check before you write "confirmed". *(M4)*
10. **Code and its docs change together**, in the same pull request. *(M4)*

## 3. Enforcement: a rule that matters is a lock, not a request

11. **A written rule asks; a check refuses.** Agents forget, misread and
   reinterpret rules. Anything that must not happen needs a check. *(M1, M6)*
12. **Layer the locks:** a rule explains, an agent hook stops the command
   before it runs, a git hook stops accidents, a required server check stops
   decisions. Each catches what the previous one misses. *(M6, M7)*
13. **"Could not check" is a failure, never a pass.** A missing hook,
    folder, tool or verdict must block, loudly. Silent passes were our worst
    bugs. *(M1, M2, M6, M7)*
14. **Block what must never happen; ask only where a quick look is enough.**
    A permission prompt is only as strong as the attention of the person
    answering it. *(M7)*
15. **A block is a stop sign.** An agent that is refused says so and stops;
    it never looks for another way around. *(M7, M9)*
16. **Copies drift; check them.** When a project holds a copy of the
    factory's settings, a check fails as soon as they differ. *(M7)*

## 4. Proof: don't trust, verify

17. **Measure; don't guess.** A baseline first, so every later claim can be
    compared with it. *(M3, M7)*
18. **A test must fail before it can prove anything,** and fail for the
    right reason. Red before Green, every time. *(M5, M8)*
19. **Test the tests:** break the code on purpose; a test must notice.
    Passing tests on the first try is a reason to doubt them. *(M5, M7)*
20. **Test the checker with a known answer:** give it work whose problems
    you already know. *(M9)*
21. **A tick, a commit message, a green build or a "merged" in chat is a claim.** Check the ones
    that matter: did the tests actually run, did the Red commit really fail?
    *(M6, M8, M9)*
22. **A proof must run where the real thing runs.** A Red step checked
    without its dependencies "fails" for the wrong reason and proves nothing.
    *(M10)*
23. **A test that depends on chance proves nothing reliably.** It missed a
    bug 3 times in 8; with fixed numbers it caught it 10 times in 10. *(M10)*
24. **Choose agents by measured results on a known answer,** one change at a
    time, at least two runs each. Cheaper per token is not cheaper per job:
    invented findings cost a human's time. *(M11)*
25. **A test that everyone passes can't tell them apart.** Include hard cases.
    *(M11)*

## 5. Work: small loops, separate roles

26. **Think on paper first:** spec, plan, tasks. Mistakes are cheapest
    before code exists, and a human reviews them there. *(M8)*
27. **One small task at a time,** each with a failing test, a commit and a
    tick, so any session can stop and another continue. *(M8)*
28. **Nobody grades their own work.** The builder and the checker are
    separate roles, with separate instructions, permissions and context.
    *(M9)*
29. **Facts for the script, judgement for the AI.** If a computer can check
    it exactly, a script checks it; AI judgement drifts. *(M9)*
30. **Put the input in front of it.** An instruction like "read everything"
    is a request; putting the content in the prompt makes it happen. *(M9)*
31. **An approval belongs to an exact version.** Changed code needs a new
    review. *(M9)*
32. **The rules of the process are part of the product.** Changing the
    factory, or a reviewer's instructions, needs at least as much review as
    changing code. *(M6, M9)*
33. **Bound every loop.** After a few rounds without agreement, a human
    decides. *(M9)*
34. **Never lose work you couldn't hand over.** Keep it until the hand-over is
    confirmed; a failed push once threw away a finished agent run.
    *(Isolation)*
35. **Agents narrow rules to fit their plan.** Seen twice ("allowed by
    Principle I"; test-first "for the logic"). Check every plan's rule check
    against the rule's own words. *(M8, M10)*
36. **Match the weight of the process to the risk.** The full loop cost about
    65 times a plain fix, and bought proof. A small fix in a tested area
    gets a short loop; a feature or a risky area gets the full one. *(M3, M10)*
37. **When a rule is wrong, change it in the open,** with a new version and
    a reason, never by quietly reading it differently. *(M8)*

## 6. The factory itself

38. **The factory uses its own rules** (dogfooding): branches, pull
    requests, checks, reviews. If a rule is too painful for us, it is too
    painful for a project. *(M6)*
39. **The kit owns *when* checks run; the project owns *what* runs.** A
    clear ownership line keeps both sides upgradable. *(M2, M6)*
40. **Record honest gaps.** Every check, review and playbook says what it
    does *not* catch. Known gaps can be closed; hidden ones can't. *(all)*
41. **Tool-written files stay out of project tools.** Each new tool brought
    files the formatter wanted to change: the kit, Spec Kit, the review.
    *(M6, M10)*
42. **The factory improves from its own use.** After each real run, a retro:
    keep, change, drop, each with evidence, and the rules change in the open.
    *(M10)*
