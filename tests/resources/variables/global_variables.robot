*** Variables ***
# ── Environment Configuration ─────────────────────────────────────────────────
${BASE_URL}              https://eventhub.rahulshettyacademy.com
${BROWSER}               chrome
${TIMEOUT}               30s
${IMPLICIT_WAIT}         5s

# ── Test Account Credentials ──────────────────────────────────────────────────
# Credentials are passed via environment variables or command line
# For local runs: export TEST_EMAIL=your@email.com TEST_PASSWORD=yourpassword
# For CI: Set as GitHub Secrets (TEST_EMAIL, TEST_PASSWORD)
${TEST_EMAIL}            %{TEST_EMAIL=test@example.com}
${TEST_PASSWORD}         %{TEST_PASSWORD=placeholder}
${ALT_EMAIL}             %{ALT_EMAIL=alt@example.com}
${ALT_PASSWORD}          %{ALT_PASSWORD=placeholder}

# ── Page URLs ─────────────────────────────────────────────────────────────────
${LOGIN_URL}             ${BASE_URL}/login
${BOOKINGS_URL}          ${BASE_URL}/bookings
${EVENTS_URL}            ${BASE_URL}/events
