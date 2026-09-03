# Live storage power law

Captured: 2026-08-28, Asia/Singapore

This is a read-only decision report. It is not authorization to delete or move the listed targets.

## Current state

| Drive | Used | Free | State |
| --- | ---: | ---: | --- |
| C: | 916.38 GiB | 16.64 GiB | Critical, 98.2 percent used |
| E: | 540.47 GiB | 391.03 GiB | Healthy working capacity |

C: reached effectively 0 MiB free during this audit. Removing two previously confirmed inactive Temp targets and allowing the dynamic pagefile to contract restored the present buffer. The buffer is not durable yet.

## Why C: keeps filling

The cause is concentrated, not a long tail of tiny files:

- AppData: about 158.40 GiB
- Desktop: about 148.12 GiB
- Pictures: about 125.33 GiB
- Aether development data: about 117.96 GiB
- FC 26 plus Overwatch: about 133.13 GiB
- Temp currently: about 14.68 GiB, with recurring browser QA profiles
- pnpm store: 20.18 GiB

The pagefile expanded above 14 GiB when memory pressure rose, then contracted to 5.26 GiB. It explains short-term swings but should not be deleted or manually downsized on this machine.

## Ranked power-law moves

### 1. Finish verified Desktop archiving, then separately confirm local removal

Exact source: `C:\Users\adamp\Desktop\win`

Exact destination: `E:\Backup\Desktop\win`

Potential C: recovery: 148.12 GiB

Read-only comparison:

- Source bytes: 159,043,843,173
- Already matching by size and timestamp: 158,963,263,262 bytes
- Remaining apparent delta: 80,579,911 bytes across 72 files
- SSD-only extras preserved: 24,690,192,373 bytes across 80 files

Important limitation: prior verification found that the 72 apparent delta files are offline cloud placeholders from an unavailable provider. A prior checksum sample covered 4,569 files and 18.18 GiB with zero mismatches, but a full cryptographic source-to-destination pass is still required before local removal.

Why this ranks first: this one move would take C: from roughly 16.6 GiB free to about 164.8 GiB free while leaving E: with about 242.9 GiB free. It solves the emergency without filling the SSD.

Safe sequence:

1. Preserve a manifest for all offline placeholders.
2. Hash every locally available source file against its destination counterpart.
3. Report mismatches, missing files, and unreadable placeholders.
4. Ask for a separate exact confirmation before removing any local source.

### 2. Remove 20 inactive browser and QA Temp roots

Measured total: 6.38 GiB

No current process command line referenced these exact roots at the final audit check. Several were written recently, so the deletion script must recheck active processes immediately before acting.

Exact targets:

1. `C:\Users\adamp\AppData\Local\Temp\sellsniper-link-evidence-qa` (1.01 GiB)
2. `C:\Users\adamp\AppData\Local\Temp\sellsniper-search-performance-qa` (0.75 GiB)
3. `C:\Users\adamp\AppData\Local\Temp\sellsniper-website-change-qa` (0.61 GiB)
4. `C:\Users\adamp\AppData\Local\Temp\sellsniper-campaign-qa` (0.44 GiB)
5. `C:\Users\adamp\AppData\Local\Temp\crossbar-edge-cdp` (0.35 GiB)
6. `C:\Users\adamp\AppData\Local\Temp\moneymeta-cdp` (0.32 GiB)
7. `C:\Users\adamp\AppData\Local\Temp\HeadlessEdge3579273821062` (0.32 GiB)
8. `C:\Users\adamp\AppData\Local\Temp\sellsniper-company-qa` (0.32 GiB)
9. `C:\Users\adamp\AppData\Local\Temp\adam-gives-edge-prod-codex` (0.32 GiB)
10. `C:\Users\adamp\AppData\Local\Temp\skill-supply-bh-20260826-v2` (0.32 GiB)
11. `C:\Users\adamp\AppData\Local\Temp\sellsniper-competitor-qa` (0.22 GiB)
12. `C:\Users\adamp\AppData\Local\Temp\beeper-chat-visual` (0.22 GiB)
13. `C:\Users\adamp\AppData\Local\Temp\cleared-chat-cdp-clean` (0.21 GiB)
14. `C:\Users\adamp\AppData\Local\Temp\node-compile-cache` (0.16 GiB)
15. `C:\Users\adamp\AppData\Local\Temp\bc-cdp-profile` (0.15 GiB)
16. `C:\Users\adamp\AppData\Local\Temp\HeadlessEdge1169615096109` (0.14 GiB)
17. `C:\Users\adamp\AppData\Local\Temp\sellsniper-edge-cdp-evidence2` (0.14 GiB)
18. `C:\Users\adamp\AppData\Local\Temp\skill-supply-bh-3107` (0.13 GiB)
19. `C:\Users\adamp\AppData\Local\Temp\sellsniper-brand-profile-qa` (0.13 GiB)
20. `C:\Users\adamp\AppData\Local\Temp\sellsniper-refresh-qa` (0.13 GiB)

