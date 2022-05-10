
<#

https://danielchronlund.com/2021/09/17/activate-your-azure-ad-pim-roles-with-powershell/

Install-Module -Name DCToolbox -Scope CurrentUser -Force
Install-Module -Name AzureADPreview -Scope CurrentUser -Force

Run this package as admin

Install-Package msal.ps -Force

#>


Connect-AzureAD


Enable-DCAzureADPIMRole -RolesToActivate 'Global Administrator' -UseMaxiumTimeAllowed -Reason 'Day to day work'
