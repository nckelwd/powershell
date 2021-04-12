write-host "------------------------------"
write-host "Active VPN Connections"
write-host "------------------------------"

#add server names here
$servername = "server1","server2"
 
foreach($srv in $servername)
{
    $vpn = Get-RemoteAccessConnectionStatistics -ComputerName $srv  
    $vpn | select @{n='Username'; e={$_.Username[0]}} , ClientIPAddress | export-csv -Path "path" -NoTypeInformation -Append
}