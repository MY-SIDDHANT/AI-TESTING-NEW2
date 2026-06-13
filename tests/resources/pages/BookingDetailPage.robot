*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# ── Booking Detail Page Locators ──────────────────────────────────────────────
${BOOKING_REF_HEADER}        xpath=//span[contains(@class,'font-mono') and contains(@class,'font-bold')]
${BOOKING_STATUS_BADGE}      xpath=//*[contains(@class,'bg-emerald') or contains(@class,'bg-red')][contains(text(),'confirmed') or contains(text(),'cancelled')]
${CANCEL_BOOKING_BUTTON}     xpath=//button[contains(text(),'Cancel Booking')]
${CHECK_REFUND_BUTTON}       id=check-refund-btn
${REFUND_SPINNER}            id=refund-spinner
${REFUND_RESULT}             id=refund-result
${BACK_TO_BOOKINGS_LINK}     xpath=//a[contains(@href,'/bookings') and contains(text(),'My Bookings')]
${EVENT_TITLE_HEADING}       xpath=//h1
${EVENT_DETAILS_SECTION}     xpath=//*[contains(text(),'Event Details')]
${CUSTOMER_DETAILS_SECTION}  xpath=//*[contains(text(),'Customer Details')]
${PAYMENT_SECTION}           xpath=//*[contains(text(),'Payment Summary')]
${CONFIRM_DIALOG}            xpath=//*[contains(text(),'Cancel this booking?')]
${CONFIRM_YES_BUTTON}        xpath=//button[contains(text(),'Yes, cancel it')]
${CONFIRM_NO_BUTTON}         xpath=//button[contains(text(),'No')]
${ACCESS_DENIED_TITLE}       xpath=//*[contains(text(),'Access Denied')]
${BOOKING_NOT_FOUND}         xpath=//*[contains(text(),'Booking not found')]

*** Keywords ***
Wait For Booking Detail Page To Load
    [Documentation]    Waits for booking detail page elements to be visible
    Wait Until Element Is Visible    ${BOOKING_REF_HEADER}    timeout=15s

Get Booking Reference From Header
    [Documentation]    Returns the booking reference displayed in header
    Wait Until Element Is Visible    ${BOOKING_REF_HEADER}    timeout=10s
    ${text}=    Get Text    ${BOOKING_REF_HEADER}
    RETURN      ${text}

Get Event Title
    [Documentation]    Returns the event title from the detail page
    Wait Until Element Is Visible    ${EVENT_TITLE_HEADING}    timeout=10s
    ${text}=    Get Text    ${EVENT_TITLE_HEADING}
    RETURN      ${text}

Click Cancel Booking Button
    [Documentation]    Clicks the Cancel Booking button
    Wait Until Element Is Visible    ${CANCEL_BOOKING_BUTTON}    timeout=10s
    Scroll Element Into View    ${CANCEL_BOOKING_BUTTON}
    Wait Until Element Is Enabled    ${CANCEL_BOOKING_BUTTON}    timeout=5s
    Click Element    ${CANCEL_BOOKING_BUTTON}
    # Wait for dialog to appear
    Wait Until Element Is Visible    ${CONFIRM_DIALOG}    timeout=10s

Confirm Cancellation In Dialog
    [Documentation]    Clicks Yes in the confirmation dialog
    Wait Until Element Is Visible    ${CONFIRM_DIALOG}    timeout=10s
    Wait Until Element Is Visible    ${CONFIRM_YES_BUTTON}    timeout=5s
    Wait Until Element Is Enabled    ${CONFIRM_YES_BUTTON}    timeout=5s
    # Use regular click with explicit element refresh
    ${buttons}=    Get WebElements    ${CONFIRM_YES_BUTTON}
    Click Element    ${buttons}[0]

Dismiss Cancellation Dialog
    [Documentation]    Clicks No/Cancel in the confirmation dialog
    Wait Until Element Is Visible    ${CONFIRM_NO_BUTTON}    timeout=5s
    Click Element    ${CONFIRM_NO_BUTTON}

Click Check Refund Eligibility
    [Documentation]    Clicks the Check Refund Eligibility button
    Wait Until Element Is Visible    ${CHECK_REFUND_BUTTON}    timeout=10s
    Click Element    ${CHECK_REFUND_BUTTON}

Wait For Refund Result
    [Documentation]    Waits for the refund spinner to disappear and result to show
    Wait Until Element Is Not Visible    ${REFUND_SPINNER}    timeout=10s
    Wait Until Element Is Visible    ${REFUND_RESULT}    timeout=5s

Get Refund Result Text
    [Documentation]    Returns the text of the refund result
    ${text}=    Get Text    ${REFUND_RESULT}
    RETURN      ${text}

Click Back To My Bookings
    [Documentation]    Clicks the breadcrumb link back to My Bookings
    Wait Until Element Is Visible    ${BACK_TO_BOOKINGS_LINK}    timeout=10s
    Click Element    ${BACK_TO_BOOKINGS_LINK}
