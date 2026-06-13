*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# ── Bookings Page Locators ────────────────────────────────────────────────────
${BOOKINGS_PAGE_TITLE}       xpath=//h1[contains(text(),'My Bookings')]
${BOOKING_CARD}              xpath=//*[@data-testid='booking-card']
${VIEW_DETAILS_LINK}         xpath=//a[.//button[contains(text(),'View Details')]]
${CLEAR_ALL_BUTTON}          xpath=//button[contains(text(),'Clear all bookings')]
${EMPTY_STATE_TITLE}         xpath=//*[contains(text(),'No bookings yet')]
${BROWSE_EVENTS_LINK}        xpath=//a[.//button[contains(text(),'Browse Events')]]
${BOOKING_REF_ON_CARD}       css=.booking-ref

*** Keywords ***
Navigate To Bookings Page
    [Documentation]    Navigates directly to /bookings
    [Arguments]        ${url}
    Go To              ${url}
    Wait Until Element Is Visible    ${BOOKINGS_PAGE_TITLE}    timeout=15s

Wait For Bookings Page To Load
    [Documentation]    Waits for the My Bookings heading or page content to appear
    # Try waiting for the title first
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${BOOKINGS_PAGE_TITLE}    timeout=10s
    IF    not ${status}
        # Fallback: wait for booking cards or empty state
        ${cards_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${BOOKING_CARD}    timeout=5s
        ${empty_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${EMPTY_STATE_TITLE}    timeout=5s
        IF    not ${cards_visible} and not ${empty_visible}
            # Last resort: wait for any page content
            Wait Until Page Contains Element    xpath=//main    timeout=10s
        END
    END

Get Booking Cards Count
    [Documentation]    Returns the count of booking cards displayed
    # Wait for loading skeletons to disappear
    ${loading}=    Run Keyword And Return Status    Wait Until Element Is Not Visible    css=.animate-pulse    timeout=10s
    # Check if page is still loading (wait for loading spinners to disappear)
    ${loading}=    Run Keyword And Return Status    Element Should Not Be Visible    css=.animate-pulse
    # Wait for either booking cards or empty state
    ${cards_present}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${BOOKING_CARD}    timeout=5s
    IF    not ${cards_present}
        # Check if it's the empty state
        ${empty_state}=    Run Keyword And Return Status    Element Should Be Visible    ${EMPTY_STATE_TITLE}
        IF    ${empty_state}
            RETURN    ${0}
        END
        # Otherwise try a longer wait
        ${cards_present2}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${BOOKING_CARD}    timeout=10s
        IF    not ${cards_present2}
            RETURN    ${0}
        END
    END
    ${cards}=    Get WebElements    ${BOOKING_CARD}
    ${count}=    Get Length    ${cards}
    RETURN       ${count}

Click First View Details Link
    [Documentation]    Clicks the first View Details button
    # Re-fetch element to avoid stale references
    Wait Until Element Is Visible    ${VIEW_DETAILS_LINK}    timeout=10s
    Wait Until Element Is Enabled    ${VIEW_DETAILS_LINK}    timeout=5s
    ${links}=    Get WebElements    ${VIEW_DETAILS_LINK}
    ${count}=    Get Length    ${links}
    IF    ${count} == 0
        Fail    No View Details links found on page
    END
    Scroll Element Into View    ${links}[0]
    Click Element    ${links}[0]

Click View Details For Card
    [Documentation]    Clicks View Details for a specific card index (0-based)
    [Arguments]        ${index}
    ${links}=    Get WebElements    ${VIEW_DETAILS_LINK}
    Click Element    ${links}[${index}]

Click Clear All Bookings
    [Documentation]    Clicks the Clear all bookings link
    Wait Until Element Is Visible    ${CLEAR_ALL_BUTTON}    timeout=10s
    Click Element    ${CLEAR_ALL_BUTTON}

Get First Booking Reference
    [Documentation]    Returns the booking reference from the first card
    Wait Until Element Is Visible    ${BOOKING_REF_ON_CARD}    timeout=10s
    ${refs}=    Get WebElements    ${BOOKING_REF_ON_CARD}
    ${text}=    Get Text    ${refs}[0]
    RETURN      ${text}
