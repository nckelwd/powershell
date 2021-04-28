#******VPN Auditing Script********

#This script will get a list of all Enabled users belonging to the group SSLVPN-Users and add them to an array
#Then it will get a list of all the enabled users with the dialInTab set to True
#Finally it runs through a loop and compares the samaccount name from the users who are in the "sslvpn-users" group to the members of the Dial-In Group. 
#They are found then their name is added to the next line in a CSV file. 

$groupMembers = @(Get-adgroupmember -identity "sslvpn-users" -Recursive | %{Get-ADUser -Identity $_.distinguishedName -Properties Enabled })
$dialIn = @(Get-ADUser -LDAPFilter "(&(objectCategory=person)(objectClass=user)(msNPAllowDialin=TRUE))" | %{Get-ADUser -Identity $_.distinguishedName -Properties Enabled })

foreach ($User in $groupMembers)
{
    if ($user.samaccountname -in $dialIn.samaccountname)
    {
        $user.UserPrincipalName | out-file -append "c:\scripts\VPNAudit.csv"
    }
}

