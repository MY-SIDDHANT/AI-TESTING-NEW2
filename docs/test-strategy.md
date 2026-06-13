# EventHub — Booking Management Test Strategy

Generated: 2026-06-11
Input: `docs/test-scenarios.md` (83 scenarios, TC-001 to TC-520)

---

## 1. Layer Distribution Summary

| Layer | Count | % | Focus Areas | Est. Run Time |
|-------|-------|---|-------------|---------------|
| **Unit** | 4 | 5% | `randomRef()`, `generateUniqueRef()` pure functions | ~2 min |
| **API/Integration** | 35 | 42% | Validators, business rules, security (auth/authz), error codes | ~15 min |
| **Component** | 8 | 10% | Loading states, form controls, refund UI state machine | ~5 min |
| **E2E** | 36 | 43% | Critical user flows, multi-page journeys, UI integration | ~25 min |
| **Total** | **83** | 100% | | ~47 min |

**Pyramid shape**: ✅ Wide at bottom (Unit + API = 47%), narrow at top (E2E = 43%)

> **Note on multi-layer coverage**: TC-102 (booking ref prefix) is tested at Unit + API for defense-in-depth. E2E only confirms the ref is displayed, not its format.

---

## 2. Layer Assignments

### Unit Tests (4 scenarios)
_Criteria: Pure function, no I/O, no DB. Source: `backend/src/services/bookingService.js`_

| TC | Title | Function Under Test | File:Line |
|---|---|---|---|
| TC-405 | Booking ref uniqueness — collision retry | `generateUniqueRef(eventTitle)` with mocked `findByRef` | `bookingService.js:21` |
| TC-408 | Event title starting with digit | `randomRef('100 Days Festival')` → "1-XXXXXX" | `bookingService.js:11` |
| TC-409 | Event title with special characters | `randomRef('@Tech Summit')` → "@-XXXXXX" | `bookingService.js:11` |
| TC-410 | Empty title fallback uses "E" prefix | `randomRef('')` → "E-XXXXXX" | `bookingService.js:12` |

**Rationale**: `randomRef()` and `generateUniqueRef()` are pure/near-pure functions requiring only a mocked `bookingRepository.findByRef`. Testing them at API or E2E adds overhead with no added confidence.

---

### API / Integration Tests (35 scenarios)
_Criteria: Backend business rule, API contract, or requires real DB state. Auth enforced via JWT. Source: `bookingController.js`, `bookingService.js`, `bookingValidator.js`_

#### Security (7 scenarios) — `backend/src/middleware/authMiddleware.js`, `bookingService.js`
| TC | Title | Endpoint | Expected | Source Reference |
|----|-------|----------|----------|------------------|
| TC-201 | Cross-user booking access 403 | `GET /api/bookings/:id` | 403 | `getBookingById()` → `ForbiddenError` |
| TC-202 | Cross-user cancellation 403 | `DELETE /api/bookings/:id` | 403 | `cancelBooking()` → `ForbiddenError` |
| TC-203 | Unauthenticated list 401 | `GET /api/bookings` | 401 | Auth middleware |
| TC-204 | Unauthenticated detail 401 | `GET /api/bookings/:id` | 401 | Auth middleware |
| TC-205 | Unauthenticated clear 401 | `DELETE /api/bookings` | 401 | Auth middleware |
| TC-206 | Cross-user lookup by ref 403 | `GET /api/bookings/ref/:ref` | 403 | `getBookingByRef()` → `ForbiddenError` |

#### Validation (7 scenarios) — `backend/src/validators/bookingValidator.js`
| TC | Title | Validation Rule | Expected |
|----|-------|-----------------|----------|
| TC-110 | Customer name min 2 chars | `isLength({ min: 2 })` | 400 + error message |
| TC-111 | Customer email format | `isEmail()` | 400 |
| TC-112 | Customer phone min 10 digits | `isLength({ min: 10 })` | 400 |
| TC-113 | Phone only valid chars | `matches(/^[0-9+\-\s()]+$/)` | 400 |
| TC-115 | Quantity 1-10 integer | `isInt({ min: 1, max: 10 })` | 400 for 0, 11, 1.5 |
| TC-413 | Phone with intl format | `+91 98765-43210` | 201 (success) |
| TC-414 | Max length customer name | No upper bound | 201 (success) |

