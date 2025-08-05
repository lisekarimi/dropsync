# =============================================================================
# DROPSYNC - FOLDER SYNC SCRIPT
# =============================================================================
# PURPOSE: Automatically sync folders from D: drive to Dropbox
# WHAT IT DOES: Copies your files while skipping cache, builds, and large files
# WHEN IT RUNS: 3 times per day (9am, 2pm, 7pm) - set up separately
# =============================================================================

# Load configuration from separate file
$configPath = Join-Path $PSScriptRoot "config.ps1"
if (Test-Path $configPath) {
    . $configPath  # Load the config file
    Write-Host "Configuration loaded from config.ps1"
} else {
    Write-Host "ERROR: config.ps1 not found!"
    Write-Host "Please create config.ps1 with your folder paths."
    exit 1
}

# =============================================================================
# WHAT TO IGNORE - FILES AND FOLDERS WE DON'T WANT IN DROPBOX
# =============================================================================
# These are cache files, build files, or large files that shouldn't be synced

# Exact names to ignore (files or folders)
$targetNames = @(
  ".env",                    # Environment variables (contains secrets)
  ".git",                    # Git repository data (causes conflicts)
  ".ruff_cache",            # Linter cache
  "node_modules",           # JavaScript dependencies (huge folder)
  "memory",                 # Memory dumps
  "logs",                   # Log files
  "dist",                   # Distribution/build files
  "build",                  # Build output
  ".ipynb_checkpoints",     # Jupyter checkpoint files
  ".pytest_cache",          # Test cache
  "__pycache__",            # Python cache files
  ".idea",                  # IntelliJ IDE files
  ".coverage",              # Code coverage files
  ".gitlab-ci-local",       # GitLab CI files
  "htmlcov",                # HTML coverage reports
  "temp_data",              # Temporary data files
  "mlruns",                 # MLflow experiment tracking
  "ghforks",                # GitHub forks folder
  ".venv"                   # Virtual environment
)

# File extensions to ignore (large or temporary files)
$extensions = @(
  ".pkl",                   # Pickle files (models, data)
  ".joblib",                # Model files
  ".h5",                    # HDF5 data files (large datasets)
  ".npz",                   # NumPy compressed arrays
  ".csv",                   # CSV data files (can be huge)
  ".parquet",               # Parquet data files
  ".feather",               # Feather data files
  ".log",                   # Log files
  ".tmp",                   # Temporary files
  ".bak",                   # Backup files
  ".spec"                   # Spec files
)

# =============================================================================
# LOGGING FUNCTION - RECORDS WHAT THE SCRIPT DOES
# =============================================================================
# This creates a diary of all sync activities with timestamps

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"        # Current date and time
    $logMessage = "[$timestamp] $Message"                       # Add timestamp to message
    Write-Host $logMessage                                      # Show on screen
    
    # Create the log folder if it doesn't exist
    $logDir = Split-Path $LogPath -Parent                       # Get folder part of log path
    if (!(Test-Path $logDir)) {                                # If folder doesn't exist
        New-Item -ItemType Directory -Path $logDir -Force      # Create it
    }
    Add-Content -Path $LogPath -Value $logMessage               # Write to log file
}

# =============================================================================
# MAIN SYNC FUNCTION - DOES THE ACTUAL COPYING
# =============================================================================
# This is where all the magic happens

function Start-Sync {
    Write-Log "=== Starting Sync: D:\ -> Dropbox ==="
    
    # STEP 1: Check and create destination folder if needed
    if (!(Test-Path $DropboxPath)) {                           # If Dropbox folder doesn't exist
        New-Item -ItemType Directory -Path $DropboxPath -Force # Create it
        Write-Log "Created destination folder: $DropboxPath"
    }
    
    # STEP 2: Check if source folder exists
    if (!(Test-Path $SourcePath)) {                           # If source doesn't exist
        Write-Log "ERROR: Source path does not exist: $SourcePath"
        return                                                # Stop the script
    }
    
    Write-Log "Source found: $SourcePath"
    Write-Log "Destination: $DropboxPath"
    
    # STEP 3: Build the list of what to ignore for robocopy
    # Convert folder names to robocopy exclude format: /XD "foldername"
    $excludeDirs = $targetNames | ForEach-Object { "/XD `"$_`"" }
    
    # Convert file extensions to robocopy exclude format: /XF "*.extension"
    $excludeFiles = ($targetNames + ($extensions | ForEach-Object { "*$_" })) | ForEach-Object { "/XF `"$_`"" }
    
    Write-Log "Will ignore $($targetNames.Count) folder types and $($extensions.Count) file extensions"
    
    # STEP 4: Set up the robocopy command with all options
    $robocopyArgs = @(
        "`"$SourcePath`"",        # FROM: Source folder
        "`"$DropboxPath`"",       # TO: Destination folder  
        "/MIR",                   # MIRROR: Make destination exactly match source
        "/R:2",                   # RETRY: Try 2 times if a file fails to copy
        "/W:1",                   # WAIT: Wait 1 second between retries
        "/MT:4",                  # THREADS: Use 4 threads for faster copying
        "/XA:H",                  # EXCLUDE: Skip hidden files
        "/XA:S",                  # EXCLUDE: Skip system files
        "/NFL",                   # QUIET: Don't list every file (less spam)
        "/NDL"                    # QUIET: Don't list every directory (less spam)
    ) + $excludeDirs + $excludeFiles  # Add our ignore lists
    
    # STEP 5: Build the complete command and run it
    $command = "robocopy " + ($robocopyArgs -join " ")
    Write-Log "Starting file copy operation..."
    
    try {
        Invoke-Expression $command                            # Actually run robocopy
        
        # STEP 6: Check if it worked (robocopy codes 0-7 = success, 8+ = error)
        if ($LASTEXITCODE -le 7) {
            Write-Log "Sync completed successfully!"
            Write-Log "Files copied from D:\ to Dropbox"
        } else {
            Write-Log "ERROR: Sync failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-Log "ERROR: Something went wrong: $($_.Exception.Message)"
    }
    
    Write-Log "=== Sync Complete ==="
}


# =============================================================================
# RUN THE SYNC - THIS IS WHERE EVERYTHING STARTS
# =============================================================================
# When you run this script, this line executes the sync function above

Write-Host "DropSync Starting..."
Write-Host "From: D:\ (entire drive)"  
Write-Host "To: Dropbox\lisekarimi"
Write-Host "Log: D:\Logs\sync_log.txt"
Write-Host ""

Start-Sync