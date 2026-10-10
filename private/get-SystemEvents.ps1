function get-SystemEvents {
	param(
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	$result = @()
	if ($IsLinux -or $IsMacOS) {
		$cmdstring = "journalctl --reverse --lines=$MaxItems --no-pager --output-fields=MESSAGE,PRIORITY,_CMDLINE,_EXE,SYSLOG_IDENTIFIER --output=json"
		Write-Verbose "command: $cmdstring"
		$rows = Invoke-Expression $cmdstring
		foreach ($row in $rows) {
			$result += $row | ConvertFrom-Json | Select-Object @{l='TimeStamp';e={ConvertFrom-UNIXTime $_.'__REALTIME_TIMESTAMP'}},PRIORITY,_CMDLINE,_EXE,SYSLOG_IDENTIFIER,MESSAGE
		}
	} else {
		$result =
			Get-WinEvent -LogName System -MaxEvents $MaxItems |
				Where-Object { $_.LevelDisplayName -in ('Error','Warning') } |
					Select-Object TimeCreated, LogName, Id, LevelDisplayName, ProviderName, Message
		$result +=
			Get-WinEvent -LogName Application -MaxEvents $MaxItems |
				Where-Object { $_.LevelDisplayName -in ('Error','Warning') } |
					Select-Object TimeCreated, LogName, Id, LevelDisplayName, ProviderName, Message
	}
	return $result
}
