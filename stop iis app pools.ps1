Stop-WebAppPool -Name "AssignmentPro"
Stop-WebAppPool -Name "DefaultAppPool"
Stop-WebAppPool -Name "Lexicon360"
Stop-WebAppPool -Name "MobileSite"
Stop-WebAppPool -Name "Registration"

Write-Output "$('[{0:MM/dd/yyyy} {0:HH:mm:ss}]' -f (Get-Date)) Lexicon360 AppPools stopped" | Out-file C:\Scripts\IISStopStartLog.txt -append