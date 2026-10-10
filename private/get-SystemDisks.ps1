function get-SystemDisks {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	if ($IsLinux -or $IsMacOS) {
		Get-PSDrive -PSProvider FileSystem |
			Sort-Object Name |
			Select-Object -First $MaxItems `
				Name, Root, `
				@{Name='Free';Expression={$_.Free}}, `
				@{Name='Used';Expression={$_.Used}}, `
				@{Name='Total';Expression={$_.Used + $_.Free}}
	} else {
		Get-Volume |
			Select-Object -First $MaxItems DriveLetter, SizeRemaining, Size
	}
}