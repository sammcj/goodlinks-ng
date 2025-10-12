.PHONY: help test clean build build-firefox build-chrome package-firefox package-chrome all

EXTENSION_NAME := goodlinks-ng
VERSION := $(shell grep '"version"' manifest.json | head -n1 | sed 's/.*"version": "\(.*\)".*/\1/')
BUILD_DIR := build
DIST_DIR := dist

# Files to include in the extension package
EXTENSION_FILES := manifest.json \
	background.js \
	options.html \
	options.css \
	options.js \
	icons/icon-16.png \
	icons/icon-32.png \
	icons/icon-48.png \
	icons/icon-128.png

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

test: ## Run unit tests
	@echo "Running tests..."
	@npm test

clean: ## Remove build and dist directories
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) $(DIST_DIR)

build: clean ## Build extension (both Firefox and Chrome)
	@echo "Building extension..."
	@mkdir -p $(BUILD_DIR)/icons
	@cp manifest.json background.js options.html options.css options.js $(BUILD_DIR)/
	@cp icons/icon-16.png icons/icon-32.png icons/icon-48.png icons/icon-128.png $(BUILD_DIR)/icons/
	@echo "Build complete: $(BUILD_DIR)/"

build-firefox: build ## Build for Firefox
	@echo "Firefox build ready in $(BUILD_DIR)/"

build-chrome: build ## Build for Chrome
	@echo "Chrome build ready in $(BUILD_DIR)/"

package-firefox: build-firefox ## Package extension for Firefox (.xpi)
	@echo "Packaging for Firefox..."
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR) && zip -r -q ../$(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-firefox.xpi *
	@echo "Firefox package created: $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-firefox.xpi"

package-chrome: build-chrome ## Package extension for Chrome (.zip)
	@echo "Packaging for Chrome..."
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR) && zip -r -q ../$(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-chrome.zip *
	@echo "Chrome package created: $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-chrome.zip"

package: package-firefox package-chrome ## Package for both Firefox and Chrome

all: test package ## Run tests and package for both browsers

validate: ## Validate manifest.json syntax
	@echo "Validating manifest.json..."
	@python3 -m json.tool manifest.json > /dev/null && echo "✓ manifest.json is valid"

lint: validate ## Run all validation checks
	@echo "Running lint checks..."
	@command -v web-ext >/dev/null 2>&1 && web-ext lint -s . -i tests/ build/ dist/ node_modules/ .git/ .vscode/ icons/goodlinks-original.png package.json package-lock.json Makefile README.md || echo "⚠ web-ext not installed - skipping extension validation"

install-firefox: package-firefox ## Install in Firefox (requires web-ext)
	@command -v web-ext >/dev/null 2>&1 || (echo "Error: web-ext not installed. Run: npm install -g web-ext" && exit 1)
	@echo "Starting Firefox with extension..."
	@web-ext run -s $(BUILD_DIR)

dev-firefox: build-firefox ## Run extension in Firefox for development
	@command -v web-ext >/dev/null 2>&1 || (echo "Error: web-ext not installed. Run: npm install -g web-ext" && exit 1)
	@echo "Starting Firefox with extension..."
	@web-ext run -s $(BUILD_DIR)

.DEFAULT_GOAL := help
