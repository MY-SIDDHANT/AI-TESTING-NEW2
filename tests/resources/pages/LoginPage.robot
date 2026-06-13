*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# ── Login Page Locators ───────────────────────────────────────────────────────
${EMAIL_INPUT}           id=email
${PASSWORD_INPUT}        id=password
${LOGIN_BUTTON}          id=login-btn

*** Keywords ***
Navigate To Login Page
    [Documentation]    Opens the login page
    [Arguments]        ${url}
    Go To              ${url}
    Wait Until Element Is Visible    ${LOGIN_BUTTON}    timeout=10s

Enter Email
    [Documentation]    Enters email into login form
    [Arguments]        ${email}
    Wait Until Element Is Visible    ${EMAIL_INPUT}
    Input Text         ${EMAIL_INPUT}    ${email}

Enter Password
    [Documentation]    Enters password into login form
    [Arguments]        ${password}
    Wait Until Element Is Visible    ${PASSWORD_INPUT}
    Input Text         ${PASSWORD_INPUT}    ${password}

Click Login Button
    [Documentation]    Clicks the Sign In button
    Click Element      ${LOGIN_BUTTON}

Submit Login Form
    [Documentation]    Fills and submits login form
    [Arguments]        ${email}    ${password}
    Enter Email        ${email}
    Enter Password     ${password}
    Click Login Button
