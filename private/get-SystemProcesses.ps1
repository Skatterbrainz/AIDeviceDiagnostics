function get-SystemProcesses {
	param (
		[parameter(Mandatory=$false)][int]$MaxItems = 100
	)
	Get-Process |
		Sort-Object CPU -Descending |
			Select-Object -First $MaxItems Name, Id, CPU, WorkingSet
}