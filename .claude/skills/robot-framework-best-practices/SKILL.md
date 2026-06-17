# Robot Framework + Selenium Test Automation Best Practices for EventHub

> **Authored by:** Senior Automation Architect (20 YOE)
> **Stack:** Robot Framework 6.x · SeleniumLibrary 6.x · Python 3.11+
> **Mirrors:** `playwright-best-practices.md` — same structure, RF/Selenium idioms

---

## 1. Project Test Setup

### Directory Structure
```
tests/
├── resources/
│   ├── keywords/
│   │   ├── common_keywords.robot
│   │   ├── event_keywords.robot
│   │   └── booking_keywords.robot
│   ├── pages/
│   │   ├── LoginPage.robot
│   │   ├── EventsPage.robot
│   │   └── BookingsPage.robot
│   ├── variables/
│   │   └── global_variables.robot
│   └── test_data/
│       └── mock_responses.py
├── booking_flow.robot
├── cross_user_booking.robot
└── event_management.robot
```

### `robot.yaml` / `pyproject.toml` Reference
```yaml
# robot.yaml (rcc-compatible)
tasks:
  run-tests:
    shell: python -m robot --outputdir results tests/
```

### `conftest.py` / Suite Setup (Browser Config)
```python
# tests/resources/config.py
BASE_URL     = "http://localhost:3000"
BROWSER      = "chrome"
TIMEOUT      = "30s"
IMPLICIT_WAIT = "5s"
HEADLESS     = False   # Set True in CI
```

### Suite-Level `__init__.robot`
```robot
*** Settings ***
Library    SeleniumLibrary    timeout=30s    implicit_wait=5s
Variables  ../resources/variables/global_variables.robot

Suite Setup       Open Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
```

### File Naming Convention
- Test suites: `tests/<feature_name>.robot`
- Use descriptive snake_case: `booking_flow.robot`, `cross_user_booking.robot`
- Group related tests in the same `.robot` file using `*** Test Cases ***`
- Keyword libraries: `resources/pages/<PageName>Page.robot`

---

## 2. Locator Strategy (Priority Order)

Always choose locators in this priority order for reliability and readability.

### Priority 1: data-testid (Most Preferred)
```robot
Click Element       xpath=//[*@data-testid='book-now-btn']
Wait Until Element Is Visible    xpath=//*[@data-testid='event-card']
```
> Tip: Create a custom keyword `Get By Test Id` to avoid repeating xpath boilerplate:
```robot
*** Keywords ***
Get By Test Id
    [Arguments]    ${testid}
    [Return]       xpath=//*[@data-testid='${testid}']
```
Usage:
```robot
${locator}=    Get By Test Id    book-now-btn
Click Element    ${locator}
```

### Priority 2: Accessibility Roles / Semantic HTML
```robot
Click Element       xpath=//a[contains(text(), 'Browse Events')]
Click Element       xpath=//button[@aria-label='Submit']
Click Element       xpath=//button[normalize-space()='Book Now']
```
Use for: links, buttons, headings — prefer text-based role selection.

### Priority 3: Labels and Placeholders
```robot
Input Text    xpath=//input[@placeholder='you@email.com']    ${EMAIL}
Input Text    xpath=//input[@placeholder='+91 98765 43210']  ${PHONE}
Input Text    xpath=//label[text()='Full Name']/following-sibling::input    ${NAME}
```
> Use `FOR Label→Input` pattern only when `id` attribute is missing.

### Priority 4: Element IDs (Stable, Explicit)
```robot
Click Element       id=login-btn
Input Text          id=event-title-input    ${EVENT_TITLE}
Input Text          id=customer-email       ${EMAIL}
Click Element       id=check-refund-btn
```
Use for: elements with explicit, stable `id` attributes.

### Priority 5: CSS Selectors (Last Resort)
```robot
Click Element       css=.confirm-booking-btn
${ref}=    Get Text    css=.booking-ref
```
Use only when no better locator exists. CSS classes can change with UI refactors.

### NEVER Use
```robot
# BAD - XPath index-based (fragile)
Click Element    xpath=//div[3]/span[2]

# BAD - Deep CSS chains
Click Element    css=.parent > .child:nth-child(3)

# BAD - Absolute XPath
Click Element    /html/body/div[1]/main/section/div[2]/button
```

---

## 3. Filtering and Scoping Patterns

### Filter elements by visible text
```robot
${cards}=    Get WebElements    xpath=//*[@data-testid='event-card']
FOR    ${card}    IN    @{cards}
    ${text}=    Get Text    ${card}
    IF    '${EVENT_TITLE}' in '${text}'
        ${target_card}=    Set Variable    ${card}
        BREAK
    END
END
```

