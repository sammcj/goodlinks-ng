.PHONY: help test clean build build-firefox build-chrome firefox chrome package-firefox package-chrome sign-firefox-listed sign-firefox-unlisted sign-firefox-listed-first publish-chrome release all

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

firefox: package-firefox ## Shortcut: Build and package Firefox extension for local installation
	@echo ""
	@echo "Firefox extension packaged: $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-firefox.xpi"
	@echo ""
	@echo "To install:"
	@echo "1. Open Firefox and navigate to about:addons"
	@echo "2. Click the gear icon and select 'Install Add-on From File...'"
	@echo "3. Select $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-firefox.xpi"
	@echo ""
	@echo "Or run 'make dev-firefox' to launch Firefox with the extension loaded for development"

chrome: package-chrome ## Shortcut: Build and package Chrome extension for local installation
	@echo ""
	@echo "Chrome extension packaged: $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-chrome.zip"
	@echo ""
	@echo "To install:"
	@echo "1. Extract the zip file"
	@echo "2. Open chrome://extensions/ (or brave://extensions/ or edge://extensions/)"
	@echo "3. Enable 'Developer mode' toggle"
	@echo "4. Click 'Load unpacked' and select the extracted directory"

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

sign-firefox-listed: build-firefox ## Sign and submit Firefox extension for listing on AMO (requires AMO_JWT_ISSUER and AMO_JWT_SECRET)
	@echo "Signing Firefox extension for AMO listing..."
	@command -v web-ext >/dev/null 2>&1 || (echo "Error: web-ext not installed. Run: npm install -g web-ext" && exit 1)
	@test -n "$(AMO_JWT_ISSUER)" || (echo "Error: AMO_JWT_ISSUER environment variable not set" && exit 1)
	@test -n "$(AMO_JWT_SECRET)" || (echo "Error: AMO_JWT_SECRET environment variable not set" && exit 1)
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR_FIREFOX) && web-ext sign \
		--channel=listed \
		--api-key=$(AMO_JWT_ISSUER) \
		--api-secret=$(AMO_JWT_SECRET) \
		--artifacts-dir=../../$(DIST_DIR) \
		$(if $(APPROVAL_TIMEOUT),--approval-timeout=$(APPROVAL_TIMEOUT))
	@echo "Firefox extension signed and submitted for listing"

sign-firefox-unlisted: build-firefox ## Sign Firefox extension for self-distribution (requires AMO_JWT_ISSUER and AMO_JWT_SECRET)
	@echo "Signing Firefox extension for self-distribution..."
	@command -v web-ext >/dev/null 2>&1 || (echo "Error: web-ext not installed. Run: npm install -g web-ext" && exit 1)
	@test -n "$(AMO_JWT_ISSUER)" || (echo "Error: AMO_JWT_ISSUER environment variable not set" && exit 1)
	@test -n "$(AMO_JWT_SECRET)" || (echo "Error: AMO_JWT_SECRET environment variable not set" && exit 1)
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR_FIREFOX) && web-ext sign \
		--channel=unlisted \
		--api-key=$(AMO_JWT_ISSUER) \
		--api-secret=$(AMO_JWT_SECRET) \
		--artifacts-dir=../../$(DIST_DIR)
	@echo "Signed Firefox extension created: $(DIST_DIR)/"

sign-firefox-listed-first: build-firefox ## Sign and submit Firefox extension for first-time listing (requires amo-metadata.json, AMO_JWT_ISSUER and AMO_JWT_SECRET)
	@echo "Signing Firefox extension for first-time AMO listing..."
	@command -v web-ext >/dev/null 2>&1 || (echo "Error: web-ext not installed. Run: npm install -g web-ext" && exit 1)
	@test -f amo-metadata.json || (echo "Error: amo-metadata.json not found. See CHROME_WEB_STORE.md for format." && exit 1)
	@test -n "$(AMO_JWT_ISSUER)" || (echo "Error: AMO_JWT_ISSUER environment variable not set" && exit 1)
	@test -n "$(AMO_JWT_SECRET)" || (echo "Error: AMO_JWT_SECRET environment variable not set" && exit 1)
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR_FIREFOX) && web-ext sign \
		--channel=listed \
		--amo-metadata=../amo-metadata.json \
		--api-key=$(AMO_JWT_ISSUER) \
		--api-secret=$(AMO_JWT_SECRET) \
		--artifacts-dir=../../$(DIST_DIR) \
		$(if $(APPROVAL_TIMEOUT),--approval-timeout=$(APPROVAL_TIMEOUT))
	@echo "Firefox extension signed and submitted for first-time listing"

publish-chrome: package-chrome ## Publish Chrome extension to Web Store (requires CHROME_CLIENT_ID, CHROME_CLIENT_SECRET, CHROME_REFRESH_TOKEN, CHROME_EXTENSION_ID)
	@echo "Publishing Chrome extension to Web Store..."
	@test -n "$(CHROME_CLIENT_ID)" || (echo "Error: CHROME_CLIENT_ID environment variable not set. See CHROME_WEB_STORE.md" && exit 1)
	@test -n "$(CHROME_CLIENT_SECRET)" || (echo "Error: CHROME_CLIENT_SECRET environment variable not set. See CHROME_WEB_STORE.md" && exit 1)
	@test -n "$(CHROME_REFRESH_TOKEN)" || (echo "Error: CHROME_REFRESH_TOKEN environment variable not set. See CHROME_WEB_STORE.md" && exit 1)
	@test -n "$(CHROME_EXTENSION_ID)" || (echo "Error: CHROME_EXTENSION_ID environment variable not set. See CHROME_WEB_STORE.md" && exit 1)
	@npx chrome-webstore-upload-cli@latest upload \
		--source $(DIST_DIR)/$(EXTENSION_NAME)-$(VERSION)-chrome.zip \
		--extension-id $(CHROME_EXTENSION_ID) \
		--client-id $(CHROME_CLIENT_ID) \
		--client-secret $(CHROME_CLIENT_SECRET) \
		--refresh-token $(CHROME_REFRESH_TOKEN) \
		--auto-publish
	@echo "Chrome extension published to Web Store"

release: ## Create a new release (usage: make release VERSION=1.0.1)
	@test -n "$(VERSION)" || (echo "Error: VERSION not specified. Usage: make release VERSION=1.0.1" && exit 1)
	@echo "Creating release v$(VERSION)..."
	@echo "Updating manifest.json..."
	@sed -i.bak 's/"version": "[^"]*"/"version": "$(VERSION)"/' manifest.json && rm manifest.json.bak
	@echo "Updating manifest.firefox.json..."
	@sed -i.bak 's/"version": "[^"]*"/"version": "$(VERSION)"/' manifest.firefox.json && rm manifest.firefox.json.bak
	@echo "Running tests..."
	@$(MAKE) test
	@echo "Committing version bump..."
	@git add manifest.json manifest.firefox.json
	@git commit -m "chore: bump version to $(VERSION)"
	@echo "Creating tag v$(VERSION)..."
	@git tag -a "v$(VERSION)" -m "Release v$(VERSION)"
	@echo "Pushing to origin..."
	@git push origin main
	@git push origin "v$(VERSION)"
	@echo "✓ Release v$(VERSION) created and pushed"
	@echo "GitHub Actions will build and publish the release automatically"

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

.DEFAULT_GOAL := package
