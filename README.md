# Software Factory

A learning project: a small, reusable kit that lets AI agents plan, build, test,
review and document software under rules I control.

**The main goal is to learn the concepts. The factory is the classroom.**

- This repo holds the "how": process, roles, guardrails and templates.
- Each project holds its own "what": its code and its knowledge.
- This repo contains no product code and no project knowledge.

## Status

All milestones (M0–M11) done: the roadmap is complete. The onboarding
playbook covers discovery, the brain, the safety net, guardrails and the trust ladder; the
task loop playbook covers spec, plan, tasks, handoffs and the review loop.
The kit's checks run as git hooks, as Claude Code hooks before every
command, and in CI on every pull request. Each agent session leaves a usage
file.

## Read next

- [What an agent can reach](docs/harness-map.md)
- [Principles](docs/principles.md): the rules of a software factory, on one page
- [Retro M10](docs/retros/m10-odd-one-out.md): the first real run, measured
- [Experiment M11](docs/experiments/m11-reviewer-models.md): which model should review
- [Concept index](docs/concepts.md): every concept in one line
- [Learning notes](docs/learning-notes.md)
- [Onboarding playbook](kit/playbooks/onboarding.md)
- [Task loop playbook](kit/playbooks/task-loop.md): spec, plan, tasks, handoffs
- [Baseline: plain Claude](docs/baselines/m3-plain-claude.md)
