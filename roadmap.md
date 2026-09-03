# Roadmap

Updated: 2026-08-28

## North star

StorageClean becomes the Windows storage decision system people trust when a disk is full. It measures quickly, explains the small number of causes that dominate usage, protects irreplaceable data, proposes the right action, requires exact confirmation, and verifies every result.

The wedge is not "CCleaner with AI." Deterministic code owns filesystem facts and execution. AI helps interpret intent, risk, and tradeoffs without receiving file contents by default.

## Perfect version definition

The finite perfect v1 standard is:

- A normal Windows user can install, scan, understand, act, verify, update, and uninstall without a terminal.
- A 1 TB drive scan stays memory-bounded, handles reparse points safely, can pause or cancel, and produces useful first results quickly.
- The product ranks the power law across folders, applications, caches, duplicate structures, and external drives.
- Every recommendation displays the exact target, measured size, rationale, risk, exclusions, reversibility, expected recovery, and verification method.
- Delete actions use quarantine or Recycle Bin when practical. Move actions verify the replacement copy before source removal.
- The product detects active processes, irreplaceability signals, cloud placeholders, hard links, reparse points, and likely generated data before offering destructive actions.
- The installer and updates are code-signed, reproducible, malware-scanned, and tested on supported Windows versions.
- Core scanning and known-path cleanup work locally. No file contents leave the device by default.
- Benchmarks demonstrate competitive scan speed and lower peak memory than the current prototype, with a documented safety advantage over incumbent cleaners.
- Recovery logs and rollback affordances make every completed action explainable.

Market leadership over CCleaner is a later business outcome, not a software acceptance test. It also requires years of trust, distribution, compatibility coverage, and support data.

## Verified current state

- The product doctrine and manual-audit evidence are documented in `SPEC.md`.
- The production landing page responds successfully at `https://storageclean.app` as of 2026-08-28.
- The production landing page has two active Windows beta download links. Both resolve to the immutable `v0.3.0-beta.1` GitHub release asset.
- A native .NET 8 WPF scanner, memory-bounded core, dependency-free self-test, Inno Setup wizard, build script, checksum, and release manifest exist in the clean release checkout at `C:\Users\adamp\Aether\storageclean.app-release`.
- The read-only beta is live. It does not yet have a destructive action engine, updater, code signature, or clean-account compatibility matrix.
- .NET 8 and the Windows Desktop runtime are installed on the development machine, so a native WPF beta can be built without adding a heavyweight framework.
- No current-user code-signing certificate was found. An unsigned beta is possible, but Windows SmartScreen trust is a release gate for a broad public launch.
- The live audit on 2026-08-28 found C: repeatedly reaching 0 free space while E: had about 392 GiB free. The immediate causes included recurring QA browser profiles, package caches, a dynamic pagefile, and large local folders that were already mostly copied to the SSD.
- `C:\Users\adamp\Desktop\win` measured about 148 GiB. A read-only Robocopy comparison found 158,963,263,262 bytes matching the SSD by size and timestamp. The remaining 80,579,911-byte apparent delta is 72 offline cloud placeholders from an unavailable provider. A full cryptographic pass and placeholder manifest are still required before any local removal.
- `C:\Users\adamp\AppData\Local\pnpm` measured about 20.30 GiB, Temp about 14.68 GiB, `C:\Users\adamp\.cache` about 5.66 GiB, and npm cache about 3.49 GiB. Exact active and disposable subsets still need classification before cleanup.
- A global `roadmap` skill now exists at `C:\Users\adamp\.codex\skills\roadmap` and passes its validator.

## Gap map

| Gap | Why it matters | Priority |
| --- | --- | --- |
| Memory-bounded native scanner | The audit itself must never worsen a full-disk incident | P0 |
| Exact-target safety model | Trust is the product, not a disclaimer | P0 |
| Working Windows package | The landing promise needs a real product | P0 |
| SSD copy and verification workflow | Moving cold data is the largest current recovery path | P0 |
| Active-process and reparse-point detection | Prevents corrupting live work and scan explosions | P0 |
| Cache ownership and recurrence diagnosis | One-time deletion does not stop regrowth | P1 |
| Irreplaceability and only-copy detection | Large personal files cannot be treated as junk | P1 |
| Signed updates and release operations | Required for credible consumer distribution | P1 |
| Private AI judgment layer | Delivers the differentiation without weakening facts or privacy | P1 |
| Broad cleaner coverage and reputation | Required to credibly surpass a mature incumbent | P2 |

## Milestones

### M0: Stabilize this machine and lock the audit baseline

Status: in progress

Outcome and user value: restore a safe free-space buffer and produce an exact, confirmable list of the few actions that recover most space.

Tasks:

