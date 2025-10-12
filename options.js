/**
 * Goodlinks-NG Options Page Script
 * Handles saving and loading of user preferences
 */

const form = document.getElementById('optionsForm');
const tagsInput = document.getElementById('tags');
const clearBtn = document.getElementById('clearBtn');
const resetHandlerBtn = document.getElementById('resetHandlerBtn');
const statusDiv = document.getElementById('status');

/**
 * Shows a status message to the user
 * @param {string} message - The message to display
 * @param {string} type - The message type ('success' or 'error')
 */
function showStatus(message, type = 'success') {
  statusDiv.textContent = message;
  statusDiv.className = `status show ${type}`;

  setTimeout(() => {
    statusDiv.className = 'status';
  }, 3000);
}

/**
 * Loads saved tags from storage
 */
async function loadOptions() {
  try {
    const result = await chrome.storage.sync.get(['tags']);
    if (result.tags) {
      tagsInput.value = result.tags;
    }
  } catch (error) {
    console.error('Failed to load options:', error);
  }
}

/**
 * Saves tags to storage
 * @param {Event} e - The form submit event
 */
async function saveOptions(e) {
  e.preventDefault();

  const tags = tagsInput.value.trim();

  try {
    await chrome.storage.sync.set({ tags });
    showStatus('Settings saved successfully', 'success');
  } catch (error) {
    console.error('Failed to save options:', error);
    showStatus('Failed to save settings', 'error');
  }
}

/**
 * Clears all saved settings
 */
async function clearOptions() {
  try {
    await chrome.storage.sync.clear();
    tagsInput.value = '';
    showStatus('Settings cleared', 'success');
  } catch (error) {
    console.error('Failed to clear options:', error);
    showStatus('Failed to clear settings', 'error');
  }
}

/**
 * Resets the protocol handler granted flag
 */
async function resetProtocolHandler() {
  try {
    await chrome.storage.sync.remove(['protocolHandlerGranted']);
    showStatus('Protocol handler reset - you will see the permission dialog on next use', 'success');
  } catch (error) {
    console.error('Failed to reset protocol handler:', error);
    showStatus('Failed to reset protocol handler', 'error');
  }
}

// Event listeners
form.addEventListener('submit', saveOptions);
clearBtn.addEventListener('click', clearOptions);
resetHandlerBtn.addEventListener('click', resetProtocolHandler);

// Load saved options when page loads
document.addEventListener('DOMContentLoaded', loadOptions);