### Reusable keyword: Find Card By Title
```robot
*** Keywords ***
Find Card By Title
    [Arguments]    ${title}
    ${cards}=    Get WebElements    xpath=//*[@data-testid='event-card']
    FOR    ${card}    IN    @{cards}
        ${text}=    Get Text    ${card}
        IF    '${title}' in '${text}'
            RETURN    ${card}
        END
    END
    Fail    Card with title '${title}' not found

# Usage:
${card}=    Find Card By Title    ${EVENT_TITLE}
Click Element    xpath=//*[@data-testid='book-now-btn']    # scoped via parent in real impl
```

### Scope action to a parent element
```robot
# Using XPath ancestor scoping
${book_btn}=    Get WebElement
...    xpath=//*[@data-testid='event-card'][contains(., '${EVENT_TITLE}')]//*[@data-testid='book-now-btn']
Click Element    ${book_btn}
```

---

## 4. Assertion Patterns

### Visibility Checks
```robot
# Positive
Wait Until Element Is Visible    xpath=//*[text()='Event created!']
Element Should Be Visible        xpath=//*[@data-testid='success-banner']

# Negative
Element Should Not Be Visible    xpath=//*[@data-testid='error-banner']
Wait Until Element Is Not Visible    id=refund-spinner    timeout=6s
```

### URL Assertions
```robot
Location Should Be    ${BASE_URL}/bookings
# Regex-style check (Python eval)
${url}=    Get Location
Should Match Regexp    ${url}    .*/events/\\d+
```

### Content Assertions
```robot
Element Should Contain    xpath=//*[@data-testid='result-box']    Eligible for refund
Element Should Contain    ${target_card}    ${EVENT_TITLE}
Page Should Contain       Event Booking Confirmed
```

### Numeric / Value Assertions
```robot
${count}=    Get Element Count    xpath=//*[@data-testid='event-card']
Should Be Equal As Integers    ${count}    6

${seats_after}=    Get Text    id=seats-remaining
${expected}=       Evaluate    ${seats_before} - 1
Should Be Equal As Integers    ${seats_after}    ${expected}
```

### Custom Timeout for Slow Operations
```robot
Wait Until Element Is Visible    xpath=//*[@data-testid='event-card']    timeout=5s
Wait Until Element Is Not Visible    id=refund-spinner    timeout=6s
```

---

## 5. Test Structure Patterns

### Standard Test Suite Structure
```robot
*** Settings ***
Library           SeleniumLibrary    timeout=30s
Resource          resources/pages/LoginPage.robot
Resource          resources/keywords/common_keywords.robot
Variables         resources/variables/global_variables.robot
Suite Setup       Open Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Setup        Login As Standard User
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Variables ***
${BASE_URL}        http://localhost:3000
${USER_EMAIL}      rahulshetty1@gmail.com
${USER_PASSWORD}   Magiclife1!
${EVENT_TITLE}     Test Event

*** Test Cases ***
User Can Book An Available Event
    [Documentation]    Validates end-to-end booking flow for a logged-in user
    # Step 1: Navigate to events
    Go To    ${BASE_URL}/events
    # Step 2: Select event
    ${card}=    Find Card By Title    ${EVENT_TITLE}
    Click Element    ${card}
    # Step 3: Book
    Click Element    id=book-now-btn
    # Step 4: Assert confirmation
    Wait Until Element Is Visible    xpath=//*[text()='Booking Confirmed']
    Page Should Contain    Booking Confirmed
```

### Reusable Login Keyword (in `LoginPage.robot`)
```robot
*** Settings ***
Library    SeleniumLibrary

*** Keywords ***
Login As Standard User
    Go To                    ${BASE_URL}/login
    Input Text               xpath=//input[@placeholder='you@email.com']    ${USER_EMAIL}
    Input Password           xpath=//input[@type='password']                ${USER_PASSWORD}
    Click Element            id=login-btn
    Wait Until Element Is Visible    xpath=//a[contains(text(), 'Browse Events')]
```

### Multi-Step Test with Comment Blocks
```robot
*** Test Cases ***
Create Event Book It And Verify Seats Reduced
    [Documentation]    Full flow: create event → book → assert seat count decremented

    # -- Step 1: Log in --
    Login As Standard User

    # -- Step 2: Create event --
    Go To    ${BASE_URL}/events/new
    Input Text    id=event-title-input    ${EVENT_TITLE}
    Click Element    id=submit-event-btn
    Wait Until Element Is Visible    xpath=//*[text()='Event created!']

    # -- Step 3: Capture seats before booking --
    Go To    ${BASE_URL}/events
    ${card}=    Find Card By Title    ${EVENT_TITLE}
    ${seats_before}=    Get Text    xpath=//*[@data-testid='seats-remaining']

    # -- Step 4: Book the event --
    Click Element    xpath=//*[@data-testid='event-card'][contains(., '${EVENT_TITLE}')]//*[@data-testid='book-now-btn']
    Wait Until Element Is Visible    xpath=//*[text()='Booking Confirmed']

    # -- Step 5: Verify seat count reduced --
    Go To    ${BASE_URL}/events
    ${seats_after}=    Get Text    xpath=//*[@data-testid='seats-remaining']
    ${expected}=    Evaluate    ${seats_before} - 1
    Should Be Equal As Integers    ${seats_after}    ${expected}
```

