# Specify the path to the Excel file and the WorkSheet Name
$FilePath = "$env:userprofile\desktop\Exit form.xlsx"
$SheetName = "Sheet2"

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false

# Open the Excel file and save it in $WorkBook
$WorkBook = $objExcel.Workbooks.Open($FilePath)

# Load the WorkSheet
$WorkSheet = $WorkBook.sheets.item($SheetName)

[pscustomobject][ordered]@{
    Lastname = $WorkSheet.Range("B3").Text
    Firstname = $WorkSheet.Range("B4").Text
    LastWorkingdate = $WorkSheet.Range("B6").Text
    PersID = $WorkSheet.Range("B10").Text
    UnitManager = $WorkSheet.Range("B11").Text
    ExitDateMB = $WorkSheet.Range("B14").Text
    OOO = $WorkSheet.Range("B15").Text
    OOOphone = $WorkSheet.Range("B16").Text
    MBaccess = $WorkSheet.Range("B17").Text
}

    $Lastname
    $Firstname
    $LastWorkingdate
    $PersID
    $UnitManager
    $ExitDateMB
    $OOO
    $OOOphone
    $MBaccess

$WorkBook.close()
