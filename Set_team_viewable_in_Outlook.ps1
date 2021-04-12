$CloudCredential=Get-Credential
connect-msolservice -credential $CloudCredential 
$CloudSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $CloudCredential -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue

Import-PSSession $CloudSession

Set-UnifiedGroup -Identity "MSPersonnel" -HiddenFromExchangeClientsEnabled:$false