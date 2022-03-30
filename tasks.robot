*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archiveof the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Tables
Library           RPA.Robocorp.Vault

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Download the csv file
    Open the intranet website
    Fill the form from csv file and save receipt
    Close the browser
    Create archive zip

*** Keywords ***
Open the intranet website
    ${url}=    Get Secret    URL
    Open Available Browser    ${url}

Download the csv file
    Add heading    Hello there!    size=Large
    Add text input    name=URL    label=Enter the URL where I can get the order file
    ${response}=    Run dialog
    Download    ${response.URL}    overwrite=True

Fill the form for one person
    Wait Until Page Contains Element    class:modal-dialog
    Click Button    OK
    [Arguments]    ${order}
    Select From List By Index    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    //form/div[3]/input    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    preview
    Wait Until Keyword Succeeds    5x    5s    Submit Order

Submit Order
    Click Button    order
    Wait Until Page Contains Element    id:receipt

Robot screenshot
    [Arguments]    ${order}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}${order}[Order number].png

Collect the receipt as a PDF
    [Arguments]    ${order}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}receipt-${order}[Order number].pdf

Embed robot image to receipt
    [Arguments]    ${order}
    Open Pdf    ${OUTPUT_DIR}${/}receipts${/}receipt-${order}[Order number].pdf
    Add Watermark Image To Pdf    ${OUTPUT_DIR}${/}${order}[Order number].png    ${OUTPUT_DIR}${/}receipts${/}receipt-${order}[Order number].pdf
    Close Pdf

Fill the form from csv file and save receipt
    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Fill the form for one person    ${order}
        Collect the receipt as a PDF    ${order}
        Robot screenshot    ${order}
        Embed robot image to receipt    ${order}
        Click Button    order-another
    END

Close the browser
    Close Browser

Create archive zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.zip
