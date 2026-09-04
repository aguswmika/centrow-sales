.PHONY: hot-reload

OS := $(shell uname -s)

hot-reload:
ifeq ($(OS),Darwin)
	@echo "Running hot reload on macOS"
	@bash scripts/hot_reload.sh
else ifeq ($(OS),Linux)
	@echo "Running hot reload on Linux"
	@bash scripts/hot_reload.sh
else
	@echo "Running hot reload on Windows"
	@powershell -ExecutionPolicy Bypass -File scripts/hot_reload.ps1
endif