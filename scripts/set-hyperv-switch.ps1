# See: https://www.thomasmaurer.ch/2016/01/change-hyper-v-vm-switch-of-virtual-machines-using-powershell/
param($vmname)
$switch_name = "VagrantNATSwitch"
Get-VM $vmname | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $switch_name
#Get-VM master | Get-VMNetworkAdapter | Connect-VMNetworkAdapter  -SwitchName VagrantNATSwitch