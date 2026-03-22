# Salesforce Configuration Guide

## Custom Objects

### Demo_Project__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Text(80) | Project display name (e.g., "Emaar Beachfront") |
| Developer_Name__c | Text(80) | Developer company name |
| Brand_Primary_Color__c | Text(7) | Hex color "#1B4D8E" |
| Brand_Secondary_Color__c | Text(7) | Hex color "#F5A623" |
| Brand_Logo_URL__c | URL | Logo image URL |
| Description__c | Long Text Area | Project marketing description |
| Status__c | Picklist | Active / Archived |
| Default_Currency__c | Text(3) | AED, EGP, SAR, etc. |

### Unit__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Auto Number: UNIT-{0000} | |
| Unit_Number__c | Text(20) | e.g., "A-1204" |
| Demo_Project__c | Lookup(Demo_Project__c) | |
| Building__c | Text(50) | Building name/number |
| Floor__c | Number | |
| Area_SQM__c | Number | |
| Area_SQFT__c | Formula | Area_SQM__c * 10.764 |
| Unit_Type__c | Picklist | Studio, 1BR, 2BR, 3BR, Penthouse, Villa, Townhouse |
| Status__c | Picklist | Available, Reserved, Sold, Under Construction, Handover Ready, Delivered |
| Handover_Date__c | Date | |
| Total_Price__c | Currency | |
| Floor_Plan_URL__c | URL | |
| Owner_Contact__c | Lookup(Contact) | The residential buyer |
| Payment_Completion__c | Formula(%) | % of total price paid |

### Installment__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Auto Number: INST-{0000} | |
| Unit__c | Master-Detail(Unit__c) | |
| Milestone_Name__c | Text(80) | "Booking", "30% Construction", "Handover" |
| Due_Date__c | Date | |
| Amount__c | Currency | |
| Status__c | Picklist | Pending, Upcoming, Paid, Overdue |
| Paid_Date__c | Date | |
| Penalty_Amount__c | Currency | |
| Invoice__c | Lookup(Invoice__c) | |
| Sort_Order__c | Number | Display sequence |

### Invoice__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Auto Number: INV-{0000} | |
| Unit__c | Lookup(Unit__c) | |
| Invoice_Date__c | Date | |
| Due_Date__c | Date | |
| Amount__c | Currency | |
| Status__c | Picklist | Draft, Sent, Paid, Overdue, Void |
| PDF_Attachment_Id__c | Text(18) | ContentDocument ID |
| Installment__c | Lookup(Installment__c) | |

### Project_Launch__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Text(80) | Launch campaign name |
| Demo_Project__c | Lookup(Demo_Project__c) | |
| Description__c | Rich Text | |
| Price_Range_Min__c | Currency | |
| Price_Range_Max__c | Currency | |
| Expected_Handover__c | Text(20) | "Q4 2026" |
| Hero_Image_URLs__c | Long Text Area | Comma-separated URLs |
| Amenities__c | Long Text Area | JSON array of amenity names |
| Launch_Date__c | Date | |
| Is_Active__c | Checkbox | |

### Waitlist_Entry__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Auto Number: WL-{0000} | |
| Contact__c | Lookup(Contact) | |
| Project_Launch__c | Lookup(Project_Launch__c) | |
| Registration_Date__c | DateTime | |
| Status__c | Picklist | Registered, Contacted, Converted, Withdrawn |
| Preferred_Unit_Type__c | Picklist | Studio, 1BR, 2BR, etc. |
| Notes__c | Long Text Area | |

### Presales_User__mdt (Custom Metadata Type)
| Field | Type | Description |
|-------|------|-------------|
| Google_Email__c | Text(100) | Whitelisted Google email |
| Display_Name__c | Text(80) | |
| Role__c | Text(50) | "Senior Presales", "Solutions Engineer" |
| Is_Active__c | Checkbox | |

## Standard Object Custom Fields

### Contact
- `PropHub_User_Id__c` (Text 36, External ID)
- `Active_Demo_Project__c` (Lookup -> Demo_Project__c)
- `FCM_Token__c` (Text 255)

### Account
- `Developer__c` (Checkbox)

### Asset
- `Unit__c` (Lookup -> Unit__c)
- `Warranty_Start_Date__c` (Date)
- `Warranty_End_Date__c` (Date)
- `Warranty_Status__c` (Formula: Active / Expiring Soon / Expired)
- `Manufacturer__c` (Text 80)
- `Category__c` (Picklist: HVAC, Appliance, Plumbing, Electrical, Furniture)
- `Serial_Number__c` (Text 50)

### Case
- `Unit__c` (Lookup -> Unit__c)
- `Service_Category__c` (Picklist: Plumbing, Electrical, HVAC, General, Maintenance)
- `Preferred_Service_Date__c` (Date)
- `Related_Asset__c` (Lookup -> Asset)

### WorkOrder
- `Unit__c` (Lookup -> Unit__c)
- `Related_Asset__c` (Lookup -> Asset)
