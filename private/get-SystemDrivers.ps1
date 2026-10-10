function get-SystemDrivers {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	if ($IsLinux -or $IsMacOS) {
		$drvNames = lsmod | tail -n +2 | awk '{print $1}' | Sort-Object | Select-Object -First $MaxItems
		foreach ($drv in $drvNames) {
			$ver = $null; $v1 = $null; $v2 = $null
			$ver = modinfo $drv | grep 'version' | awk '{print $2}'
			if ($ver.Count -gt 1) {
				$v1 = $ver[0]
				$v2 = $ver[1]
			} else {
				$v1 = $ver[0]
				$v2 = $null
			}
			[pscustomobject]@{
				Name       = $drv
				Version    = $v1
				SrcVersion = $v2
			}
		}
	} else {
		Get-CimInstance -ClassName Win32_PnPSignedDriver |
			Select-Object -First $MaxItems DeviceID,DriverVersion,Manufacturer,Description
	}
}