Follow-up: patch teardown in the owning QA scripts after their active tasks stop. Otherwise this recovery will regrow.

### 3. Remove four regenerable package or browser caches

Measured total: 4.63 GiB

Exact targets:

1. `C:\Users\adamp\AppData\Local\npm-cache\_npx` (2.41 GiB)
2. `C:\Users\adamp\AppData\Local\npm-cache\_cacache` (1.08 GiB)
3. `C:\Users\adamp\.cache\puppeteer` (0.68 GiB)
4. `C:\Users\adamp\.cache\codex-incomplete-node-modules` (0.46 GiB)

Tradeoff: tools may redownload packages or browser binaries later. Do not remove `C:\Users\adamp\.cache\codex-runtimes`, because the current Codex runtime is using it.

### 4. Prune, but do not manually delete, the pnpm store

Exact store: `C:\Users\adamp\AppData\Local\pnpm\store`

Current total: 20.18 GiB

Potential recovery: unknown until `pnpm store prune` runs.

Several pnpm builds and development processes are active, so this is deferred until they stop. The safe action is the package manager's prune command, not recursive deletion of the store.

### 5. Pictures only after a second-drive capacity decision

Exact source: `C:\Users\adamp\Pictures`

Comparison destination: `E:\Backup\Pictures`

Potential C: recovery: 125.33 GiB

Read-only comparison found 133,986,981,549 bytes matching by size and timestamp and about 599 MB needing refresh. Moving both Desktop and Pictures would leave E: at only about 12.6 percent free, below the preferred 15 percent reserve. Do Desktop first, then reassess or add another backup drive.

### Deferred by current instruction or safety

- FC 26 and Overwatch, about 133.13 GiB combined: move only through their launchers, not by moving folders directly.
- `C:\Users\adamp\Videos`, about 47.47 GiB: the current `E:\Videos` layout did not match, so no source removal is justified.
- `C:\Users\adamp\Aether`, about 117.96 GiB: the SSD backup is not complete enough for a move.
- Hugging Face models, 3.09 GiB: several models were used today, including Stable Audio and Whisper. Relocate the model cache deliberately rather than deleting it blindly.
- `C:\ProgramData\Package Cache`, 4.78 GiB: keep it for application repair and uninstall support.
- `C:\pagefile.sys`: system-managed and necessary under current memory pressure.
- OneDrive: the remaining directory is only about 0.46 MiB, so it is not a storage move.

## Exact confirmation phrases

- `CONFIRM TEMP-20` authorizes only the 20 Temp roots listed in section 2, with an immediate active-process recheck.
- `CONFIRM CACHE-4` authorizes only the four regenerable caches listed in section 3.
- `CONFIRM DESKTOP FULL VERIFY` authorizes a read-only full hash comparison and offline-placeholder manifest. It does not authorize local removal.

After a successful full Desktop verification, local removal will require a new, separate confirmation naming `C:\Users\adamp\Desktop\win`.
