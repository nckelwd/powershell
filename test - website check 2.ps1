$IE = new-object -comObject 'internetexplorer.application'
$IE.visible=$true

$username = "helpdesk"
$password = "h3lpd3$k"

$IE.navigate2("xen.suddath.com")

While ($IE.Busy -eq $true) {Start-Sleep -Seconds 2;}

$usernamefield = $IE.document.getElementByID('user')
$usernamefield.value = "$username"

$passwordfield = $IE.document.getElementByID('password')
$passwordfield.value = "$password"

$Link = $IE.document.getElementByID('btnLogin')
$Link.click()

