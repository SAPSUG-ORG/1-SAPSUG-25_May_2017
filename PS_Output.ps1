#region variables

$script:dateTime = Get-Date
$script:logdateTime = Get-Date -format M.d.yyyy.hh.mm.ss
$script:LogPath = 'C:\Demo' #logging location
$script:LogFile = "Demo-$script:logdateTime.txt" #logging file
$script:willWeLog = $true #enable logging

#endregion

#region supportingFunction

<#
.SYNOPSIS
Write-Log Cmdlet will create and log file entry in a text file.
.DESCRIPTION
Creates a log file if missing and append Log messages with a predefined EntryType as Info, Warn or Error. 
.EXAMPLE
Write-Log -Message 'Good news today' -EntryType Info -LogFileName $logfile -LogFilePath $lpath
Create a new Information log entry
.EXAMPLE
Write-Log -Message 'Warning to all' -EntryType Warn -LogFileName $logfile -LogFilePath $lpath
Create a new Warning log entry
.EXAMPLE
Write-Log -Message 'exploded today' -EntryType Error -LogFileName $logfile -LogFilePath $lpath
Create a new Error log entry
.OUTPUTS
   C:\rs-pkgs\rswinrm.txt
.NOTES
   Used for logging all actions performed on the server in regards to WinRM actions
#>
function Write-Log {
	[CmdletBinding()]
	Param
	(
		[string]$Message,
		[ValidateSet('Info', 'Warn', 'Error')]
		[string]$EntryType,
		[string]$LogFilePath = $LogPath,
		[string]$LogFileName = $LogFile
	)
	begin {
		$LogPath = @($LogFilePath, $LogFileName -join '\')
	}
	process {
		try {
			# Create Log File
			if (-not (Test-Path $LogPath)) {
				$LogFilePathOut = New-Item -Path $LogFilePath -ItemType Directory -ErrorAction SilentlyContinue
				$LogPathOut = New-Item -Path $LogFileName -ItemType File -ErrorAction SilentlyContinue
				if ($LogPathOut.Exists) {
					Write-Verbose -Message "[$(Get-Date)] Info  :: $LogPath was created"
				}
			}
			$LogMessagePrefix = if ($EntryType -eq 'Error') {
				"[$(Get-Date)] $EntryType ::"
			}
			else {
				"[$(Get-Date)] $EntryType  ::"
			}
			Add-Content $LogPath -Value @("$LogMessagePrefix $Message")
			
			Write-Output -InputObject @("$LogMessagePrefix $Message")
		}
		catch [Exception]
		{
			Write-Output -InputObject "[$(Get-Date)] Info  :: $($MyInvocation.MyCommand)"
			Write-Output -InputObject "[$(Get-Date)] Error :: $_ "
		}
	}
}

#endregion

#region functionExamples

function Get-ServiceStatusVerbose {
	[CmdletBinding()]
	param ()
	try {
		$serviceName = Read-Host "Please Enter a Service Name"
		Write-Verbose "Checking status of $serviceName ..."
		$service = Get-Service -Name $serviceName
		$serviceStatus = $service.Status
		Write-Verbose "$serviceName current status: $serviceStatus"
	}
	catch {
		$PSCmdlet.ThrowTerminatingError($_)
	}
	Write-Verbose "Returning status..."
	return $serviceStatus
}

#uh-oh this doesn't seem to be what we're looking for!
function Get-ServiceStatusOutput {
	[CmdletBinding()]
	param ()
	
	try {
		$serviceName = Read-Host "Please Enter a Service Name"
		$service = Get-Service -Name $serviceName
		$serviceStatus = $service.Status
		Write-Output "$serviceName current status: $serviceStatus" -ForegroundColor Cyan
	}
	catch {
		$PSCmdlet.ThrowTerminatingError($_)
	}
	return $serviceStatus
}

function Get-ServiceIdeal {
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$ServiceName
	)
	
	try {
		Write-Verbose "Checking status of $serviceName ..."
		$service = Get-Service -Name $serviceName
		$serviceStatus = $service.Status
		Write-Verbose "$serviceName current status: $serviceStatus"
	}
	catch {
		$PSCmdlet.ThrowTerminatingError($_)
	}
	Write-Verbose "Returning status..."
	return $serviceStatus
}

#endregion
<#
blog post about write-host
http://www.jsnover.com/blog/2013/12/07/write-host-considered-harmful/
Windows PowerShell: The Many Options for Out
https://technet.microsoft.com/en-us/library/gg213852.aspx
#>

#lets do an example of write-host
try {
	$serviceName = Read-Host "Please Enter a Service Name"
	$service = Get-Service -Name $serviceName
	$serviceStatus = $service.Status
	Write-Host "$serviceName current status: $serviceStatus" -ForegroundColor Cyan
}
catch {
	throw
}

#write-output - you've been using it all along because it writes to the pipeline!
Get-Service

Get-Service | Write-Output

#contrast the two
$a = 'Testing Write-OutPut' | Write-Output
$b = 'Testing Write-Host' | Write-Host

Get-Variable a, b

#example with logging
$serviceName = "BITS"
Write-Log -EntryType Info "Getting the Service status for $serviceName"
$serviceStatus = Get-ServiceIdeal -ServiceName $serviceName
if ($serviceStatus -ne $null -and $serviceStatus -ne "") {
	Write-Log -EntryType Info "$serviceName status: $serviceStatus"
}
else {
	Write-Log -EntryType Error "Unable to determine the Service status for $serviceName"
}