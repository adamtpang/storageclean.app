# storageclean.app - product spec

**Created:** 2026-08-22
**Status:** first real spec. Supersedes the stub in `CLAUDE.md`, which held
only the safety doctrine (that doctrine survives intact, see Safety below).

## Provenance of this document

This spec is not speculative. On 2026-08-15 through 2026-08-22 a full manual
storage cleanup ran on this machine (C: went from 8.6 GB free to 120 GB free at
its best point). Every capability claimed below was actually performed by hand
first, in line with the Aether standing rule "manual before automation, Elon's
Algorithm order." The real findings from that pass are cited as evidence
throughout.

## One sentence

CCleaner asks what type a file is. storageclean asks what a file is *to you*,
and what the right move for it is, where deleting is only one of several moves.

## The competitor, stated fairly

CCleaner is pattern-matching cleanup: known cache paths, file extensions,
browser history, registry entries, startup items, and a duplicate finder
matching on name, size, date, or content. It is fast, deterministic, cheap, and
runs in seconds. Its registry cleaner is a soft spot (Microsoft warns against
registry cleaners generally), but the core product is genuinely good at what it
does.

Its model of a disk: **files have types, some types are junk.**

That model is the entire opportunity. It cannot see structure, intent,
irreplaceability, or cause.

## Capability comparison

| Capability | CCleaner | storageclean | Session evidence |
| --- | --- | --- | --- |
| Find junk by pattern | Core strength | Table stakes | Cleared ~69 GB of caches and temp |
| Understand what a file *is* | No | Core | Separated `wonderhall.MP4` (irreplaceable) from downloaded films (re-gettable) |
| Diagnose *why* space grew | No, reports numbers | Core | Traced a +33.85 GB week to duplicate branch clones, not cache growth |
| Catch structural problems | No | Core | Found a 9.49 GB content corpus git-tracked inside an app repo |
| Explain anomalies | No | Core | Diagnosed a bogus 1.43 TB / 178M-file scan as pnpm symlink recursion |
| Actions beyond delete | No | Core | Compressed 68 GB to 16.6 GB, moved to external, untracked from git |
| Verify before destroying | Basic | Mandatory | Byte-count match on both sides before every deletion |
| Judge "is this my only copy" | No | Core | The OneDrive placeholder investigation (5,580 files cloud-only) |

## The three wedges

Not "CCleaner but AI." These are the things CCleaner structurally cannot do.

### 1. Irreplaceability triage

Surface the files that exist in exactly one place. This was the single most
valuable output of the manual pass, and it is backup-adjacent anxiety that no
cleaner addresses today.

Real finding: `Pictures` was 127 GB but only ~5 GB was actual photos. The rest
was 21 large files, mostly irreplaceable personal video (event footage, a music
project, camera raw clips, personal recordings, a Google Takeout export). A
type-based cleaner sees "a folder of media." The real answer was "most of this
exists nowhere else."

### 2. Compression as a first-class action

Delete is destructive and often unnecessary. Re-encoding is not.

Real numbers from the manual pass, GPU HEVC at CQ 24:

| File | Before | After | Ratio |
| --- | --- | --- | --- |
| wonderhall.MP4 | 53.0 GB | 8.24 GB | 6.4x |
| C6259-001.mov | 6.52 GB | 1.57 GB | 4.1x |
| C6258.RSV_fixed.mov | 5.01 GB | 1.39 GB | 3.6x |
| maanasa old.mp4 | 1.15 GB | 87 MB | 13.5x |
| conjecture school 1.mp4 | 7.66 GB | 6.36 GB | 1.2x |

Total: 68 GB to 16.6 GB, about 51.5 GB reclaimed with no data loss and no
quality objection from the user.

The last row matters as much as the first. Already-efficient files barely
shrink, and the product must detect and skip those rather than burning an hour
of GPU time for 17%. A probe-then-decide step is required, not optional.

### 3. Developer-aware cleanup

This is where the real growth was, and CCleaner is blind to all of it.

Real findings: seven near-duplicate full clones of one repo (17.86 GB, each
with its own `node_modules`), stale git worktrees, a multi-gigabyte content
corpus committed into an app repo's history, `node_modules` and Python venvs
inflating every backup pass, and a malformed folder named after a broken shell
command left by an interrupted cleanup.

## Safety doctrine (inherited, non-negotiable)

Carried forward verbatim in spirit from the original `CLAUDE.md`:

- Audit first.
- Never delete, move, overwrite, or deduplicate without explicit confirmation
  of the exact targets.
- Nothing is deleted before its replacement copy is verified byte-for-byte.
- Quarantine over deletion where a reversible option exists.

The manual pass followed this and it held up. It is the product's spine, not a
disclaimer.

## Honest risks

These are real and should shape the roadmap, not be argued away.

- **Speed and cost.** CCleaner runs in seconds, free. The manual pass took
  hours and several scans timed out outright on large directories. This gap is
  severe for a consumer product and probably forces a hybrid design: fast
  deterministic scanning, AI only at the judgment layer.
- **Trust asymmetry.** Users already hesitate to let a rule-based tool delete
  things. An LLM doing it is a far bigger ask.
- **Permission friction.** The manual pass repeatedly hit OS and harness guards
  on deletion, and fell back to handing the user commands to run themselves. A
  shipped product must solve this cleanly or it is only an expensive advisor.
- **Privacy.** "Point an AI at your entire drive" needs a real answer. Local
  inference, or never transmitting file contents, are the credible ones.

## Open questions

- Local model or hosted? Privacy answer and cost answer are the same decision.
- What is the actual unit of value: one-time audit, or continuous monitoring?
  The manual pass had to be re-run days later because caches regrew.
- Does compression belong in v1? It produced the largest single win, but it is
  also the slowest and most GPU-dependent feature.

## Gate check before building

The Aether standing rule "concentration over spread" sets a hard gate: no new
project front until at least three numbered `ASAP_CHECKLIST.md` items are
actually done, not drafted. Building this out is a new front. That gate should
be checked and either satisfied or explicitly overridden before code is written.
