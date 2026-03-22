# MuleSoft Configuration Guide

## Architecture

PropHub uses a 3-layer MuleSoft API architecture:

```
iOS App -> Experience API -> Process API -> System API -> Salesforce
```

## API Projects

### 1. prophub-experience-api (Experience Layer)
- The iOS app communicates only with this API
- Handles JWT validation
- Orchestrates calls to process APIs
- Transforms responses to mobile-friendly JSON
- Deployed on CloudHub 2.0

### 2. prophub-process-api (Process Layer)
- Business logic and data aggregation
- Payment summary calculations
- Data enrichment across objects
- Orchestration of multiple Salesforce queries

### 3. prophub-system-api (System Layer)
- Direct Salesforce connector (OAuth 2.0 JWT Bearer Flow)
- SOQL queries and CRUD operations
- Bulk operations for demo data loading

## Salesforce Connector Configuration

```yaml
salesforce:
  config:
    connection:
      type: "oauth-jwt"
      consumerKey: "${sf.consumer.key}"
      keyStorePath: "${sf.keystore.path}"
      storePassword: "${sf.keystore.password}"
      principal: "${sf.username}"
      tokenEndpoint: "https://login.salesforce.com/services/oauth2/token"
      audienceUrl: "https://login.salesforce.com"
```

## Environment Properties

Each environment (dev, staging, prod) requires:

```yaml
# application-{env}.yaml
mule:
  env: dev
sf:
  consumer.key: "your-connected-app-consumer-key"
  keystore.path: "salesforce-keystore.jks"
  keystore.password: "${secure::sf.keystore.password}"
  username: "integration@yourorg.com"
google:
  oauth.clientId: "your-google-client-id"
jwt:
  secret: "${secure::jwt.secret}"
  expiration: 3600
```

## Deployment

```bash
# Deploy to CloudHub 2.0
mvn clean deploy -DmuleDeploy \
  -Danypoint.username=your-username \
  -Danypoint.password=your-password \
  -Denv=dev
```

## API Gateway Policies

Apply these policies in API Manager:
1. **Rate Limiting**: 100 requests/minute per client
2. **JWT Validation**: Validate PropHub JWT tokens
3. **CORS**: Allow iOS app origins
4. **Spike Control**: Max 20 concurrent connections
