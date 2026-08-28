# Testing

Tests make rapid product work safe. The goal is full behavioral coverage of every interactive path and regression-prone decision.

## Framework

- Vitest with the jsdom environment
- React Testing Library for component behavior
- GitHub Actions for pull request and push verification

## Commands

```bash
pnpm test
pnpm typecheck
pnpm build
```

Use `pnpm test:watch` while developing.

## Layers

- Component tests live in `__tests__/` and exercise user-visible behavior.
- Integration tests should cover workflows that cross multiple components or services.
- Browser tests should cover the production landing at desktop and mobile widths.

## Conventions

- Name files `*.test.tsx`.
- Assert observable behavior, not implementation details.
- Reset local storage and document state between browser-like tests.
- Add a regression test whenever a bug is fixed.
