Import-Module Activedirectory

Get-ADGroup -filter * -properties *|select SAMAccountName, Description|Export-Csv -Path c:\Scripts\ADGroupList.csv