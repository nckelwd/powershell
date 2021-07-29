$adminSiteURL = "https://aprenergyholdingslimited-admin.sharepoint.com"

$O365UsernameofSharingUser = "jennet.orasheva@aprenergy.com"

$UsertoGrantAccessTo = "nicholas.elwood@aprenergy.com"



Connect-SPOService -Url $adminSiteURL 



$FormattedSiteURL = "https://aprenergyholdingslimited-my.sharepoint.com/personal/" + ($O365UsernameofSharingUser -Replace ("\.|\@",'_'))

Get-SPOUser -Site $FormattedSiteURL | where {$_.IsSiteAdmin} | fl

Get-SPOUser -Site $FormattedSiteURL | fl



Get-SPOUser -Site $FormattedSiteURL -Limit all | Select-Object DisplayName, LoginName, IsSiteAdmin | Sort-Object IsSiteAdmin, DisplayName | Format-Table -GroupBy IsSiteAdmin -AutoSize



set-spouser -Site $FormattedSiteURL -LoginName $UsertoGrantAccessTo -IsSiteCollectionAdmin $true