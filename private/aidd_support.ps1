function ConvertFrom-UNIXTime {
	param(
		[parameter(Mandatory=$true)]$DateValue
	)
	if ([string]::IsNullOrEmpty($DateValue)) {
		return $null
	}
	$ts = [long]$DateValue
	[DateTimeOffset]::FromUnixTimeMilliseconds($ts / 1000).LocalDateTime
}

