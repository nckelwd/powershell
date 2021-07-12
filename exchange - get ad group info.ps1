Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Get-UnifiedGroup -Identity "cloudadminteam" | Format-List DisplayName,EmailAddresses,Notes,ManagedBy,AccessType

Disconnect-ExchangeOnline