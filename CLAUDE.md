# Repository guidance

## Testing

Run `pnpm test`, `pnpm typecheck`, and `pnpm build` before shipping. Component tests live in `__tests__/`; see `TESTING.md` for conventions.

Full behavioral coverage is the goal. New conditionals need tests for each path, bug fixes need regression tests, and existing tests must remain green.

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes. APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev`. Verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

## Safety (carried over from the planning folder, 2026-09-03)

- Audit first.
- Do not delete, move, overwrite, or deduplicate files without Adam's explicit confirmation of the exact targets.
- The storage-audit planning layer (SPEC.md, roadmap.md, the confirmed cleanup .ps1 scripts, artifacts/) now lives in this repo. The former separate `storageclean.app` folder was an older, non-git snapshot of this same app plus that planning layer; it was consolidated here and renamed `storageclean.app-planning-old`, kept until Adam removes it.
