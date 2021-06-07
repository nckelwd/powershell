Get-WmiObject Win32_Product | Where-Object {$_.Name -like "TeamViewer 11 Host*"} | Select-Object -ExpandProperty IdentifyingNumber
