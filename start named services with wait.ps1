Start-Service -Name 'Grow Services'
Start-Sleep -s 10
Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Grow Services Started" | Out-file C:\Scripts\GrowStopStartLog.txt -append
Start-Service -Name 'Grow Workflow Server'
Start-Sleep -s 10
Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Grow Workflow Server Started" | Out-file C:\Scripts\GrowStopStartLog.txt -append
Start-Service -Name 'Grow Data Event Server'
Start-Sleep -s 10
Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Grow Data Event Server Started" | Out-file C:\Scripts\GrowStopStartLog.txt -append