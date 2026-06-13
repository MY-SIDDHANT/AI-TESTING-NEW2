# EventHub — Booking Management Test Scenarios

Generated: 2026-06-11
Scope: Booking Management (Flow 3 — Create Booking, Flow 4 — View, Cancel, Clear, Refund Eligibility)

---

## Happy Path

### TC-001: View bookings list with existing bookings
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in; user has at least one confirmed booking
**Steps**:
1. Navigate to `/bookings`
2. Observe the list of booking cards rendered
**Expected Results**: Each booking card displays booking reference, event name, quantity, total price, and "View Details" link
**Business Rule**: Flow 4 — Manage Bookings
**Suggested Layer**: E2E

---

### TC-002: View single booking detail page
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in; user has at least one confirmed booking
**Steps**:
1. Navigate to `/bookings`
2. Click "View Details" on any booking card
3. Observe the booking detail page at `/bookings/:id`
**Expected Results**: Page shows event details (title, date, venue, city, category), customer details (name, email, phone), payment summary (quantity, price per ticket, total paid), booking reference in breadcrumb and header, booking ID, and "Check eligibility for refund?" link
**Business Rule**: Booking model fields; Flow 4
**Suggested Layer**: E2E

---

### TC-003: Cancel a single booking from the detail page
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in; user has at least one confirmed booking
**Steps**:
1. Navigate to `/bookings/:id`
2. Click "Cancel Booking" button
3. Confirm in the dialog by clicking "Yes, cancel it"
4. Observe redirect and bookings list
**Expected Results**: Success toast "Booking cancelled successfully" appears; user is redirected to `/bookings`; cancelled booking no longer appears in the list
**Business Rule**: Booking cancellation deletes the record; seats released for dynamic events
**Suggested Layer**: E2E

---

### TC-004: Clear all bookings from the bookings list page
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in; user has at least one booking
**Steps**:
1. Navigate to `/bookings`
2. Click "Clear all bookings" link
3. Confirm the browser confirm dialog
4. Observe the page after clearing
**Expected Results**: All bookings are removed; page shows empty state "No bookings yet" with "Browse Events" button
**Business Rule**: `DELETE /api/bookings` clears all user bookings; `clearAllBookings` service method
**Suggested Layer**: E2E

---

### TC-005: Navigate back to bookings list from detail page
**Category**: Happy Path
**Priority**: P2
**Preconditions**: User is on a booking detail page
**Steps**:
1. Click "← Back to My Bookings" button at bottom of detail page
**Expected Results**: User is navigated to `/bookings`
**Business Rule**: UI navigation flow
**Suggested Layer**: E2E

---

### TC-006: Navigate to bookings via "View My Bookings" after completing a booking
**Category**: Happy Path
**Priority**: P1
**Preconditions**: User just completed a booking (confirmation card shown)
**Steps**:
1. After booking confirmation, click "View My Bookings" link
2. Observe the bookings page
**Expected Results**: User lands on `/bookings` and the newly created booking appears in the list
**Business Rule**: Flow 3 → Flow 4 navigation
**Suggested Layer**: E2E

---

### TC-007: Lookup booking by reference via API
**Category**: Happy Path
**Priority**: P1
**Preconditions**: User is authenticated; user has a booking with known `bookingRef`
**Steps**:
1. Send `GET /api/bookings/ref/:ref` with valid JWT and own booking ref
**Expected Results**: 200 response with full booking data including nested event
**Business Rule**: `GET /api/bookings/ref/:ref` endpoint
**Suggested Layer**: API

---

