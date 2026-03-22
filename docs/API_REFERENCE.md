# API Reference

All endpoints are prefixed with `/api/v1`. MuleSoft handles auth token validation, Salesforce session management, and response transformation.

## Authentication

### POST /auth/token
Exchange Google ID token for PropHub JWT.

**Request:**
```json
{
  "googleIdToken": "eyJhbGciOiJSUzI1...",
  "orgId": "00Dxx0000001234"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1...",
  "expiresIn": 3600,
  "user": {
    "id": "user-001",
    "email": "consultant@example.com",
    "displayName": "Ahmed Hassan",
    "role": "Senior Presales",
    "contactId": "003xx000001234"
  }
}
```

### POST /auth/refresh
Refresh an expired access token.

**Headers:** `Authorization: Bearer <refreshToken>`

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1...",
  "expiresIn": 3600
}
```

### POST /auth/logout
Invalidate the current session.

**Headers:** `Authorization: Bearer <token>`

---

## Demo Projects

### GET /projects
List all active demo projects.

**Response:**
```json
[
  {
    "id": "proj-001",
    "name": "Emaar Beachfront",
    "developer": "Emaar Properties",
    "logoUrl": "https://example.com/emaar-logo.png",
    "brandPrimaryColor": "#1B4D8E",
    "brandSecondaryColor": "#F5A623",
    "unitCount": 42
  }
]
```

### GET /projects/{projectId}
Get full project details with statistics.

---

## Units

### GET /projects/{projectId}/units
List units for a project, optionally filtered.

**Query Parameters:**
- `contactId` (required) - Filter by owner contact
- `status` (optional) - Filter by status

**Response:**
```json
[
  {
    "id": "unit-001",
    "unitNumber": "A-1204",
    "building": "Tower A",
    "floor": 12,
    "areaSqm": 85.5,
    "areaSqft": 920.3,
    "unitType": "2BR",
    "status": "Delivered",
    "handoverDate": "2025-06-15T00:00:00Z",
    "floorPlanUrl": "https://example.com/plan.jpg"
  }
]
```

### GET /units/{unitId}
Get full unit detail with payment summary.

---

## Finance

### GET /units/{unitId}/installments
List all installments for a unit.

**Response:**
```json
[
  {
    "id": "inst-001",
    "milestoneName": "Booking Fee",
    "dueDate": "2024-01-15T00:00:00Z",
    "amount": 150000.00,
    "status": "Paid",
    "paidDate": "2024-01-10T00:00:00Z",
    "penaltyAmount": null
  }
]
```

### GET /units/{unitId}/invoices
List all invoices for a unit.

### GET /units/{unitId}/invoices/{invoiceId}/pdf
Download invoice PDF (binary stream).

### GET /units/{unitId}/payment-summary
Get aggregated payment summary.

**Response:**
```json
{
  "totalPrice": 1500000.00,
  "paidAmount": 750000.00,
  "remainingBalance": 750000.00,
  "nextDueDate": "2025-04-01T00:00:00Z",
  "overdueCount": 1,
  "overdueAmount": 150000.00
}
```

---

## Service Requests

### GET /units/{unitId}/service-requests
List service requests for a unit.

**Query Parameters:**
- `status` (optional) - Filter by status (open, closed)

### POST /units/{unitId}/service-requests
Create a new service request.

**Request:**
```json
{
  "category": "Plumbing",
  "subject": "Kitchen sink leak",
  "description": "Water leaking from under the kitchen sink",
  "preferredDate": "2025-04-01T10:00:00Z",
  "assetId": null
}
```

### POST /service-requests/{requestId}/attachments
Upload a photo attachment (multipart/form-data).

### GET /service-requests/{requestId}
Get full service request details with work order info.

---

## Assets

### GET /units/{unitId}/assets
List all registered assets for a unit.

### GET /assets/{assetId}
Get full asset detail.

### GET /assets/{assetId}/warranty
Get warranty details.

**Response:**
```json
{
  "startDate": "2024-06-15T00:00:00Z",
  "endDate": "2026-06-15T00:00:00Z",
  "status": "Active",
  "provider": "Samsung",
  "terms": "2-year manufacturer warranty..."
}
```

### GET /assets/{assetId}/maintenance
List maintenance records (work orders).

---

## Chat (Agentforce Proxy)

### POST /chat/sessions
Create a new chat session.

**Request:**
```json
{
  "contactId": "003xx000001234",
  "projectId": "proj-001",
  "unitId": "unit-001"
}
```

**Response:**
```json
{
  "sessionId": "session-abc123",
  "welcomeMessage": "Hello! How can I help you today?"
}
```

### POST /chat/sessions/{sessionId}/messages
Send a message and receive agent response.

**Request:**
```json
{
  "text": "What's the status of my unit?",
  "quickReplyValue": null
}
```

**Response:**
```json
{
  "messages": [
    {
      "text": "Your unit A-1204 is currently Delivered.",
      "sender": "agent",
      "timestamp": "2025-03-22T14:30:00Z",
      "quickReplies": [
        { "label": "View payments", "value": "view_payments" },
        { "label": "Request service", "value": "request_service" }
      ]
    }
  ]
}
```

### DELETE /chat/sessions/{sessionId}
End the chat session.

---

## Push Notifications

### POST /notifications/register
Register FCM device token.

**Request:**
```json
{
  "fcmToken": "dGVzdC10b2tlbi1mb3ItZmNt...",
  "contactId": "003xx000001234",
  "platform": "ios"
}
```

---

## Error Responses

All errors follow this format:
```json
{
  "error": {
    "code": 401,
    "message": "Invalid or expired token"
  }
}
```

| Code | Meaning |
|------|---------|
| 400 | Bad request (invalid parameters) |
| 401 | Unauthorized (invalid/expired token) |
| 403 | Forbidden (not whitelisted) |
| 404 | Resource not found |
| 429 | Rate limited |
| 500 | Internal server error |