#### Business Rules (12 scenarios) — `backend/src/services/bookingService.js`
| TC | Title | Service Method | Rationale |
|----|-------|----------------|-----------|
| TC-100 | FIFO pruning — different event | `createBooking()` | Tests `findOldestUserBookingExcludingEvent` path |
| TC-101 | FIFO pruning — same event fallback | `createBooking()` | Tests `sameEventFallback` + `decrementSeats` |
| TC-102 | Booking ref first char matches title | `createBooking()` | Verify ref pattern via API response |
| TC-106 | Total price = price × quantity | `createBooking()` | Verify `totalPrice` in response |
| TC-107 | Pagination params | `getBookings()` | `?page=1&limit=10` pagination response |
| TC-108 | Cancel releases seats (computed) | `cancelBooking()` | Dynamic seat computation after delete |
| TC-114 | Status always "confirmed" | `createBooking()` | Hardcoded in service |
| TC-400 | 9→10 prunes oldest (different) | `createBooking()` | FIFO edge at exact limit |
| TC-401 | 9→10 same event burns seat | `createBooking()` | `decrementSeats` called |
| TC-406 | Clear when 1 booking | `clearAllBookings()` | Returns `{ deleted: 1 }` |
| TC-407 | Pagination page 2 | `getBookings()` | `?page=2&limit=5` |
| TC-412 | Multiple bookings same event | `createBooking()` | Both succeed |

#### Negative/Error (9 scenarios) — Error paths via API
| TC | Title | Expected Code | Source Reference |
|----|-------|---------------|------------------|
| TC-007 | Lookup by ref (happy) | 200 | `getBookingByRef()` |
| TC-301 | Non-existent ID | 404 | `NotFoundError` |
| TC-302 | Insufficient seats | 400 | `InsufficientSeatsError` |
| TC-303 | Non-existent event | 404 | `NotFoundError` in event lookup |
| TC-304 | Missing required fields | 400 | Validator array |
| TC-305 | Quantity 0 or negative | 400 | `isInt({ min: 1 })` |
| TC-306 | Quantity > 10 | 400 | `isInt({ max: 10 })` |
| TC-307 | Cancel already-cancelled | 404 | `findById` returns null |
| TC-411 | Quantity = available seats | 201 | Exact boundary success |

---

### Component Tests (8 scenarios)
_Criteria: Single component renders correctly for a given prop or mocked state. No real network calls. Source: `frontend/app/bookings/page.tsx`, `frontend/app/bookings/[id]/page.tsx`_

| TC | Title | Component | What to Test |
|----|-------|-----------|--------------|
| TC-105 | Refund spinner 4 seconds | `RefundEligibility` | State machine: idle → checking → result with timer |
| TC-308 | Error state on server down | `BookingsContent` | `isError` branch renders error empty state |
| TC-500 | Skeleton loading state | `BookingsContent` | `isLoading` renders 5 `BookingCardSkeleton` |
| TC-502 | Detail page loading spinner | `BookingDetailPage` | `isLoading` renders `Spinner size="lg"` |
| TC-507 | "Clearing..." button state | `BookingsContent` | `clearing` state disables button |
| TC-508 | Refund button hidden after check | `RefundEligibility` | Button removed after status change |
| TC-509 | Access Denied state | `BookingDetailPage` | 403 error renders Access Denied |
| TC-519 | Form loading during submit | `BookingForm` | `isPending` state |

**Rationale**: All these states are driven by React state/hooks (`isLoading`, `isError`, `clearing`, `isPending`). These are testable via route interception or direct component rendering with mocked props. Running full E2E for loading skeletons is wasteful.

---

### E2E Tests (36 scenarios)
_Criteria: Multi-page user journey, full-stack data flow, cross-session security requiring real browser state. Source: Playwright, `playwright.config.ts`_

**Base URL**: `http://localhost:3000` (local) | `https://eventhub.rahulshettyacademy.com` (prod)
**Test File**: `tests/booking-management.spec.js`
**Test Accounts**: `rahulshetty1@gmail.com` / `Magiclife1!` (primary), `rahulshetty1@yahoo.com` / `Magiclife1!` (cross-user)

#### Complete E2E Test Cases (36 total)

