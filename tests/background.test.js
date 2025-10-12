/**
 * Unit tests for background.js
 * Tests URL construction logic for the Goodlinks URL scheme
 */

const { test } = require('node:test');
const assert = require('node:assert');

// Import the function to test
const { buildGoodlinksUrl } = require('../background.js');

test('buildGoodlinksUrl - basic URL without tags', () => {
  const url = 'https://smcleod.net/2025/03/the-democratisation-paradox-what-history-teaches-us-about-ai/';
  const title = 'The Democratisation Paradox';
  const tags = '';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.startsWith('goodlinks://x-callback-url/save?'));
  assert.ok(result.includes('url=https%3A%2F%2Fsmcleod.net'));
  assert.ok(result.includes('title=The%20Democratisation%20Paradox'));
  assert.ok(result.includes('quick=1'));
  assert.ok(!result.includes('&tags='));
});

test('buildGoodlinksUrl - URL with single tag', () => {
  const url = 'https://smcleod.net/2025/03/the-democratisation-paradox-what-history-teaches-us-about-ai/';
  const title = 'The Democratisation Paradox';
  const tags = 'work';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('&tags=work'));
  assert.ok(result.includes('quick=1'));
});

test('buildGoodlinksUrl - URL with multiple space-separated tags', () => {
  const url = 'https://smcleod.net/2025/03/the-democratisation-paradox-what-history-teaches-us-about-ai/';
  const title = 'The Democratisation Paradox';
  const tags = 'work personal important';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('&tags=work%20personal%20important'));
});

test('buildGoodlinksUrl - handles special characters in URL', () => {
  const url = 'https://example.com/article?foo=bar&baz=qux';
  const title = 'Example Article';
  const tags = '';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('url=https%3A%2F%2Fexample.com%2Farticle%3Ffoo%3Dbar%26baz%3Dqux'));
});

test('buildGoodlinksUrl - handles special characters in title', () => {
  const url = 'https://example.com';
  const title = 'Article: "Special Characters" & Symbols!';
  const tags = '';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('title=Article%3A%20%22Special%20Characters%22%20%26%20Symbols!'));
});

test('buildGoodlinksUrl - handles Unicode characters', () => {
  const url = 'https://example.com';
  const title = 'Article with émojis 🚀 and ñ characters';
  const tags = '';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('goodlinks://x-callback-url/save?'));
  assert.ok(result.includes('quick=1'));
});

test('buildGoodlinksUrl - handles empty title', () => {
  const url = 'https://example.com';
  const title = '';
  const tags = '';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('title='));
  assert.ok(result.includes('url=https%3A%2F%2Fexample.com'));
});

test('buildGoodlinksUrl - verifies URL scheme structure', () => {
  const url = 'https://example.com';
  const title = 'Test';
  const tags = 'test';

  const result = buildGoodlinksUrl(url, title, tags);

  // Should have proper structure: scheme://x-callback-url/action?params
  assert.ok(result.startsWith('goodlinks://x-callback-url/save?'));
  assert.ok(result.includes('url='));
  assert.ok(result.includes('title='));
  assert.ok(result.includes('tags='));
  assert.ok(result.endsWith('quick=1'));
});

test('buildGoodlinksUrl - handles long URLs', () => {
  const url = 'https://example.com/' + 'a'.repeat(500);
  const title = 'Long URL Test';
  const tags = '';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('goodlinks://x-callback-url/save?'));
  assert.ok(result.length > 500);
});

test('buildGoodlinksUrl - handles tags with special characters', () => {
  const url = 'https://example.com';
  const title = 'Test';
  const tags = 'tag-with-dash tag_with_underscore';

  const result = buildGoodlinksUrl(url, title, tags);

  assert.ok(result.includes('tags=tag-with-dash%20tag_with_underscore'));
});
