#Connect to Office 365 / Outlook Live
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-host -foregroundcolor "Green"  "`nThis script will Enable and set auto reply for the email address you enter below.`n"

$Email = Read-Host -Prompt 'Input the email address that you would like to update'
$message = Read-Host -Prompt 'Enter the message'

Set-MailboxAutoReplyConfiguration -Identity $Email –InternalMessage $message –ExternalMessage $message -AutoReplyState enabled


Remove-PSSession $Session