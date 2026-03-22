# Developer Setup Guide

## Prerequisites

1. **macOS** 14.0+ (Sonoma)
2. **Xcode** 15.2+ with iOS 17 SDK
3. **Swift** 5.9+
4. Active Apple Developer account (for device testing)

## Steps

### 1. Clone the Repository

```bash
git clone https://github.com/madel-xperience1st/Claude-RealEstate-Xp1st26-.git
cd Claude-RealEstate-Xp1st26-
```

### 2. Open the Project

```bash
open Package.swift
```

Xcode will resolve Swift Package Manager dependencies automatically:
- GoogleSignIn-iOS
- firebase-ios-sdk
- Kingfisher
- KeychainAccess

### 3. Configure Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create or select a project
3. Navigate to APIs & Services > Credentials
4. Create an OAuth 2.0 Client ID (iOS type)
5. Enter your bundle ID: `com.prophub.app`
6. Copy the Client ID to `PropHub/Core/Config/AppConfig.plist` -> `GoogleClientID`
7. In Xcode, add a URL scheme with the reversed client ID

### 4. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing
3. Add an iOS app with bundle ID `com.prophub.app`
4. Download `GoogleService-Info.plist`
5. Place it in `PropHub/Resources/GoogleService-Info.plist`
6. Enable Cloud Messaging in Firebase Console

### 5. Configure MuleSoft

1. Set the MuleSoft base URL in `AppConfig.plist` -> `MuleBaseURL`
2. Set the default Salesforce Org ID in `AppConfig.plist` -> `DefaultOrgId`
3. See [MULESOFT_CONFIG.md](MULESOFT_CONFIG.md) for API deployment

### 6. Build and Run

1. Select an iOS 17+ simulator (iPhone 15 Pro recommended)
2. Press Cmd+R to build and run
3. Sign in with a whitelisted Google account

## Running Tests

```bash
# Command line
xcodebuild test -scheme PropHub -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Or in Xcode: Cmd+U
```

## SwiftLint

```bash
brew install swiftlint
swiftlint lint
```