---

## 6. Page Object Model (POM) in Robot Framework

Robot Framework implements POM via **Resource files** — one `.robot` file per page.

### `tests/resources/pages/LoginPage.robot`
```robot
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${EMAIL_INPUT}     xpath=//input[@placeholder='you@email.com']
${PASS_INPUT}      xpath=//input[@type='password']
${LOGIN_BTN}       id=login-btn
${NAV_BROWSE}      xpath=//a[contains(text(), 'Browse Events')]

*** Keywords ***
Navigate To Login Page
    Go To    ${BASE_URL}/login

Login With Credentials
    [Arguments]    ${email}    ${password}
    Input Text        ${EMAIL_INPUT}    ${email}
    Input Password    ${PASS_INPUT}     ${password}
    Click Element     ${LOGIN_BTN}
    Wait Until Element Is Visible    ${NAV_BROWSE}

Login As Standard User
    Navigate To Login Page
    Login With Credentials    ${USER_EMAIL}    ${USER_PASSWORD}
```

### `tests/resources/pages/EventsPage.robot`
```robot
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${EVENT_CARD}       xpath=//*[@data-testid='event-card']
${BOOK_BTN}         xpath=//*[@data-testid='book-now-btn']
${SEATS_LABEL}      xpath=//*[@data-testid='seats-remaining']

*** Keywords ***
Navigate To Events Page
    Go To    ${BASE_URL}/events

Get Seats Remaining For Event
    [Arguments]    ${event_title}
    ${locator}=    Set Variable
    ...    xpath=//*[@data-testid='event-card'][contains(., '${event_title}')]//*[@data-testid='seats-remaining']
    ${seats}=    Get Text    ${locator}
    RETURN    ${seats}

Book Event By Title
    [Arguments]    ${event_title}
    ${btn}=    Set Variable
    ...    xpath=//*[@data-testid='event-card'][contains(., '${event_title}')]//*[@data-testid='book-now-btn']
    Click Element    ${btn}
    Wait Until Element Is Visible    xpath=//*[text()='Booking Confirmed']
```

**POM Rules:**
- One Resource file per page/major component
- Store locators as `*** Variables ***` at the top of the Resource file
- Keywords represent user actions, not low-level steps
- Keep `Should Be` assertions in test files, not in Resource keyword files
- Resource files live in `tests/resources/pages/` directory

---

## 7. API / Response Mocking

Robot Framework doesn't natively intercept HTTP like Playwright. Use one of these patterns:

### Option A: MockServer / WireMock (Recommended for API isolation)
```python
# tests/resources/test_data/mock_server.py
import requests

def setup_mock_events(base_mock_url):
    payload = {
        "request": {"method": "GET", "urlPattern": "/api/events.*"},
        "response": {
            "status": 200,
            "headers": {"Content-Type": "application/json"},
            "body": '{"data": [], "pagination": {"total": 6}}'
        }
    }
    requests.post(f"{base_mock_url}/__admin/mappings", json=payload)
```
```robot
*** Settings ***
Library    resources/test_data/mock_server.py

*** Test Cases ***
Events Page Shows Six Cards When API Returns Six Events
    Setup Mock Events    http://localhost:8080
    Go To    ${BASE_URL}/events
    ${count}=    Get Element Count    xpath=//*[@data-testid='event-card']
    Should Be Equal As Integers    ${count}    6
```

### Option B: Python `requests` for direct API seeding
```robot
*** Settings ***
Library    RequestsLibrary

*** Keywords ***
Seed Event Via API
    [Arguments]    ${title}    ${seats}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body}=       Create Dictionary    title=${title}    seats=${seats}
    POST On Session    api    /api/events    json=${body}    headers=${headers}
    Status Should Be    201
```

### Mock Data as Python Dict (equivalent to JS constants)
```python
# tests/resources/test_data/mock_responses.py
SIX_EVENTS_RESPONSE = {
    "data": [{"id": i, "title": f"Event {i}", "seats": 10} for i in range(1, 7)],
    "pagination": {"page": 1, "totalPages": 1, "total": 6, "limit": 12},
}
```

---

## 8. Test Users

