#test folder paths on PC, create if none exist
If(!(test-path "C:\Scripts\"))
    {md "C:\Scripts\"}

$date = (Get-Date).ToString('MM-dd-yyyy')
$properties = "Enabled", "employeeID", "employeeNumber", "GivenName", "surname", "EmailAddress", "samAccountName"
#$filter = "(Enabled -eq 'true') -and (employeeID -like '*') -and (employeeNumber -notlike '*')"
#$filter = "(Enabled -eq 'true') -and (sAMAccountName -eq 'elwoodn')"
$users = Get-ADUser -Filter $filter -Properties $properties |  select $properties
$exp = @()
$exp_ch = @()

#loop through users
foreach ($u in $users) {

    #loads user attributes
    if($u.enabled -eq $true){
        $Status = "Active"
    }
    else{ $status = "Inactive"}

    $obj = new-object PSObject 
    $obj | add-member -MemberType NoteProperty -name STATUS -value $Status
    $obj | add-member -MemberType NoteProperty -name SamAccountName -value $u.SamAccountName
    $obj | add-member -MemberType NoteProperty -name USERNAME -value $u.EmailAddress
    $obj | add-member -MemberType NoteProperty -name FIRSTNAME -value $u.givenName
    $obj | add-member -MemberType NoteProperty -name LASTNAME -value $u.surName
    $obj | add-member -MemberType NoteProperty -name EMAIL -value $u.EmailAddress
    $obj | add-member -MemberType NoteProperty -name EMPID -value $u.employeeid
    $obj | add-member -MemberType NoteProperty -name EMPNUM -value $u.employeeNumber
    #set-aduser  -identity $u.SamAccountName -replace @{employeeNumber = $u.employeeID} -Credential $creds

    $exp += $obj    
}

$exp | Export-csv -path "C:\Scripts\EEID_Report_$date.csv" -NoTypeInformation


<#
foreach ($u in $users) {

    #loads user attributes
    if($u.enabled -eq $true){
        $Status = "Active"
    }
    else{ $status = "Inactive"}

    $obj_ch = new-object PSObject 
    $obj_ch | add-member -MemberType NoteProperty -name STATUS -value $Status
    $obj_ch | add-member -MemberType NoteProperty -name SamAccountName -value $u.SamAccountName
    $obj_ch | add-member -MemberType NoteProperty -name USERNAME -value $u.EmailAddress
    $obj_ch | add-member -MemberType NoteProperty -name FIRSTNAME -value $u.givenName
    $obj_ch | add-member -MemberType NoteProperty -name LASTNAME -value $u.surName
    $obj_ch | add-member -MemberType NoteProperty -name EMAIL -value $u.EmailAddress
    $obj_ch | add-member -MemberType NoteProperty -name EMPID -value $u.employeeid
    $obj_ch | add-member -MemberType NoteProperty -name EMPNUM -value $u.employeeNumber

    $exp_ch += $obj_ch    
}

$exp_ch | Export-csv -path "C:\Scripts\EEID_Report_ChangeComplete_$date.csv" -NoTypeInformation
#>