1. Classify the large Temp, pnpm, npm, and `.cache` subsets as active, regenerable, movable, or protected.
2. Copy the 80.6 MB Desktop delta to E: after exact approval.
3. Verify the Desktop source and SSD copy with a streaming cryptographic manifest.
4. Present exact cleanup or move targets with expected recovery and rollback rules.
5. Patch the responsible QA teardown scripts after their active tasks stop.

Completion criteria:

- C: has at least 100 GiB free, or at minimum 15 percent free.
- Every destructive or move action has exact user confirmation.
- The repeated-growth causes have owners and prevention fixes.

ETA: 4 to 8 focused hours, 1 to 3 elapsed days. Confidence: high for diagnosis, medium for source-copy verification because hashing 148 GiB takes time.

Dependencies and risks: active SellSniper QA sessions, SSD availability, and explicit target confirmation.

### M1: Read-only Windows scanner beta

Status: in progress, public read-only beta shipped

Outcome and user value: a working Windows EXE that safely scans selected drives and displays ranked storage causes without changing files.

Tasks:

1. Create a .NET 8 WPF application with a calm, technical interface.
2. Implement streaming directory enumeration, reparse-point exclusion, access-error reporting, cancellation, and bounded concurrency.
3. Show drive capacity, free space, ranked folders, cumulative share, and suggested next investigations.
4. Add active-process signals and read-only export to JSON.
5. Add unit tests and a self-test mode using fixture trees.

Completion criteria:

- A self-contained x64 EXE launches on a clean Windows account.
- The scanner completes the fixture suite without following reparse loops or exceeding the memory budget.
- The UI performs no delete, move, deduplicate, or compression action.

Remaining ETA: 2 to 4 focused hours for broader drive and fresh-account validation, 1 to 3 elapsed days. Confidence: high.

Dependencies and risks: enough free build space and representative large-tree testing.

### M2: Installer wizard and safe beta distribution

Status: in progress, unsigned installer and live download complete

Outcome and user value: users can install and uninstall StorageClean normally, and the landing download points to a verified artifact.

Tasks:

1. Create a per-user installer wizard with Start Menu entry, optional desktop shortcut, version metadata, and clean uninstall.
2. Publish a self-contained `win-x64` build and generate checksums.
3. Test install, launch, scan, upgrade, and uninstall in a fresh Windows environment.
4. Scan the installer and publish an immutable beta release asset.
5. Enable the landing-page Windows button only after the asset and checksum are live.
6. Clearly label the build as beta and disclose SmartScreen behavior until signing is complete.

Completion criteria:

- The public URL downloads the tested installer.
- The installer, installed executable, and uninstaller work without admin rights for the default path.
- The site build, typecheck, accessibility smoke test, and download check pass.

Remaining ETA: 3 to 6 focused hours for a clean-account test matrix. Code-signing lead time is separate and may take 1 to 4 elapsed weeks. Confidence: medium.

Dependencies and risks: installer tooling, clean-machine testing, GitHub or equivalent release hosting, and lack of a signing certificate.

### M3: Exact-confirmation action engine

Status: not started

Outcome and user value: StorageClean can reclaim safe caches and quarantine files while making state changes explicit and recoverable.

Tasks:

1. Model proposed, confirmed, executing, verified, failed, and rolled-back action states.
2. Require exact paths and exclusions in confirmation.
3. Recheck active processes and target identity immediately before execution.
4. Prefer Recycle Bin or quarantine, record an action journal, and verify recovered bytes.
5. Add known-path cache recipes with versioning and tests.
6. Add privilege separation for the small set of actions that genuinely need elevation.

Completion criteria:

- Interrupted actions recover safely.
- A stale scan cannot authorize a changed target.
- Every successful action has before and after evidence.

ETA: 20 to 35 focused hours, 1 to 2 elapsed weeks. Confidence: medium.

Dependencies and risks: Windows filesystem edge cases, locks, antivirus interaction, and privilege boundaries.

### M4: Verified SSD moves and only-copy protection

Status: not started

Outcome and user value: users can move large cold data with proof that the destination is complete, while the product warns when a file appears irreplaceable.

Tasks:

1. Build resumable copy with size, timestamp, and streaming hash verification.
2. Detect destination capacity, filesystem limits, disconnection, and path-length problems.
3. Keep source removal as a separate exact confirmation after verification.
4. Inventory likely copies without reading content into an AI service.
5. Add cloud-placeholder, hard-link, reparse-point, and backup-age handling.

Completion criteria:

- Power-loss and disconnect tests never remove an unverified source.
- Verification manifests are portable and auditable.
- The UI distinguishes a backup from the only known copy.

ETA: 28 to 48 focused hours, 2 to 4 elapsed weeks. Confidence: medium.

Dependencies and risks: slow hash passes, removable-drive reliability, and ambiguous backup semantics.

### M5: Private recommendation engine and recurrence prevention

Status: not started

Outcome and user value: the product explains why space grew and recommends delete, move, compress, uninstall, or leave alone, while measured facts stay deterministic.

Tasks:

