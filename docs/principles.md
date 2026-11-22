# Principles of a software factory

The rules we follow, learned by building one, M0 to M9. Each has its reason
and where we learned it. The how (scripts, settings) is in the
[playbooks](../kit/playbooks/); the full stories are in the
[learning notes](learning-notes.md); every term is in the
[concept index](concepts.md).

## 1. Reach: limit what an agent can break

1. **Give the smallest world that does the job.** Every permission is a
   way to cause damage. A device-only app instead of the live database; no
   shell for a reviewer. *(M0, M5, M9)*
2. **Trust is earned, per area, and can be lost.** Read-only first, then
   small changes, then features, each rung proven by a record (5 PRs in a
   row with no correction). One serious slip drops that area one rung.
   *(M6)*
3. **Some things stay human on every rung:** merging, repo settings,
   deploying, the live database, secrets, installing software. *(M6)*

## 2. Knowledge: write it down, once, and keep it true

4. **Files are the truth, not memory.** Agents forget everything between
   sessions. What isn't in a file doesn't exist for the next agent,
   including instructions given only in chat. *(M4, M8)*
5. **One fact, one place.** A copy is a fact nobody updates. Link instead.
   *(M4, M7, M8)*
6. **Mark guesses.** A wrong fact is worse than a missing one. Evidence is
   not proof: check before you write "confirmed". *(M4)*
7. **Code and its docs change together**, in the same pull request. *(M4)*

## 3. Enforcement: a rule that matters is a lock, not a request

8. **A written rule asks; a check refuses.** Agents forget, misread and
   reinterpret rules. Anything that must not happen needs a check. *(M1, M6)*
9. **Layer the locks:** a rule explains, an agent hook stops the command
   before it runs, a git hook stops accidents, a required server check stops
   decisions. Each catches what the previous one misses. *(M6, M7)*
10. **"Could not check" is a failure, never a pass.** A missing hook,
    folder, tool or verdict must block, loudly. Silent passes were our worst
    bugs. *(M1, M2, M6, M7)*
11. **Block what must never happen; ask only where a quick look is enough.**
    A permission prompt is only as strong as the attention of the person
    answering it. *(M7)*
12. **A block is a stop sign.** An agent that is refused says so and stops;
    it never looks for another way around. *(M7, M9)*
13. **Copies drift; check them.** When a project holds a copy of the
    factory's settings, a check fails as soon as they differ. *(M7)*

## 4. Proof: don't trust, verify

14. **Measure; don't guess.** A baseline first, so every later claim can be
    compared with it. *(M3, M7)*
15. **A test must fail before it can prove anything,** and fail for the
    right reason. Red before Green, every time. *(M5, M8)*
16. **Test the tests:** break the code on purpose; a test must notice.
    Passing tests on the first try is a reason to doubt them. *(M5, M7)*
17. **Test the checker with a known answer:** give it work whose problems
    you already know. *(M9)*
18. **A tick, a commit message or a green build is a claim.** Check the ones
    that matter: did the tests actually run, did the Red commit really fail?
    *(M6, M8, M9)*

## 5. Work: small loops, separate roles

19. **Think on paper first:** spec, plan, tasks. Mistakes are cheapest
    before code exists, and a human reviews them there. *(M8)*
20. **One small task at a time,** each with a failing test, a commit and a
    tick, so any session can stop and another continue. *(M8)*
21. **Nobody grades their own work.** The builder and the checker are
    separate roles, with separate instructions, permissions and context.
    *(M9)*
22. **Facts for the script, judgement for the AI.** If a computer can check
    it exactly, a script checks it; AI judgement drifts. *(M9)*
23. **Put the input in front of it.** An instruction like "read everything"
    is a request; putting the content in the prompt makes it happen. *(M9)*
24. **An approval belongs to an exact version.** Changed code needs a new
    review. *(M9)*
25. **The rules of the process are part of the product.** Changing the
    factory, or a reviewer's instructions, needs at least as much review as
    changing code. *(M6, M9)*
26. **Bound every loop.** After a few rounds without agreement, a human
    decides. *(M9)*
27. **When a rule is wrong, change it in the open,** with a new version and
    a reason, never by quietly reading it differently. *(M8)*

## 6. The factory itself

28. **The factory uses its own rules** (dogfooding): branches, pull
    requests, checks, reviews. If a rule is too painful for us, it is too
    painful for a project. *(M6)*
29. **The kit owns *when* checks run; the project owns *what* runs.** A
    clear ownership line keeps both sides upgradable. *(M2, M6)*
30. **Record honest gaps.** Every check, review and playbook says what it
    does *not* catch. Known gaps can be closed; hidden ones can't. *(all)*
