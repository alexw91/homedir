---
name: aweibel-design-doc
description: Write a design doc on aweibel's section template. Use when asked for a design doc, a technical proposal, an RFC, a rollout plan, or a plan another team has to review and approve.
argument-hint: "What is the doc for, and who approves it? (e.g. 'rollout plan for the load balancing team to approve', 'design doc for the new cache layer')"
---

# aweibel design doc

Produce a design doc that a named reader can act on. The skeleton with per-section prompts is in [`TEMPLATE.md`](TEMPLATE.md) — copy from there once you know which sections survive.

Tone and prose rules live in `.kiro/steering/writing-tone-and-style.md` and already apply. File naming and location follow the `handoff` skill.

## 1. Settle the ask before drafting

Two things decide every later choice, so get them explicitly:

- **What decision does this doc drive**, and **who signs it**. A doc for a peer team to approve is a different artifact from an internal record of a decision already made.
- **Who owns each thing you are asking for.** A doc that asks a team to accept a risk, change their code, and agree a date is asking three different people.

If either is unclear, or the request is a single line, run the `grilling` skill first and write nothing until the frontier is empty and the user confirms the shared understanding. A doc drafted from an unexamined request gets rewritten.

## 2. Choose the section set

Include every section the decision needs and cut the rest. The full template suits a genuine design exploration; a doc asking another team to approve one plan is shorter, and reviewability is the point.

**Length.** Aim for two pages of body, not counting appendices; three is fine. Treat two to three pages as the soft maximum. A larger design may run longer, but that is the exception, and at five pages look for detail to move out. To shrink any section, in order: cut what does not help the ask, summarize what remains, and move the rest to an appendix.

| Section | Include when |
|---|---|
| Purpose | Always. Lead with the asks, numbered, each naming who decides it. |
| Background | Always. What the reader needs to evaluate the ask, nothing more. When the change touches another team's system, lead with how that system works today, scoped to the parts the change touches, for the owning team to confirm before they weigh the change. |
| Problem Details | The technical problem is not fully carried by Purpose and Background. |
| Challenges & Risks | Always for anything that changes a running system, oncall load, or infrastructure cost. |
| Goals / Non-Goals | Always. |
| Decisions and Options | Always. One block per decision the doc asks for; a decision with one live option lists that option and its recommendation. |
| One-Way Doors | The plan commits to something hard to reverse: a public API, a config surface, or behavior customers or other teams will rely on. |
| Security Considerations | Recommended. Cut only when the design touches no security surface. |
| Assumptions | The evaluation rests on something you believe but have not verified. |
| Open Questions | Always. An empty Open Questions on a real plan means you stopped looking. |
| Proof of Concept | A cheaper partial version would de-risk the commitment. |
| Proposed Milestones | Work spans more than one release or owner. |
| Points of Contact | The doc crosses enough teams that the reader cannot find the owners. |
| Previous Related Documents | A reader would otherwise re-derive prior work. Fold one or two links into Purpose instead. |
| Appendix | Detail moved out of the body, or machine-readable input the reader acts on. |

## 3. Write

**Every ask names its decider.** "We need agreement on X" is incomplete; "we are asking the load balancing team to agree X" is actionable.

**Say only what the ask needs.** An aside the reader finds interesting is worse than one they find wrong, because it moves the discussion off the decision and onto the aside. Before a paragraph survives, name the ask it serves. This bites hardest on findings you are proud of and on alternatives you already rejected.

**Every claim is a surface.** A reviewer can challenge anything you assert, so make each claim one you can defend. This is not a licence for vagueness: where a claim carries the argument, be specific and show the derivation. The claim to cut is the specific one that carries nothing.

**Cite a number only when it carries the argument.** A figure is the most challengeable kind of claim, and a reader who disproves one distrusts the rest. A bounded worst case or a measured ceiling earns its place, and show the derivation when you use one. Counts that are incidental to the decision come out.

**Describe your own systems at the reader's level.** They are judging your ask, not reviewing your implementation. "We built a service that reconciles the two inventories nightly and flags mismatches" is what they need; tool names, code structure, and commit hashes are not.

**When the change touches a system another team owns, open with a pedagogical description of how that system works today — before the proposed change.** Keep it to the parts the change touches; this is orientation, not a full design doc. The Background section does two jobs. It gives every reviewer — owning-team and not — the same model to reason from. And it is a checkpoint: the owning team verifies the overview matches reality, so a wrong assumption surfaces at the top, where it's cheap, instead of buried under implementation detail. Agreement on the change is only meaningful when both sides agree on how the system works.

**Score every option against the Goals.** Each decision block lists criteria that trace to a Goal, and each option gets a + or − per criterion with one line on why. The recommendation cites only criteria already scored; a factor that first appears in the recommendation belongs in the criteria list. Lead with prose and add a table only when it helps. Recommending a short-term and a long-term option together is fine when you say how the first leads to the second.

**Non-Goals say why, not just what.** "Legacy endpoints are out of scope" invites the question. "Legacy endpoints are out of scope, because there is no equivalent config surface to key on" closes it.

**Risks are described by you and accepted by the owner.** For each risk: what could go wrong, your reading of how likely and how bad, and the remediation an affected team can apply. Then leave acceptance with the team that owns the system. Write that you believe the risk is small; do not write that it is closed. You rarely have the authority.

**Every remediation gets a worked example.** A risk with no remediation is a warning; a risk with a copy-pasteable config or code block is a decision the reader can make.

**Copy examples from real source.** Config keys, API signatures, and internal option names follow conventions you will get wrong by inference. Read a real instance and copy its shape, including whether values are quoted and which block they nest in. Say in your reply where each example came from, so the user can check it.

**Do not generalize past what you checked.** "No service has ever turned this off" and "we looked for teams that turned it off and could not find any" differ by exactly the claim you cannot defend. If you inspected a subset, say it was a subset.

**State what you verified and what you did not.** A claim about another team's system that you inferred rather than read is the fastest way to lose the room. Record the unverified claims the evaluation rests on under Assumptions, and mark each one whose failure would change the recommendation.

## 4. Verify before handing over

- Every section present is one the section table says to include, and every one the table requires is present.
- Every ask in Purpose has a decider.
- Every goal is marked must-have or nice-to-have and names its customer.
- Every criterion in Decisions and Options traces to a Goal, and every recommendation cites only criteria scored above it.
- Every hard-to-reverse commitment in the plan is named under One-Way Doors.
- The body, excluding appendices, runs two to three pages, or the design is large enough to need more.
- Every paragraph serves one of the asks, and you can name which.
- Every claim left in is one you can defend, and none generalizes past what you checked.
- Every risk has a remediation, and none claims to be closed.
- Every code or config example was copied from source you read this session.
- If the change touches another team's system, Background leads with the current-state overview, scoped to what the change touches, attributed to what you read or were told, and placed before the proposal.
- Every number in prose either carries an argument or comes out.
- Headings render, fenced blocks are balanced, and no section appears twice. Concurrent human edits make this a real check, not a formality — re-read the finished file rather than trusting your edits landed as issued.

Report which sections you cut and why, and list anything you asserted without being able to verify it.
