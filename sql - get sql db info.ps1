##### To install the SqlServer module:
#Install-Module -Name SqlServer

##### If there are previous versions of the SqlServer module on the computer, 
##### you may be able to use Update-Module (later in this article), or provide the -AllowClobber parameter:
#Install-Module -Name SqlServer -AllowClobber

##### If you are not able to run the PowerShell session as administrator, you can install for the current user:
#Install-Module -Name SqlServer -Scope CurrentUser

##### When updated versions of the SqlServer module are available, you can update the version using Update-Module:
#Update-Module -Name SqlServer

##### To view the versions of the module installed:
#Get-Module SqlServer -ListAvailable

##### To use a specific version of the module, you can import it with a specific version number similar to the following:
#Import-Module SqlServer -Version 21.1.18080


<# Unneccesary to Import-Module? 
push-location;
import-module sqlps;
Pop-Location;
#>

#####test folder paths on PC, create if none exist


$savePath = "C:\Users\Nicholas.Elwood\Desktop\SQLServers\$((get-date).ToString('yyyyMMdd'))"
If(!(test-path $savePath))
{md "$savePath"}


##### SQL Server Variables

$Servers = @(
"servername"
)

##### Runs the GP Users and Roles sql script

foreach ($Server in $Servers)
{
$SQLVER = invoke-sqlcmd -InputFile "C:\Users\Nicholas.Elwood\Desktop\SQLServers\SelectSQLVersion.sql" -serverinstance $Server -database master;
$SQLVER | Export-CSV "$savePath\Results_$((get-date).ToString('yyyyMMdd')).csv" -Append
}


$SQLVER = invoke-sqlcmd -InputFile "C:\Users\Nicholas.Elwood\Desktop\SQLServers\SelectSQLVersionEdison.sql" -serverinstance server\instance -database master;
$SQLVER | Export-CSV "$savePath\ResultsEdison_$((get-date).ToString('yyyyMMdd')).csv" -Append


###### Not needed if not importing module
#remove-module sqlps;