1. Build local feature extraction for ownership, recency, reproducibility, backup confidence, and recurrence.
2. Keep file contents and private filenames local by default.
3. Add a structured recommendation schema with confidence and evidence.
4. Detect recurring QA profiles, dependency stores, duplicate clones, stale worktrees, and generated corpora.
5. Add prevention recommendations and owner attribution.

Completion criteria:

- Recommendations can be reproduced from stored non-content evidence.
- Low-confidence judgments do not produce one-click destructive actions.
- Recurring leaks are surfaced separately from one-time recovery.

ETA: 30 to 55 focused hours, 3 to 5 elapsed weeks. Confidence: medium-low.

Dependencies and risks: privacy design, false positives, and evaluation data.

### M6: Consumer-grade release

Status: not started

Outcome and user value: a signed, updateable, supportable Windows product with measured reliability and performance.

Tasks:

1. Acquire and protect a code-signing identity, then sign the installer and binaries.
2. Add signed automatic updates with rollback.
3. Test supported Windows builds, filesystems, user profiles, languages, antivirus products, and restricted accounts.
4. Benchmark scan time, memory, recovery accuracy, and false-positive rates against relevant incumbents.
5. Add privacy controls, crash reporting consent, documentation, support diagnostics, and a vulnerability response process.
6. Run a staged beta and close the highest-risk trust and compatibility gaps.

Completion criteria:

- Signed production builds install without unexplained warnings.
- Release and rollback are reproducible.
- Safety and performance targets are published and met.
- Beta evidence supports expansion beyond early technical users.

ETA: 60 to 120 focused hours plus beta observation, 6 to 12 elapsed weeks. Confidence: low until beta data exists.

Dependencies and risks: certificate issuance, update infrastructure, compatibility breadth, user trust, and support load.

## Now, next, later

### Now

- Finish the exact power-law storage audit and restore a durable free-space buffer.
- Validate the shipped read-only beta on a fresh Windows account and larger representative trees.
- Keep the unsigned status explicit while selecting a code-signing path.

### Next

- Add exact-confirmation cache actions.
- Add verified SSD moves and only-copy protection.
- Obtain code signing and establish release operations.

### Later

- Add compression with a probe-first benefit test.
- Add uninstall recommendations and duplicate development-structure cleanup.
- Expand deterministic cleaner coverage, continuous monitoring, and private AI guidance.
- Invest in distribution and trust signals required to challenge a mature incumbent.

## ETA model

Assumptions:

- One founder working with Codex, with focused implementation blocks and manual Windows QA.
- No unexpected kernel, antivirus, or filesystem compatibility issue.
- External approvals, code-signing issuance, and real-user observation happen on calendar time, not model time.
- The perfect v1 standard stays fixed. New platforms and speculative features remain Later.

Forecast:

| Horizon | Focused engineering | Likely elapsed calendar | Confidence |
| --- | --- | --- | --- |
| Time to useful read-only beta | Achieved in the initial implementation session | Shipped 2026-08-28 | High |
| Time to excellent private beta | 88 to 158 hours | 6 to 10 weeks | Medium |
| Time to perfect v1 | 158 to 292 hours | 4 to 6 months | Low-medium |
| Credible path to surpass CCleaner as a product | Not responsibly estimable from code alone | 9 to 18 months of product and trust evidence at minimum | Low |

The critical path is scanner reliability, action safety, verified moves, signing and updates, then real-user evidence. Visual polish is not the critical path.

## Risks and decision gates

- **Free-space gate:** do not perform large builds when C: is below 15 GiB free. Put build intermediates on E: when possible.
- **Safety gate:** do not enable destructive UI until target identity, active-use checks, confirmation, journaling, and verification are tested together.
- **Download gate:** do not enable the production Windows button until the linked installer exists, has a checksum, and passes install and uninstall smoke tests.
- **Signing gate:** an unsigned beta can be shared deliberately, but broad production positioning waits for code signing.
- **Privacy gate:** do not send file contents or private filenames to a hosted model by default.
- **Performance gate:** test on million-file trees and low-free-space systems without recursive in-memory enumeration.
- **Scope gate:** macOS, mobile, registry cleaning, and speculative optimization remain outside perfect v1.

## Progress protocol

- Refresh this file after each milestone or material scope change.
- Mark work complete only with a local path, test result, release artifact, or deployed URL as evidence.
- Recalculate downstream ETAs when a critical-path assumption changes.
- Preserve exact cleanup confirmations and verification records in dated audit artifacts, not in vague prose.

## Changelog

- 2026-08-28: Initial evidence-based roadmap created. Defined the perfect v1 boundary, separated unsigned beta from signed production, and placed the current emergency storage audit on the critical path.
- 2026-08-28: Shipped `v0.3.0-beta.1`. The scanner self-test, application launch, installer install, installer launch, uninstall, landing tests, typecheck, production build, release download, and live custom-domain link all passed. Signing and clean-account breadth remain open gates.
