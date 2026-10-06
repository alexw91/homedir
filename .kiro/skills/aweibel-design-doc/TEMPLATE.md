# Template

The full skeleton. Copy the sections the section table in [`SKILL.md`](SKILL.md) says to include, then delete these prompts as you fill each one.

---

### Previous Related Documents

<Prior docs covering similar ground. Mark any that are recommended reading before this one.>

# Purpose

<What decision are we trying to make, and who signs it? What customer problem does this solve? Who are the customers and why do they care? Lead with the asks, numbered, each naming its decider. Give the reader enough to decide by the end of this section whether they need to read the rest.>

# Background

<What an engineer unfamiliar with this area needs to evaluate the ask. Relevant teams, packages, and systems, and what each does. Current state of the world. A high-level diagram if it helps. If the change touches a system another team owns, open with how it works today — scoped to the parts the change touches — for the owning team to confirm before the proposal.>

# Problem Details

<Only if Purpose and Background do not already carry the technical problem. Go deep here rather than there.>

# Challenges & Risks

<Why is this hard? What can go wrong? For each risk: your reading of likelihood and impact, and the remediation an affected team can apply, with a worked example. Leave acceptance with the team that owns the system. What can we investigate now to shrink a risk before committing? Include other consequences of the plan, good or bad: more customer contacts taking a share of oncall time, or lower CPU on another team's service cutting their infrastructure cost.>

# Goals

<Specific and measurable, in priority order. These are the criteria Decisions and Options scores against. Mark each must-have or nice-to-have, and name the customer who needs it, even when that is the team. State its kind: a performance target with before and after figures ("FooService p90 latency drops from XX ms to YY ms"), a spec requirement with its section and MUST ("RFC 9000 §12.2.4 requires…"), or a functional requirement a named customer depends on. For each measurable goal, name the metric and where its data comes from. Note any goals in tension with each other.>

1. Goal #1
2. Goal #2

### Non-Goals

<What we are deliberately not doing, and why not. A non-goal without a reason invites the question it was meant to close. Include anything deferred to a follow-up.>

1. Non-Goal #1
2. Non-Goal #2

# Decisions and Options

<One block per decision the doc asks for. Order options most to least likely to be recommended. Keep each option high level and move supporting detail to an appendix. A decision with one live option lists that option and its recommendation.>

## Decision 1: <headline>

<The decision you are trying to make, in two or three sentences.>

Option 1: <short description> (Recommended)

<The work needed: which packages and systems change, and which teams are involved.>

- <Criterion from Goals> (+/−): <how this option meets or misses it>
- <Criterion from Goals> (+/−): …

Option 2: <short description>

- <Criterion from Goals> (+/−): …

"Do Nothing" option:

<Is waiting, or letting customers solve it themselves, viable? Is the expected benefit greater than the cost of building and maintaining this?>

Non-viable option: <short description>

<An option that looks obvious but is blocked by a non-obvious constraint. Name the constraint, so the reader does not propose it in review.>

Recommendation:

<Prose first; a table only if it helps. Why this option wins, citing only the criteria scored above. If you recommend a short-term and a long-term option, say how the first leads to the second.>

# One-Way Doors

<Commitments in this plan that are hard or impossible to reverse: public APIs, config surfaces, and behavior customers or other teams will come to rely on. Name each so reviewers give it more scrutiny than the two-way doors.>

# Security Considerations

<What security problems this solves, what it introduces, and where its sharp edges are and how you mitigate them. Think about how the design could be misused.>

# Assumptions

<What the evaluation takes on faith: another team's delivery date, how another system works internally, the data you expect to see. Mark each one whose failure would change the recommendation.>

# Open Questions

<What we do not know yet, what needs an answer from another team, and what could change the recommendation. Give each question an owner and an action that would resolve it. Name the specific advice you want from reviewers, so the review meeting spends its time there. An empty Open Questions on a real plan means you stopped looking.>

1. Question 1?
2. Question 2?

# Proof of Concept

<Is there a cheaper partial version that would de-risk the commitment? What do teams need before they can commit to a date?>

# Proposed Milestones

<Concrete tasks in dependency order, grouped into milestones, each with an owner and a target. Mark prerequisites.>

# Points of Contact

<Teams and systems involved, with an engineer and a manager for each. Cut this section unless the doc crosses enough teams that the reader cannot find the owners.>

# Appendix

<Detail moved out of the body to keep it within length, machine-readable input the reader acts on, and links worth having. If the reader has to feed something into a tool or a config, it belongs here in the shape the tool takes.>
