$date = (get-date)
$14daysago = ($date).AddDays(-14).ToString("MM/dd/yyyy")
$disabledou =  "OU=Disabled - Email Active,OU=APR,DC=aprenergy,DC=local"
$properties = "Enabled", "employeeID", "GivenName", "surname", "EmailAddress", "samAccountName", "info", "msDS-CloudExtensionAttribute3"
$filter = "(Enabled -eq 'false')"
$users = Get-ADUser -Filter $filter -SearchBase $disabledou -Properties $properties |  select $properties

function checkTermDate{
    if ("msDS-CloudExtensionAttribute3" -eq "<not set>") {
        Write-Host $u.samAccountName $u.'msDS-CloudExtensionAttribute3' "manual" -ForegroundColor Yellow
    }
    elseif ("msDS-CloudExtensionAttribute3" -ge $14daysago) {
        Write-Host $u.samAccountName $u.'msDS-CloudExtensionAttribute3' "this tracks" -ForegroundColor Green
    } 
    else {
        Write-Host $u.samAccountName $u.'msDS-CloudExtensionAttribute3' "nope" -ForegroundColor Red
    }
}

#loop through users
foreach ($u in $users) {
    checkTermDate
}




#contains Termination date
#"msDS-CloudExtensionAttribute3"="$date"
