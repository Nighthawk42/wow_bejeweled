# Dedicated-mainline integration plan

This plan records the repository restructuring observed after fetching `origin` on 2026-08-24. It is an integration gate, not authorization to rewrite the modernization history before its target-branch and source-layout policy are settled.

## Observed state

- `modernization` is clean and committed. Its root commit is `52d12bd38c8f8a512f8938343be8e34e7905863c`; it intentionally has no merge base with either `origin/mainline` or `origin/archive`.
- `origin/archive` preserves source commit `6faec1c`, the immutable evidence snapshot used by the completed analysis.
- `origin/mainline` descends from `6faec1c` through the repository restructure and now contains only `Bejeweled/Bejeweled.lua` and `Bejeweled/Bejeweled.toc` as runtime files.
- The new contribution guide requires one Lua file and one TOC per client branch. The modernization currently uses private modules and an ordered TOC, so adopting that rule requires an explicit source-versus-release-layout decision.

## Safety decision

Do not pull, merge, or rebase `origin/mainline` into `modernization`. A rebase cannot express the relationship because there is no shared history, and copying the worktree to a temporary directory would add no protection beyond the committed branch.

## Migration gate

When maintainers designate the modernization target branch and layout, integrate in a separate branch or worktree:

1. Preserve a named ref at the final pre-integration modernization commit.
2. Create the integration branch from the then-current `origin/mainline`.
3. Decide whether modular files are accepted as modernization source or must be bundled into a generated `Bejeweled/Bejeweled.lua` release artifact. Do not hand-concatenate modules or discard the verified load order.
4. Import the completed analysis, tests, documentation, and runtime commits as a deliberate squash or patch series; do not attempt an unrelated-history merge.
5. Reconcile the canonical TOC name, semantic version, changelog, acknowledgement, license, and contribution rules without changing either SavedVariables wire format.
6. Re-run the immutable-evidence hashes, all 8,401-line coverage checks, Lua 5.1 runtime tests, Retail API audit, and in-game verification before replacing this branch.

Until those decisions are made, `modernization` remains the recoverable implementation branch and `origin/archive` remains the source-evidence reference.
