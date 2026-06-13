*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# ── Events Page Locators ──────────────────────────────────────────────────────
${EVENTS_PAGE_HEADING}       xpath=//h1[contains(text(),'Events') or contains(text(),'Browse')]
${EVENT_CARD}                xpath=//*[@data-testid='event-card']
${BOOK_NOW_BUTTON}           xpath=//*[@data-testid='book-now-btn']
${EVENT_CARD_TITLE}          xpath=//*[@data-testid='event-card']//h3
${SANDBOX_BANNER}            xpath=//*[contains(text(),'sandbox holds')]
${AVAILABLE_EVENT_CARD}      xpath=//*[@data-testid='event-card'][not(.//*[contains(text(),'SOLD OUT')])]

*** Keywords ***
Navigate To Events Page
    [Documentation]    Navigates directly to /events
    [Arguments]        ${url}
    Go To              ${url}
    Wait Until Element Is Visible    ${EVENT_CARD}    timeout=15s

Wait For Events Page To Load
    [Documentation]    Waits for event cards to appear
    Wait Until Element Is Visible    ${EVENT_CARD}    timeout=15s

Get Event Cards Count
    [Documentation]    Returns the count of event cards displayed
    ${cards}=    Get WebElements    ${EVENT_CARD}
    ${count}=    Get Length    ${cards}
    RETURN       ${count}

Click Book Now On First Event
    [Documentation]    Clicks Book Now on the first event card
    ${buttons}=    Get WebElements    ${BOOK_NOW_BUTTON}
    Click Element    ${buttons}[0]

Click Book Now On First Available Event
    [Documentation]    Clicks Book Now on the first event card that is NOT sold out
    # Use XPath to find event cards that don't contain SOLD OUT
    ${locator}=    Set Variable    xpath=//*[@data-testid='event-card'][not(.//*[contains(text(),'SOLD OUT')])]//*[@data-testid='book-now-btn']
    Wait Until Element Is Visible    ${locator}    timeout=10s
    ${buttons}=    Get WebElements    ${locator}
    ${count}=    Get Length    ${buttons}
    IF    ${count} == 0
        Fail    No available events found - all events are sold out
    END
    Click Element    ${buttons}[0]

Click Book Now On Event By Title
    [Documentation]    Clicks Book Now on an event card matching the title
    [Arguments]        ${title}
    ${locator}=    Set Variable    xpath=//*[@data-testid='event-card'][.//*[contains(text(),'${title}')]]//*[@data-testid='book-now-btn']
    Wait Until Element Is Visible    ${locator}    timeout=10s
    Click Element    ${locator}
