#Install-Module -Name MicrosoftTeams -Force -AllowClobber -Scope CurrentUser

#Connect-MicrosoftTeams

Get-CsGroupPolicyAssignment -PolicyType TeamsAppSetupPolicy

Get-CsOnlineUser -Filter {TeamsAppSetupPolicy -eq "TB Test"} | select DisplayName, userPrincipalName, Identity

#Disconnect-MicrosoftTeams