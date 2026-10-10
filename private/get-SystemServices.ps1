function get-SystemServices {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	if ($IsLinux -or $IsMacOS) {
		Invoke-Expression "systemctl list-units --type=service --no-pager --legend=false --output=json" | ConvertFrom-Json | Select-Object -First $MaxItems
	} else {
		Get-Service |
			Sort-Object Name |
				Select-Object Name, DisplayName, StartType, Status -First $MaxItems
	}
}