*** Settings ***
Documentation    Booking Flow E2E Tests
...              Tests: TC-001 (View Bookings List), TC-002 (View Booking Detail), TC-003 (Cancel Booking)
...              Source: docs/test-strategy.md

Library          SeleniumLibrary    timeout=30s    implicit_wait=5s
Resource         resources/keywords/common_keywords.robot
Resource         resources/pages/LoginPage.robot
Resource         resources/pages/BookingsPage.robot
Resource         resources/pages/BookingDetailPage.robot
Resource         resources/pages/EventsPage.robot
Resource         resources/pages/EventDetailPage.robot
Resource         resources/variables/global_variables.robot

Suite Setup       Open Browser And Login
Suite Teardown    Close All Browsers
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot


*** Variables ***
# Test data for booking creation
${CUSTOMER_NAME}     Test User
${CUSTOMER_PHONE}    9876543210


*** Test Cases ***
TC-001: View Bookings List
    [Documentation]    Verify user can view their bookings list after login
    ...                Journey: Login → navigate to /bookings → assert booking cards rendered
    [Tags]    smoke    happy-path    P0

    # -- Step 1: Ensure at least one booking exists --
    Ensure At Least One Booking Exists

    # -- Step 2: Navigate to bookings page --
    Navigate To My Bookings

    # -- Step 3: Assert bookings page loaded correctly --
    Page Should Contain    My Bookings
    Page Should Contain    View and manage all your ticket bookings

    # -- Step 4: Assert booking cards are rendered --
    ${count}=    Get Booking Cards Count
    Should Be True    ${count} >= 1    msg=Expected at least 1 booking card, found ${count}

    # -- Step 5: Assert booking card contains expected elements --
    Element Should Be Visible    ${BOOKING_CARD}
    Element Should Be Visible    ${VIEW_DETAILS_LINK}


TC-002: View Booking Detail
    [Documentation]    Verify user can view detailed booking information
    ...                Journey: Login → /bookings → Click "View Details" → assert all sections displayed
    [Tags]    smoke    happy-path    P0

    # -- Step 1: Ensure at least one booking exists --
    Ensure At Least One Booking Exists

    # -- Step 2: Navigate to bookings and get booking reference --
    Navigate To My Bookings
    ${expected_ref}=    Get First Booking Reference

    # -- Step 3: Click View Details on first booking --
    Click First View Details Link

    # -- Step 4: Wait for booking detail page to load --
    Wait For Booking Detail Page To Load

    # -- Step 5: Assert booking reference matches --
    ${actual_ref}=    Get Booking Reference From Header
    Should Be Equal    ${actual_ref}    ${expected_ref}

    # -- Step 6: Assert all detail sections are visible --
    Element Should Be Visible    ${EVENT_DETAILS_SECTION}     msg=Event Details section not visible
    Element Should Be Visible    ${CUSTOMER_DETAILS_SECTION}  msg=Customer Details section not visible
    Element Should Be Visible    ${PAYMENT_SECTION}           msg=Payment Summary section not visible

    # -- Step 7: Assert Cancel and Refund options are visible --
    Element Should Be Visible    ${CANCEL_BOOKING_BUTTON}     msg=Cancel Booking button not visible
    Element Should Be Visible    ${CHECK_REFUND_BUTTON}       msg=Check Refund button not visible


TC-003: Cancel Booking
    [Documentation]    Verify user can cancel a booking via detail page
    ...                Journey: Login → /bookings → view detail → Cancel Booking → confirm dialog → redirect
    [Tags]    smoke    happy-path    P0

    # -- Step 1: Navigate to bookings and ensure at least one exists --
    Navigate To My Bookings
    ${initial_count}=    Get Booking Cards Count
    
    # If no bookings exist, create one first
    IF    ${initial_count} == 0
        Create Fresh Booking For Test
        Navigate To My Bookings
        ${initial_count}=    Get Booking Cards Count
    END
    
    Should Be True    ${initial_count} >= 1    msg=Need at least 1 booking to test cancellation

    # -- Step 2: Click View Details on first booking --
    Wait Until Element Is Visible    ${VIEW_DETAILS_LINK}    timeout=10s
    Click First View Details Link
    Wait For Booking Detail Page To Load

    # -- Step 3: Click Cancel Booking button --
    Click Cancel Booking Button

    # -- Step 4: Assert confirmation dialog appears --
    Element Should Be Visible    ${CONFIRM_DIALOG}    msg=Cancel confirmation dialog not visible
    Page Should Contain    Cancel this booking?

    # -- Step 5: Confirm the cancellation --
    Confirm Cancellation In Dialog

    # -- Step 6: Assert redirect to bookings page --
    Wait Until Location Contains    /bookings    timeout=15s
    ${current_url}=    Get Location
    Log    URL after cancellation: ${current_url}
    # Wait for page content to load
    Wait For Bookings Page To Load
    ${url_after_wait}=    Get Location
    Log    URL after wait: ${url_after_wait}

    # -- Step 7: Assert success toast appeared (optional) --
    ${toast_visible}=    Run Keyword And Return Status    Page Should Contain    cancelled
    Log    Toast message visible: ${toast_visible}

    # -- Step 8: Assert booking count reduced by 1 --
    Wait Until Element Is Visible    ${BOOKINGS_PAGE_TITLE}    timeout=10s
    Capture Page Screenshot    final-bookings-page.png
    ${final_count}=    Get Booking Cards Count
    Log    Final booking count: ${final_count}
    ${expected_count}=    Evaluate    ${initial_count} - 1
    Log    Expected booking count: ${expected_count}
    # If final count is 0, the page may need a refresh
    IF    ${final_count} == 0
        Reload Page
        Wait Until Element Is Visible    ${BOOKINGS_PAGE_TITLE}    timeout=10s
        ${final_count}=    Get Booking Cards Count
        Log    After refresh booking count: ${final_count}
    END
    Should Be Equal As Integers    ${final_count}    ${expected_count}    msg=Booking count should decrease by 1 after cancellation


*** Keywords ***
Open Browser And Login
    [Documentation]    Suite setup: Opens browser and logs in with test account
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Login As Standard User

Ensure At Least One Booking Exists
    [Documentation]    Checks if bookings exist, creates one if not
    Navigate To My Bookings
    ${count}=    Get Booking Cards Count
    IF    ${count} == 0
        Create Fresh Booking For Test
        Navigate To My Bookings
    END

Create Fresh Booking For Test
    [Documentation]    Creates a new booking using the first available event
    Go To    ${EVENTS_URL}
    Wait For Events Page To Load
    Click Book Now On First Available Event
    Wait For Event Detail Page To Load
    ${timestamp}=    Get Time    epoch
    ${unique_email}=    Set Variable    test${timestamp}@test.com
    Complete Booking With Single Ticket    ${CUSTOMER_NAME}    ${unique_email}    ${CUSTOMER_PHONE}

Wait Until Location Contains
    [Documentation]    Waits until URL contains the specified substring
    [Arguments]        ${substring}    ${timeout}=10s
    Wait Until Keyword Succeeds    ${timeout}    1s    Location Should Contain    ${substring}
