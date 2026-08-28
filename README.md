# Storage Clean

Landing page for [storageclean.app](https://storageclean.app).

Storage Clean is a local-first Windows storage manager in development. It is designed to explain why space grew, protect irreplaceable files, and recommend verifiable delete, move, compress, or uninstall actions.

The public site is a Next.js application. A signed Windows installer is not available yet, so the landing page labels the desktop app as coming soon.

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
