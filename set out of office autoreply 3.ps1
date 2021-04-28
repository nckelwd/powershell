#Connect to Office 365 / Outlook Live
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-host  "This script will disable and set to blank to auto reply for the email address you enter below."

$Email = Read-Host -Prompt 'Input the email address that you would like to update'

Set-MailboxAutoReplyConfiguration -Identity $Email –InternalMessage " " –ExternalMessage " " -AutoReplyState Disabled


Remove-PSSession $Session