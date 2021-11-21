*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Open the order website
...               Download csv file with order data
...               Fill in the order according to csv data and submit order.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Tables
Library           RPA.Excel.Files
Library           RPA.Robocorp.Vault
Library           RPA.Dialogs


*** Variables ***
${OK_BUTTON}                //div[@class="alert-buttons"]/button[text()="OK"]
${LEGS_NUMBER}              //input[@placeholder='Enter the part number for the legs']
${LINK_ORDER_YOUR_ROBOT}    //a[text()="Order your robot!"]

*** Keywords ***
Open the robot order website
    ${secret}=     Get Secret    robotsparebin
    Open Available Browser       ${secret}[url]
    Click Element When Visible   ${LINK_ORDER_YOUR_ROBOT}
    Wait And Click Button        ${OK_BUTTON}


*** Keywords ***
Take csv address From User
    Add text input    csv_url    label=input the addreess with csv file
    ${response}=    Run dialog
    [Return]    ${response.csv_url}

*** Keywords ***
Download the CSV file with orders
    ${url}=     Take csv address From User
    Download    ${url}   overwrite=True

*** Keywords ***
Get orders
    ${csv_orders}=   Read table from CSV    orders.csv    header=True
    [Return]    ${csv_orders}

*** Keywords ***
Fill And Submit The Form For One Order
    [Arguments]    ${orders}
    Select From List By Value    id:head           ${orders}[Head]
    Select Radio Button          body              ${orders}[Body]
    Input Text                   ${LEGS_NUMBER}    ${orders}[Head]
    Input Text                   id:address        ${orders}[Address]
    Click Button                 id:preview
    Wait Until Page Contains Element    id:robot-preview-image
    Click Button                        id:order
    Wait Until Page Contains Element    id:receipt
    Store receipt as PDF file           ${orders}
    Take a screenshot of the robot      ${orders}
    Embed robot screenshot to receipt   ${orders}
    Click Button                        id:order-another
    Wait And Click Button               ${OK_BUTTON}

*** Keywords ***
Fill The Form Using CSV File
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Wait Until Keyword Succeeds    5x    2 sec   Fill And Submit The Form For One Order    ${order}
    END

*** Keywords ***
Store receipt as PDF file
    [Arguments]    ${orders}
      Wait Until Element Is Visible    id:receipt
     ${order_receipt_html}=    Get Element Attribute    id:receipt    outerHTML
      Html To Pdf    ${order_receipt_html}    ${CURDIR}${/}output${/}pdf_receipts${/}receipt${orders}[Order number].pdf


*** Keywords ***
Take a screenshot of the robot
    [Arguments]    ${orders}
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}robot_screenshots_png${/}screenshot${orders}[Order number].png

*** Keywords ***
Embed robot screenshot to receipt
    [Arguments]    ${orders}
    ${path_to_robot_image}=    Create List  ${CURDIR}${/}output${/}robot_screenshots_png${/}screenshot${orders}[Order number].png    
    Open Pdf    ${CURDIR}${/}output${/}pdf_receipts${/}receipt${orders}[Order number].pdf
    Add Files To Pdf   ${path_to_robot_image}   ${CURDIR}${/}output${/}pdf_receipts${/}receipt${orders}[Order number].pdf    append=True

*** Keywords ***
Create zip from pdf receipts
        Archive Folder With Zip  ${CURDIR}${/}output${/}pdf_receipts  receipts.zip

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
      Open the robot order website
      Download the CSV file with orders
      Fill The Form Using CSV File
      Create zip from pdf receipts




