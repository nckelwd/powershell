Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Add-MailboxPermission -Identity "IT Support Desk" -User "Nicholas.Elwood@aprenegy.com" -AccessRights FullAccess -InheritanceType All

#Add-RecipientPermission "IT Support Desk" -AccessRights SendAs -Trustee "Nicholas.Elwood@aprenergy.com"

Disconnect-ExchangeOnline