*** Settings ***
Library    SeleniumLibrary
Resource   ../pages/LoginPage.robot
Resource   ../pages/BookingsPage.robot
Resource   ../pages/BookingDetailPage.robot
Resource   ../variables/global_variables.robot

*** Keywords ***
Login As Standard User
    [Documentation]    Logs in with the standard test account
    Navigate To Login Page    ${LOGIN_URL}
    Submit Login Form         ${TEST_EMAIL}    ${TEST_PASSWORD}
    Wait Until Location Does Not Contain    /login    timeout=15s

Login With Credentials
    [Documentation]    Logs in with specified credentials
    [Arguments]        ${email}    ${password}
    Navigate To Login Page    ${LOGIN_URL}
    Submit Login Form         ${email}    ${password}
    Wait Until Location Does Not Contain    /login    timeout=15s

Navigate To My Bookings
    [Documentation]    Navigates to the bookings page and waits for load
    Go To    ${BOOKINGS_URL}
    Wait For Bookings Page To Load

Logout User
    [Documentation]    Logs out by clearing localStorage and navigating to login
    Execute JavaScript    localStorage.clear()
    Go To    ${LOGIN_URL}

Get By Test Id
    [Documentation]    Returns XPath locator for data-testid attribute
    [Arguments]        ${testid}
    RETURN             xpath=//*[@data-testid='${testid}']

Wait Until Location Does Not Contain
    [Documentation]    Waits until URL no longer contains a substring
    [Arguments]        ${substring}    ${timeout}=10s
    Wait Until Keyword Succeeds    ${timeout}    1s    Location Should Not Contain    ${substring}

Location Should Not Contain
    [Documentation]    Fails if current URL contains the substring
    [Arguments]        ${substring}
    ${url}=    Get Location
    Should Not Contain    ${url}    ${substring}
