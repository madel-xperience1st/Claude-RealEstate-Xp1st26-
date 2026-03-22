# Changelog

All notable changes to PropHub will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-22

### Added
- **Phase 1 - Foundation**
  - Google OAuth 2.0 SSO with presales whitelist validation via MuleSoft
  - Multi-org connection manager with Keychain-encrypted storage
  - Demo project switcher with dynamic app theming
  - Central networking layer (APIService) with token management
  - Offline caching with 15-minute TTL
  - Network connectivity monitoring

- **Phase 1 - Core Features (Structure)**
  - Dashboard with quick stats, unit summary, payment overview
  - Unit listing and detail views with floor plan display
  - Finance module: installments, invoices, overdue tracking
  - Service request creation with photo attachments
  - Asset inventory with warranty timeline visualization
  - Maintenance schedule view
  - Agentforce-powered chat interface
  - Push notification routing with deep linking
  - New launches browsing with waitlist enrollment

- **Infrastructure**
  - GitHub Actions CI/CD (build, test, SwiftLint, release)
  - SwiftLint configuration
  - Comprehensive localization (Localizable.strings)
  - Unit tests for models, extensions, and API router
  - Complete project documentation
