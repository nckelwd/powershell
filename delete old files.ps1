#Days older than
$HowOld = -1

#Path to the root folder
$Path = "path"

#Get the files to delete
$filesToDelete = Get-ChildItem -Path $Path -File -Recurse | Where {$_.lastwritetime -lt (Get-Date).AddDays($HowOld)}

#Delete the files
$filesToDelete | Remove-Item -Force -WhatIf