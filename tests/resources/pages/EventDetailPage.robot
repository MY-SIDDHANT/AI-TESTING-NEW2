*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# ── Event Detail / Booking Form Locators ──────────────────────────────────────
${EVENT_DETAIL_TITLE}        xpath=//h1
${TICKET_COUNT}              id=ticket-count
${INCREMENT_BTN}             xpath=//button[contains(text(),'+')]
${DECREMENT_BTN}             xpath=//button[contains(text(),'−') or contains(text(),'-')]
${CUSTOMER_NAME_INPUT}       id=customerName
${CUSTOMER_EMAIL_INPUT}      id=customer-email
${CUSTOMER_PHONE_INPUT}      id=phone
${CONFIRM_BOOKING_BTN}       id=confirm-booking
${BOOKING_CONFIRMATION}      xpath=//*[contains(@class,'booking-ref') and contains(@class,'font-mono')]
${BOOKING_REF_DISPLAY}       css=.booking-ref
${VIEW_MY_BOOKINGS_LINK}     xpath=//a[@href='/bookings']//button[contains(text(),'View My Bookings')]
${BROWSE_MORE_EVENTS_LINK}   xpath=//a[.//button[contains(text(),'Browse More Events')]]
${AVAILABLE_SEATS_TEXT}      xpath=//*[contains(text(),'Available') or contains(text(),'seats')]

*** Keywords ***
Wait For Event Detail Page To Load
    [Documentation]    Waits for event detail page to load
    Wait Until Element Is Visible    ${EVENT_DETAIL_TITLE}    timeout=15s
    Wait Until Element Is Visible    ${CONFIRM_BOOKING_BTN}    timeout=10s

Get Event Title From Detail Page
    [Documentation]    Returns the event title from the detail page
    ${text}=    Get Text    ${EVENT_DETAIL_TITLE}
    RETURN      ${text}

Get Ticket Count
    [Documentation]    Returns current ticket quantity
    ${text}=    Get Text    ${TICKET_COUNT}
    ${count}=   Convert To Integer    ${text}
    RETURN      ${count}

Set Ticket Quantity
    [Documentation]    Sets ticket quantity to specified number (1-10)
    [Arguments]        ${quantity}
    ${current}=    Get Ticket Count
    IF    ${quantity} > ${current}
        ${clicks}=    Evaluate    ${quantity} - ${current}
        FOR    ${i}    IN RANGE    ${clicks}
            Click Element    ${INCREMENT_BTN}
        END
    ELSE IF    ${quantity} < ${current}
        ${clicks}=    Evaluate    ${current} - ${quantity}
        FOR    ${i}    IN RANGE    ${clicks}
            Click Element    ${DECREMENT_BTN}
        END
    END

Fill Booking Form
    [Documentation]    Fills out the booking form
    [Arguments]        ${name}    ${email}    ${phone}
    Wait Until Element Is Visible    ${CUSTOMER_NAME_INPUT}    timeout=10s
    Wait Until Element Is Enabled    ${CUSTOMER_NAME_INPUT}    timeout=5s
    # Use standard Input Text - works with most React apps
    Input Text    ${CUSTOMER_NAME_INPUT}     ${name}
    Input Text    ${CUSTOMER_EMAIL_INPUT}    ${email}
    Input Text    ${CUSTOMER_PHONE_INPUT}    ${phone}
    Wait Until Element Is Enabled    ${CONFIRM_BOOKING_BTN}    timeout=5s

Click Confirm Booking
    [Documentation]    Clicks the Confirm Booking button
    Wait Until Element Is Visible    ${CONFIRM_BOOKING_BTN}    timeout=10s
    Wait Until Element Is Enabled    ${CONFIRM_BOOKING_BTN}    timeout=5s
    Click Element    ${CONFIRM_BOOKING_BTN}
    # Wait for confirmation to appear
    Wait Until Element Is Visible    ${BOOKING_REF_DISPLAY}    timeout=20s

Wait For Booking Confirmation
    [Documentation]    Waits for booking confirmation to appear
    # Wait for the booking confirmation card with booking reference
    Wait Until Element Is Visible    ${BOOKING_REF_DISPLAY}    timeout=20s

Get Booking Reference From Confirmation
    [Documentation]    Returns the booking reference after successful booking
    Wait Until Element Is Visible    ${BOOKING_REF_DISPLAY}    timeout=10s
    ${text}=    Get Text    ${BOOKING_REF_DISPLAY}
    RETURN      ${text}

Click View My Bookings From Confirmation
    [Documentation]    Clicks View My Bookings link after booking
    Wait Until Element Is Visible    ${VIEW_MY_BOOKINGS_LINK}    timeout=10s
    Click Element    ${VIEW_MY_BOOKINGS_LINK}

Complete Booking With Single Ticket
    [Documentation]    Completes a booking for 1 ticket with given details
    [Arguments]        ${name}    ${email}    ${phone}
    Fill Booking Form    ${name}    ${email}    ${phone}
    Click Confirm Booking
    Wait For Booking Confirmation