| User        | Email                    | Password    | Purpose           |
|-------------|--------------------------|-------------|-------------------|
| Gmail User  | rahulshetty1@gmail.com   | Magiclife1! | Primary tester    |
| Yahoo User  | rahulshetty1@yahoo.com   | Magiclife1! | Cross-user tests  |

Store credentials only in `*** Variables ***` blocks or `.env` / vault — never hardcode in test steps.

---

## 9. Dynamic Data Handling

### Unique Test Data (Timestamp-based)
```robot
*** Keywords ***
Generate Unique Event Title
    ${ts}=    Get Time    epoch
    ${title}=    Set Variable    Test Event ${ts}
    RETURN    ${title}
```

### Usage
```robot
*** Test Cases ***
Create Unique Event
    ${EVENT_TITLE}=    Generate Unique Event Title
    Set Suite Variable    ${EVENT_TITLE}
    Go To    ${BASE_URL}/events/new
    Input Text    id=event-title-input    ${EVENT_TITLE}
```

---

## 10. Wait Strategies

### DO: Use `Wait Until` keywords (auto-retry built in)
```robot
Wait Until Element Is Visible    xpath=//*[text()='Event created!']
Wait Until Element Is Enabled    id=submit-btn
Wait Until Page Contains         Booking Confirmed
```

### DO: Use `waitUntil` equivalent for navigation
```robot
Go To    ${BASE_URL}/bookings/${id}
Wait Until Element Is Visible    xpath=//*[@data-testid='booking-detail']    timeout=10s
```

### DON'T: Use arbitrary sleeps
```robot
# BAD - Never do this
Sleep    2s
```

### Exception: Testing timed UI elements (spinners, loaders)
```robot
# OK — asserting a spinner appears then disappears within a window
Wait Until Element Is Visible      id=refund-spinner
Wait Until Element Is Not Visible  id=refund-spinner    timeout=6s
```

---

## 11. Debugging Tips

### Log to Console from Test
```robot
Log    Created event: "${EVENT_TITLE}"    console=True
Log    Booking confirmed. Ref: ${BOOKING_REF}    console=True
Log    Seats before: ${SEATS_BEFORE}, after: ${SEATS_AFTER}    console=True
```

### Capture Screenshot on Failure (Auto via Teardown)
```robot
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
```

### Run a Single Test File
```bash
python -m robot --outputdir results tests/booking_flow.robot
```

### Run a Single Test Case by Name
```bash
python -m robot --test "User Can Book An Available Event" tests/booking_flow.robot
```

### Run with Tag Filter
```bash
python -m robot --include smoke tests/
```

### View HTML Report
```bash
open results/report.html   # macOS
start results/report.html  # Windows
```

### Pause for Debug (RF 5+)
```robot
Pause Execution    # Opens interactive console mid-test
```

---

## 12. Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | Do Instead |
|---|---|---|
| `Sleep    2s` | Flaky, wastes time | Use `Wait Until Element Is Visible` |
| `xpath=//div[3]/span[2]` | Fragile positional XPath | Use `data-testid` or `id` |
| Hardcoded booking/event IDs in locators | Tests break when DB resets | Generate data dynamically with timestamps |
| `Run Keyword Only` left in suite | Skips other tests in CI | Remove debug-only flags before commit |
| No assertions after an action | Test passes but proves nothing | Always `Wait Until` + `Should Be` after interactions |
| Suite-level shared mutable state | Order-dependent failures | Use `Test Setup`/`Test Teardown` for isolation |
| Assertions inside Page Object keywords | Couples reusability to outcomes | Keep all `Should Be` / `Element Should` in test files |
| Using `Get Text` without trimming | Leading/trailing spaces break `Should Be Equal` | `${val}=    Strip String    ${raw}` before asserting |
| Catch-all `Run Keyword And Ignore Error` | Silently swallows failures | Only use when genuinely optional; always log the result |
| Magic numbers in assertions | Unclear intent | Use named variables: `${EXPECTED_SEAT_COUNT}=    6` |

---

## 13. Tags and CI Integration

### Tagging Tests
```robot
*** Test Cases ***
Booking Happy Path Smoke
    [Tags]    smoke    booking    regression
    ...

Refund Eligibility Check
    [Tags]    regression    refund
    ...
```

### Run by tag in CI (GitHub Actions / Jenkins)
```bash
# Smoke only
python -m robot --include smoke --outputdir results tests/

# Exclude WIP
python -m robot --exclude wip --outputdir results tests/
```

### Recommended Tags
| Tag | Purpose |
|---|---|
| `smoke` | Critical path — run on every PR |
| `regression` | Full suite — nightly |
| `wip` | Work in progress — always excluded from CI |
| `cross-user` | Tests requiring two user sessions |
| `api` | API-layer tests via RequestsLibrary |