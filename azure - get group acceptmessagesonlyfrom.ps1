Connect-ExchangeOnline
$groupname = "DL-AllLocations-All"

Get-UnifiedGroup -Identity $groupname | select -expandproperty AcceptMessagesOnlyFrom