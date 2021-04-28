Start-WebAppPool -Name "AssignmentPro"
Start-WebAppPool -Name "DefaultAppPool"
Start-WebAppPool -Name "Lexicon360"
Start-WebAppPool -Name "MobileSite"
Start-WebAppPool -Name "Registration"

Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Lexicon360 AppPools started" | Out-file C:\Scripts\IISStopStartLog.txt -append