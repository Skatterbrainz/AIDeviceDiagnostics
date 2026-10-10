function get-SystemDisks {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	if ($IsLinux -or $IsMacOS) {
		Get-DiskInfo |
			Select-Object -First $MaxItems *
	} else {
		Get-Volume |
			Select-Object -First $MaxItems DriveLetter, SizeRemaining, Size
	}
}