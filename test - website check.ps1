$IE = new-object -com internetexplorer.application
$IE.visible=$true
$IE.navigate2("http://archiver.suddath.com")


While ($IE.Busy -eq $true) {Start-Sleep -Seconds 2;}

$AdvLink = $IE.document.getElementByID('advancesOptionsLnk')
$AdvLink.click()

$searchfield = $IE.document.getElementByID('ctl00_phMainContents_ctrAdvanceSearch_lvwIncCond_ctrl0_Condition_txtText')
$searchfield.value = "SOD"

$SearchLink = $IE.document.getElementByID('ctl00_phMainContents_ctrAdvanceSearch_btnAdvanceSearch')
$SearchLink.click()