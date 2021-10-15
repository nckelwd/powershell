$date = (Get-Date).ToString('MM-dd-yyyy')
$properties = "Enabled", "employeeID", "GivenName", "surname", "EmailAddress", "manager", "Department", "Title", "samAccountName", "whenCreated", "employeeType"
$filter = "(Enabled -eq 'true')"
$users = Get-ADUser -Filter $filter -Properties $properties | where-object employeeType -eq $null |  Select-Object $properties
$exp = @()

#loop through users
foreach ($u in $users) {

    #loads user attributes
    if($u.enabled -eq $true){
        $Status = "Active"
    }
    else{ $status = "Inactive"}

    $obj = new-object PSObject 
    $obj | add-member -MemberType NoteProperty -name EMPID -value $u.employeeid
    $obj | add-member -MemberType NoteProperty -name SamAccountName -value $u.SamAccountName
    $obj | add-member -MemberType NoteProperty -name USERNAME -value $u.EmailAddress
    $obj | add-member -MemberType NoteProperty -name FIRSTNAME -value $u.givenName
    $obj | add-member -MemberType NoteProperty -name LASTNAME -value $u.surName
    $obj | add-member -MemberType NoteProperty -name STATUS -value $Status
    $obj | add-member -MemberType NoteProperty -name EmployeeType -value $u.employeeType
    $obj | add-member -MemberType NoteProperty -name EMAIL -value $u.EmailAddress
    $obj | add-member -MemberType NoteProperty -name TITLE -value $u.Title
    $obj | add-member -MemberType NoteProperty -name DEPARTMENT -value $u.Department
    $obj | add-member -MemberType NoteProperty -name MANAGER -value (Get-AdUser $u.Manager).samAccountName
    $obj | add-member -MemberType NoteProperty -name CREATEDATE -value $u.whenCreated


    $exp += $obj    
}

$exp | Export-csv -path "C:\Scripts\APR_ADExportSOX_$date.csv" -NoTypeInformation