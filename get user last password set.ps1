
function ADPWSearch {

$namesearch = Read-Host 'What is the username?'
$filter = 'sAMAccountName -eq $namesearch'
$users = Get-ADUser -Filter $filter -Properties * |  select enabled, displayname, description, physicalDeliveryOfficeName, emailaddress, "msDS-cloudExtensionAttribute5", @{name ="pwdLastSet";` expression={[datetime]::FromFileTime($_.pwdLastSet)}}

if ($users) {
    $users
    ADPWRetry
}
else {
    Write-Host $namesearch "does not exist."
    ADPWRetry
}

}

function ADPWRetry {

$tryagain = Read-Host 'Search another user? Use Y or N to proceed.'

if ($tryagain -eq "Y") {
    ADPWSearch
}
elseif ($tryagain -eq "N") {
    Write-host "Quit searching."
    exit
}
else {
    Write-host "Invaild response. Quit searching."
    exit
}
}

ADPWSearch