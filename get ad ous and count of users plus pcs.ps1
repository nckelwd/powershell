$results = Get-ADOrganizationalUnit -Properties CanonicalName -Filter * | Sort-Object CanonicalName |
ForEach-Object {
    [pscustomobject]@{
        Name          = Split-Path $_.CanonicalName -Leaf
        CanonicalName = $_.CanonicalName
        UserCount     = @(Get-AdUser -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count
        ComputerCount = @(Get-AdComputer -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count
    }
}
$results | Export-Csv -Path C:\scripts\export_OUs.csv -NoTypeInformation