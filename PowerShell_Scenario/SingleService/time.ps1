# This script is majorly focused on restarting a windows service of at every 15 minutes. My requirement is to restart the service using task scheduler
# so I am keeping the script very simple. 
# Before starting on this you should have the basic idea of task scheduler, and basic idea about powershell default variables.
# Define the service name

$serviceName = "MSSQLSERVER"

# Define the log file path
$logFilePath = "C:\ApplicatinLog\LogFile.log"

# Function to log messages to the log file
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logEntry
}

# Check if the service exists
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Log-Message "Service '$serviceName' does not exist on this machine."
    exit 1
}

# Restart the service based on its current status
try {
    # If the service is running or in a transitional state (e.g., Paused, StartPending, StopPending), stop it
    if ($service.Status -ne "Stopped") {
        Stop-Service -Name $serviceName -Force
        Log-Message "Service '$serviceName' was in state '$($service.Status)' and has been stopped for a restart."
    } else {
        Log-Message "Service '$serviceName' was already stopped. Starting the service."
    }
    
    # Start the service
    Start-Service -Name $serviceName
    Log-Message "Service '$serviceName' has been started successfully."

    # Wait for the service to reach the 'Running' status
    $service.WaitForStatus('Running', '00:00:30')

    if ($service.Status -eq "Running") {
        Log-Message "Service '$serviceName' is running normally after start/restart."
    } else {
        Log-Message "Service '$serviceName' failed to start."
    }
} catch {
    Log-Message "Error occurred while restarting the service '$serviceName': $_"
}
