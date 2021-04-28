Stop-Service -Name 'Grow Data Event Server'
Start-Sleep -s 10
Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Grow Data Event Server stopped" | Out-file C:\Scripts\GrowStopStartLog.txt -append
Stop-Service -Name 'Grow Workflow Server'
Start-Sleep -s 10
Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Grow Workflow Server stopped" | Out-file C:\Scripts\GrowStopStartLog.txt -append
Stop-Service -Name 'Grow Services'
Start-Sleep -s 10
Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Grow Services stopped" | Out-file C:\Scripts\GrowStopStartLog.txt -append