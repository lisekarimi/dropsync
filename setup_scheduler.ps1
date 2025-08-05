# =============================================================================
# DROPSYNC SCHEDULER SETUP
# =============================================================================
# Sets up Windows Task Scheduler to run DropSync 3 times daily
# Run this script as Administrator
# =============================================================================

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'"
    pause
    exit 1
}

Write-Host "Setting up DropSync automatic scheduling..." -ForegroundColor Green

# Get the current script directory to find DropSync.ps1
$scriptDir = $PSScriptRoot
$dropSyncScript = Join-Path $scriptDir "DropSync.ps1"

# Check if DropSync.ps1 exists
if (!(Test-Path $dropSyncScript)) {
    Write-Host "ERROR: DropSync.ps1 not found in $scriptDir" -ForegroundColor Red
    Write-Host "Please make sure DropSync.ps1 is in the same folder as this script."
    pause
    exit 1
}

Write-Host "Found DropSync script: $dropSyncScript" -ForegroundColor Yellow

# Remove existing tasks if they exist
$taskNames = @("DropSync_Morning", "DropSync_Afternoon", "DropSync_Evening", "DropSync_Night")
foreach ($taskName in $taskNames) {
    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Removed existing task: $taskName" -ForegroundColor Yellow
    } catch {
        # Task didn't exist, continue
    }
}

# Create the PowerShell action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$dropSyncScript`""

# Create triggers for 4 times daily
$trigger1 = New-ScheduledTaskTrigger -Daily -At "11:00"  # 11 AM
$trigger2 = New-ScheduledTaskTrigger -Daily -At "15:00"  # 3 PM  
$trigger3 = New-ScheduledTaskTrigger -Daily -At "18:00"  # 6 PM
$trigger4 = New-ScheduledTaskTrigger -Daily -At "20:00"  # 8 PM

# Create task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Create the principal (run as current user)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

# Register the scheduled tasks
try {
    Register-ScheduledTask -TaskName "DropSync_Morning" -Action $action -Trigger $trigger1 -Settings $settings -Principal $principal -Description "DropSync - Morning backup (11 AM)"
    Write-Host "Created task: DropSync_Morning (11:00 AM)" -ForegroundColor Green
    
    Register-ScheduledTask -TaskName "DropSync_Afternoon" -Action $action -Trigger $trigger2 -Settings $settings -Principal $principal -Description "DropSync - Afternoon backup (3 PM)"
    Write-Host "Created task: DropSync_Afternoon (3:00 PM)" -ForegroundColor Green
    
    Register-ScheduledTask -TaskName "DropSync_Evening" -Action $action -Trigger $trigger3 -Settings $settings -Principal $principal -Description "DropSync - Evening backup (6 PM)"
    Write-Host "Created task: DropSync_Evening (6:00 PM)" -ForegroundColor Green
    
    Register-ScheduledTask -TaskName "DropSync_Night" -Action $action -Trigger $trigger4 -Settings $settings -Principal $principal -Description "DropSync - Night backup (8 PM)"
    Write-Host "Created task: DropSync_Night (8:00 PM)" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "SUCCESS! DropSync will now run automatically:" -ForegroundColor Green
    Write-Host "  11:00 AM daily" -ForegroundColor Cyan
    Write-Host "  3:00 PM daily" -ForegroundColor Cyan  
    Write-Host "  6:00 PM daily" -ForegroundColor Cyan
    Write-Host "  8:00 PM daily" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To test now: Get-ScheduledTask -TaskName 'DropSync*' | Start-ScheduledTask" -ForegroundColor Yellow
    Write-Host "To view tasks: Get-ScheduledTask -TaskName 'DropSync*'" -ForegroundColor Yellow
    Write-Host "To remove tasks: Get-ScheduledTask -TaskName 'DropSync*' | Unregister-ScheduledTask" -ForegroundColor Yellow
    
} catch {
    Write-Host "ERROR creating scheduled tasks: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")