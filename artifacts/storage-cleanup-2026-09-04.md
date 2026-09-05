# Storage cleanup record, 2026-09-03 to 2026-09-04

Read-only decision report plus the actions Adam explicitly confirmed. Every deletion below was named by exact target and approved in chat before it ran. Nothing was moved, deduplicated, or deleted on inference.

## Result

| Point in time | C: free |
| --- | ---: |
| Start of session, 2026-09-03 | 1.6 GiB |
| After Temp, caches, pnpm prune | 27.4 GiB |
| After Visual Studio installer cache and Unity editor | 44.6 GiB |
| After build artifacts (node_modules, .next, Bun and Unity caches) | 105.1 GiB |
| After reboot, 2026-09-04 | 107.9 GiB |
| After Antigravity backup, duplicates, blockchain chain data, voice model, emulator, 2026-09-04 | 128.8 GiB |

Capacity is 933 GiB. The full-drive walk on 2026-09-04 counted 9,468,160 files in 422 seconds with zero access errors.

## What was removed, in order

1. 344 inactive browser QA profile directories under the user Temp folder, 13.46 GiB. Each was checked against live process command lines immediately before removal.
2. npm `_cacache` and the puppeteer browser download, 2.71 GiB. The npm `_npx` cache was held open by running node processes and was left in place.
3. `pnpm store prune`: 150 packages, 14,320 files, 5.62 GiB. Package manager command only, no manual store deletion.
4. Wizard101, through its own uninstaller. Folder and registry entry gone. Its measured 11.6 GiB never appeared as free space before or after reboot; the earlier measurement likely double counted.
5. Visual Studio installer download cache in Temp, 3.71 GiB.
6. Unity editor 6000.5.7f1 through its own silent uninstaller, 12.3 GiB actual. See the caveat below.
7. 1,335 `node_modules` and `.next` directories across the workspace, worktrees, and a secondary dev folder, plus the Bun install cache and Unity caches. 120.1 GiB logical, 84.7 GiB actual. The gap is pnpm hardlink sharing with its store. The active repo (this one) kept its install so the test suite stayed green; verified 10 of 10 passing afterwards.
8. Antigravity IDE backup folder, 2.9 GiB, and the second copies of two byte-identical files (a 1.7 GiB video and a 1.7 GiB PDF), verified by SHA-256 before removal.
9. Re-syncable chain data of a dormant blockchain mining node, 14.1 GiB across three folders. Its wallet and key files were left in place untouched. The miner had crashed on 2026-08-09 and its companion WSL distro no longer existed.
10. A 2023 text-to-speech model cache, 2.9 GiB (the Python package that uses it stays and redownloads on demand), and an Android emulator through its own uninstaller, 4.2 GiB.

Also this session, not storage but related: an orphaned Python process from an earlier tool call had pinned one CPU core for three hours writing 25.8 GB into a dead pipe, and the Windows TextInputHost had spun for 13,000 CPU seconds. Both were stopped. Two idle Next.js dev servers were closed, freeing 1.7 GB of memory.

## Caveat on the Unity removal

The editor removal was approved on the basis that no local project referenced it. That check searched four levels deep from the user profile and missed a project five levels deep that does reference exactly that version and had commits ten days earlier. The editor will need to be reinstalled through Unity Hub (about 20 GiB) before that project can be opened again. Unity Hub was kept for that reason.

## Measurement gotcha

During the bulk delete of millions of hardlinked files, `Get-PSDrive` reported free space falling from 44.6 to 20.2 GiB. `fsutil volume diskfree` read 42.5 GiB at the same moment and shadow copy storage was zero. NTFS free-space accounting lags a large unlink storm and recovers when it settles. Confirm with `fsutil` before acting on a sudden drop.

## Still open

- Desktop\win (146 GiB) and Pictures (125 GiB) are mirrored to the E: portable SSD and wait for a full read-only hash verification against it before any local removal. The SSD was not connected during this session.
- Roughly 188 GiB of video across Videos, Desktop media, and Pictures is the natural first library for the Plex Media Server that is already installed but has never been set up. Pointing it at the SSD is the zero-cost path and doubles as the storage move.
- Stale git worktrees, audited 2026-09-05 (about 16 GiB across seven container folders). Nine of the ten 1.3 GiB summon.company archive worktrees have every commit on a remote and differ only in three files the agent sync tool rewrites, so they are removable without loss. Seven worktrees hold commits on no remote (summon.company-sum-196, idiguam.com, two youchop.app checkouts, anchormarianas.com, sprite.email, summon.guide with 230 uncommitted files) and must be pushed or kept. Four are orphans whose parent repo moved and are plain directories now. Removal waits on an exact-target confirmation.
- Done 2026-09-05: the 59 browser QA scripts now share a helper that removes each run's Temp profile on exit and sweeps folders left by dead PIDs on the next start, so the 13 GiB Temp recovery no longer regrows.
