# Storage Clean

Landing page for [storageclean.app](https://storageclean.app).

Storage Clean is a local-first Windows storage manager in development. It is designed to explain why space grew, protect irreplaceable files, and recommend verifiable delete, move, compress, or uninstall actions.

The public site is a Next.js application. A published unsigned, read-only Windows beta is available. The desktop beta scans and exports measurements; destructive cleanup and AI judgment remain planned.

## Local development

```bash
pnpm install
pnpm dev
```

## Verification

```bash
pnpm typecheck
pnpm build
```

## Deploy

Production deploys through the existing Vercel project for `storageclean.app`.

GitHub deployment restored October 2026 through the existing storageclean.app Vercel project. The production branch is main.