### TC-008: Create a booking for a static event (E2E)
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in; static events exist (seeded)
**Steps**:
1. Navigate to `/events`
2. Click "Book Now" on any static event card (e.g., "Tech Conference Bangalore")
3. Verify landing on `/events/:id` with event details displayed
4. Note available seats count
5. Select quantity using +/- buttons (e.g., 2 tickets)
6. Fill Full Name (min 2 chars)
7. Fill Email (valid format)
8. Fill Phone Number (min 10 digits)
9. Click "Confirm Booking"
10. Observe confirmation card
**Expected Results**: Confirmation card shows "Booking Confirmed! 🎉"; booking reference displayed (starting with event title's first letter); customer name, quantity, and total price shown; "View My Bookings" and "Browse More Events" buttons visible
**Business Rule**: Flow 3 — Book an Event; Rule 7 — Booking ref format
**Suggested Layer**: E2E

---

### TC-009: Booking reduces available seats on the event detail page
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in; event has known available seats
**Steps**:
1. Navigate to `/events/:id` and note available seats
2. Complete a booking for 3 tickets
3. Navigate back to the same event detail page
4. Check available seats count
**Expected Results**: Available seats reduced by 3 (the booked quantity)
**Business Rule**: Rule 6 — Seat count reduces immediately on booking confirmation
**Suggested Layer**: E2E

---

### TC-010: Complete booking flow and verify in bookings list
**Category**: Happy Path
**Priority**: P0
**Preconditions**: User is logged in
**Steps**:
1. Book an event and note the booking reference
2. Click "View My Bookings" on confirmation card
3. Locate the booking card with the noted reference
**Expected Results**: New booking appears in the list with correct event name, quantity, total price, and booking reference
**Business Rule**: Flow 3 → Flow 4 integration
**Suggested Layer**: E2E

---

## Business Rules

### TC-100: FIFO pruning — 10th booking replaces oldest booking from a different event
**Category**: Business Rule
**Priority**: P0
**Preconditions**: User has exactly 9 bookings (all for different events); user has JWT token
**Steps**:
1. Note the oldest booking ID
2. Create a new booking (10th) for a different event via `POST /api/bookings`
3. Retrieve all user bookings
**Expected Results**: Total booking count remains 9; the oldest booking is deleted; the new booking is present
**Business Rule**: Max 9 bookings per user; FIFO pruning prefers deleting from a different event
**Suggested Layer**: API

---

### TC-101: FIFO pruning — same-event fallback permanently burns a seat
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User has exactly 9 bookings all for the SAME event; enough seats remain
**Steps**:
1. Create a 10th booking for the same event
2. Retrieve the event's available seats
**Expected Results**: Oldest booking is deleted; new booking is created; `availableSeats` decremented by the new booking's quantity (seat permanently burned via `decrementSeats`)
**Business Rule**: `sameEventFallback` path in `bookingService.createBooking`
**Suggested Layer**: API

---

### TC-102: Booking reference first character matches event title first character
**Category**: Business Rule
**Priority**: P0
**Preconditions**: User is logged in; event with known title exists (e.g., "Tech Conference Bangalore")
**Steps**:
1. Book the event
2. Read the `bookingRef` from the confirmation card or API response
**Expected Results**: `bookingRef` starts with the uppercase first character of the event title (e.g., "T-XXXXXX" for "Tech Conference")
**Business Rule**: `randomRef` function: prefix = `eventTitle[0].toUpperCase()`; Rule 7
**Suggested Layer**: E2E / API

---

### TC-103: Refund eligibility — single ticket booking is eligible
**Category**: Business Rule
**Priority**: P0
**Preconditions**: User has a booking with quantity = 1
**Steps**:
1. Navigate to `/bookings/:id` for the single-ticket booking
2. Click "Check eligibility for refund?"
3. Wait for spinner to disappear (4 seconds)
4. Read the refund result
**Expected Results**: `#refund-result` shows green "Eligible for refund. Single-ticket bookings qualify for a full refund."
**Business Rule**: Rule 8 — quantity === 1 → eligible
**Suggested Layer**: E2E

---

### TC-104: Refund eligibility — multi-ticket booking is NOT eligible
**Category**: Business Rule
**Priority**: P0
**Preconditions**: User has a booking with quantity > 1 (e.g., 3 tickets)
**Steps**:
1. Navigate to `/bookings/:id` for the multi-ticket booking
2. Click "Check eligibility for refund?"
3. Wait for spinner to disappear (4 seconds)
4. Read the refund result
**Expected Results**: `#refund-result` shows red "Not eligible for refund. Group bookings (3 tickets) are non-refundable." with correct quantity displayed
**Business Rule**: Rule 8 — quantity > 1 → not eligible
**Suggested Layer**: E2E

---

### TC-105: Refund eligibility spinner shows for approximately 4 seconds
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User is on a booking detail page
**Steps**:
1. Click "Check eligibility for refund?"
2. Immediately check for spinner
3. Observe when spinner disappears and result appears
**Expected Results**: `#refund-spinner` is visible immediately after clicking; spinner disappears and `#refund-result` appears after ~4 seconds
**Business Rule**: Rule 8 — `setTimeout(..., 4000)` in `RefundEligibility` component
**Suggested Layer**: E2E / Component

---

### TC-106: Total price is calculated as price × quantity
**Category**: Business Rule
**Priority**: P0
**Preconditions**: User books an event with known price
**Steps**:
1. Book an event (e.g., price $1499, quantity 3)
2. View the booking detail page
**Expected Results**: "Total Paid" shows $4,497 (1499 × 3); `totalPrice` in API response equals `event.price × quantity`
**Business Rule**: Rule 9 — `totalPrice = event.price × quantity`
**Suggested Layer**: E2E / API

---

### TC-107: Bookings page shows max 10 bookings per page (pagination)
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User has more than 10 bookings visible in DB (unlikely with limit 9, but relevant for API pagination param)
**Steps**:
1. Send `GET /api/bookings?page=1&limit=10`
**Expected Results**: Response includes `pagination.limit = 10`, `pagination.totalPages`, and `data` array with at most 10 items
**Business Rule**: Rule 4 — max 9 bookings per user; API default limit = 10
**Suggested Layer**: API

---

### TC-108: Cancelling a booking releases seat count for dynamic events (computed)
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User has a dynamic (user-created) event with a booking
**Steps**:
1. Note the current available seats for the event (computed: totalSeats - booked quantities)
2. Cancel the booking for that event
3. Re-fetch the event detail
**Expected Results**: Available seats increase by the cancelled booking's quantity
**Business Rule**: Rule 6 — dynamic events compute seats as `totalSeats - sum(user's booking quantities)`; cancellation removes the booking record
**Suggested Layer**: API / E2E

---

### TC-109: Bookings list shows "Clear all bookings" button whenever bookings exist
**Category**: Business Rule
**Priority**: P2
**Preconditions**: User has at least one booking
**Steps**:
1. Navigate to `/bookings`
2. Look for "Clear all bookings" link
**Expected Results**: "Clear all bookings" link is visible in the top-right of the page header
**Business Rule**: Flow 4 — UI always shows clear option when bookings exist
**Suggested Layer**: E2E / Component

---

### TC-110: Customer name validation — minimum 2 characters required
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `customerName: "A"` (1 character)
**Expected Results**: HTTP 400; validation error "Customer name must be at least 2 characters"
**Business Rule**: `validateCreateBooking` — `isLength({ min: 2 })`
**Suggested Layer**: API

---

### TC-111: Customer email validation — must be valid email format
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `customerEmail: "notanemail"`
**Expected Results**: HTTP 400; validation error "Customer email must be a valid email address"
**Business Rule**: `validateCreateBooking` — `isEmail()`
**Suggested Layer**: API

---

### TC-112: Customer phone validation — minimum 10 digits required
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `customerPhone: "12345"` (5 digits)
**Expected Results**: HTTP 400; validation error "Customer phone must be at least 10 digits"
**Business Rule**: `validateCreateBooking` — `isLength({ min: 10 })`
**Suggested Layer**: API

---

### TC-113: Customer phone validation — only allows digits and valid characters
**Category**: Business Rule
**Priority**: P2
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `customerPhone: "abc1234567890"`
**Expected Results**: HTTP 400; validation error "Customer phone must contain only digits and +, -, spaces, or parentheses"
**Business Rule**: `validateCreateBooking` — `matches(/^[0-9+\-\s()]+$/)`
**Suggested Layer**: API

---

### TC-114: Booking status is always "confirmed" upon creation
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User creates a booking via API
**Steps**:
1. Send `POST /api/bookings` with valid data
2. Check the response `status` field
**Expected Results**: `status` is always "confirmed"; no other status values possible on creation
**Business Rule**: `bookingService.createBooking` — hardcoded `status: 'confirmed'`
**Suggested Layer**: API

---

### TC-115: Booking quantity is an integer between 1 and 10 (inclusive)
**Category**: Business Rule
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `quantity: 1` → expect success
2. Send `POST /api/bookings` with `quantity: 10` → expect success
3. Send `POST /api/bookings` with `quantity: 1.5` → expect failure
**Expected Results**: Integer values 1-10 succeed; non-integer or out-of-range values return 400
**Business Rule**: `validateCreateBooking` — `isInt({ min: 1, max: 10 })`
**Suggested Layer**: API

---

## Security

### TC-200: Cross-user booking access returns "Access Denied" (UI)
**Category**: Security
**Priority**: P0
**Preconditions**: Two test accounts exist (rahulshetty1@gmail.com and rahulshetty1@yahoo.com); User A has a booking
**Steps**:
1. Log in as User A, create a booking, note the booking ID
2. Log out (clear localStorage JWT)
3. Log in as User B
4. Navigate to `/bookings/:userA_booking_id`
**Expected Results**: Page shows "Access Denied" title and "You are not authorized to view this booking." description
**Business Rule**: Rule 2 — cross-user access returns 403; frontend renders "Access Denied" on 403 response
**Suggested Layer**: E2E

---

### TC-201: Cross-user booking access returns 403 via API
**Category**: Security
**Priority**: P0
**Preconditions**: User A has a booking; User B has a valid JWT
**Steps**:
1. Send `GET /api/bookings/:userA_booking_id` with User B's JWT
**Expected Results**: HTTP 403; response body contains "You are not authorized to view this booking"
**Business Rule**: `bookingService.getBookingById` — `booking.userId !== userId` → ForbiddenError
**Suggested Layer**: API

---

### TC-202: Cross-user booking cancellation returns 403 via API
**Category**: Security
**Priority**: P0
**Preconditions**: User A has a booking; User B has a valid JWT
**Steps**:
1. Send `DELETE /api/bookings/:userA_booking_id` with User B's JWT
**Expected Results**: HTTP 403; booking is NOT deleted from the database
**Business Rule**: `bookingService.cancelBooking` — `booking.userId !== userId` → ForbiddenError
**Suggested Layer**: API

---

### TC-203: Unauthenticated access to bookings list returns 401
**Category**: Security
**Priority**: P0
**Preconditions**: No valid JWT
**Steps**:
1. Send `GET /api/bookings` without Authorization header
**Expected Results**: HTTP 401; "Unauthorized" error message
**Business Rule**: Auth middleware on all `/api/bookings` routes
**Suggested Layer**: API

---

### TC-204: Unauthenticated access to booking detail returns 401
**Category**: Security
**Priority**: P0
**Preconditions**: No valid JWT
**Steps**:
1. Send `GET /api/bookings/:id` without Authorization header
**Expected Results**: HTTP 401; "Unauthorized" error message
**Business Rule**: Auth middleware
**Suggested Layer**: API

---

### TC-205: Unauthenticated DELETE /api/bookings returns 401
**Category**: Security
**Priority**: P0
**Preconditions**: No valid JWT
**Steps**:
1. Send `DELETE /api/bookings` without Authorization header
**Expected Results**: HTTP 401
**Business Rule**: Auth middleware; `clearAllBookings` requires authenticated user
**Suggested Layer**: API

---

### TC-206: Cross-user booking lookup by ref returns 403
**Category**: Security
**Priority**: P1
**Preconditions**: User A has a booking with known ref; User B has a valid JWT
**Steps**:
1. Send `GET /api/bookings/ref/:userA_ref` with User B's JWT
**Expected Results**: HTTP 403; "You do not own this booking"
**Business Rule**: `bookingService.getBookingByRef` — ownership check
**Suggested Layer**: API

---

## Negative / Error

### TC-300: Navigate to non-existent booking ID shows "Booking not found"
**Category**: Negative
**Priority**: P1
**Preconditions**: User is logged in
**Steps**:
1. Navigate to `/bookings/99999` (ID that does not exist)
**Expected Results**: Page shows "Booking not found" and "This booking doesn't exist or may have been cancelled." with "View My Bookings" button
**Business Rule**: `bookingService.getBookingById` throws NotFoundError → API returns 404; frontend renders not-found empty state
**Suggested Layer**: E2E

---

### TC-301: GET /api/bookings/:id with non-existent ID returns 404
**Category**: Negative
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `GET /api/bookings/99999` with valid JWT
**Expected Results**: HTTP 404; error message "Booking with id 99999 not found"
**Business Rule**: `bookingService.getBookingById` — NotFoundError
**Suggested Layer**: API

---

### TC-302: Create booking with insufficient seats returns 400
**Category**: Negative
**Priority**: P0
**Preconditions**: User is authenticated; event has 0 personal available seats (all booked by this user)
**Steps**:
1. Send `POST /api/bookings` with `quantity: 1` for a fully-booked event
**Expected Results**: HTTP 400; "Only 0 seat(s) available, but 1 requested"
**Business Rule**: `bookingService.createBooking` — `InsufficientSeatsError` when `personalAvailable < quantity`
**Suggested Layer**: API

---

### TC-303: Create booking for non-existent event returns 404
**Category**: Negative
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `eventId: 99999`
**Expected Results**: HTTP 404; "Event with id 99999 not found"
**Business Rule**: `bookingService.createBooking` — event lookup fails → NotFoundError
**Suggested Layer**: API

---

### TC-304: Create booking with missing required fields returns 400
**Category**: Negative
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with missing `customerName`, `customerEmail`, or `customerPhone`
**Expected Results**: HTTP 400; validation error message listing missing fields
**Business Rule**: Input validators on the bookings route
**Suggested Layer**: API

---

### TC-305: Create booking with quantity = 0 or negative returns 400
**Category**: Negative
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `quantity: 0`
2. Send `POST /api/bookings` with `quantity: -1`
**Expected Results**: HTTP 400; validation error for both cases
**Business Rule**: quantity must be 1–10 per booking model
**Suggested Layer**: API

---

### TC-306: Create booking with quantity > 10 returns 400
**Category**: Negative
**Priority**: P1
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `quantity: 11`
**Expected Results**: HTTP 400; validation error
**Business Rule**: quantity must be 1–10
**Suggested Layer**: API

---

### TC-307: Cancel a booking that has already been cancelled returns 404
**Category**: Negative
**Priority**: P1
**Preconditions**: User is authenticated; a booking exists
**Steps**:
1. Delete the booking via `DELETE /api/bookings/:id`
2. Attempt to delete the same booking again
**Expected Results**: HTTP 404; "Booking with id X not found"
**Business Rule**: `cancelBooking` uses `bookingRepository.findById` — not found after deletion
**Suggested Layer**: API

---

### TC-308: Bookings page shows error state when server is unreachable
**Category**: Negative
**Priority**: P2
**Preconditions**: Backend server is down or returns 500
**Steps**:
1. Navigate to `/bookings` with backend unavailable
**Expected Results**: Error empty state renders: "Couldn't load bookings", "Failed to connect to the server. Please try again.", and a "Retry" button
**Business Rule**: `isError` branch in `BookingsContent` component
**Suggested Layer**: Component / E2E

---

### TC-309: Create booking with invalid email format shows client-side validation error
**Category**: Negative
**Priority**: P1
**Preconditions**: User is on event detail booking form
**Steps**:
1. Fill customer name and phone with valid values
2. Enter invalid email (e.g., "notanemail")
3. Click "Confirm Booking"
**Expected Results**: Form does not submit; email field shows error "Enter a valid email"
**Business Rule**: Client-side validation in `BookingForm.validate()`
**Suggested Layer**: E2E

---

### TC-310: Create booking with short customer name shows client-side validation error
**Category**: Negative
**Priority**: P1
**Preconditions**: User is on event detail booking form
**Steps**:
1. Enter customer name with only 1 character
2. Fill email and phone with valid values
3. Click "Confirm Booking"
**Expected Results**: Form does not submit; name field shows error "Name must be at least 2 chars"
**Business Rule**: Client-side validation in `BookingForm.validate()`
**Suggested Layer**: E2E

---

### TC-311: Create booking with invalid phone number shows client-side validation error
**Category**: Negative
**Priority**: P1
**Preconditions**: User is on event detail booking form
**Steps**:
1. Fill name and email with valid values
2. Enter phone number with fewer than 10 digits (e.g., "12345")
3. Click "Confirm Booking"
**Expected Results**: Form does not submit; phone field shows error "Enter a valid 10-digit phone"
**Business Rule**: Client-side validation in `BookingForm.validate()`
**Suggested Layer**: E2E

---

### TC-312: Booking attempt for sold-out event shows sold-out UI state
**Category**: Negative
**Priority**: P1
**Preconditions**: Event has 0 available seats
**Steps**:
1. Navigate to event detail page for sold-out event
2. Observe the booking form state
**Expected Results**: Form indicates sold-out state; confirm button may be disabled or show appropriate messaging
**Business Rule**: `soldOut = event.availableSeats === 0` in `BookingForm`
**Suggested Layer**: E2E

---

## Edge Cases

### TC-400: Exactly 9 bookings — adding a 10th prunes oldest from a DIFFERENT event (preferred)
**Category**: Edge Case
**Priority**: P0
**Preconditions**: User has exactly 9 bookings across multiple events
**Steps**:
1. Note the ID of the oldest booking (different event from the new booking's event)
2. Create a new (10th) booking for Event X
3. Check the bookings list
**Expected Results**: Count stays at 9; oldest booking (different event) is gone; new booking is present
**Business Rule**: `findOldestUserBookingExcludingEvent` preferential pruning in `bookingService.createBooking`
**Suggested Layer**: API

---

### TC-401: Exactly 9 bookings all from same event — 10th triggers same-event fallback and burns seat
**Category**: Edge Case
**Priority**: P1
**Preconditions**: User has 9 bookings all for Event X
**Steps**:
1. Create a new booking for Event X (10th)
2. Re-fetch Event X's available seats
**Expected Results**: Oldest booking removed; new booking created; `availableSeats` is permanently decremented by the new quantity (seat burned via `eventRepository.decrementSeats`)
**Business Rule**: `sameEventFallback = true` → `decrementSeats` called in `bookingService.createBooking`
**Suggested Layer**: API

---

### TC-402: Booking with quantity = 1 (minimum) — full happy path
**Category**: Edge Case
**Priority**: P1
**Preconditions**: User is logged in; event has available seats
**Steps**:
1. Navigate to event detail page
2. Leave quantity at 1 (default minimum)
3. Fill customer form and confirm booking
**Expected Results**: Booking created with `quantity: 1`; `totalPrice = price × 1`; booking ref generated
**Business Rule**: quantity boundary: 1 is minimum
**Suggested Layer**: E2E

---

### TC-403: Booking with quantity = 10 (maximum)
**Category**: Edge Case
**Priority**: P1
**Preconditions**: User is logged in; event has >= 10 available seats
**Steps**:
1. Navigate to event detail; click "+" 9 times to reach quantity 10
2. Fill form and confirm booking
**Expected Results**: Booking created with `quantity: 10`; `totalPrice = price × 10`; increment button disabled at 10
**Business Rule**: quantity boundary: 10 is maximum; UI should prevent going above 10
**Suggested Layer**: E2E

---

### TC-404: Refund eligibility boundary — quantity = 2 is NOT eligible (just above threshold)
**Category**: Edge Case
**Priority**: P1
**Preconditions**: User has a booking with quantity = 2
**Steps**:
1. Navigate to booking detail
2. Click "Check eligibility for refund?"
3. Wait 4 seconds
**Expected Results**: Result shows "Not eligible for refund. Group bookings (2 tickets) are non-refundable."
**Business Rule**: Rule 8 — threshold is quantity === 1; quantity = 2 is the first ineligible value
**Suggested Layer**: E2E

---

### TC-405: Booking reference uniqueness — collision retry mechanism
**Category**: Edge Case
**Priority**: P2
**Preconditions**: Many bookings exist with the same event title prefix (stress scenario)
**Steps**:
1. Create many bookings for events starting with the same letter
2. Verify each `bookingRef` is unique in DB
**Expected Results**: All booking references are unique; no duplicates; fallback timestamp-based ref used after 10 failed attempts
**Business Rule**: `generateUniqueRef` — up to 10 retries, then timestamp fallback
**Suggested Layer**: Unit

---

### TC-406: Clear all bookings when only one booking exists
**Category**: Edge Case
**Priority**: P2
**Preconditions**: User has exactly 1 booking
**Steps**:
1. Navigate to `/bookings`
2. Click "Clear all bookings" and confirm
**Expected Results**: Booking is deleted; page shows empty state; `DELETE /api/bookings` returns `{ deleted: 1 }`
**Business Rule**: `clearAllBookings` — `deleteAllForUser` returns count of deleted records
**Suggested Layer**: E2E / API

---

### TC-407: Pagination on bookings list (API) — page 2 with partial results
**Category**: Edge Case
**Priority**: P2
**Preconditions**: User has more than the default page limit of bookings visible in API
**Steps**:
1. Send `GET /api/bookings?page=2&limit=5`
**Expected Results**: Returns page 2 results; `pagination.page = 2`; `data` array contains at most 5 items
**Business Rule**: Pagination behavior in `bookingService.getBookings`
**Suggested Layer**: API

---

### TC-408: Event title starting with a number — booking ref prefix is uppercase of that character
**Category**: Edge Case
**Priority**: P2
**Preconditions**: An event exists whose title starts with a digit (e.g., "100 Days Festival")
**Steps**:
1. Book the event
2. Check the `bookingRef`
**Expected Results**: `bookingRef` starts with "1-XXXXXX" (digit is used as-is, `toUpperCase()` has no effect on digits)
**Business Rule**: `randomRef` — `prefix = (eventTitle?.[0] ?? 'E').toUpperCase()`
**Suggested Layer**: API / Unit

---

### TC-409: Booking for event with special characters in title
**Category**: Edge Case
**Priority**: P2
**Preconditions**: An event exists whose title starts with a special character or has special chars (e.g., "@Tech Summit")
**Steps**:
1. Book the event
2. Check the `bookingRef`
**Expected Results**: `bookingRef` starts with "@-XXXXXX" (special char used as-is after toUpperCase)
**Business Rule**: `randomRef` — no filtering of special characters from prefix
**Suggested Layer**: API / Unit

---

### TC-410: Event with empty title fallback — booking ref uses "E" prefix
**Category**: Edge Case
**Priority**: P3
**Preconditions**: Hypothetically an event with empty title (edge case in code)
**Steps**:
1. Create a booking for an event where title is empty/null (requires direct DB manipulation)
2. Check the `bookingRef`
**Expected Results**: `bookingRef` starts with "E-XXXXXX" (fallback default)
**Business Rule**: `randomRef` — `prefix = (eventTitle?.[0] ?? 'E').toUpperCase()`
**Suggested Layer**: Unit

---

### TC-411: Booking quantity exactly equals available seats
**Category**: Edge Case
**Priority**: P1
**Preconditions**: Event has exactly 5 available seats
**Steps**:
1. Book 5 tickets for the event
**Expected Results**: Booking succeeds; available seats become 0 after booking
**Business Rule**: Rule 6 — seat availability check allows exact match
**Suggested Layer**: E2E / API

---

### TC-412: Multiple sequential bookings by same user for same event
**Category**: Edge Case
**Priority**: P1
**Preconditions**: User is logged in; event has sufficient seats
**Steps**:
1. Create booking #1 for Event X (2 tickets)
2. Create booking #2 for Event X (3 tickets)
3. Check total booked quantity and available seats
**Expected Results**: Both bookings created successfully; available seats reduced by total (5); user has two separate booking records for same event
**Business Rule**: Rule 6 — Same user can book same event multiple times for testing
**Suggested Layer**: API / E2E

---

### TC-413: Booking phone number with international format (+91, spaces, dashes)
**Category**: Edge Case
**Priority**: P2
**Preconditions**: User is authenticated
**Steps**:
1. Send `POST /api/bookings` with `customerPhone: "+91 98765-43210"`
**Expected Results**: Booking created successfully; phone stored with formatting preserved
**Business Rule**: `validateCreateBooking` — regex allows `+`, `-`, spaces, parentheses
**Suggested Layer**: API

---

### TC-414: Booking with maximum length customer name
**Category**: Edge Case
**Priority**: P3
**Preconditions**: User is authenticated
**Steps**:
1. Create booking with very long customer name (200+ chars)
**Expected Results**: Booking created successfully (no max length validation in current code)
**Business Rule**: No upper limit on customerName in validators
**Suggested Layer**: API

---

## UI State

### TC-500: Bookings list shows skeleton loading state while fetching
**Category**: UI State
**Priority**: P1
**Preconditions**: User navigates to `/bookings` (slow network or first load)
**Steps**:
1. Navigate to `/bookings` with throttled network
2. Observe the page before data loads
**Expected Results**: 5 `BookingCardSkeleton` placeholders are shown while `isLoading = true`; no real booking data yet
**Business Rule**: `isLoading` branch in `BookingsContent`
**Suggested Layer**: Component / E2E

---

### TC-501: Bookings list shows empty state when user has no bookings
**Category**: UI State
**Priority**: P1
**Preconditions**: User is logged in with zero bookings
**Steps**:
1. Navigate to `/bookings`
**Expected Results**: Empty state renders with "No bookings yet", "You haven't booked any events yet..." description, and "Browse Events" button linking to `/events`
**Business Rule**: `bookings.length === 0` branch in `BookingsContent`
**Suggested Layer**: E2E / Component

---

### TC-502: Booking detail page shows loading spinner while fetching
**Category**: UI State
**Priority**: P2
**Preconditions**: User navigates to `/bookings/:id` on slow network
**Steps**:
1. Navigate to `/bookings/:id` with throttled network
2. Observe the page before data loads
**Expected Results**: Full-screen spinner (`Spinner size="lg"`) is visible while `isLoading = true`
**Business Rule**: `isLoading` branch in `BookingDetailPage`
**Suggested Layer**: Component

---

### TC-503: Cancel booking confirmation dialog appears before deletion
**Category**: UI State
**Priority**: P0
**Preconditions**: User is on a booking detail page
**Steps**:
1. Click "Cancel Booking" button
2. Observe dialog
**Expected Results**: `ConfirmDialog` appears with title "Cancel this booking?", description mentioning the booking ref and seat count, "Yes, cancel it" and close buttons
**Business Rule**: Two-step confirmation prevents accidental cancellations
**Suggested Layer**: E2E / Component

---

### TC-504: Cancel booking dialog close without confirming does NOT cancel
**Category**: UI State
**Priority**: P1
**Preconditions**: User is on a booking detail page
**Steps**:
1. Click "Cancel Booking"
2. Click the close/dismiss button on the dialog (not "Yes, cancel it")
3. Observe booking status
**Expected Results**: Dialog closes; booking remains in the list; no API call made
**Business Rule**: `onClose` sets `confirm = false`; `handleCancel` only runs on confirm
**Suggested Layer**: E2E

---

### TC-505: Booking detail breadcrumb displays the booking reference
**Category**: UI State
**Priority**: P2
**Preconditions**: User navigates to a valid booking detail page
**Steps**:
1. Navigate to `/bookings/:id`
2. Observe the breadcrumb nav at the top
**Expected Results**: Breadcrumb shows "My Bookings / {bookingRef}" where bookingRef is in monospace font
**Business Rule**: Breadcrumb uses `booking.bookingRef`
**Suggested Layer**: E2E

---

### TC-506: Cancel booking success — toast and redirect
**Category**: UI State
**Priority**: P0
**Preconditions**: User confirms booking cancellation
**Steps**:
1. Confirm cancellation in the dialog
2. Observe page transition and notifications
**Expected Results**: Success toast "Booking cancelled successfully" appears; user is redirected to `/bookings`
**Business Rule**: `onSuccess` callback in `handleCancel`
**Suggested Layer**: E2E

---

### TC-507: "Clear all bookings" button shows "Clearing..." while in progress
**Category**: UI State
**Priority**: P2
**Preconditions**: User has bookings; network is slow
**Steps**:
1. Click "Clear all bookings" and confirm dialog
2. Observe the button state while request is in flight
**Expected Results**: Button text changes to "Clearing…" and is disabled (`disabled:opacity-50`) during the API call
**Business Rule**: `clearing` state variable in `BookingsContent`
**Suggested Layer**: Component / E2E

---

### TC-508: Refund eligibility — "Check eligibility" button hidden after result shown
**Category**: UI State
**Priority**: P2
**Preconditions**: User is on a booking detail page in idle refund state
**Steps**:
1. Click "Check eligibility for refund?"
2. Wait for result to appear
**Expected Results**: After status transitions from "idle" → "checking" → "eligible/ineligible", the initial button is no longer visible; spinner replaces it during check; result card replaces spinner after 4 seconds
**Business Rule**: `RefundEligibility` component status state machine: idle → checking → eligible/ineligible
**Suggested Layer**: E2E / Component

---

### TC-509: Booking detail shows "Access Denied" state for 403 errors
**Category**: UI State
**Priority**: P0
**Preconditions**: Another user's booking ID is known
**Steps**:
1. Log in as User B
2. Navigate to `/bookings/:userA_booking_id`
3. Observe the rendered state
**Expected Results**: `EmptyState` with title "Access Denied" and description "You are not authorized to view this booking." renders (not "Booking not found")
**Business Rule**: Frontend checks `error.status === 403` to differentiate Access Denied vs Not Found
**Suggested Layer**: E2E

---

### TC-510: Bookings page pagination UI renders when total exceeds page size
**Category**: UI State
**Priority**: P2
**Preconditions**: API returns `pagination.totalPages > 1`
**Steps**:
1. Navigate to `/bookings` with enough bookings to trigger multi-page response
2. Observe pagination controls
**Expected Results**: `Pagination` component renders with correct `currentPage` and `totalPages`; clicking next page updates URL `?page=N` and loads next page of bookings
**Business Rule**: Pagination in `BookingsContent` driven by `pagination` from API response
**Suggested Layer**: E2E / Component

---

### TC-511: Booking form — increment button disabled at maximum quantity
**Category**: UI State
**Priority**: P1
**Preconditions**: User is on event detail booking form; event has >= 10 available seats
**Steps**:
1. Click "+" button to reach quantity 10
2. Attempt to click "+" again
**Expected Results**: "+" button is disabled (`disabled:opacity-40`); quantity stays at 10; `(max 10)` label visible
**Business Rule**: `maxQty = Math.min(10, event.availableSeats)`; button disabled when `quantity >= maxQty`
**Suggested Layer**: E2E

---

### TC-512: Booking form — decrement button disabled at minimum quantity (1)
**Category**: UI State
**Priority**: P1
**Preconditions**: User is on event detail booking form
**Steps**:
1. Observe default quantity (1)
2. Attempt to click "-" button
**Expected Results**: "-" button is disabled; quantity stays at 1
**Business Rule**: Button disabled when `quantity <= 1`
**Suggested Layer**: E2E

---

### TC-513: Booking form — max quantity limited by available seats
**Category**: UI State
**Priority**: P1
**Preconditions**: Event has only 3 available seats
**Steps**:
1. Navigate to event detail page
2. Try to increment quantity to 4
**Expected Results**: "+" button disabled at 3; `(max 3)` label shown; user cannot select more tickets than available
**Business Rule**: `maxQty = Math.min(10, event.availableSeats)`
**Suggested Layer**: E2E

---

### TC-514: Booking form — price summary updates dynamically with quantity
**Category**: UI State
**Priority**: P1
**Preconditions**: User is on event detail booking form for an event priced at $100
**Steps**:
1. Default quantity = 1, observe total = $100
2. Increment to 2, observe total
3. Increment to 5, observe total
**Expected Results**: Total updates immediately: 1×$100=$100, 2×$100=$200, 5×$100=$500
**Business Rule**: Rule 9 — `total = parseFloat(event.price) × form.quantity`
**Suggested Layer**: E2E

---

### TC-515: Booking confirmation card displays all booking details
**Category**: UI State
**Priority**: P0
**Preconditions**: User just completed a booking
**Steps**:
1. Complete a booking and observe the confirmation card
**Expected Results**: Card shows: success icon with checkmark, "Booking Confirmed! 🎉" heading, booking reference in indigo monospace font, customer name, ticket quantity, formatted total price
**Business Rule**: `BookingConfirmation` component displays `booking.data` fields
**Suggested Layer**: E2E

---

### TC-516: Booking detail page — event details section shows complete information
**Category**: UI State
**Priority**: P1
**Preconditions**: User navigates to a booking detail page
**Steps**:
1. Navigate to `/bookings/:id`
2. Locate "Event Details" section
**Expected Results**: Section displays: Event title, Category, Date (formatted), Venue, City
**Business Rule**: `DetailSection` component with event fields
**Suggested Layer**: E2E

---

### TC-517: Booking detail page — customer details section shows submitted info
**Category**: UI State
**Priority**: P1
**Preconditions**: User navigates to a booking detail page
**Steps**:
1. Navigate to `/bookings/:id`
2. Locate "Customer Details" section
**Expected Results**: Section displays: Name, Email, Phone as submitted during booking
**Business Rule**: `booking.customerName`, `booking.customerEmail`, `booking.customerPhone`
**Suggested Layer**: E2E

---

### TC-518: Booking detail page — payment summary shows breakdown
**Category**: UI State
**Priority**: P1
**Preconditions**: User navigates to a booking detail page for a 3-ticket booking at $100/ticket
**Steps**:
1. Navigate to `/bookings/:id`
2. Locate "Payment Summary" section
**Expected Results**: Shows "Tickets: 3", "Price per ticket: $100", "Total Paid: $300" (highlighted in indigo)
**Business Rule**: Payment calculation display
**Suggested Layer**: E2E

---

### TC-519: Booking form — loading state during submission
**Category**: UI State
**Priority**: P2
**Preconditions**: User fills booking form and submits
**Steps**:
1. Fill form and click "Confirm Booking"
2. Observe button state during API call
**Expected Results**: Button shows loading state (`isPending` from `useCreateBooking`)
**Business Rule**: `isPending` state from mutation hook
**Suggested Layer**: Component

---

### TC-520: Event detail page — shows event title, date, venue, price, and available seats
**Category**: UI State
**Priority**: P0
**Preconditions**: User navigates to an event detail page
**Steps**:
1. Navigate to `/events/:id`
2. Observe event information displayed
**Expected Results**: Page shows event title as heading, category badge, formatted date and time, venue and city, price per ticket, available seats count
**Business Rule**: Event model display on booking page
**Suggested Layer**: E2E
