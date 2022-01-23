<###################################################################################################
.SYNOPSIS
    Run an infinite ping test and concat boolean results to a log file.

.DESCRIPTION
    Run an infinite ping test and concat boolean results to a log file. Only logs time and True (if 
	test was successful) or False (if test was not successful). Outputs 5 second error box on failures.
	CTRL + C to end.

.INPUTS
	$address    
	Name or IP address of the target.

	$file
	The name of the output file (w/ extension).    

.OUTPUTS
	None directly, but creates a log file specified by the user in $file.

.EXAMPLE
	# Run the script to start logging to $file
	.\pingTest.ps1

	### In another PoSh window you can run the following: ###
		# Get tail end of log
		$file = ".\myFile.log"
		Get-Content .\$file -Wait

		# Get # of failed pings
		$failed = (Select-String -Path $file -Pattern "False" -AllMatches).Matches.Count
		$failed

		# Get # of successful pings
		$success = (Select-String -Path $file -Pattern "True" -AllMatches).Matches.Count
		$success

		# Get success rate
		($success / ($success + $failed)).tostring("P")
		
		# Get failure rate
		($failed / ($success + $failed)).tostring("P")

		# Get first result
		(Get-Content $file)[0]

		# Get last result
		Get-Content $file -Tail 1

		# Get last successful result
		(Get-Content $file | Where-Object { $_ -like "*True*"})[-1]

		# Get last failed result
		(Get-Content $file | Where-Object { $_ -like "*False*"})[-1]

.LINK
	https://github.com/rjmccallumbigl/PowerShell-Ping-Test

.NOTES
    Author: Ryan McCallum
    Last Modified: 01-22-2022
	Background: Trying to log how often wireless connectivity drops on my Raspberry Pi
    Version 0.2 - make the pop up box always on top
	TODO: replace $shell.popup with less obtrusive tooltip or tray popup
	Sources:
		https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-display-pop-up-window/
		https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/x83z1d9f(v=vs.84)?redirectedfrom=MSDN
		https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/using-pop-up-dialogs-that-are-always-visible

####################################################################################################>

param (
	[Parameter(Mandatory = $true, HelpMessage = "Name or IP address of the target.")]
	[Alias('a')]
	[string]
	$address,
	[Parameter(Mandatory = $true, HelpMessage = "The name of the output file (w/ extension).")]
	[Alias('f')]
	[string]
	$file
)

# Declare variables
$working = $true

# Run boolean ping test, send results to $file
while ($true) {
	$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$working = Test-NetConnection $address -InformationLevel Quiet
	$date + " - " + $working >> ".\$file"

	# Pops up window when ping test fails
	if (!$working) {		
		$shell = New-Object -ComObject wscript.shell -ErrorAction Stop
		$shellPopUp = $shell.popup("Raspberry Pi Connection Broken at $($date)!", 5, "Error", 4096) # 4096 is always on top, 0 is default
	}

	# Pause 5 seconds
	Start-Sleep -s 5
}
