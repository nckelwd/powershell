$username = Read-Host -Prompt "Input the username for AutoReply Configuration"

Get-ADUser -Identity $username

$confirmationUsername = Read-Host "Is this is the correct user? (Y/N)"

if ($confirmationUsername -eq 'y') {
	# proceed
}
else
{
	
	exit
}

$AutoReplyInternal = Read-Host -Prompt "Input the Internal AutoReply Message"

Write-Host "Your Internal AutoReply message is:"
Write-Host $AutoReplyInternal
Write-Host ""

$confirmationARI = Read-Host "Is the message correct? (Y/N)"

if ($confirmationARI -eq 'y') {
	# proceed
}
else
{
	exit
}

$ChoiceARE = Read-Host -Prompt "Should the External AutoReply match the Internal message? (Y/N)"

if ($ChoiceARE -eq 'y') {
	$AutoReplyExternal = $AutoReplyInternal
}
else
{
	$AutoReplyExternal = Read-Host "Input the External AutoReply Message"
}

Write-Host "Your External AutoReply Message is:"
Write-Host $AutoReplyExternal
Write-Host ""

$confirmationARE = Read-Host "Is the message correct? (Y/N)"

if ($confirmationARE -eq 'y') {
	# proceed
}
else
{
	exit
}


$ConfirmationSet = Read-Host -Prompt "Set AutoReply configuration for this user? (Y/N)"

if ($ConfirmationSet -eq 'y') {
	Set-MailboxAutoReplyConfiguration -Identity $username -AutoReplyState Enabled -InternalMessage $AutoReplyInternal -ExternalMessage $AutoReplyExternal

Write-Host ""
Write-Host "The autoreply message has been set."
}
else
{
	Write-Host ""
	Write-Host "You have cancelled the AutoReply Configuration. Please start the script again to continue."
}


