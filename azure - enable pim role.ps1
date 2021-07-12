Install-Module "Microsoft.Azure.ActiveDirectory.PIM.PSModule"

$roleid = Get-PrivilegedRoleAssignment | Where-Object {$_.RoleName -eq "Global Administrator"}

Enable-PrivilegedRoleAssignment -TicketNumber "I376524" -Reason "Handling SharePoint issue" -Duration 2 -RoleId $roleid
