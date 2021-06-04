$token = Read-Host -Prompt "Enter your API account token now"
$bearer = "Bearer",$token
 
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("authorization", $bearer)
 
$request = Invoke-RestMethod -Uri "https://webapi.teamviewer.com/api/v1/devices" -Method Get -Headers $header
$request.devices | Select-Object -Property "remotecontrol_id","alias","online_state","last_seen","groupid" | Export-Csv "C:\Scripts\TVDevicesListExport4ne.csv"
 
$grequest = Invoke-RestMethod -Uri "https://webapi.teamviewer.com/api/v1/groups" -Method Get -Headers $header
$grequest.groups | Select-Object -Property "name","id" | Export-Csv “C:\Scripts\TVGroupsListExport5ne.csv"