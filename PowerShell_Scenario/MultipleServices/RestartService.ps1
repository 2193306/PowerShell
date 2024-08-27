## Restarting of Multiple Windows Services using powershell as well as scheduling through windows task scheduler. 

## Before starting on this you should have basic idea about windows task scheduler, inbuilt powershell variables and basic knowledge of
## loops, and statements.  

## This task majorly focuses on Restarting multiple windows ( custome deployed ) services on daily bases and generate log file and store them.
## Which will helps us to trouble shoot the applications and making our lifes easy!!


## Thumb rule of any development whether it is declerative or imperating scriptings no one should use the main template file. It should remain 
## constant. So, I am using XML to parse the services names. You can write end number of services in this XML file. 


# Create a Folder Structure:

# C:\ServiceConfig\ - This folder will contain the Services.xml file.
# C:\ServiceLogs\ - This folder will store the daily log files.
# Place the Files



##Folder Structure and File Placement:

$XmlFilePath = "C:\ServiceConfig\Services.xml"

# Load the XML file
if (-not (Test-Path $XmlFilePath)) {
    Write-Host "XML file not found at path: $XmlFilePath"
    exit
}

[xml]$XmlContent = Get-Content -Path $XmlFilePath
$ServiceNames = $XmlContent.Services.Service

# Get today's date for log file creation
$Date = Get-Date -Format "yyyy-MM-dd"
$LogFile = "C:\ServiceLogs\Log_$Date.log"

# Ensure the log directory exists
$LogDir = "C:\ServiceLogs"
if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory
}

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    Add-Content -Path $LogFile -Value $LogEntry
}

# Main logic to check and restart services
foreach ($ServiceName in $ServiceNames) {
    $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if ($Service -eq $null) {
        Log-Message "Service '$ServiceName' not found."
        continue
    }

    if ($Service.Status -eq "Running") {
        Log-Message "Service '$ServiceName' is running. No action needed."
    } else {
        Log-Message "Service '$ServiceName' is in state '$($Service.Status)'. Attempting to restart."
        try {
            Restart-Service -Name $ServiceName -Force -ErrorAction Stop
            Log-Message "Service '$ServiceName' successfully restarted."
        } catch {
            Log-Message "Failed to restart service '$ServiceName'. Error: $_"
        }
    }
}
