$date = (Get-Date).ToString('MM-dd-yyyy')
$properties = "Enabled", "employeeID", "objectGUID", "UserPrincipalName", "GivenName", "surname", "EmailAddress", "manager", "Department", "City", "Title", "OfficePhone", "Fax", "StreetAddress", "State", "PostalCode", "Country", "employeetype", "Division", "Description", "physicalDeliveryOfficeName", "msDS-cloudExtensionAttribute1", "samAccountName"
$filter = "(Enabled -eq 'true') -and (EmployeeType -eq 'APR Employee') -and (employeeID -like '*')"
$users = Get-ADUser -Filter $filter -Properties $properties |  select $properties
$exp = @()

#loop through users
$count = 0
foreach ($u in $users) {
    if($count -eq 0){
        $obj = new-object PSObject 
        $obj | add-member -MemberType NoteProperty -name STATUS -value "STATUS"
        $obj | add-member -MemberType NoteProperty -name USERID -value "USERID"
        $obj | add-member -MemberType NoteProperty -name SamAccountName -value "SamAccountName"
        $obj | add-member -MemberType NoteProperty -name USERNAME -value "Username"
        $obj | add-member -MemberType NoteProperty -name FIRSTNAME -value "First Name"
        $obj | add-member -MemberType NoteProperty -name LASTNAME -value "Last Name"
        $obj | add-member -MemberType NoteProperty -name MI -value "Middle Name"
        $obj | add-member -MemberType NoteProperty -name GENDER -value "Gender"
        $obj | add-member -MemberType NoteProperty -name EMAIL -value "Email"
        $obj | add-member -MemberType NoteProperty -name MANAGER -value "Manager"
        $obj | add-member -MemberType NoteProperty -name HR -value "Human Resource"
        $obj | add-member -MemberType NoteProperty -name DEPARTMENT -value "Department"
        $obj | add-member -MemberType NoteProperty -name JOBCODE -value "Job Code"
        $obj | add-member -MemberType NoteProperty -name DIVISION -value "Division"
        $obj | add-member -MemberType NoteProperty -name LOCATION -value "Location"
        $obj | add-member -MemberType NoteProperty -name TIMEZONE -value "Time Zone"
        $obj | add-member -MemberType NoteProperty -name HIREDATE -value "Hire Date"
        $obj | add-member -MemberType NoteProperty -name COMPANYEXITDATE -value "Company Exit Date"
        $obj | add-member -MemberType NoteProperty -name EMPID -value "Employee Id"
        $obj | add-member -MemberType NoteProperty -name TITLE -value "Title"
        $obj | add-member -MemberType NoteProperty -name BIZ_PHONE -value "Business Phone"    
        $obj | add-member -MemberType NoteProperty -name FAX -value "Business Fax"
        $obj | add-member -MemberType NoteProperty -name ADDR1 -value "Address 1"
        $obj | add-member -MemberType NoteProperty -name ADDR2 -value "Address 2"
        $obj | add-member -MemberType NoteProperty -name CITY -value "City"
        $obj | add-member -MemberType NoteProperty -name STATE -value "State"
        $obj | add-member -MemberType NoteProperty -name ZIP -value "ZIP"
        $obj | add-member -MemberType NoteProperty -name COUNTRY -value "Country/Region"    
        $obj | add-member -MemberType NoteProperty -name REVIEW_FREQ -value "Review Frequency"
        $obj | add-member -MemberType NoteProperty -name LAST_REVIEW_DATE -value "Last Review Date"
        $obj | add-member -MemberType NoteProperty -name CUSTOM01 -value "Customizable Field 1"
        $obj | add-member -MemberType NoteProperty -name CUSTOM02 -value "Customizable Field 2"
        $obj | add-member -MemberType NoteProperty -name CUSTOM03 -value "Customizable Field 3"
        $obj | add-member -MemberType NoteProperty -name CUSTOM04 -value "Customizable Field 4"
        $obj | add-member -MemberType NoteProperty -name CUSTOM05 -value "Customizable Field 5"
        $obj | add-member -MemberType NoteProperty -name CUSTOM06 -value "Customizable Field 6"
        $obj | add-member -MemberType NoteProperty -name CUSTOM07 -value "Customizable Field 7"
        $obj | add-member -MemberType NoteProperty -name CUSTOM08 -value "Customizable Field 8"
        $obj | add-member -MemberType NoteProperty -name CUSTOM09 -value "Customizable Field 9"
        $obj | add-member -MemberType NoteProperty -name CUSTOM010 -value "Customizable Field 10"
        $obj | add-member -MemberType NoteProperty -name CUSTOM011 -value "Customizable Field 11"
        $obj | add-member -MemberType NoteProperty -name CUSTOM012 -value "Customizable Field 12"
        $obj | add-member -MemberType NoteProperty -name CUSTOM013 -value "Customizable Field 13"
        $obj | add-member -MemberType NoteProperty -name CUSTOM014 -value "Customizable Field 14"
        $obj | add-member -MemberType NoteProperty -name CUSTOM015 -value "Customizable Field 15"
        $obj | add-member -MemberType NoteProperty -name MATRIX_MANAGER -value "Matrix Manager"
        $obj | add-member -MemberType NoteProperty -name DEFAULT_LOCALE -value "Default Locale"
        $obj | add-member -MemberType NoteProperty -name PROXY -value "Proxy"
        $obj | add-member -MemberType NoteProperty -name CUSTOM_MANAGER -value "Custom Manager"
        $obj | add-member -MemberType NoteProperty -name SECOND_MANAGER -value "Second Manager"
        $obj | add-member -MemberType NoteProperty -name LOGIN_METHOD -value "Login Method"
        $obj | add-member -MemberType NoteProperty -name PERSON_ID_EXTERNAL -value "PERSON_ID_EXTERNAL"
        $obj | add-member -MemberType NoteProperty -name ASSIGNMENT_ID_EXTERNAL -value "Assignment ID"   

        $exp += $obj
        $count++    
    }
    #loads user attributes
    if($u.enabled -eq $true){
        $Status = "Active"
    }
    else{ $status = "Inactive"}

    $obj = new-object PSObject 
    $obj | add-member -MemberType NoteProperty -name STATUS -value $Status
    $obj | add-member -MemberType NoteProperty -name USERID -value $u.objectGUID
    $obj | add-member -MemberType NoteProperty -name SamAccountName -value $u.SamAccountName
    $obj | add-member -MemberType NoteProperty -name USERNAME -value $u.EmailAddress
    $obj | add-member -MemberType NoteProperty -name FIRSTNAME -value $u.givenName
    $obj | add-member -MemberType NoteProperty -name LASTNAME -value $u.surName
    $obj | add-member -MemberType NoteProperty -name MI -value ""
    $obj | add-member -MemberType NoteProperty -name GENDER -value $u."msDS-cloudExtensionAttribute1"
    $obj | add-member -MemberType NoteProperty -name EMAIL -value $u.EmailAddress
    $obj | add-member -MemberType NoteProperty -name MANAGER -value (Get-AdUser $u.Manager).objectGUID
    $obj | add-member -MemberType NoteProperty -name HR -value "aa30721f-d293-410f-8faf-88b80a1b7175"
    $obj | add-member -MemberType NoteProperty -name DEPARTMENT -value $u.Department
    $obj | add-member -MemberType NoteProperty -name JOBCODE -value ""
    $obj | add-member -MemberType NoteProperty -name DIVISION -value "APR"
    $obj | add-member -MemberType NoteProperty -name LOCATION -value $u.physicalDeliveryOfficeName
    $obj | add-member -MemberType NoteProperty -name TIMEZONE -value "EST"
    $obj | add-member -MemberType NoteProperty -name HIREDATE -value ""
    $obj | add-member -MemberType NoteProperty -name COMPANYEXITDATE -value ""
    $obj | add-member -MemberType NoteProperty -name EMPID -value $u.employeeid
    $obj | add-member -MemberType NoteProperty -name TITLE -value $u.Title
    $obj | add-member -MemberType NoteProperty -name BIZ_PHONE -value ""    
    $obj | add-member -MemberType NoteProperty -name FAX -value ""
    $obj | add-member -MemberType NoteProperty -name ADDR1 -value ""
    $obj | add-member -MemberType NoteProperty -name ADDR2 -value ""
    $obj | add-member -MemberType NoteProperty -name CITY -value ""
    $obj | add-member -MemberType NoteProperty -name STATE -value ""
    $obj | add-member -MemberType NoteProperty -name ZIP -value ""
    $obj | add-member -MemberType NoteProperty -name COUNTRY -value ""    
    $obj | add-member -MemberType NoteProperty -name REVIEW_FREQ -value ""
    $obj | add-member -MemberType NoteProperty -name LAST_REVIEW_DATE -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM01 -value $u.Division
    $obj | add-member -MemberType NoteProperty -name CUSTOM02 -value $u.Description
    $obj | add-member -MemberType NoteProperty -name CUSTOM03 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM04 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM05 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM06 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM07 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM08 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM09 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM010 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM011 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM012 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM013 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM014 -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM015 -value ""
    $obj | add-member -MemberType NoteProperty -name MATRIX_MANAGER -value ""
    $obj | add-member -MemberType NoteProperty -name DEFAULT_LOCALE -value "en_US"
    $obj | add-member -MemberType NoteProperty -name PROXY -value ""
    $obj | add-member -MemberType NoteProperty -name CUSTOM_MANAGER -value ""
    $obj | add-member -MemberType NoteProperty -name SECOND_MANAGER -value ""
    $obj | add-member -MemberType NoteProperty -name LOGIN_METHOD -value ""
    $obj | add-member -MemberType NoteProperty -name PERSON_ID_EXTERNAL -value ""
    $obj | add-member -MemberType NoteProperty -name ASSIGNMENT_ID_EXTERNAL -value ""    

    $exp += $obj    
}

$exp | Export-csv -path "C:\Scripts\APR_ADExport_$date.csv" -NoTypeInformation