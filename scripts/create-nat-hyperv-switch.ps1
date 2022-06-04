$switch_name = "VagrantNATSwitch"
$ip_addr = "192.168.100.1"
$ip_prefix = "24"
$ip_addr_prefix = "192.168.100.0/24"
$network_name = "VagrantNATNetwork"

if ($switch_name -notin (Get-VMSwitch | Select-Object -ExpandProperty Name)) {
    New-VMSwitch -Name $switch_name -SwitchType Internal
} else {
    Set-VMSwitch -Name $switch_name -SwitchType Internal
}

$vmnet_adapter = Get-VMNetworkAdapter -ManagementOS -SwitchName $switch_name

$network_adapter = Get-NetAdapter | ? { $_.DeviceID -eq $vmnet_adapter.DeviceID }

if ($network_adapter | Get-NetIPAddress -IPAddress $ip_addr -ErrorAction SilentlyContinue) {
    $network_adapter | Disable-NetAdapterBinding -ComponentID ms_server -ErrorAction SilentlyContinue
    $network_adapter | Enable-NetAdapterBinding -ComponentID ms_server -ErrorAction SilentlyContinue
} else {
    $network_adapter | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
    $network_adapter | Set-NetIPInterface -Dhcp Disabled -ErrorAction SilentlyContinue
    $network_adapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress $ip_addr -PrefixLength $ip_prefix -ErrorAction Stop | Out-Null
}

$interface_alias = $network_adapter.Name
Set-NetConnectionProfile -InterfaceAlias $interface_alias -NetworkCategory Private

if ($ip_addr_prefix -notin (Get-NetNAT | Select-Object -ExpandProperty InternalIPInterfaceAddressPrefix)) {
    New-NetNAT -Name $network_name -InternalIPInterfaceAddressPrefix $ip_addr_prefix
} else {
    Write-Host ("{0} for static IP configuration already exists. skipping" -F $ip_addr_prefix)
}