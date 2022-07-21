Connect-ExchangeOnline

#add the target user email address here. This is the person who has access to the mailbox and wants it/them removed
$user = "bernardo.hobrecht@aprenergy.com"

#enter in all the delegate email address you want to remove from the user
$delegateEmails = (
"Javier.Berge@aprenergy.com",
"Ariel.Bidart@aprenergy.com",
"Pedro.Brandan@aprenergy.com",
"Cristian.DelRio@aprenergy.com",
"Nazareno.Dulcce@aprenergy.com",
"Damian.Marinos@aprenergy.com",
"Facundo.Miraball@aprenergy.com",
"Jose.Montiel@aprenergy.com",
"Yolin.Moya@aprenergy.com",
"Diego.Quinteros@aprenergy.com",
"Luis.Rios@aprenergy.com",
"Marcelo.Rizzardi@aprenergy.com",
"Federico.Salinas@aprenergy.com",
"Jose.Santangelo@aprenergy.com",
"Lucas.Torrozzi@aprenergy.com",
"Matias.Venini@aprenergy.com")

foreach ($d in $delegateEmails) {
Add-MailboxPermission -Identity $d -User $user -AccessRights FullAccess -InheritanceType All -Automapping $false
}

Disconnect-ExchangeOnline