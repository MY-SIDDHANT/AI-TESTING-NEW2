*** Variables ***
# ── Environment Configuration ─────────────────────────────────────────────────
${BASE_URL}              https://eventhub.rahulshettyacademy.com
${BROWSER}               chrome
${TIMEOUT}               30s
${IMPLICIT_WAIT}         5s

# ── Test Account Credentials ──────────────────────────────────────────────────
${TEST_EMAIL}            rahulshetty1@yahoo.com
${TEST_PASSWORD}         Magiclife1!
${ALT_EMAIL}             rahulshetty1@gmail.com
${ALT_PASSWORD}          Magiclife1!

# ── Page URLs ─────────────────────────────────────────────────────────────────
${LOGIN_URL}             ${BASE_URL}/login
${BOOKINGS_URL}          ${BASE_URL}/bookings
${EVENTS_URL}            ${BASE_URL}/events
