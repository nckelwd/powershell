Connect-ExchangeOnline

$groupname = "DL-Jacksonville-Employees"

Get-UnifiedGroup -Identity $groupname |select -expandproperty AcceptMessagesOnlyFrom | fl