| # | TC | Title | Category | Priority | Target URL | Assertion / Journey |
|---|-----|-------|----------|----------|------------|---------------------|
| 1 | TC-001 | View bookings list | Happy Path | P0 | `/bookings` | Login → navigate → assert cards rendered |
| 2 | TC-002 | View booking detail | Happy Path | P0 | `/bookings/:id` | Login → `/bookings` → "View Details" → assert all sections |
| 3 | TC-003 | Cancel booking | Happy Path | P0 | `/bookings/:id` | Login → detail → "Cancel Booking" → confirm → redirect to `/bookings` |
| 4 | TC-004 | Clear all bookings | Happy Path | P0 | `/bookings` | Login → "Clear all bookings" → confirm → assert empty state |
| 5 | TC-005 | Back navigation | Happy Path | P2 | `/bookings/:id` → `/bookings` | Detail → "← Back to My Bookings" |
| 6 | TC-006 | View My Bookings after booking | Happy Path | P1 | `/events/:id` → `/bookings` | Book event → "View My Bookings" → assert booking |
| 7 | TC-008 | Create booking E2E | Happy Path | P0 | `/events` → `/events/:id` | Events list → select → fill form → confirm card |
| 8 | TC-009 | Seats reduce after booking | Happy Path | P0 | `/events/:id` | Note seats → book → revisit → verify decreased |
| 9 | TC-010 | Booking in list after create | Happy Path | P0 | `/events/:id` → `/bookings` | Complete booking → navigate → find card |
| 10 | TC-103 | Refund eligible (qty=1) | Business Rule | P0 | `/bookings/:id` | `#refund-result` shows "Eligible for refund" |
| 11 | TC-104 | Refund not eligible (qty>1) | Business Rule | P0 | `/bookings/:id` | `#refund-result` shows "Not eligible" |
| 12 | TC-109 | Clear button visible | Business Rule | P2 | `/bookings` | "Clear all bookings" link visible when bookings exist |
| 13 | TC-200 | Cross-user access UI | Security | P0 | `/bookings/:otherUserId` | Login User A → create booking → logout → Login User B → "Access Denied" |
| 14 | TC-300 | Non-existent ID UI | Negative | P1 | `/bookings/99999` | "Booking not found" empty state |
| 15 | TC-309 | Invalid email client error | Negative | P1 | `/events/:id` | Form error: "Enter a valid email" |
| 16 | TC-310 | Short name client error | Negative | P1 | `/events/:id` | Form error: "Name must be at least 2 chars" |
| 17 | TC-311 | Invalid phone client error | Negative | P1 | `/events/:id` | Form error: "Enter a valid 10-digit phone" |
| 18 | TC-312 | Sold-out event UI | Negative | P1 | `/events/:id` | Sold-out state; booking disabled |
| 19 | TC-402 | Min quantity=1 booking | Edge Case | P1 | `/events/:id` | "−" button disabled at qty=1 |
| 20 | TC-403 | Max quantity=10 booking | Edge Case | P1 | `/events/:id` | "+" button disabled at qty=10 |
| 21 | TC-404 | Qty=2 not eligible | Edge Case | P1 | `/bookings/:id` | Refund check shows ineligible for qty=2 |
| 22 | TC-501 | Empty state no bookings | UI State | P1 | `/bookings` | "No bookings yet" + "Browse Events" link |
| 23 | TC-503 | Cancel dialog appears | UI State | P0 | `/bookings/:id` | ConfirmDialog with "Cancel this booking?" |
| 24 | TC-504 | Dialog close doesn't cancel | UI State | P1 | `/bookings/:id` | Dismiss dialog → booking remains |
| 25 | TC-505 | Breadcrumb shows ref | UI State | P2 | `/bookings/:id` | Breadcrumb: "My Bookings / {ref}" |
| 26 | TC-506 | Cancel toast + redirect | UI State | P0 | `/bookings/:id` → `/bookings` | Toast "Booking cancelled successfully" |
| 27 | TC-510 | Pagination UI | UI State | P2 | `/bookings?page=2` | Pagination controls visible |
| 28 | TC-511 | Increment disabled at 10 | UI State | P1 | `/events/:id` | "+" button `disabled` at qty=10 |
| 29 | TC-512 | Decrement disabled at 1 | UI State | P1 | `/events/:id` | "−" button `disabled` at qty=1 |
| 30 | TC-513 | Max qty = available seats | UI State | P1 | `/events/:id` | `(max N)` label matches available |
| 31 | TC-514 | Price updates with qty | UI State | P1 | `/events/:id` | Total updates on qty change |
| 32 | TC-515 | Confirmation card details | UI State | P0 | `/events/:id` | Ref, name, qty, total displayed |
| 33 | TC-516 | Event details section | UI State | P1 | `/bookings/:id` | Title, Category, Date, Venue, City |
| 34 | TC-517 | Customer details section | UI State | P1 | `/bookings/:id` | Name, Email, Phone |
| 35 | TC-518 | Payment summary section | UI State | P1 | `/bookings/:id` | Tickets, Price/ticket, Total Paid |
| 36 | TC-520 | Event page info | UI State | P0 | `/events/:id` | Title, date, venue, price, seats |

