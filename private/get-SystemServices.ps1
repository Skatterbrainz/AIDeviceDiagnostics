function get-SystemServices {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	Get-Service |
		Sort-Object Name |
			Select-Object Name, DisplayName, StartType, Status -First $MaxItems
}