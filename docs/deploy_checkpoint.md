# Deploy checkpoint

**Goal of this stage:** move from “it works on my machine” to “it’s safe to merge, others can leverage it successfully, and it's ready to run in production on a schedule.”

## What you should have by the end of Deploy
You will have:
1. A clean, reviewable commit history on your feature branch
2. A repeatable “confidence run” command that passes locally
3. A pull request description with a tight validation checklist
4. A clear understanding of what CI gates (if it does, and why)
5. A merged PR so `main` is the source of truth

## Working rules for this stage
- Run a final local build before opening the PR.
- Keep PRs small, scoped, and easy to review.
- Put the most important context in the PR description, not elsewhere.
- Treat CI as the merge gate. If checks are not green, do not merge.
- Merge only when you can explain what changed, how it was validated, and what “done” means.

## Required inputs
You will need:
- A local repo with your branch checked out
- All relevant tests passing from the Test stage (or at least no blocking tests)
- Remote configured (`origin`) pointing to your fork
- Access to GitHub to open a pull request

## Deploy requirements (minimum)

### 1) Final local confidence check: build what you changed
Run an end-to-end build that includes models + tests:
`dbt build`

**Expectation:**
- Command finishes successfully.
- Models build and tests pass together.

### 2) Push your branch
Push/Sync your branch so you can open a PR

**Expectation:**
- Remote branch exists on GitHub.
- There is a clear branch name that reflects the work.

### 3) Open a PR with a structured description
Open a PR from your branch into `main`.

**PR description must include:**
- **What changed:** staging models, fact models, and tests
- **How to validate:** run `dbt build`
- **What “done” looks like:** conversion rate and time-to-order metrics by platform

**Copy/paste PR checklist:**
- [ ] Sources added for `raw_website_events` and `raw_flower_orders`
- [ ] `stg_website_events` and `stg_flower_orders` built
- [ ] `fct_customer_funnel` built (1 row per customer)
- [ ] `mart_platform_funnel_metrics` built (1 row per platform)
- [ ] Schema + business logic tests added
- [ ] `dbt build` passes locally

### 4) CI gate: what must be checked before merge
At minimum, CI should run:

```
dbt deps
dbt compile
```

Ideally, CI also runs:
- `dbt build` for the models you changed ('dbt build -s state:modified+')

**Why this matters:**
- Compile catches broken refs, missing sources, and syntax errors.
- Build catches runtime issues and test failures.

### 5) Merge strategy
Merge only when:
- Review feedback is addressed.
- All required checks are green.
- The PR description clearly communicates changes and validation.

**Definition of “deployment moment”:**
- The merge makes `main` the single source of truth for what should run.

## Quick self-checks (do these before you move to Operate)
- You can run `dbt build` locally and it passes.
- Your PR description explains **what changed**, **how to validate**, and **what done looks like**.
- CI checks are green (or you can explain exactly why they are not).
- After merge, you can confidently say: “This is safe to run from `main`.”

## Common pitfalls
- Skipping the final local build and relying on CI to catch obvious issues.
- PRs that are too large to review quickly.
- Missing validation steps in the PR description.
- Assuming “compile-only CI” is useless. It still prevents many broken merges.
- Merging with failing checks because “it’s just a learning project.”

## Suggested deploy loop (repeat)
1. Run a final build locally:
   `dbt build`
2. Push/Sync your branch:
3. Open the PR and paste the checklist from above.
4. Fix any CI failures.
5. Merge only when checks are green and review is complete.