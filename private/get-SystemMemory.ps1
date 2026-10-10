function get-SystemMemory {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	if ($IsLinux -or $IsMacOS) {
		Get-MemoryInfo | Select-Object @{Name='TimeStamp';Expression={Get-Date}}, MemTotal, MemFree
	} else {
		Get-Counter '\Memory\Available MBytes'
	}
}