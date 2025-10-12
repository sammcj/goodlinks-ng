# Chrome Web Store Publishing Guide

This guide covers publishing the extension to the Chrome Web Store, both manually and automatically.

## Prerequisites

1. **Google Account** with Chrome Web Store developer access
2. **Developer fee**: $5 USD one-time payment
3. **Extension assets**: Screenshots, promotional images (see requirements below)

## Initial Manual Submission

### Step 1: Create Developer Account

1. Visit [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
2. Sign in with your Google account
3. Pay the $5 one-time developer registration fee

### Step 2: Prepare Assets

Required assets (create these before submission):

- **Icon**: 128x128px (already have this)
- **Small promo tile**: 440x280px
- **Screenshots**: At least 1, up to 5 (1280x800 or 640x400)
- **Promotional images** (optional but recommended):
  - Large promo tile: 920x680px
  - Marquee: 1400x560px

### Step 3: Submit Extension

1. Click "New Item" in the Developer Dashboard
2. Upload `dist/goodlinks-ng-1.0.0-chrome.zip`
3. Fill in the listing information:
   - **Name**: Goodlinks-NG
   - **Summary**: Send web pages to the Goodlinks app with a single click. No sign-in required.
   - **Description**: (Use similar to Firefox listing)
   - **Category**: Productivity
   - **Language**: English
4. Upload screenshots and promotional images
5. Select visibility: Public, Unlisted, or Private
6. Submit for review

**Note**: Save your **Extension ID** after submission - you'll need it for automation.

## Automated Publishing Setup

### Step 1: Get API Credentials

#### A. Enable Chrome Web Store API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Navigate to "APIs & Services" → "Library"
4. Search for "Chrome Web Store API"
5. Click "Enable"

#### B. Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Select "External" user type
3. Fill in required information:
   - App name: "Goodlinks-NG Publisher"
   - User support email: your email
   - Developer contact: your email
4. Add test users: Add your email address
5. Save

#### C. Create OAuth Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Application type: "Web application"
4. Name: "Goodlinks-NG Web Store Publisher"
5. Add Authorised redirect URI: `https://developers.google.com/oauthplayground`
6. Click "Create"
7. **Save the Client ID and Client Secret**

#### D. Generate Refresh Token

1. Visit [OAuth 2.0 Playground](https://developers.google.com/oauthplayground)
2. Click the gear icon (⚙️) in top right
3. Check "Use your own OAuth credentials"
4. Enter your Client ID and Client Secret
5. In "Step 1 - Select & authorize APIs":
   - Input field: `https://www.googleapis.com/auth/chromewebstore`
   - Click "Authorize APIs"
6. Sign in with your Google account
7. In "Step 2 - Exchange authorization code for tokens":
   - Click "Exchange authorization code for tokens"
8. **Copy the Refresh Token**

### Step 2: Configure Credentials

You'll need three values:
- **Client ID**: From OAuth credentials
- **Client Secret**: From OAuth credentials
- **Refresh Token**: From OAuth Playground
- **Extension ID**: From Chrome Web Store Developer Dashboard (after first submission)

**For local use**, export as environment variables:

```bash
export CHROME_CLIENT_ID="your-client-id.apps.googleusercontent.com"
export CHROME_CLIENT_SECRET="your-client-secret"
export CHROME_REFRESH_TOKEN="your-refresh-token"
export CHROME_EXTENSION_ID="your-extension-id"
```

**For GitHub Actions**, add as repository secrets:
1. Go to repository Settings → Secrets and variables → Actions
2. Add secrets:
   - `CHROME_CLIENT_ID`
   - `CHROME_CLIENT_SECRET`
   - `CHROME_REFRESH_TOKEN`
   - `CHROME_EXTENSION_ID`

### Step 3: Publish Updates

**Manual publishing:**
```bash
make publish-chrome
```

**Automatic publishing:**
When you run `make release VERSION=1.0.1`, GitHub Actions will automatically:
1. Build and test the extension
2. Sign Firefox extension for AMO
3. Publish Chrome extension to Web Store
4. Create GitHub release with both packages

## Manual Publishing to Chrome Web Store

To manually update the extension:

1. Build the package: `make package-chrome`
2. Go to [Developer Dashboard](https://chrome.google.com/webstore/devconsole)
3. Click on your extension
4. Click "Package" → "Upload new package"
5. Upload `dist/goodlinks-ng-X.Y.Z-chrome.zip`
6. Update version number and descriptions if needed
7. Click "Submit for review"

## Review Process

- **Initial submission**: Usually 1-3 days
- **Updates**: Often faster, can be hours to 1-2 days
- You'll receive email notifications about review status

## Troubleshooting

### "Access blocked" error during OAuth
- Make sure you added your email as a test user in OAuth consent screen
- The app doesn't need to be verified for personal/testing use

### API not enabled
- Double-check Chrome Web Store API is enabled in Google Cloud Console
- Make sure you're using the correct project

### Invalid refresh token
- Refresh tokens can expire if not used for 6 months
- Generate a new one using OAuth Playground

## References

- [Chrome Web Store Developer Documentation](https://developer.chrome.com/docs/webstore/)
- [Using the Chrome Web Store API](https://developer.chrome.com/docs/webstore/using_webstore_api/)
- [OAuth 2.0 Playground](https://developers.google.com/oauthplayground)
