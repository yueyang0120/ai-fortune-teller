# Ai Fortune Teller

SwiftUI iOS app for Zi Wei Dou Shu readings, including personal chart analysis and synastry flows.

## Build

Open `ai-fortune-teller.xcodeproj` in Xcode, select the `ai-fortune-teller` scheme, and build.

CLI checks used for this repo:

```sh
xcodebuild -project ai-fortune-teller.xcodeproj -scheme ai-fortune-teller -configuration Debug -destination 'generic/platform=iOS Simulator' ENABLE_ON_DEMAND_RESOURCES=NO build
xcodebuild -project ai-fortune-teller.xcodeproj -scheme ai-fortune-teller -configuration Release -destination 'generic/platform=iOS' ENABLE_ON_DEMAND_RESOURCES=NO build
```

## Local API Keys

The committed `Info.plist` uses placeholder API keys. Do not commit real keys.

For local development, set the provider keys in Xcode scheme environment variables, or copy `Config.xcconfig.example` to `Config.xcconfig` and keep it local. `Config.xcconfig` is ignored by git.

Required only for live AI analysis:

- `GEMINI_API_KEY`
- `OPENAI_API_KEY`
- `DEEPSEEK_API_KEY`
