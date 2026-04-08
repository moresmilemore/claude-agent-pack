---
scope: coder, reviewer
load_when: files matching **/*.tsx, **/*.jsx, **/*.vue, **/*.svelte, **/*.css, **/*.scss, **/components/**, **/styles/**
---

# UI Style Rules

Load this file when touching UI code (components, styles, markup).

## Component Structure

- One component per file. File name matches component name (`PascalCase.tsx`).
- Props: explicit interface / type at the top of the file. No `any`.
- Avoid default exports for components — named exports surface rename errors.

## CSS / Styling

- Match the project's styling approach (Tailwind, CSS modules, styled-components, vanilla CSS). Do not mix.
- No inline `style` props unless the value is computed at runtime.
- Design tokens (colors, spacing, font sizes) come from the project's tokens file, not magic numbers.
- Responsive: mobile-first. Scale up with media queries, never down.

## Accessibility (Never Optional)

- Every interactive element has an accessible name.
- Color contrast ≥ WCAG AA (4.5:1 for text, 3:1 for large text).
- Keyboard navigation: every clickable element is focusable and operable with Enter/Space.
- `alt` text on every image. Decorative images get `alt=""`.
- Form inputs have `<label>` associations.

## State Management

- Local state first. Global state only when two unrelated components need the same data.
- No `useState` for server state — use the project's data-fetching library (React Query, SWR, etc.).

## Performance

- No inline object/array literals as props if the component is `React.memo`'d — they break memoization.
- Lazy-load routes and heavy components.
- Images: always specify dimensions to prevent layout shift.

## Naming

- Event handlers: `handle<Thing>` inside the component, `on<Thing>` as the prop name.
- Boolean props: `is<X>`, `has<X>`, `should<X>`.
- Custom hooks: `use<Thing>`.
