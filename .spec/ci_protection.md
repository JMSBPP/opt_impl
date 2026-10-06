# Verification Gate and Branch Protection

**Status:** Accepted
**Date:** 2026-10-06

## Decision

The verified part of development is centralized in `justfile` and enforced by GitHub Actions CI.

Local verification command:

```sh
just verify
```

`just verify` runs:

```sh
pack typecheck opt_impl
pack test opt_impl
```

## CI

GitHub Actions workflow:

```text
.github/workflows/ci.yml
```

The required CI job is named:

```text
verify
```

It runs on pushes and pull requests targeting:

- `main`
- `dev`

## Branch Protection Intent

Protected branches should require the `verify` status check before changes land.

Protection target branches:

- `main`
- `dev`

The intended policy is:

- pushes must pass the verification gate;
- pull requests must pass the verification gate;
- direct changes that bypass `just verify`/CI are not accepted as completed work.

## Development Rule

Before pushing implementation changes, run:

```sh
just verify
```

CI is the remote enforcement of the same command. If CI fails, the change is not considered integrated, even if local typechecking passed.
