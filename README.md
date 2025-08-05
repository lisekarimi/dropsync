# DropSync - Local to Dropbox Sync

Automatically sync local folders to Dropbox while skipping cache and large files.

## 🚀 Quick Start

1. **Configure paths in `config.ps1`:**
   ```powershell
   $SourcePath = "D:\YourSourceFolder"
   $DropboxPath = "C:\Users\YourUsername\Dropbox\YourBackupFolder"
   $LogPath = "D:\Logs\sync_log.txt"
   ```

2. **Run manual sync:**
   ```bash
   make sync
   ```

3. **Setup automatic scheduling:**
   ```bash
   # Run PowerShell as Administrator
   .\setup_scheduler.ps1
   ```

## 📁 Files

- **`DropSync.ps1`** - Main sync script
- **`config.ps1`** - Your personal paths
- **`setup_scheduler.ps1`** - Creates Windows scheduled tasks
- **`Makefile`** - Simple commands (`make sync`, `make help`)

## ⏰ Schedule

Default: Runs automatically 4 times daily at 11:00 AM, 3:00 PM, 6:00 PM, 8:00 PM.

**To customize times:** Edit the trigger times in `setup_scheduler.ps1` before running:
```powershell
$trigger1 = New-ScheduledTaskTrigger -Daily -At "09:00"  # Change to your preferred time
$trigger2 = New-ScheduledTaskTrigger -Daily -At "13:00"  # Change to your preferred time
# etc.
```

## 🚫 What Gets Ignored

**Folders:** `.git`, `node_modules`, `__pycache__`, `.venv`, `logs`, `dist`, `build`, etc.

**Files:** `*.pkl`, `*.csv`, `*.h5`, `*.log`, `*.tmp`, etc.

## 📋 Commands

```bash
make sync      # Run sync now
make log       # View last 20 log entries
make help      # Show all commands
```

## 📊 Monitoring

- **Sync logs:** `D:\Logs\sync_log.txt`
- **Task status:** `Get-ScheduledTask -TaskName 'DropSync*'`
- **Task history:** Task Scheduler GUI (`taskschd.msc`)

## 🔧 Management

**View scheduled tasks:**
```powershell
Get-ScheduledTask -TaskName 'DropSync*'
```

**Test a task manually:**
```powershell
Start-ScheduledTask -TaskName "DropSync_Morning"
```

**Remove all tasks:**
```powershell
Get-ScheduledTask -TaskName 'DropSync*' | Unregister-ScheduledTask
```

## ⚠️ Requirements

- Windows PowerShell
- Dropbox desktop app installed
- Administrative privileges (for scheduler setup only)

---

**Your workspace is now automatically backed up to Dropbox!**
