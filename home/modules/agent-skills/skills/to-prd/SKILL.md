---
name: to-prd
description: Turn the current conversation into a PRD or a refactor plan and file it as a GitHub issue. Use when the user wants a PRD from the current context, wants to plan a refactor, or wants a refactoring RFC broken into safe incremental steps.
---

Produce a written spec from what you already know and file it as a GitHub issue. Two shapes:

- **PRD** (default, for new features) — synthesize from the conversation. Do NOT interview the user.
- **Refactor plan** (when the work is changing existing code rather than adding capability) — interview the user first, then produce a plan of tiny commits.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already.

2. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

3. Check the codebase for test coverage of the affected area. If coverage is thin, ask the user what their testing plan is.

4. **Refactor plans only** — before writing anything up:
   - Ask for a long, detailed description of the problem and any solutions they have in mind, then verify their assertions against the code
   - Ask whether they considered other options, and present alternatives
   - Interview them about the implementation, in detail
   - Pin down exact scope: what changes, and explicitly what does not
   - Break the work into the tiniest possible commits. Per Martin Fowler: "make each refactoring step as small as possible, so that you can always see the program working." Each commit leaves the codebase working.

5. Write it up using the template below and submit it as a GitHub issue. For a refactor plan, replace **User Stories** with a **Commits** section — a long, plain-English list of those tiny commits — and write Problem Statement and Solution from the developer's perspective rather than the user's.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
