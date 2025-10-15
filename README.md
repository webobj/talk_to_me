# Talk To Me - Voice Companion App

A voice-based companion app for macOS and iOS that allows you to have conversations using your voice. The app remembers your conversation history and uses AI to provide helpful responses.

## Features

- **Voice Input**: Talk to your companion using speech recognition
- **Voice Output**: Hear responses spoken back to you
- **Conversation Memory**: All conversations are saved locally and used for context
- **Cross-Platform**: Works on both macOS and iOS
- **AI-Powered**: Uses OpenAI's GPT for intelligent responses (configurable for other LLMs)

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://docs.flutter.dev/get-started/install
   - Follow the installation guide for macOS

2. **Xcode** (for macOS and iOS development)
   - Install from the Mac App Store
   - Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - Run `sudo xcodebuild -runFirstLaunch`

3. **CocoaPods** (for iOS dependencies)
   - Install with: `sudo gem install cocoapods`

## Setup Instructions

### 1. Install Flutter

```bash
# Verify Flutter installation
flutter doctor

# Make sure all checks pass for macOS and iOS development
```

### 2. Clone and Setup Project

```bash
cd talk_to_me_app

# Get Flutter dependencies
flutter pub get
```

### 3. Configure API Key

```bash
# Copy the example env file
cp .env.example .env

# Edit .env and add your OpenAI API key
# Get your API key from: https://platform.openai.com/api-keys
```

Edit `.env`:
```
OPENAI_API_KEY=sk-your-actual-api-key-here
```

### 4. Configure Platform-Specific Settings

#### For macOS:

Edit `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
</dict>
</plist>
```

Edit `macos/Runner/Info.plist` and add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice input.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to understand your voice.</string>
```

#### For iOS:

Edit `ios/Runner/Info.plist` and add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice input.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to understand your voice.</string>
```

## Running the App

### Run on macOS:

```bash
flutter run -d macos
```

### Run on iOS Simulator:

```bash
# List available simulators
flutter devices

# Run on iPhone simulator
flutter run -d "iPhone 15 Pro"
```

### Run on Physical iPhone:

1. Connect your iPhone via USB
2. Trust the computer on your iPhone
3. In Xcode, go to Signing & Capabilities and select your team
4. Run: `flutter run`

## Project Structure

```
talk_to_me_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── message.dart          # Message data model
│   ├── services/
│   │   ├── database_helper.dart  # SQLite database management
│   │   ├── conversation_service.dart  # Conversation & AI logic
│   │   └── voice_service.dart    # Speech-to-text & text-to-speech
│   ├── screens/
│   │   └── home_screen.dart      # Main UI screen
│   └── widgets/
│       └── message_bubble.dart   # Chat message UI component
├── assets/                       # Static assets
├── .env                          # Environment variables (API keys)
└── pubspec.yaml                  # Dependencies
```

## How to Use

1. **Launch the app** on your macOS or iOS device
2. **Tap the microphone button** to start speaking
3. **Speak your question or request**
4. **Wait for the response** - the app will both display and speak the response
5. **Continue the conversation** - all messages are saved for context

## Customization

### Using a Different LLM

Edit `lib/services/conversation_service.dart` to change the AI provider:

```dart
// Replace OpenAI API with Anthropic Claude, Google Gemini, etc.
// Update the API endpoint and request format accordingly
```

### Adjusting Voice Settings

Edit `lib/services/voice_service.dart` to modify:
- Speech rate
- Voice pitch
- Language
- Listening duration

### Styling

Modify `lib/widgets/message_bubble.dart` and `lib/screens/home_screen.dart` to customize the UI appearance.

## Troubleshooting

### "Command not found: flutter"
- Make sure Flutter is added to your PATH
- Run: `export PATH="$PATH:`pwd`/flutter/bin"`

### Microphone permissions denied
- Check System Preferences > Security & Privacy > Microphone
- Ensure your app has permission

### API key errors
- Verify your `.env` file exists and contains the correct API key
- Make sure you have credits in your OpenAI account

### iOS build errors
- Run `cd ios && pod install && cd ..`
- Clean build: `flutter clean && flutter pub get`

## Dependencies

- `speech_to_text`: Speech recognition
- `flutter_tts`: Text-to-speech
- `provider`: State management
- `sqflite`: Local database
- `http`: API requests
- `flutter_dotenv`: Environment variables

## Future Enhancements

- [ ] Support for multiple AI providers
- [ ] Custom wake word detection
- [ ] Background voice activation
- [ ] iCloud sync for conversations
- [ ] Conversation export/import
- [ ] Multi-language support
- [ ] Custom voice selection

## License

MIT License - feel free to use this project as a starting point for your own voice app!
