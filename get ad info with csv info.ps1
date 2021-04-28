$CSVData = Import-Csv -Path C:\scripts\uportalusers.csv
$ADUsers = Get-ADUser -Filter * -Properties Enabled,employeeID,lastLogon,company,department,division
$Results = @()

Foreach ($Line in $CSVData) {
    $EEID = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).employeeID
    $LastLog = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).lastLogon
    $Company = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Company
    $Department = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Department
    $Division = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Division
    $Line | Add-Member -MemberType NoteProperty -Name "Employee ID" -Value $EEID
    $Line | Add-Member -MemberType NoteProperty -Name "Last Logon Date" -Value $LastLog
    $Line | Add-Member -MemberType NoteProperty -Name "Company" -Value $Company
    $Line | Add-Member -MemberType NoteProperty -Name "Department" -Value $Department
    $Line | Add-Member -MemberType NoteProperty -Name "Division" -Value $Division
    $Results += $Line
}

$Results | Export-Csv -Path C:\Scripts\UportalNew.csv -Force -NoTypeInformation -Append