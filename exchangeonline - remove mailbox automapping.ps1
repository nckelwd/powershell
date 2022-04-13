Connect-ExchangeOnline
<#
$userEmails = {"marco.castillo@aprenergy.com",
"richard.chavez@aprenergy.com",
"jeron.derama@aprenergy.com",
"wilmar.gomez@aprenergy.com",
"antar.hammouche@aprenergy.com",
"medardo.hernandez@aprenergy.com",
"juan.huerta@aprenergy.com",
"wilfredo.kaw@aprenergy.com",
"jesus.lugo@aprenergy.com",
"luis.miranda@aprenergy.com",
"javier.ortega@aprenergy.com",
"yamil.jeran.ortega@aprenergy.com",
"romelito.perodes@aprenergy.com",
"hector.rangel@aprenergy.com",
"daniel.robles@aprenergy.com",
"antonio.rodriguez@aprenergy.com",
"laura.rodriguez@aprenergy.com",
"arnold.sevillano@aprenergy.com",
"miguel.tellez@aprenergy.com",
"nirson.toj@aprenergy.com",
"nilo.vasquez@aprenergy.com",
"jorge.pimentel@aprenergy.com"}
#>
<#
$userEmails = ("mario.barajas@aprenergy.com",
"roberto.blanco@aprenergy.com")
#>

$userEmails = (
"marco.castillo@aprenergy.com",
"richard.chavez@aprenergy.com",
"jeron.derama@aprenergy.com",
"wilmar.gomez@aprenergy.com",
"medardo.hernandez@aprenergy.com",
"yamil.jeran.ortega@aprenergy.com",
"nirson.toj@aprenergy.com",
"jorge.pimentel@aprenergy.com"
)

foreach ($u in $userEmails) {
Add-MailboxPermission -Identity $u -User "Carlos.Alvarez@aprenergy.com" -AccessRights FullAccess -InheritanceType All -Automapping $false
}