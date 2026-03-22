# PropHub

> Real Estate Customer Portal for Salesforce Presales Demos

![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

PropHub is a production-grade iOS application designed for Salesforce presales consultants to demo branded real estate customer experiences for developers like Emaar, Sodic, DAMAC, and more. Every demo can be re-themed in real time to match the client's branding, backed by live Salesforce data routed through MuleSoft.

---

## Screenshots

| Login | Dashboard | My Units | Finance | Chat |
|-------|-----------|----------|---------|------|
| ![Login](docs/screenshots/login.png) | ![Dashboard](docs/screenshots/dashboard.png) | ![Units](docs/screenshots/units.png) | ![Finance](docs/screenshots/finance.png) | ![Chat](docs/screenshots/chat.png) |

---

## Features

### Authentication & Multi-Org
- Google OAuth 2.0 SSO with presales whitelist validation
- Multi-org connection manager for switching Salesforce environments
- Secure token storage in iOS Keychain

### Demo Switcher
- Real-time app re-theming per demo project (colors, logo, developer name)
- Grid-based project selector with live unit counts

### My Units
- Browse owned units with status, floor, area, and handover dates
- Floor plan viewing with payment progress visualization
- Quick-action navigation to payments, services, and assets

### Finance
- Installment timeline with milestone tracking
- Invoice listing with PDF download
- Overdue payment alerts with penalty tracking

### Service Requests
- Create service requests with photo attachments
- Track request lifecycle: New > Assigned > In Progress > Completed
- Category-based classification (Plumbing, Electrical, HVAC, General)

### Assets & Warranty
- Registered asset inventory per unit
- Visual warranty timeline (Active / Expiring Soon / Expired)
- Maintenance schedule with technician details

### Agentforce Chat
- AI-powered conversational support via Salesforce Agentforce
- Quick-reply buttons and typing indicators
- Live agent escalation

### Push Notifications
- Firebase Cloud Messaging integrated with Marketing Cloud
- Deep-linked notifications for payments, services, and launches

### New Launches & Waitlist
- Browse upcoming project launches with image carousels
- One-tap waitlist enrollment

---

## Architecture

```
iOS App (SwiftUI)
    |
    v  HTTPS / REST
MuleSoft Anypoint (CloudHub 2.0)
    |  Experience API -> Process API -> System API
    v  Salesforce REST API
Salesforce Org
    Sales Cloud | Service Cloud | Field Service | Marketing Cloud | Agentforce
```

---

## Prerequisites

- **Xcode** 15.2+
- **Swift** 5.9+
- **iOS** 17.0+ deployment target
- **Google Cloud** project with OAuth 2.0 credentials
- **Firebase** project with FCM enabled
- **Salesforce** org with Sales Cloud, Service Cloud, Field Service
- **MuleSoft** Anypoint Platform account (CloudHub 2.0)

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/madel-xperience1st/Claude-RealEstate-Xp1st26-.git
cd Claude-RealEstate-Xp1st26-

# 2. Open in Xcode
open Package.swift

# 3. Configure (see Configuration section below)

# 4. Select iOS 17+ simulator and run (Cmd+R)
```

---

## Configuration

### 1. Google OAuth Setup
1. Create a project in Google Cloud Console
2. Enable the Google Sign-In API
3. Create OAuth 2.0 Client ID for iOS
4. Add the client ID to `PropHub/Core/Config/AppConfig.plist` -> `GoogleClientID`
5. Add the reversed client ID as a URL scheme in Xcode

### 2. Firebase Setup
1. Create a Firebase project
2. Add an iOS app with your bundle ID
3. Download `GoogleService-Info.plist` to `PropHub/Resources/`
4. Enable Cloud Messaging

### 3. MuleSoft Configuration
1. Set the MuleSoft API gateway URL in `AppConfig.plist` -> `MuleBaseURL`
2. See [docs/MULESOFT_CONFIG.md](docs/MULESOFT_CONFIG.md) for full API setup

### 4. Salesforce Org
1. Create the custom objects and fields listed in [docs/SALESFORCE_CONFIG.md](docs/SALESFORCE_CONFIG.md)
2. Add presales users to `Presales_User__mdt`
3. Load demo data

---

## Demo Setup Guide

To create a new demo for a real estate developer:

1. **Salesforce**: Create a `Demo_Project__c` record with developer name, brand colors (hex), logo URL, default currency
2. **Units**: Create `Unit__c` records linked to the project
3. **Contact**: Create a Contact with `Owner_Contact__c` on units
4. **Launch App**: Sign in -> Select the new demo project -> App re-themes automatically

See [docs/DEMO_GUIDE.md](docs/DEMO_GUIDE.md) for the complete walkthrough.

---

## Project Structure

```
PropHub/
├── App/              # Entry point, app delegate, root navigation
├── Core/
│   ├── Config/       # Environment, secrets, caching
│   ├── Networking/   # API service, router, token management
│   ├── Auth/         # Google OAuth, session management
│   └── Extensions/   # Date, Color, View extensions
├── Features/
│   ├── DemoSwitcher/ # Project selection and theming
│   ├── Dashboard/    # Overview screen
│   ├── Units/        # Unit listing and detail
│   ├── Finance/      # Installments, invoices, overdue
│   ├── Services/     # Service requests
│   ├── Assets/       # Assets, warranty, maintenance
│   ├── Chat/         # Agentforce chat
│   ├── Notifications/# Push notification routing
│   └── NewLaunches/  # Project launches and waitlist
├── Shared/
│   ├── Components/   # Reusable UI components
│   └── Theme/        # Dynamic theming engine
└── Resources/        # Localization, config files
```

---

## API Reference

See [docs/API_REFERENCE.md](docs/API_REFERENCE.md) for the complete MuleSoft API specification.

---

## Deployment

### MuleSoft APIs
Deploy to CloudHub 2.0 via Anypoint Platform:
```bash
mvn clean deploy -DmuleDeploy
```

### iOS App
1. Archive in Xcode: Product -> Archive
2. Distribute via TestFlight or Ad Hoc

---

## Contributing

1. Branch from `main`: `feature/your-feature-name`
2. Follow Conventional Commits:
   - `feat:` New features
   - `fix:` Bug fixes
   - `docs:` Documentation
   - `chore:` Maintenance
3. Submit a PR with a clear description
4. Ensure CI passes (build, tests, SwiftLint)

---

## Versioning

This project uses Semantic Versioning:
- **MAJOR**: Breaking API changes
- **MINOR**: New features (backward-compatible)
- **PATCH**: Bug fixes

Tags: `v1.0.0`, `v1.1.0`, `v1.0.1`, etc.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Google Sign-In fails | Verify `GoogleClientID` in AppConfig.plist and URL schemes |
| "Unauthorized" after login | Confirm email is in `Presales_User__mdt` in Salesforce |
| API calls return 401 | Check MuleSoft token validation; token may be expired |
| Push notifications not received | Verify `GoogleService-Info.plist` and FCM token registration |
| App shows stale data | Pull-to-refresh or switch orgs to clear cache |

---

## License

MIT License. See [LICENSE](LICENSE) for details.
