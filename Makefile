# =====================================
# 🔄 DropSync - D: Drive to Dropbox Sync
# =====================================

sync: ## Run sync from D: to Dropbox
	powershell -ExecutionPolicy Bypass -File DropSync.ps1

log: ## View sync log
	powershell -Command "Get-Content 'D:\Logs\sync_log.txt' -Tail 20"

schedule: ## Setup 4x daily auto-sync
	powershell -ExecutionPolicy Bypass -File setup_scheduler.ps1

# =====================================
# 📚 Documentation & Help
# =====================================

help: ## Show this help message
	@echo Available commands:
	@echo.
	@python -c "import re; lines=open('Makefile', encoding='utf-8').readlines(); targets=[re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$',l) for l in lines]; [print(f'  make {m.group(1):<20} {m.group(2)}') for m in targets if m]"

# =====================================
# 🧹 Phony Targets
# =====================================
.PHONY: sync log schedule help
