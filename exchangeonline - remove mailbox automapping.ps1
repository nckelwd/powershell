Connect-ExchangeOnline

#add the target user email address here. This is the person who has access to the mailbox and wants it/them removed
$user = "bernardo.hobrecht@aprenergy.com"

#enter in all the delegate email address you want to remove from the user
$delegateEmails = ("ivan.achaga@aprenergy.com")

foreach ($d in $delegateEmails) {
Add-MailboxPermission -Identity $d -User $user -AccessRights FullAccess -InheritanceType All -Automapping $false
}

Disconnect-ExchangeOnline