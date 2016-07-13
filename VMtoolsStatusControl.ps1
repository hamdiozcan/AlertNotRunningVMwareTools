# PowerShell VMtoolsStatusControl
# July 2016 Hamdi OZCAN http://ozcan.com
# task schedule 
# C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe -file C:\PowerCLI\VMtoolsStatusControl.ps1

add-pssnapin VMware.VimAutomation.Core
Connect-VIServer vcenterHostName

[System.Collections.ArrayList]$A1 = @("placeholder")
[System.Array]$A2 = @()
$OutputMail = ""

$A2 = gc "C:\PowerCLI\VMtoolsStatusControl.txt"
if (!$A2) {$A2 += "placeholder"}

ForEach ($VM in Get-Cluster CLUSTER_NAME | Get-VM | where-object {($_.extensiondata.Guest.ToolsStatus -eq "toolsNotRunning")} ) 
{
$A1 += $VM.Name
}

ForEach ($VM in Compare-Object $A1 $A2 | Where-Object { $_.SideIndicator -eq "<=" } ) 
{
$OutputMail = $OutputMail + $VM.InputObject + "`n"
$VM.InputObject >> "C:\PowerCLI\VMtoolsStatusControl.txt"
}

ForEach ($VM in Compare-Object $A1 $A2 | Where-Object { $_.SideIndicator -eq "=>" } )
{
$A1.Remove($VM.InputObject)
$A1 > "C:\PowerCLI\VMtoolsStatusControl.txt"
}

if ($OutputMail) {send-mailmessage -to "mailme@mailme.com" -from "VMwareTools <vcenter@vcenter.local>" -subject "VMwareTools Not Running" -body $OutputMail -smtpServer mail.mailme.com}

Disconnect-VIServer -Force -Confirm:$false
#Remove-PSSnapin -Name VMWare.VimAutomation.Core
