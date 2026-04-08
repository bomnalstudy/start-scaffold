# Orchestration and Harness Research

This document captures source-backed practices to harden orchestration and harness design.

## 1. Test layering and speed balance

Source:

- Martin Fowler, Test Pyramid
- https://martinfowler.com/articles/practical-test-pyramid.html

Practical takeaway:

- keep many fast checks at lower layers
- keep fewer expensive high-level tests
- avoid "all e2e" strategy that slows feedback loops

How we apply:

- run lightweight rule checks on every run
- run scenario harness for medium/high risk changes
- run minimal end-to-end only for critical flows

## 2. Harness isolation and reproducibility

Source:

- Playwright Best Practices
- https://playwright.dev/docs/best-practices

Practical takeaway:

- test user-visible behavior
- isolate tests from each other
- control external dependencies and data

How we apply:

- each harness scenario has explicit preconditions
- avoid relying on external third-party runtime behavior
- keep scenario setup deterministic

## 3. Fixture-style setup for scalable checks

Source:

- pytest fixtures docs
- https://docs.pytest.org/en/stable/how-to/fixtures.html

Practical takeaway:

- explicit reusable setup blocks scale better than ad-hoc setup code
- setup should be modular and composable

How we apply:

- define reusable precondition snippets in harness specs
- keep setup names explicit and scenario-scoped

## 4. DAG-like orchestration discipline

Source:

- Apache Airflow tasks concepts
- https://airflow.apache.org/docs/apache-airflow/2.10.5/core-concepts/tasks.html

Practical takeaway:

- tasks should have explicit dependencies
- retries/timeouts should be first-class
- each task has clear state transitions

How we apply:

- orchestration steps must be ordered and dependency-aware
- each stage should fail fast with clear status
- retries and stop conditions should be explicit

## 5. Eval mindset for non-deterministic systems

Source:

- OpenAI Evaluation best practices
- https://platform.openai.com/docs/guides/evaluation-best-practices

Practical takeaway:

- AI output is variable, so we need structured evals
- combine metric checks and rubric checks
- continuously evaluate, not just one-off testing

How we apply:

- add repeatable pass/fail criteria in harness
- keep a small stable regression set for repeated runs
- evolve checks as new failure patterns appear

## Hardening Checklist

Before adding a new orchestration or harness flow:

- define stage order and dependencies
- define retry/timeout/stop behavior
- define deterministic setup
- define minimal pass criteria
- define what to log for future sessions

Before closing:

- confirm objective coverage
- confirm no overfitting to one test case
- confirm next-step tasks are documented
