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
    // Get user's configured tags
    const result = await chrome.storage.sync.get(['tags']);
    const tags = result.tags || '';

    // Build the Goodlinks URL scheme
    const goodlinksUrl = buildGoodlinksUrl(tab.url, tab.title, tags);

    // Trigger the protocol on the current tab. The browser intercepts the
    // external-protocol navigation, shows its "Open in GoodLinks?" prompt, and
    // leaves the page loaded - so there is no throwaway tab to close and nothing
    // races the permission dialog. The previous approach opened a new tab and
    // closed it on a timer, which dismissed Firefox's prompt before the user
    // could click "Allow".
    await chrome.tabs.update(tab.id, { url: goodlinksUrl });
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