#### Category Breakdown
| Category | Count | Test Cases |
|----------|-------|------------|
| Happy Path | 9 | TC-001, TC-002, TC-003, TC-004, TC-005, TC-006, TC-008, TC-009, TC-010 |
| Business Rule | 3 | TC-103, TC-104, TC-109 |
| Security | 1 | TC-200 |
| Negative | 5 | TC-300, TC-309, TC-310, TC-311, TC-312 |
| Edge Case | 3 | TC-402, TC-403, TC-404 |
| UI State | 15 | TC-501, TC-503, TC-504, TC-505, TC-506, TC-510, TC-511, TC-512, TC-513, TC-514, TC-515, TC-516, TC-517, TC-518, TC-520 |
| **Total** | **36** | |

---

## 3. Decision Rationale — Contested Assignments

### TC-102: Booking ref first char → API (primary) + Unit (secondary)
**Suggested**: E2E / API
**Decision**: API + Unit; E2E only verifies display
**Rationale**: The `randomRef()` function is backend logic. While E2E can verify via UI, testing the pattern assertion (`^T-[A-Z0-9]{6}$`) is faster and more reliable at the API layer. Unit tests for edge cases (digits, special chars, empty). E2E should only verify the ref is displayed, not its format.

### TC-103/TC-104: Refund eligibility → E2E (not Component)
**Suggested**: E2E
**Assigned**: E2E
**Rationale**: `RefundEligibility` is client-side only (no API). Component test could work, but the 4-second timeout and state transitions are better verified in a real browser context. The existing E2E infrastructure supports this. Keep at E2E for now; promote to Component if suite grows.

### TC-105: Refund spinner timing → Component (not E2E)
**Assigned**: Component
**Rationale**: Testing exact timing (4000ms) is flaky in E2E due to network/render variance. Use component test with timer mocking (`jest.useFakeTimers()` or Playwright clock API).

### TC-309/TC-310/TC-311: Client-side validation → E2E (not API)
**Assigned**: E2E
**Rationale**: These test the form's `validate()` function which runs before API call. Could be unit-tested, but E2E verifies the actual user experience of error messages appearing. They're quick and add confidence in the UI layer.

### TC-500/TC-502: Loading states → Component
**Assigned**: Component
**Rationale**: Skeleton and spinner states require controlling `isLoading` which means mocking hooks. This is simpler in component tests than throttling network in E2E.

### TC-100/TC-101/TC-400/TC-401: FIFO pruning → API (not E2E)
**Assigned**: API
**Rationale**: FIFO pruning is orchestrated entirely in `bookingService.createBooking`. It involves:
1. `bookingRepository.countUserBookings(userId)` — count check
2. `bookingRepository.findOldestUserBookingExcludingEvent(userId, eventId)` — FIFO selection
3. `bookingRepository.delete(oldest.id)` — pruning
4. `eventRepository.decrementSeats(eventId, quantity)` — seat burn for same-event fallback
None of these are observable in the UI without checking booking counts before and after. An API test can precisely set up 9 bookings, issue the 10th, and assert DB state.

---

## 4. Anti-Patterns Found in Existing Tests

### ✅ Good Practices Observed (`tests/booking-management.spec.js`)
1. **Login helper reuse** — `login(page)` and `clearBookings(page)` prevent duplication
2. **Test isolation** — Each test clears state before running
3. **Meaningful assertions** — Tests verify specific content, not just presence
4. **Step comments** — `// -- Step N: --` blocks improve readability
5. **Booking ref validation** — TC-102 verifies pattern match with regex

