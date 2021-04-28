#test folder paths on PC, create if none exist
$path1 = "C:\Scripts\"
If(!(test-path $path1))
{md "C:\Scripts\"}

$path2 = "C:\Scripts\Used License Data\"
If(!(test-path $path2))
{md "C:\Scripts\Used License Data\"}


$msolcred = get-credential
connect-msolservice -credential $msolcred

Write-Output "Checking Office Licenses"

$Skus1 = @("companyname:VISIOCLIENT"
,"companyname:CRMPLAN2"
,"companyname:POWERAPPS_INDIVIDUAL_USER"
,"companyname:POWER_BI_INDIVIDUAL_USER"
,"companyname:POWER_BI_PRO"
,"companyname:WINDOWS_STORE"
,"companyname:ENTERPRISEPACK"
,"companyname:POWER_BI_ADDON"
,"companyname:FLOW_FREE"
,"companyname:MICROSOFT_BUSINESS_CENTER"
,"companyname:MCOEV"
,"companyname:EXCHANGEDESKLESS"
,"companyname:POWERAPPS_VIRAL"
,"companyname:CRMSTANDARD"
,"companyname:AAD_PREMIUM_P2"
,"companyname:DYN365_ENTERPRISE_PLAN1"
,"companyname:POWER_BI_STANDARD"
,"companyname:MCOMEETADV"
,"companyname:AAD_PREMIUM"
,"companyname:SPE_E3"
,"companyname:ENTERPRISEWITHSCAL"
,"companyname:MCOPSTN2"
,"companyname:CRMSTORAGE"
,"companyname:DYN365_ENTERPRISE_TEAM_MEMBERS"
,"companyname:RIGHTSMANAGEMENT_ADHOC"
)

$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hh-mm-ss')

Foreach($skuq in $Skus1)
{
Get-MsolUser -all |
Where {$_.IsLicensed -eq $true -and $_.Licenses.AccountSKUID -eq $skuq} |
Select DisplayName,UserPrincipalName, @{n="Licenses Type";e={$skuq}} | 
Export-Csv -Path C:\scripts\License_Data.csv -NoTypeInformation -append
}

Write-Output "Checking AD Users"

$CSVData = Import-Csv -Path C:\scripts\License_Data.csv
$ADUsers = Get-ADUser -Filter * -Properties company,department,division,organization
$Results = @()
Foreach ($Line in $CSVData) {
    $Company = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Company
    $Department = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Department
    $Division = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Division
    $Organization = ($ADUsers | Where {$_.UserPrincipalName -eq $Line.UserPrincipalName}).Organization
    $Line | Add-Member -MemberType NoteProperty -Name "Company" -Value $Company
    $Line | Add-Member -MemberType NoteProperty -Name "Department" -Value $Department
    $Line | Add-Member -MemberType NoteProperty -Name "Division" -Value $Division
    $Line | Add-Member -MemberType NoteProperty -Name "Organization" -Value $Organization
    $Results += $Line
}

$Results | Export-Csv -Path C:\Scripts\License_Data_AD_$CurrentDate.csv -Force -NoTypeInformation -Append

Move-Item -Path "C:\scripts\License_Data.csv" -Destination "C:\Scripts\Used License Data\License_Data_$CurrentDate.csv"

Write-Output "Script complete. Please check your C:\Scripts folder for your completed file."