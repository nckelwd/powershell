#Connect to Azure AD
Connect-AzureAD
 
#Create new Office 365 group
#New-AzureADMSGroup -DisplayName "Accounts Group" -MailNickname "Accounts" -GroupTypes "Unified" -Description "Office 365 Group for Accounts Departmnet" -MailEnabled $True -SecurityEnabled $True


Get-AzureADMSGroup -SearchString "cloudadminteam"
Get-AzureADGroup -SearchString "cloudadminteam"