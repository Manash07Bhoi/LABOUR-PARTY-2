# Phase 1: Existing Releases Audit

## Inventory
The following releases were queried from the GitHub API on repository `Manash07Bhoi/LABOUR-PARTY-2`:

### 1. `v1.2.0-rc`
- **Name**: Labour Party RC-1.2
- **Date (Published)**: 2026-05-25T07:11:39Z
- **Assets**: 1 attached (`app-arm64-v8a-release.apk` | 18.2 MB | SHA: `963c6cfc4...`)
- **Flags**: Prerelease = True
- **Reasoning**: This was a test/intermediate release testing keystore parameters and file sizes.
- **Classification**: **DELETE**

### 2. `v1.0.1-hotfix-rc1`
- **Name**: Labour Party — Hotfix RC-1.1
- **Date (Published)**: 2026-05-25T02:20:19Z
- **Assets**: 1 attached (`app-arm64-v8a-release.apk` | 18.2 MB | SHA: `ca380b27...`)
- **Flags**: Prerelease = True
- **Reasoning**: This was an emergency patch deployed during the QA and Hotfix cycle audit tracking. Since we are creating a unified stable version, this hotfix branch release is now obsolete as a public download.
- **Classification**: **DELETE**

### 3. `v1.0.0-rc1`
- **Name**: Labour Party RC-1
- **Date (Published)**: 2026-05-24T01:40:07Z
- **Assets**: 1 attached (`app-arm64-v8a-release.apk` | 18.1 MB | SHA: `adf3ff59...`)
- **Flags**: Prerelease = True
- **Reasoning**: This was the primary Release Candidate that kickstarted the Production Readiness Program. Since it represents a milestone in the testing cycle history (and its tag is referenced in historical PRs), the release page itself can be archived, or the tag kept while deleting the redundant duplicate release page.
- **Classification**: **DELETE** (Release Page), **KEEP** (Tag `v1.0.0-rc1` in Git history)
