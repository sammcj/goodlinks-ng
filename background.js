/**
 * Goodlinks-NG Background Service Worker
 * Handles the browser action click and sends URLs to the Goodlinks app
 */

/**
 * Constructs the Goodlinks URL scheme with proper encoding
 * @param {string} url - The page URL to save
 * @param {string} title - The page title
 * @param {string} tags - Space-separated tags (optional)
 * @returns {string} The constructed Goodlinks URL scheme
 */
function buildGoodlinksUrl(url, title, tags) {
  const encodedUrl = encodeURIComponent(url);
  const encodedTitle = encodeURIComponent(title);
  const tagParam = tags ? `&tags=${encodeURIComponent(tags)}` : '';

  return `goodlinks://x-callback-url/save?url=${encodedUrl}&title=${encodedTitle}${tagParam}&quick=1`;
}

/**
 * Sends the current tab to Goodlinks app
 * @param {chrome.tabs.Tab} tab - The active tab to save
 */
async function saveToGoodlinks(tab) {
  try {
    // Get user's configured tags and check if protocol handler has been used before
    const result = await chrome.storage.sync.get(['tags', 'protocolHandlerGranted']);
    const tags = result.tags || '';
    const handlerGranted = result.protocolHandlerGranted || false;

    // Build the Goodlinks URL scheme
    const goodlinksUrl = buildGoodlinksUrl(tab.url, tab.title, tags);

    // Open the URL scheme (this will trigger Goodlinks on macOS)
    // Firefox requires the tab to be active for protocol handlers to work reliably
    const newTab = await chrome.tabs.create({ url: goodlinksUrl, active: true });

    // Smart timeout: longer delay on first use for permission dialog, quick close on subsequent uses
    const timeout = handlerGranted ? 500 : 20000; // 500ms if granted, 20s for first-time approval

    setTimeout(async () => {
      chrome.tabs.remove(newTab.id).catch(() => {
        // Tab already closed by user, ignore
      });

      // Mark protocol handler as granted after first use
      if (!handlerGranted) {
        await chrome.storage.sync.set({ protocolHandlerGranted: true });
      }
    }, timeout);

  } catch (error) {
    console.error('Goodlinks-NG: Failed to save to Goodlinks:', error);
  }
}

// Listen for browser action clicks (only in browser environment)
if (typeof chrome !== 'undefined' && chrome.action) {
  chrome.action.onClicked.addListener(saveToGoodlinks);
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { buildGoodlinksUrl };
}
