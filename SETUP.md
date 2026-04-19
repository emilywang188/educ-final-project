# WordCast Setup Instructions

## Getting Started

This app requires a Google Gemini API key for the podcast text-to-speech feature.

### 1. Get Your Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Sign in with your Google account
3. Click "Create API Key" or copy an existing one
4. Your API key should start with `AIza`

### 2. Configure the API Key

You have two options:

#### Option A: Using Config.swift (Recommended)

1. Copy `WordCast/WordCast/Config-template.swift` to `WordCast/WordCast/Config.swift`
2. Open `Config.swift`
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key

```bash
cp WordCast/WordCast/Config-template.swift WordCast/WordCast/Config.swift
# Then edit Config.swift and add your API key
```

#### Option B: Using Info.plist (Alternative)

1. Copy `WordCast/WordCast/Info-template.plist` to `WordCast/WordCast/Info.plist`
2. Open `Info.plist`
3. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key

```bash
cp WordCast/WordCast/Info-template.plist WordCast/WordCast/Info.plist
# Then edit Info.plist and add your API key
```

### 3. Build and Run

Open `WordCast.xcodeproj` in Xcode and run the project.

## Security Notes

- **Never commit** `Config.swift` or `Info.plist` to version control
- These files are already in `.gitignore`
- Only commit the `-template` files
- Keep your API key private and don't share it publicly
