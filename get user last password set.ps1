$namesearch = Read-Host 'What is the username?'

$filter = 'sAMAccountName -eq $namesearch'
$users = Get-ADUser -Filter $filter -Properties * |  select enabled, displayname, description, physicalDeliveryOfficeName, emailaddress, @{name ="pwdLastSet";` expression={[datetime]::FromFileTime($_.pwdLastSet)}}


$users