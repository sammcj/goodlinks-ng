# Goodlinks-NG

A lightweight browser extension for Firefox and Chromium-based browsers that sends web pages directly to the [Goodlinks](https://goodlinks.app) app using its URL scheme. No sign-in required.

## Features

- **One-click saving**: Click the extension icon to instantly save the current page to Goodlinks
- **Configurable tags**: Set default tags that are automatically applied to saved links
- **Cross-browser**: Works in Firefox, Chrome, Brave, Edge, and other Chromium-based browsers
- **Privacy-focused**: Works entirely offline with no external connections
- **Official branding**: Uses the official Goodlinks icon

## Requirements

- macOS (Goodlinks is a macOS/iOS app)
- [Goodlinks app](https://apps.apple.com/app/id1474335294) installed
- Firefox or a Chromium-based browser (Chrome, Brave, Edge, etc.)

## Installation

### Development/Testing Installation

**For Firefox:**
1. Clone or download this repository
2. Build for Firefox:
   ```bash
   make build-firefox
   ```
3. Open Firefox and navigate to `about:debugging#/runtime/this-firefox`
4. Click "Load Temporary Add-on"
5. Select the `manifest.json` file from the `build/` directory

**Note:** Unsigned extensions in Firefox are removed when the browser closes. For permanent installation, the extension needs to be signed by Mozilla or use Firefox Developer/Nightly Edition with signing disabled.

**For Chrome/Brave/Edge:**
1. Clone or download this repository
2. Build for Chrome:
   ```bash
   make build-chrome
   ```
3. Open browser and navigate to extensions page:
   - Chrome: `chrome://extensions/`
   - Brave: `brave://extensions/`
   - Edge: `edge://extensions/`
4. Enable "Developer mode" (toggle in top-right)
5. Click "Load unpacked"
6. Select the `build/` directory

### Distribution Packages

Build both browser packages:
```bash
make package
```

This creates:
- `dist/goodlinks-ng-1.0.0-firefox.xpi` - Firefox package
- `dist/goodlinks-ng-1.0.0-chrome.zip` - Chrome/Brave/Edge package

**Note:** The Firefox `.xpi` requires Mozilla signing for permanent installation. For production use, submit to [Firefox Add-ons](https://addons.mozilla.org).

## Usage

### Saving a Page

1. Navigate to any web page you want to save
2. Click the Goodlinks-NG extension icon in your browser toolbar
3. The page will be automatically saved to Goodlinks

The extension uses the `quick=1` parameter, so the link is saved immediately without showing the Goodlinks editor interface.

### Configuring Tags

1. Right-click the extension icon and select "Options" (or access via browser extension settings)
2. Enter space-separated tags (e.g., `work personal important`)
3. Click "Save"

These tags will be automatically applied to all links you save. Leave the field empty to save without tags.

## Development

### Project Structure

```
goodlinks-ng/
├── manifest.json         # Chrome manifest (Manifest V3 with service worker)
├── manifest.firefox.json # Firefox manifest (Manifest V3 with background scripts)
├── background.js         # Background script handling URL scheme
├── options.html          # Settings page HTML
├── options.css           # Settings page styles
├── options.js            # Settings page logic
├── icons/               # Official Goodlinks icons (multiple sizes)
├── tests/               # Unit tests
├── Makefile             # Build automation
└── package.json         # Node.js configuration
```

**Note:** Firefox and Chrome require different manifest configurations. Firefox uses `background.scripts` whilst Chrome uses `service_worker`. The Makefile automatically uses the correct manifest for each browser.

### Building

```bash
# Show all available targets
make help

# Run tests
make test

# Build for Firefox (default)
make build

# Or explicitly:
make build-firefox

# Build for Chrome/Chromium
make build-chrome

# Build and package for distribution (both browsers)
make package

# Run in Firefox for development (requires web-ext)
make dev-firefox
```

### Testing

The extension includes unit tests for the URL construction logic:

```bash
npm test
```

Tests cover:
- URL encoding
- Tag handling
- Special character handling
- Unicode support

### Technical Details

The extension uses the [Goodlinks URL scheme](https://goodlinks.app/url-scheme/) to communicate with the app:

```
goodlinks://x-callback-url/save?url=<encoded-url>&title=<encoded-title>&tags=<tags>&quick=1
```

When you click the extension icon:
1. The extension retrieves the current tab's URL and title
2. It loads your configured tags from browser storage
3. It constructs a properly encoded Goodlinks URL scheme
4. It opens the URL scheme in a new tab (immediately triggering Goodlinks)
5. It closes the tab to avoid showing a "page cannot be displayed" error

## Store Compliance

This extension is designed to comply with both Firefox Add-ons and Chrome Web Store requirements:

- ✅ Manifest V3 and V2 for Firefox
- ✅ No remote code execution
- ✅ No external dependencies or CDN assets
- ✅ Clear, single purpose
- ✅ Minimal permissions (`activeTab`, `storage`)
- ✅ Privacy-focused (no data collection)

## Licence

- Copyright (c) 2025 Sam McLeod
- Apache 2.0 License. See [LICENSE](LICENSE) for details.

## Attribution

This extension uses the official Goodlinks icon, which is property of its creator. Goodlinks is a registered trademark.

## Contributing

Contributions are welcome. Please ensure:
- Code follows the existing style
- Tests pass (`make test`)
- The extension builds successfully (`make build`)
- Changes work in both Firefox and Chrome

## Support

This is an unofficial community extension, not affiliated with the Goodlinks app developers.

For issues with the extension, please [open an issue](../../issues).
