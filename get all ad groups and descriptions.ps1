Import-Module Activedirectory

$savePAth = "C:\Scripts\ADCounter.csv"

$Groups = Get-ADGroup -filter {GroupCategory -eq 'security'} -Properties * | Select-Object SAMAccountName | Export-Csv $savePAth

Import-Csv $savePAth
$Results = @()

foreach ($G in $Groups) {
    $num = (Get-ADGroup -Properties *).Member.Count
    ##Write-Host "the group" $g.SamAccountName "has" $num.count "users"
    ##$G | Add-Member -MemberType NoteProperty -Name $g -Value $num.count
    $G | Add-Member -MemberType NoteProperty -Name "UserCount" -Value $g.$num
    $Results += $G
}

$Results | Export-Csv "C:\Scripts\ADCounter.csv" -NoTypeInformation -Append