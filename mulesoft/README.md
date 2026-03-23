# PropHub MuleSoft API

Complete MuleSoft 4 API connecting the PropHub iOS app to your Salesforce org.

## Architecture

```
iOS App (SwiftUI)
    |  HTTPS REST + JWT Bearer
    v
PropHub MuleSoft API (Single CloudHub App)
    |-- Experience Layer  (REST endpoints, JWT validation, response shaping)
    |-- Process Layer     (business logic, aggregation, DataWeave transforms)
    |-- System Layer      (Salesforce Connector, SOQL queries, CRUD)
    |
    v
Salesforce Org (Sales Cloud + Service Cloud + Field Service)
```

**Design choice:** Single deployable app with internal 3-tier separation. Uses only 1 CloudHub worker (trial-friendly). Can be split into 3 separate apps later for production.

## Quick Start (5 minutes)

### Prerequisites
- Java 17+
- Maven 3.8+
- MuleSoft Anypoint Platform account (trial works)
- Salesforce org with PropHub objects deployed

### Step 1: Configure Credentials

```bash
cd mulesoft
cp .env.template .env
# Edit .env with your Salesforce + Anypoint credentials
```

### Step 2: Get Your Salesforce Security Token

1. Log into Salesforce
2. Go to: **Setup > My Personal Information > Reset My Security Token**
3. Check your email for the new token
4. Add it to `.env` as `SF_SECURITY_TOKEN`

### Step 3: Deploy

**Option A - Local testing (no CloudHub needed):**
```bash
./deploy.sh --local
```
API runs at `http://localhost:8081/api/v1`

**Option B - Deploy to CloudHub:**
```bash
./deploy.sh
```

**Option C - GitHub Actions (recommended for redeployment):**
1. Add these GitHub Secrets to your repo:
   - `ANYPOINT_USERNAME`
   - `ANYPOINT_PASSWORD`
   - `SF_USERNAME`
   - `SF_PASSWORD`
   - `SF_SECURITY_TOKEN`
   - `SF_DEMO_USER_EMAIL`
   - `JWT_SECRET`
2. Push to `main` branch or trigger manually

## When Your Trial Expires (New Org Setup)

This is the key advantage of the GitHub DevOps approach:

### New MuleSoft Trial
1. Sign up for new Anypoint Platform trial
2. Update **3 GitHub Secrets**:
   - `ANYPOINT_USERNAME` → new trial login
   - `ANYPOINT_PASSWORD` → new trial password
3. Go to Actions tab → Run workflow → Done!

### New Salesforce Trial
1. Sign up for new Salesforce developer org
2. Deploy PropHub custom objects (from `salesforce-data/` CSVs)
3. Update **3 GitHub Secrets**:
   - `SF_USERNAME` → new org username
   - `SF_PASSWORD` → new org password
   - `SF_SECURITY_TOKEN` → new security token
4. Go to Actions tab → Run workflow → Done!

**Total time: ~10 minutes** vs rebuilding everything from scratch.

## API Endpoints

All endpoints are prefixed with `/api/v1`.

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/token` | Exchange Google token for JWT |
| POST | `/auth/refresh` | Refresh expired token |
| POST | `/auth/logout` | Invalidate session |
| GET | `/projects` | List active demo projects |
| GET | `/projects/{id}` | Project detail |
| GET | `/projects/{id}/units` | List units (filtered by contact) |
| GET | `/units/{id}` | Unit detail |
| GET | `/units/{id}/installments` | Payment installments |
| GET | `/units/{id}/invoices` | Invoice list |
| GET | `/units/{id}/invoices/{id}/pdf` | Download invoice PDF |
| GET | `/units/{id}/payment-summary` | Aggregated payment summary |
| GET | `/units/{id}/service-requests` | Service requests list |
| POST | `/units/{id}/service-requests` | Create service request |
| GET | `/service-requests/{id}` | Service request detail |
| POST | `/service-requests/{id}/attachments` | Upload photo |
| GET | `/units/{id}/assets` | Assets list |
| GET | `/assets/{id}` | Asset detail |
| GET | `/assets/{id}/warranty` | Warranty info |
| GET | `/assets/{id}/maintenance` | Maintenance records |
| POST | `/chat/sessions` | Create chat session |
| POST | `/chat/sessions/{id}/messages` | Send chat message |
| DELETE | `/chat/sessions/{id}` | End chat session |
| POST | `/notifications/register` | Register push token |
| GET | `/launches` | List project launches |
| GET | `/launches/{id}` | Launch detail |
| POST | `/waitlist` | Join launch waitlist |
| GET | `/health` | Health check |

## Project Structure

```
mulesoft/
├── prophub-api/
│   ├── pom.xml                          # Maven config + dependencies
│   ├── src/main/mule/
│   │   ├── prophub-api.xml              # Main HTTP listener + APIKit router
│   │   ├── global-config.xml            # SF connector, HTTP, ObjectStore
│   │   ├── error-handler.xml            # Global error handling (matches iOS APIError)
│   │   ├── experience/                  # REST endpoint routing
│   │   │   ├── auth-api.xml
│   │   │   ├── projects-api.xml
│   │   │   ├── units-api.xml
│   │   │   ├── finance-api.xml
│   │   │   ├── service-requests-api.xml
│   │   │   ├── assets-api.xml
│   │   │   ├── chat-api.xml
│   │   │   ├── notifications-api.xml
│   │   │   └── launches-api.xml
│   │   ├── process/                     # Business logic + DataWeave transforms
│   │   │   ├── auth-process.xml
│   │   │   ├── projects-process.xml
│   │   │   ├── units-process.xml
│   │   │   ├── finance-process.xml
│   │   │   ├── service-requests-process.xml
│   │   │   ├── assets-process.xml
│   │   │   └── launches-process.xml
│   │   └── system/                      # Salesforce SOQL queries + CRUD
│   │       └── salesforce-operations.xml
│   └── src/main/resources/
│       ├── api/prophub-api.raml         # API specification
│       ├── application-dev.yaml         # Dev environment config
│       ├── application-sandbox.yaml     # Sandbox environment config
│       └── log4j2.xml                   # Logging config
├── .github/workflows/
│   └── deploy-mulesoft.yml             # GitHub Actions CI/CD
├── .env.template                        # Credential template
├── .gitignore
├── deploy.sh                            # Quick deploy script
└── README.md                            # This file
```

## Connecting the iOS App

After deployment, update your iOS app's `AppConfig.plist`:

```xml
<key>MuleBaseURL</key>
<string>https://prophub-api.us-east-2.cloudhub.io/api/v1</string>
```

For local testing:
```xml
<key>MuleBaseURL</key>
<string>http://localhost:8081/api/v1</string>
```

Then set `AppSettings.useMockData = false` to switch from mock data to live Salesforce data.

## Troubleshooting

**Salesforce connection fails:**
- Verify security token (Setup > Reset My Security Token)
- Check IP restrictions (Setup > Network Access > add your IP range)
- For sandbox: ensure `sf.login.url` uses `https://test.salesforce.com`

**401 errors from iOS app:**
- Check that `Presales_User__mdt` has your email whitelisted
- Verify the token hasn't expired (default: 1 hour)

**SOQL errors:**
- Ensure all custom objects and fields from `SALESFORCE_CONFIG.md` are deployed
- Check field-level security for the integration user

**CloudHub deployment fails:**
- Verify Anypoint credentials
- Check that app name isn't already taken (must be globally unique)
- Trial orgs: ensure you haven't exceeded the 1 worker limit
