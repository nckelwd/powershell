$users = @(Get-ADGroupMember -Identity '<groupname>')
$users.count