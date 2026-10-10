function get-SystemSummary {
	param()
	if ($IsLinux) {
		$Results.System = @{
			ComputerName  = $(hostname)
			User          = $env:USER
			Uptime        = $(uptime --pretty)
			OSVersion     = (Get-Content '/etc/os-release' | Where-Object { $_ -like 'PRETTY_NAME=*' } | ForEach-Object { $_ -replace 'PRETTY_NAME="', '' -replace '"', '' })
			Manufacturer  = (hostnamectl | Where-Object { $_.Trim() -like 'Hardware Vendor*' } | ForEach-Object { $_.Trim() -replace 'Hardware Vendor: ', '' })
			Model         = (hostnamectl | Where-Object { $_.Trim() -like 'Hardware Model*' } | ForEach-Object { $_.Trim() -replace 'Hardware Model: ', '' })
			BIOSVersion   = (hostnamectl | Where-Object { $_.Trim() -like 'Firmware Version*' } | ForEach-Object { $_.Trim() -replace 'Firmware Version: ', '' })
			KernelVersion = (hostnamectl | Where-Object { $_.Trim() -like 'Kernel*' } | ForEach-Object { $_.Trim() -replace 'Kernel: ', '' })
		}
	} else {
		$Results.System = @{
			ComputerName = $env:COMPUTERNAME
			User         = $env:USERNAME
			Uptime       = (Get-Date) - ((Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime)
			OSVersion    = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
			Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
			Model        = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
			BIOSVersion  = (Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion
		}
	}
}