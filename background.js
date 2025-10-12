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
    // Get user's configured tags from storage
    const result = await chrome.storage.sync.get(['tags']);
    const tags = result.tags || '';

    // Build the Goodlinks URL scheme
    const goodlinksUrl = buildGoodlinksUrl(tab.url, tab.title, tags);

    // Open the URL scheme (this will trigger Goodlinks on macOS)
    // We create a new tab briefly to trigger the custom URL scheme
    const newTab = await chrome.tabs.create({ url: goodlinksUrl, active: false });

    // Close the tab after a brief delay to avoid "page can't be displayed" error
    setTimeout(() => {
      chrome.tabs.remove(newTab.id).catch(() => {
        // Ignore errors if tab already closed
      });
    }, 100);

  } catch (error) {
    console.error('Failed to save to Goodlinks:', error);
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
