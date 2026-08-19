# Ledgerly Fluent 2 application standard

This is the authoritative design and implementation standard for Ledgerly's application UI under `apps/web`. It applies to product screens, authentication, navigation, dialogs, forms, tables, notifications and responsive states. Statutory accounts pages and exported PDF/DOCX documents are governed separately under **Statutory output exception**.

The normative external references are Microsoft's current Fluent 2 guidance for [design principles](https://fluent2.microsoft.design/design-principles), [design tokens](https://fluent2.microsoft.design/design-tokens), [layout](https://fluent2.microsoft.design/layout), [typography](https://fluent2.microsoft.design/typography), [color](https://fluent2.microsoft.design/color), [accessibility](https://fluent2.microsoft.design/accessibility), [React buttons](https://fluent2.microsoft.design/components/web/react/core/button/usage), [React dialogs](https://fluent2.microsoft.design/components/web/react/core/dialog/usage) and [React message bars](https://fluent2.microsoft.design/components/web/react/core/messagebar/usage). Where this standard and a Fluent component's current guidance differ, follow the component guidance and update this document in the same pull request.

## Non-negotiable implementation rules

- Use public `@fluentui/react-components` v9 components. Do not imitate a Fluent control with raw HTML and custom CSS when a public component exists.
- Style with Fluent semantic alias tokens. Do not introduce product palettes, hard-coded semantic hex values, private `.fui-*` selectors or unscoped `!important` overrides.
- Use Fluent tokens for color, typography, spacing, stroke, radius, elevation, duration and motion. A raw value needs a documented exception and a regression test.
- Use the Fluent web type ramp and system font stack. Do not create intermediate font sizes or weights to make a layout fit.
- Use sentence case. Labels describe the action or value in an accountant's language; they do not expose database enums, infrastructure, internal IDs or implementation state.
- Use one primary action per page region, dialog footer or form action group. Navigation is a `Link`; commands are `Button` controls.
- Never convey status through color alone. Pair semantic color with text and, where useful, an official Fluent icon.

## Component mapping

| Product need | Required Fluent primitive |
| --- | --- |
| Command or submission | `Button` |
| Navigation | `Link`, `TabList`/`Tab`, or the established accessible navigation pattern |
| Text, number, date and selection inputs | `Field` containing `Input`, `Textarea`, `Dropdown`, `Combobox`, `SpinButton` or a supported date control |
| Confirmation or focused setup task | `Dialog`, `DialogSurface`, `DialogBody`, `DialogTitle`, `DialogContent`, `DialogActions` |
| Page/surface feedback | `MessageBar`, `MessageBarBody`, `MessageBarTitle`, `MessageBarActions` with the correct intent |
| Structured records | Fluent `Table` family; use `DataGrid` only when its interaction model is required |
| Status | `Badge` with a mapped semantic appearance and readable label |
| Context actions | `Menu` family; do not create floating bespoke option lists |
| Section disclosure | `Accordion` family or an established native disclosure only when semantics and keyboard behaviour are equivalent |
| Help | `Tooltip` for concise supplementary text; essential instructions remain visible |
| Loading | `Spinner`, `Skeleton`, or progress component appropriate to the known/unknown duration |

Composition is allowed; reimplementation of component behaviour is not. Use public slots, props and `makeStyles` rather than private DOM selectors.

## Tokens, spacing and density

- The layout rhythm is Fluent's 4 px base grid. Prefer `tokens.spacing*`; the 2, 6 and 10 px ramp values are allowed where Fluent uses them for icon alignment.
- Default application controls are the standard Fluent size. Compact density is allowed for data-dense tables and row actions, provided 44 x 44 px touch targets remain available at touch breakpoints.
- Related label/control/help text form one spacing group. Fields in the same row align by label baseline, control top and control height.
- Use semantic radius and shadow tokens. Pill/circular radius is reserved for components whose Fluent specification calls for it, not generic panels or statuses.
- Empty space must express hierarchy, not inflate a task. Avoid dead panels and duplicated explanations.

## Typography and content hierarchy

- Use Fluent preset text components or matching tokens: caption, body, body strong, subtitle and title. Page titles, section titles, body copy and metadata use one consistent semantic level across the application.
- Body text is never reduced to create room. Truncate non-essential single-line values with an accessible full-value tooltip; wrap meaningful prose.
- Keep heading levels logical and unique to their view. Each route has one page `h1`; dialogs start with their labelled `DialogTitle`.
- Left-align prose and labels in left-to-right layouts. Align numeric table columns consistently and use tabular numerals where available.
- Write concise professional English. Avoid marketing phrases, implementation caveats and vague labels such as “Continue” when the committed action can be named.

## Action hierarchy

