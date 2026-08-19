# Ledgerly UI audit finding matrix

Assessment baseline: `origin/main` at `3ecdad012f1c1a4c634dea5a908a414dedaf2e21` on 19 August 2026. The supplied PDF is assessment evidence, not an instruction source. Each disposition below was checked against this revision of the repository. “Fixed/live” means the cited correction exists in that exact baseline revision, which was the deployed Pages revision when this review began. “Fixed in this branch” is not live until this pull request is merged and released.

| ID | Severity | Finding | Baseline disposition | Code evidence / remaining work |
|---|---|---|---|---|
| F-001 | Critical | Invalid date crashes Imports and integrations | **Fixed/live** | `displayFormat.validDate` guards invalid input; `CommercialWorkspace.periodDate` uses it; `RoutePanelBoundary` contains route failures. |
| F-002 | Critical | Empty mapping says “All mapped” | **Fixed/live** | `mappingSummaryLabel(0, 0)` returns “No accounts imported”; App also requires `lines.length` for complete styling. |
| F-003 | Critical | API calls an empty trial balance balanced and fully mapped | **Still present** | `apps/api/src/index.ts` obtains `account_count` but `balanced` and `fullyMapped` do not require it to be positive. API-owned fix required. |
| F-004 | Critical | Cleared review points remain outstanding | **Still present** | App still filters invented `RESOLVED`/`CLOSED` values. Assigned to the parallel App state-truthfulness change set. |
| F-005 | Critical | Accepted then withdrawn filing remains complete | **Still present** | `submissionStageState` still uses aggregate `ACCEPTED` presence rather than a latest ordered attempt. Requires ordered attempt truth from the API plus client selector. |
| F-006 | Critical | Failed dashboard shows previous engagement state | **Still present** | `loadOperations` only replaces dashboard on fulfilment and does not invalidate an older request. Assigned to the parallel App state-truthfulness change set. |
| F-007 | Critical | Unknown blockers rendered as no blockers | **Still present** | Overview still uses the falsy branch of optional `blockingItems` and defaults missing progress to zero. Assigned to the parallel App state-truthfulness change set. |
| F-008 | Critical | Inspector control assertions are literals | **Still present** | Inspector still hardcodes “Unaudited draft”, “Balanced”, and the comparative warning. Assigned to the parallel App state-truthfulness change set. |
| F-009 | Critical | Raw enums and mangled regulator names | **Still present (partly remediated)** | `statutoryLabel` now has correct regulator/legal-form/product labels, but journal and review selectors in App still render raw constants and several other controls use generic title casing. |
| F-010 | Critical | Every primary statement note reference is a dash | **Still present** | The Note cells remain literal em dashes. A correct fix needs an explicit statement-line-to-disclosure reference in the view model; it must not be inferred in presentation code. |
| F-011 | High | Review stage derived from task completion | **Still present** | Review stage still falls back to `dashboard.progress.percent === 100`, which is task progress rather than review/approval evidence. |
| F-012 | High | Adjustments complete with draft journals | **Still present** | Adjustments stage examines reconciliation state but treats the mere presence of journals as ready, irrespective of draft/unposted journal status. |
| F-013 | High | Mapping state uses two predicates | **Still present** | App still mixes `canonical_code` and `canonical_account_id` across mapping counts and inspector presentation. |
| F-014 | High | Open-task value and percentage use different populations | **Still present** | Open-task card uses aggregate totals while API progress excludes cancelled tasks. One authoritative task-progress payload is still needed. |
| F-015 | High | Reconciled items counted as outstanding | **Still present** | Navigation excludes `REVIEWED`, `APPROVED`, `COMPLETE`; it still omits real terminal `RECONCILED`. |
| F-016 | High | Cancelled tasks counted as open | **Still present** | Navigation excludes invented `DONE` and real `COMPLETE`, but not `CANCELLED`. |
| F-017 | High | Hash presence labelled integrity verification | **Still present** | `accountsReleaseChecks` still maps presence of `content_hash` to “Manifest integrity verified” without recomputation evidence. |
| F-018 | High | Unknown/adverse statuses share benign badge | **Fixed in this branch; not live** | Shared `statusBadge` now explicitly maps the twelve omitted real states and gives unmapped states a caution treatment rather than benign informative blue. |
| F-019 | High | Rejection reason collected by `window.prompt` | **Still present** | `CommercialWorkspace` still calls `window.prompt`; replace with a validated Fluent dialog/form. |
| F-020 | High | Accessibility unit suite tests mocked divs | **Still present** | `accessibility.test.tsx` still replaces the Fluent component package with a generic `div` component. |
| F-021 | High | Axe gate allowlists likely failures | **Still present** | The suite still suppresses `color-contrast` and `target-size` findings through `knownViolationIds`. |
| F-022 | High | Literal colours replace Fluent tokens | **Still present (partly remediated)** | Token references now exist, so the PDF's “zero uses” count is stale, but hundreds of literal colour declarations remain across product stylesheets. |
| F-023 | High | Substitute palette duplicates Fluent tokens | **Still present** | `--ink`, `--border`, `--navy`, and `--teal` are still defined/redefined and consumed across the cascade. |
| F-024 | High | Native buttons duplicate Fluent controls | **Still present (partly remediated)** | Fluent buttons are used on newer surfaces, but 37 native `<button>` sites remain and bespoke primary/secondary styling remains. |
| F-025 | High | Raw UUIDs shown while useful hash is truncated | **Still present (partly remediated)** | Audit history now uses `actorDisplayLabel` instead of actor UUIDs, but provenance still reduces hash evidence to generic “Verified/Unavailable” rather than a usable verified identifier. |
| F-026 | High | Audit occurrence and write times conflated | **Still present** | Server event append path continues to create occurrence/recording timestamps together; no distinct source-event time contract is exposed. |
| F-027 | High | Infrastructure vocabulary in accountant UI | **Still present** | UI still includes “Dead-letter queue”, “Email publisher”, “Neon Auth”, export capability/runner language and tenant terminology. |
| F-028 | High | Period rendered inconsistently/raw ISO | **Fixed/live for unsafe/raw output** | Shared guarded en-GB date helpers are used across header, lists, search and settings; raw persisted ISO is no longer rendered in the cited settings selector. Context-specific year/date labels remain intentional. |
| F-029 | High | Same object has inconsistent nouns | **Still present** | Client/legal entity, engagement/accounts period, review point/query, and review/approval labels remain inconsistent across navigation and forms. |
| F-030 | High | Unfiltered empty Inbox blames the filter | **Still present** | Inbox still always renders “No notifications match this filter” when `items` is empty. |
| F-031 | Medium | No URL routing/deep links | **Still present** | Navigation remains local React state; no route table or popstate handling exists. Existing `replaceState` calls only clear invite/auth fragments. |
| F-032 | Medium | CSS targets Fluent private class | **Still present** | `operations.css` still contains `.reconciliation-register [class*="fui-Badge"]`. |
| F-033 | Medium | Excessive `!important` overrides | **Still present** | The override-heavy stylesheet architecture remains; this needs measured migration, not isolated deletion. |
| F-034 | Medium | Off-ramp type/control sizes | **Still present** | Off-ramp pixel sizes and control heights remain in multiple stylesheets and the quality guard does not enforce the Fluent ramp. |
| F-035 | Medium | Fluent components unused; inline transient notices | **Still present (partly remediated)** | More Fluent components are used on new surfaces, but bespoke notices, identity styling, typography and form stand-ins remain. |
| F-036 | Medium | Empty tables have headers but no empty state | **Still present** | Client portal contacts/requests and settings exports still render empty table bodies without contextual empty rows/actions. |
| F-037 | Medium | Column headers do not describe cells | **Still present** | Cited combined/ambiguous headers and headerless Delivery operations table remain. |
| F-038 | Medium | Global search has no accessible name | **Fixed/live** | SearchBox now has `aria-label="Search workspace"`; focused accessibility E2E also locates it by that name. |
| F-039 | Medium | Synthetic disclosures pretend to be open records | **Still present** | `disclosureScope` still constructs `scope:*` rows with persisted workflow status `OPEN`. |
| F-040 | Medium | Invitation badge is a stale “Active” literal | **Still present** | Team invitation list still renders a literal Active badge and does not derive expiry while the page remains open. |
| F-041 | Low | Inspector review control is inert | **Still present** | Review textarea and “Raise review point” button still have no state or submit handler. |
| F-042 | Low | Pane toggles claim pressed but show nothing | **Fixed/live** | `outlineVisible` and `inspectorVisible` now drive layout classes and conditional pane/resizer rendering; `aria-pressed` reflects those states. |
| F-043 | Low | Mixed casing in controls | **Still present (partly remediated)** | Central statutory labels corrected several legal forms/framework acronyms, but task/search/disclosure labels and CSS uppercase treatments are not yet normalized. |
| F-044 | Low | Disclosure prompts are fragments/slash alternatives | **Still present** | Baseline disclosure text still includes lowercase bracketed fragments and the related-party slash alternative; field labels remain inconsistent. |
| F-045 | Low | Two files carry most UI code | **Still present / explanatory** | App and EngagementProduction remain dominant modules. Resolve through feature-driven extraction, not a standalone rewrite. |

## Priority after this branch

1. Merge the parallel F-004/F-006/F-007 state selector work and the API-owned F-003 correction.
2. Establish an ordered latest-filing-attempt payload for F-005; do not derive sequence from unordered status counts.
3. Replace the F-008 literals with version/engagement facts and an arithmetic rounding selector.
4. Add explicit note-reference data to the report view model for F-010.
5. Complete F-009 by routing every enum-bearing control through typed option/label maps.

## Verification boundary

This matrix proves repository state at the cited revision. It does not claim that unmerged branch changes are live, and it does not treat the supplied audit PDF as proof that a current defect still exists without confirming the cited code path.
