Get-ADOrganizationalUnit -Filter * -properties canonicalname |select canonicalname | Export-CSV -Path "C:\scripts\ADorg.csv"