*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the csv file
    ${csv_file}    Read csv file into Table
    Order robots and save relevant data    ${csv_file}

Create ZIP archive of the receipts and the images

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true

Read csv file into Table
    ${csv_file}    Read table from CSV    orders.csv    header=True
    RETURN    ${csv_file}

Close the annoying modal
    Wait And Click Button    css:.btn.btn-dark

Order robots and save relevant data
    [Arguments]    ${csv_file}

    # LOOPING THESE STEPS
    FOR    ${row}    IN    @{csv_file}
        Close the annoying modal
        Input One Order    ${row}
        ${pdf}    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Click Button    order-another
    END

Input One Order
    [Arguments]    ${row}

    Wait Until Element Is Visible    head
    Select From List By Index    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath=//input[@placeholder='Enter the part number for the legs']    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    preview

    # LAST BUTTON CAN RESULT IN ERROR
    TRY
        Wait Until Keyword Succeeds    3x    1s    Click Button    order
    EXCEPT    AS    ${error}
        Log    ${error}
    END

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    receipt
    ${receipt}    Get Element Attribute    receipt    outerHTML

    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${order_number}.pdf

    RETURN    ${OUTPUT_DIR}${/}${order_number}.pdf

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close pdf    ${pdf}     

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${screenshot}=    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}${order_number}
    RETURN    ${screenshot}

Create ZIP archive of the receipts and the images

