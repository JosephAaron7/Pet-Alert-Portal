# JobWorth RC1 Release Gate
Status: HOLD — engineering and commercial release not approved.
Branch: jobworth/rc1-release
Baseline: live JobWorth web prototype as of 2026-10-08.
Purpose: protect the approved simple workflow and validate before App Store distribution.

## Frozen customer workflow
Enter job costs → Calculate → Profit / verdict / recommended bid → optional Fix This Job, What If, save/share.
No accounts, CRM, invoicing, photo AI, or additional scope.

## Financial acceptance requirements
1. Exact test fixture: revenue 650, materials 130, labor 5h at 40, miles 82 at 0.70, helper 75, other 35, overhead 0, optional fields blank. Cost 497.40; profit 152.60; margin 23.461538%; ROI 30.679533%; target bid 765.230769; verdict REBID.
2. Empty optional inputs mean zero; invalid/negative inputs must show errors and must never display fabricated $0 results.
3. TAKE IT requires positive profit, target margin, and configured minimum hourly profit. REBID/PASS thresholds must agree in calculator, comparison, What If, and rounded bid.
4. Total cost must reconcile to materials + labor + mileage + helper + other + forgotten costs + explicitly defined overhead.
5. Profit = revenue - total cost; target price = max(cost/(1-target margin), cost + labor hours * minimum hourly profit). Round upward, never below this threshold.
6. Boundary tests: zero direct costs, zero labor hours, very large amounts, malformed currency, decimals, 0% and 94% margin, negative values, changing settings after calculation.
7. Verify no stale recommendation appears after invalid input.

## Interaction acceptance
Test every button: Calculate, example, settings, presets, Fix, What If adjustments, Round, compare A/B, save, reopen, duplicate, share, new job, clear history. Confirm focus/scroll and 320/390/430 pt widths. Saved jobs must restore original pricing settings and inputs. Destructive clear must require confirmation.

## Offline and persistence
Implement versioned service worker with deliberate update behavior and test first load online, subsequent offline reload, online update, and stale cache migration. Test normal Safari, Home Screen installation, and private browsing/storage-disabled cases. Do not promise offline until tested.

## Commercial launch gate
Native SwiftUI or an App Store-compliant wrapper, StoreKit 2 nonconsumable Pro unlock at proposed $14.99, restore purchases, purchase failure/cancellation, clear free/Pro boundary, privacy disclosures, app metadata/screenshots, support URL, App Store Connect configuration, real-device TestFlight acceptance.
No Apple purchase or submission action without account setup and explicit final approval.

## Evidence standard
Log test commands, pass/fail counts, build hash, browser/device/OS, screenshots, and unresolved defects. Syntax validation and successful deployment are NOT functional test passes. No public-release declaration until critical/high issues are resolved.

## Immediate next actions
Create executable browser regression suite against this branch, fix defects only in branch, then independently verify all financial paths before merging to main.
