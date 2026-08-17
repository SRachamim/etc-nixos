---
name: audit-dependencies-g
description: Audit outdated and vulnerable dependencies, risk-classify by code-level impact, update in risk order with verification, and submit a PR. Use when the user wants to update packages, check for vulnerabilities, or audit dependency health.
---

# Audit Dependencies

Audit outdated and vulnerable packages, risk-classify them by breaking-change severity and code-level usage, update in safe order, and verify after each group.

## Input

The user specifies (or the agent infers):
- **Scope**: all dependencies, a specific package, or a category (e.g. "security-only", "patch-only")
- **Ecosystem**: npm, dotnet, pip, or auto-detect from the repo

## Steps

### 0. Mode gate

Follow the **mode-gate-g** skill -- require Plan mode for the audit phase.

### 1. Discover outdated and vulnerable packages

Run the ecosystem-appropriate audit commands:

| Ecosystem | Outdated | Vulnerable |
|-----------|----------|------------|
| npm | `npm outdated --json` | `npm audit --json` |
| dotnet | `dotnet list package --outdated` | `dotnet list package --vulnerable` |
| pip | `pip list --outdated --format=json` | `pip-audit --format=json` |

Collect: package name, current version, latest version, vulnerability CVEs (if any).

### 2. Risk-classify

For each outdated package, determine risk:

| Risk tier | Criteria | Update order |
|-----------|----------|--------------|
| **Critical** | Known CVE with CVSS >= 7.0 | First |
| **Patch** | Semver patch bump, no breaking changes | Second |
| **Minor** | Semver minor bump, additive API | Third |
| **Major** | Semver major bump or known breaking changes | Last |

For Major-tier packages:
- Search for release notes / changelogs (web search)
- Scan the codebase for usage of deprecated/removed APIs
- Note specific code locations that would need changes

### 3. Present audit summary

Present the classified list to the user:
- Critical (security): N packages
- Patch (safe): N packages
- Minor (low risk): N packages
- Major (breaking): N packages with specific impact notes

Wait for user approval on which tiers to proceed with.

### 4. Update in risk order

For each approved tier, starting with Critical:

1. Update the packages in that tier
2. Run the build
3. Run the test suite
4. If tests fail: investigate, apply minimal fixes, or roll back and note the failure
5. Commit the tier as a single commit (e.g. "Update 5 patch dependencies")

### 5. Submit

Once all approved tiers are updated and green:
- Follow the **commit-and-push-g** skill to push
- If the user wants a PR, follow `/submit-feature-g`

### 6. Evolve

Follow the **capture-improvement-g** skill.
