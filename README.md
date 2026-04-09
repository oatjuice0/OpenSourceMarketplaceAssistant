# Open Source Marketplace Assistant

An iPhone app that takes a photo of anything you want to sell and uses AI to instantly write a Facebook Marketplace listing for you — title, price, and description, ready to copy and paste.

---

## What You Need Before Starting

- **A Mac computer** (any Mac that can run the latest macOS)
- **Xcode** (free app from Apple — this is what builds and runs iPhone apps)
- **An iPhone** or you can test on a simulated iPhone on your Mac
- **An API key** from Google, OpenAI, or Anthropic (this is how the app talks to the AI — explained below. **Google Gemini is free!**)

---

## Step 1: Install Xcode

1. Open the **App Store** on your Mac
2. Search for **Xcode**
3. Click **Get** / **Install** (it's free but large — about 12 GB, so it may take a while)
4. Once installed, **open Xcode once** and let it finish installing any extra components it asks for

---

## Step 2: Download This Project

**Option A — If you're comfortable with Terminal:**
1. Open **Terminal** (search for it in Spotlight with Cmd + Space)
2. Paste this and press Enter:
   ```
   git clone https://github.com/oatjuice0/OpenSourceMarketplaceAssistant.git
   ```
3. A folder called `OpenSourceMarketplaceAssistant` will appear in your home directory

**Option B — Download as a ZIP (easier):**
1. Go to [https://github.com/oatjuice0/OpenSourceMarketplaceAssistant](https://github.com/oatjuice0/OpenSourceMarketplaceAssistant)
2. Click the green **Code** button
3. Click **Download ZIP**
4. Find the ZIP in your Downloads folder and double-click it to unzip

---

## Step 3: Open the Project in Xcode

1. Find the folder you just downloaded/cloned
2. Double-click the file called **`OpenSourceMarketplaceAssistant.xcodeproj`** — it has a blue icon
3. Xcode will open with the project loaded

---

## Step 4: Set Up Signing (Required)

Xcode needs to know who you are before it can build an app, even just for testing on your own device.

1. In Xcode, click **`MarketplaceAssistant`** in the left sidebar (the very top item with the blue app icon)
2. In the middle panel, click the **Signing & Capabilities** tab
3. Check the box that says **Automatically manage signing**
4. Under **Team**, click the dropdown and select **Add an Account...**
5. Sign in with your **Apple ID** (any Apple ID works — you do NOT need a paid developer account)
6. After signing in, select your name from the Team dropdown
7. If the Bundle Identifier shows an error, change it to something unique like `com.yourname.marketplace`

---

## Step 5: Run the App

**To test on the simulator (no iPhone needed):**
1. At the top of Xcode, you'll see a device selector (it might say "iPhone 16" or similar)
2. Pick any iPhone model from the list
3. Click the **▶ Play button** (top-left corner) or press **Cmd + R**
4. Wait for it to build (first time takes a minute or two)
5. A simulated iPhone will pop up on screen with the app running

**To test on your real iPhone:**
1. Plug your iPhone into your Mac with a USB cable
2. When prompted on your iPhone, tap **Trust This Computer**
3. In Xcode's device selector at the top, choose your iPhone's name
4. Click the **▶ Play button** or press **Cmd + R**
5. The first time, you may need to go to **Settings > General > VPN & Device Management** on your iPhone and trust yourself as a developer

---

## Step 6: Get an AI API Key

The app needs an API key to connect to the AI that analyzes your photos. You only need **one** of the three options below. We recommend starting with **Google Gemini** since it's completely free.

### Cost Comparison

| Provider | Cost per scan | Credit card required? | Best for |
|----------|--------------|----------------------|----------|
| **Google Gemini** | **FREE** (up to 15 scans/min) | No | Everyone — start here |
| **OpenAI** (GPT-4o) | ~$0.01–0.03 | Yes | Highest quality results |
| **Anthropic** (Claude) | ~$0.01–0.03 | Yes | Great quality, alternative to OpenAI |

### Option A — Google Gemini (FREE — recommended)
1. Go to [https://aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Sign in with any **Google account** (your Gmail works)
3. Click **Create API Key**
4. Pick any Google Cloud project (or let it create one — doesn't matter)
5. Copy the key
6. That's it — **no credit card, no billing, no charges.** The free tier gives you 15 requests per minute and 1 million tokens per minute, which is way more than you'll ever need.

### Option B — OpenAI (GPT-4o) — paid, ~$0.01/scan
1. Go to [https://platform.openai.com/signup](https://platform.openai.com/signup) and create an account
2. Go to [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
3. Click **Create new secret key**
4. Copy the key (it starts with `sk-`)
5. You'll need to add a payment method and load a small balance ($5 gets you roughly 200–500 scans)

### Option C — Anthropic (Claude) — paid, ~$0.01/scan
1. Go to [https://console.anthropic.com/](https://console.anthropic.com/) and create an account
2. Go to [https://console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys)
3. Click **Create Key**
4. Copy the key (it starts with `sk-ant-`)
5. You'll need to add a payment method and load a small balance ($5 gets you roughly 200–500 scans)

### Enter your key in the app:
1. Open the app and tap the **Settings** tab (gear icon)
2. Choose your **Provider** (Google Gemini, OpenAI, or Anthropic)
3. Paste your API key into the **API Key** field
4. You'll see a green checkmark confirming it's saved

---

## How to Use the App

1. **Scan tab** — This is the main screen
   - Tap **Library** to pick a photo from your camera roll, or **Camera** to take a new one
   - Optionally pick a **Category** (like Electronics, Furniture, etc.) to help the AI price it better
   - Adjust the **Listing Style** if you want (e.g., Friendly tone, OBO pricing, Pickup Only)
   - Tap **Generate Listing**
   - The AI will return a **title**, **price**, and **description**
   - Tap the 📋 icon next to any field to copy it to your clipboard
   - Tap **Save Listing** to keep it for later

2. **Saved tab** — All your saved listings in one place
   - Tap any listing to view and edit it
   - Swipe left on a listing to delete it

3. **Settings tab** — Where your API key and preferences live

---

## Frequently Asked Questions

**Is this app free?**
Yes! The app is free and open source, and if you use **Google Gemini** as your AI provider, the API is free too. OpenAI and Anthropic charge a tiny amount per scan (~$0.01–0.03) but Gemini costs nothing.

**Does it work without an API key?**
No. The app needs an API key to send your photo to the AI. Without one, the Generate button will prompt you to add a key in Settings.

**Can I use this on iPad?**
It's built for iPhone only, but it will run on iPad in a compatibility window.

**The camera button doesn't show up?**
If you're running on the simulator, there's no camera — just use the Library button to pick a photo instead.

**I get an error when I try to generate?**
- Make sure your API key is entered correctly in Settings
- Make sure you have an internet connection
- Make sure your API account has billing set up and a positive balance

**How many scans can I do per day?**
10 per day by default. The counter resets at midnight. You can reset it manually in Settings for testing.

---

## Project Structure (for developers)

```
MarketplaceAssistant/
├── App/              App entry point and theme colors
├── Models/           Data models and option enums
├── Services/         API calls, Keychain, persistence, scan limiting
├── ViewModels/       Business logic (MVVM pattern)
└── Views/
    ├── Scan/         Main generation screen
    ├── Saved/        Saved listings list
    ├── ItemDetail/   Edit screen for a listing
    ├── Settings/     API key and preferences
    └── Components/   Reusable UI (pills, toasts, camera)
```

**Tech:** SwiftUI · iOS 16+ · MVVM · Zero third-party dependencies

---

Made with ❤️ and AI
