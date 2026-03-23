# Salesforce Data Import Guide

## Import Order (MUST follow this sequence — parent objects first)

| # | File | Salesforce Object | Records | Method |
|---|------|-------------------|---------|--------|
| 1 | `01_Account.csv` | Account | 4 | Insert |
| 2 | `02_Contact.csv` | Contact | 6 | Insert |
| 3 | `03_Demo_Project__c.csv` | Demo_Project__c | 4 | Insert |
| 4 | `04_Unit__c.csv` | Unit__c | 4 | Insert |
| 5 | `05_Installment__c.csv` | Installment__c | 9 | Insert |
| 6 | `06_Invoice__c.csv` | Invoice__c | 6 | Insert |
| 7 | `07_Asset.csv` | Asset | 7 | Insert |
| 8 | `08_Case.csv` | Case | 5 | Insert |
| 9 | `09_WorkOrder.csv` | WorkOrder | 4 | Insert |
| 10 | `10_Project_Launch__c.csv` | Project_Launch__c | 2 | Insert |
| 11 | `11_Presales_User__mdt.csv` | Presales_User__mdt | 1 | Deploy via Metadata API |

## How to Import

### Option A: Salesforce Data Loader (Recommended)

1. Download [Salesforce Data Loader](https://developer.salesforce.com/tools/data-loader)
2. Login to your Salesforce org
3. For each file in order (1-10):
   - Click **Insert**
   - Select the target object
   - Map CSV columns to Salesforce fields
   - Run the import
4. **Important**: After importing `Demo_Project__c` (#3), note the Salesforce IDs
   - You'll need these to update the lookup fields in `Unit__c` and `Project_Launch__c`

### Option B: Salesforce CLI (sfdx)

```bash
# Login to your org
sf org login web -a MyOrg

# Import in order
sf data import tree -f 01_Account.csv -o MyOrg
sf data import tree -f 02_Contact.csv -o MyOrg
# ... continue for each file
```

### Option C: Workbench (Web-based)

1. Go to https://workbench.developerforce.com
2. Login to your org
3. Go to **Data > Insert**
4. Select the object, upload the CSV, map fields
5. Execute — repeat for each file in order

## Lookup Field Mapping Notes

The CSV files use **external ID / name references** for lookup fields:

| CSV Column | Maps To | How to Map |
|------------|---------|------------|
| `Demo_Project__c.Name` | Demo_Project__c lookup | Match by project Name field |
| `Unit__c.Unit_Number__c` | Unit__c lookup | Match by Unit_Number__c (make this an External ID) |
| `Owner_Contact__c.PropHub_User_Id__c` | Contact lookup | Match by PropHub_User_Id__c (External ID) |

### Before importing, set these as External IDs in Salesforce:
1. **Contact** > `PropHub_User_Id__c` — mark as External ID
2. **Unit__c** > `Unit_Number__c` — mark as External ID

This allows Data Loader to resolve lookups by name instead of Salesforce IDs.

## Custom Metadata (Presales_User__mdt)

Custom Metadata cannot be loaded via Data Loader. Instead:
1. **Setup > Custom Metadata Types > Presales User > Manage Records > New**
2. Enter the values from `11_Presales_User__mdt.csv`

Or deploy via Metadata API / VS Code with Salesforce Extensions.

## Total Records: 48
- 4 Accounts (developers)
- 6 Contacts (demo user + 5 technicians)
- 4 Demo Projects (Emaar, SODIC, DAMAC, Roshn)
- 4 Units (2BR, 1BR, Penthouse, Villa)
- 9 Installments (booking through post-handover)
- 6 Invoices
- 7 Assets (appliances with warranties)
- 5 Cases (service requests)
- 4 Work Orders (maintenance records)
- 2 Project Launches
- 1 Presales User (custom metadata)
