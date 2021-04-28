$groupMembers = @(Get-adgroupmember -identity "sslvpn-users" -Recursive | %{Get-ADUser -Identity $_.distinguishedName -Properties Enabled })
foreach ($User in $groupMembers)
{    
        $user.UserPrincipalName | out-file -append "c:\scripts\SSLVPNUserGroup.csv"    
}

$dialIn = @(Get-ADUser -LDAPFilter "(&(objectCategory=person)(objectClass=user)(msNPAllowDialin=TRUE))" | %{Get-ADUser -Identity $_.distinguishedName -Properties Enabled })

foreach ($di in $groupMembers)
{    
        $di.UserPrincipalName | out-file -append "c:\scripts\Dialin.csv"    
}