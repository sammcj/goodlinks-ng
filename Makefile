.PHONY: help test clean build build-firefox build-chrome package-firefox package-chrome all

EXTENSION_NAME := goodlinks-ng
VERSION := $(shell grep '"version"' manifest.json | head -n1 | sed 's/.*"version": "\(.*\)".*/\1/')
BUILD_DIR := build
BUILD_DIR_FIREFOX := $(BUILD_DIR)/firefox
BUILD_DIR_CHROME := $(BUILD_DIR)/chrome
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

build-firefox: ## Build for Firefox
	@echo "Building extension for Firefox..."
	@mkdir -p $(BUILD_DIR_FIREFOX)/icons
	@cp manifest.firefox.json $(BUILD_DIR_FIREFOX)/manifest.json
	@cp background.js options.html options.css options.js $(BUILD_DIR_FIREFOX)/
	@cp icons/icon-16.png icons/icon-32.png icons/icon-48.png icons/icon-128.png $(BUILD_DIR_FIREFOX)/icons/
	@echo "Firefox build complete: $(BUILD_DIR_FIREFOX)/"

build-chrome: ## Build for Chrome
	@echo "Building extension for Chrome..."
	@mkdir -p $(BUILD_DIR_CHROME)/icons
	@cp manifest.json background.js options.html options.css options.js $(BUILD_DIR_CHROME)/
	@cp icons/icon-16.png icons/icon-32.png icons/icon-48.png icons/icon-128.png $(BUILD_DIR_CHROME)/icons/
	@echo "Chrome build complete: $(BUILD_DIR_CHROME)/"

build: clean build-firefox build-chrome ## Build for both Firefox and Chrome

package-firefox: build-firefox ## Package extension for Firefox (.xpi)
	@echo "Packaging for Firefox..."
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR_FIREFOX) && zip -r -q ../../$(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-firefox.xpi *
	@echo "Firefox package created: $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-firefox.xpi"

package-chrome: build-chrome ## Package extension for Chrome (.zip)
	@echo "Packaging for Chrome..."
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR_CHROME) && zip -r -q ../../$(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-chrome.zip *
	@echo "Chrome package created: $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-chrome.zip"

package: clean ## Package for both Firefox and Chrome
	@$(MAKE) package-firefox
	@$(MAKE) package-chrome

all: test package ## Run tests and package for both browsers

validate: ## Validate manifest files syntax
	@echo "Validating manifests..."
	@python3 -m json.tool manifest.json > /dev/null && echo "✓ manifest.json (Chrome) is valid"
	@python3 -m json.tool manifest.firefox.json > /dev/null && echo "✓ manifest.firefox.json (Firefox) is valid"

lint: validate ## Run all validation checks
	@echo "Running lint checks..."
	@command -v web-ext >/dev/null 2>&1 && web-ext lint -s . -i tests/ build/ dist/ node_modules/ .git/ .vscode/ icons/goodlinks-original.png package.json package-lock.json Makefile README.md || echo "⚠ web-ext not installed - skipping extension validation"

dev-firefox: build-firefox ## Run extension in Firefox for development
	@command -v web-ext >/dev/null 2>&1 || (echo "Error: web-ext not installed. Run: npm install -g web-ext" && exit 1)
	@echo "Starting Firefox with extension..."
	@web-ext run -s $(BUILD_DIR_FIREFOX)

.DEFAULT_GOAL := help
