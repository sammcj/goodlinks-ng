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

### From Source

1. Clone or download this repository
2. Build the extension:
   ```bash
   make build
   ```

3. **For Firefox:**
   - Open Firefox and navigate to `about:debugging#/runtime/this-firefox`
   - Click "Load Temporary Add-on"
   - Select the `manifest.json` file from the `build/` directory

4. **For Chrome/Brave:**
   - Open Chrome and navigate to `chrome://extensions/`
   - Enable "Developer mode" (toggle in top-right)
   - Click "Load unpacked"
   - Select the `build/` directory

### From Package

1. Build distribution packages:
   ```bash
   make package
   ```

2. Install the appropriate package:
   - Firefox: Install the `.xpi` file from the `dist/` directory
   - Chrome: Load the `.zip` file as an unpacked extension

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
├── manifest.json        # Extension manifest (Manifest V3)
├── background.js        # Service worker handling URL scheme
├── options.html         # Settings page HTML
├── options.css          # Settings page styles
├── options.js           # Settings page logic
├── icons/              # Official Goodlinks icons (multiple sizes)
├── tests/              # Unit tests
├── Makefile            # Build automation
└── package.json        # Node.js configuration
```

### Building

```bash
# Show all available targets
make help

# Run tests
make test

# Build for both browsers
make build

# Build and package for distribution
make package

# Run in Firefox for development
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

- ✅ Manifest V3
- ✅ No remote code execution
- ✅ No external dependencies or CDN assets
- ✅ Clear, single purpose
- ✅ Minimal permissions (`activeTab`, `storage`)
- ✅ Privacy-focused (no data collection)

## Licence

MIT

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

For Goodlinks app support, contact [[email protected]](mailto:[email protected]).
