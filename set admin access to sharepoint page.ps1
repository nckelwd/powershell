#sharepoint online enable custom scripts powershell - Disable DenyAddAndCustomizePages Flag
Set-SPOSite $SiteURL -DenyAddAndCustomizePages $False
$url = "https://aprenergyholdingslimited-my.sharepoint.com/personal/david_dorman_aprenergy_com"
Get-SPOSite $url | fl
 
get-sposite $url | select owner 
 
set-spouser -Site $url -LoginName Ballard.Barker@aprenergy.com -IsSiteCollectionAdmin $true