### ⚠️ Anti-Patterns to Address
| Issue | Location | Recommendation |
|-------|----------|----------------|
| **No API test coverage** | `tests/` folder has only E2E specs | Add `tests/api/` folder with booking API tests for TC-100, TC-201–206, TC-301–307 |
| **No Unit tests** | No `__tests__/` folder in backend | Add `backend/src/services/__tests__/bookingService.test.js` for TC-405, TC-408–410 |
| **Hardcoded BASE_URL** | `const BASE_URL = 'https://eventhub.rahulshettyacademy.com'` | Use `process.env.BASE_URL` or Playwright config's `baseURL` |
| **Magic timeout** | `bookEvent()` waits for `.booking-ref` without explicit timeout | Add `{ timeout: 5000 }` for slow environments |

### 🚨 Missing Test Coverage (Critical)
| Area | Missing Tests | Priority |
|------|---------------|----------|
| FIFO pruning (9→10) | TC-100, TC-400, TC-401 | P0 — critical business rule |
| Security (403/401) | TC-201–206 | P0 — security regression risk |
| Input validation (backend) | TC-110–115 | P1 — backend validators untested |
| Pagination | TC-107, TC-407 | P2 — edge case |

---

## 5. Defense-in-Depth Coverage Map

Critical rules covered at multiple layers for maximum confidence:

| Rule | Unit | API | Component | E2E |
|---|---|---|---|---|
| Booking ref prefix = event title first char | TC-408–410 | TC-102 | — | TC-102 (display) |
| Price = price × quantity | — | TC-106 | — | TC-006 (implicit) |
| Refund: qty=1 eligible, qty>1 not | — | — | TC-105 | TC-103, TC-104 |
| Cross-user access denied | — | TC-201, TC-202, TC-206 | TC-509 | TC-200 |
| Cancel booking | — | TC-307 | — | TC-003, TC-506 |
| FIFO pruning at 9 bookings | — | TC-100, TC-101, TC-400, TC-401 | — | — |
| Auth required (401) | — | TC-203, TC-204, TC-205 | — | — |
| Input validation | — | TC-110–115 | — | TC-309–311 |

---

## 6. Implementation Priority Order

Ship in this order — each tier unblocks the next:

**Tier 1 — P0, must pass before any release**
- E2E: `TC-001, TC-002, TC-003, TC-004, TC-008, TC-009, TC-010` (happy paths)
- E2E: `TC-200` (cross-user access UI)
- E2E: `TC-103, TC-104` (refund eligibility)
- API: `TC-201, TC-202` (security 403)
- API: `TC-302` (insufficient seats)

**Tier 2 — P1, run in CI on every PR**
- API: `TC-100, TC-101, TC-400, TC-401` (FIFO pruning)
- API: `TC-110–115` (validation)
- API: `TC-203, TC-204, TC-205` (auth 401)
- API: `TC-301, TC-303–307` (error codes)
- Component: `TC-105, TC-500, TC-502, TC-507, TC-508, TC-509, TC-519`
- E2E: `TC-006, TC-309–312, TC-402–404, TC-501, TC-503–506, TC-511–518`

**Tier 3 — P2, run nightly or pre-release**
- Unit: `TC-405, TC-408, TC-409, TC-410`
- API: `TC-007, TC-106, TC-107, TC-407, TC-411–414`
- E2E: `TC-005, TC-109, TC-505, TC-510, TC-520`

---

## 7. Source File Map for Test Generation

| Layer | Test File Location | Key Source Files |
|---|---|---|
| Unit | `backend/src/services/__tests__/bookingService.test.js` | `bookingService.js` — `randomRef()`, `generateUniqueRef()` |
| API | `tests/api/bookings.api.spec.js` | `backend/src/routes/bookingRoutes.js`, `bookingValidator.js` |
| Component | `tests/components/booking-ui.spec.js` | `frontend/app/bookings/page.tsx`, `[id]/page.tsx` |
| E2E | `tests/booking-management.spec.js` | Full stack; use `rahulshetty1@gmail.com` / `rahulshetty1@yahoo.com` |

---

## Summary

**Total Scenarios**: 83
**Recommended Distribution**: Unit 5% | API 42% | Component 10% | E2E 43%
**Pyramid Shape**: ✅ Valid (wide base, narrow top)

**Current Gap**: API and Unit layers are empty — prioritize Tier 1 & 2

The existing E2E tests (TC-001, TC-002, TC-003, TC-006, TC-102) cover happy paths well. The critical gap is **API-layer security and validation tests** which should catch issues faster than E2E and provide defense-in-depth for business rules like FIFO pruning.
