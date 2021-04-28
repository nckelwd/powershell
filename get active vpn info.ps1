write-host "------------------------------"
write-host "Active VPN Connections"
write-host "------------------------------"
 
$servername = "server1","server2"
$date = get-date
$Export = new-object psobject
$Export | Add-Member -MemberType NoteProperty -Name "Date_Time" -Value $date 
 
foreach($srv in $servername)
{
    $vpn = Get-RemoteAccessConnectionStatisticsSummary -ComputerName $srv    
    $Export | Add-Member -MemberType NoteProperty -Name $srv -Value $vpn.TotalVPNConnections     
}
 

$Export | export-csv -Path "path" -NoTypeInformation -Append