- A region has at most one `appearance="primary"` button. Secondary actions use neutral/outline appearance; low-frequency actions use subtle or transparent appearance where Fluent guidance permits.
- Destructive actions state the object and require proportionate confirmation. Disable an action only when its prerequisite is clear nearby.
- “New [object]” creates a new object. “Add [object]” adds an existing object. Button labels have no terminal punctuation.
- Repeated actions use the same component, label, size and placement throughout a workflow.

## Dialogs and forms

- Use the full Fluent Dialog composition. The surface has a sensible task-specific `maxWidth`; it must not fill a desktop merely because the viewport is wide.
- Keep the title and dismiss affordance in the header, focused form content in `DialogContent`, and actions in an aligned `DialogActions` footer.
- Put each label immediately above its control with `Field`. Required state belongs to the field; do not mark optional valid values as required.
- On desktop, use a two-column grid only for short related fields. Full-context choices, long names and validation messages span the full width. At narrow widths the grid becomes one column without horizontal scrolling.
- Opening a dialog moves focus inside it. Closing returns focus to the invoker. Escape, tab order, submit and validation work from the keyboard. Do not nest dialogs.
- Long values truncate safely in closed selectors and expose their full value by accessible name or tooltip.

## Tables and dense records

- Column headers and cells share the same grid. Numeric values align right; labels align left; action columns are narrow and consistent.
- A row is not clickable unless focus, hover and keyboard behaviour make the interaction explicit. Otherwise use a Link or Button in the row.
- Use responsive column priority: preserve identity, status and primary action; collapse secondary metadata into a detail surface rather than clipping it.
- Empty, loading, unavailable and failed states are distinct. Never show zero, complete, balanced or mapped when data was not loaded.

## Message bars and status semantics

- Use an official `MessageBar` for surface-level information, success, warning or error. The `intent` determines icon and semantic tokens.
- `warning` identifies an action or risk needing attention; `error` identifies a failed or blocked operation; `success` confirms a completed operation; `info` supplies neutral context.
- Do not hand-build alert borders, icons or colors. Do not use semantic status colors for decoration.
- Status labels come from an explicit domain-to-display map. Never title-case a database constant as a fallback.

## Navigation

- Every destination has a stable URL and supports deep links, reload and browser back/forward.
- Breadcrumb ancestors are links; only the current location is plain text.
- Sidebar groups and rows share one geometry, icon size, label style and selected/focus treatment. Stage tabs and sidebar destinations expose the same state truthfully.
- Navigation never depends on pointer interaction alone and never silently leaves the view unchanged.

## Responsive behaviour

- Design fluidly from 320 px through large desktop. Test at minimum 390 x 844, 768 x 1024 and 1440 x 900.
- Use content-driven breakpoints. Side-by-side fields become one column before labels, values or actions collide.
- No application page introduces horizontal viewport scrolling. Deliberately scrollable data regions must be labelled and keep controls reachable.
- Drawers and inspectors must resize, collapse or dismiss; they must not cover the document or primary task without an escape route.

## Accessibility

- Meet WCAG 2.2 AA. Normal text contrast is at least 4.5:1; large text and non-text UI meet their applicable thresholds.
- Preserve visible focus, logical keyboard order, accessible names, programmatic labels, error association and focus restoration.
- Validate Windows forced-colors behaviour with system colors. Light/dark/high-contrast support comes through semantic tokens, not parallel palettes.
- Touch targets are at least 44 x 44 px where touch input is expected.
- Automated axe checks are a floor, not completion. Perform keyboard, zoom/reflow and screen-reader semantic review on changed flows.

## Statutory output exception

Accounts-preview paper and PDF/DOCX output are legal documents, not application chrome. They may use print-specific fonts, dimensions, monochrome rules and statutory table geometry. Keep those styles within the statutory renderer/print boundary. Application controls surrounding the preview remain fully Fluent. Product semantic colors must never leak into statutory output.

## Visual QA matrix

Every changed view must be checked for:

1. light theme, dark-theme token compatibility and Windows forced colors;
2. desktop, tablet and narrow/mobile widths;
3. empty, loading, populated, validation, blocked and API-failure states;
4. 100%, 200% and 400% zoom/reflow where applicable;
5. keyboard-only operation, focus entry/exit and focus restoration;
6. repeated component consistency across adjacent screens;
7. long legal names, dates, currency values, translated-length stress and safe truncation;
8. no infrastructure language, fixture identifiers, raw enums or contradictory state claims.

## Release gates

A UI change cannot merge until all applicable gates pass:

- strict TypeScript and complete web unit tests;
- UI source-quality guard and its rule tests;
- security-header tests and production build;
- focused Playwright journeys at desktop and narrow widths;
- axe gate plus manual keyboard/focus/forced-colors review;
- before/after visual evidence for affected states;
- functional verification of every changed action and its persisted/API output;
- production smoke test after an exact-SHA deployment.

Exceptions must be narrow, documented beside the affected implementation, time-bounded, approved in review and represented as explicit debt in the guard baseline. A blanket exception or a private Fluent selector is not acceptable.
