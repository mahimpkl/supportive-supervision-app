# 🧪 Testing Guide - Supervision App Backend

## **🚀 Quick Start Testing**

### **Step 1: Start the Server**
```bash
cd supervision-app-backend
npm run dev
```

### **Step 2: Set up Database with Sample Data**
```bash
# In a new terminal
npm run migrate sample
```

### **Step 3: Run the Test Scripts**
```bash
# Quick test for basic functionality
node quick-test.js

# Comprehensive endpoint testing
node test-endpoints.js

# Test Excel export functionality
node test-export.js

# Create sample data for export testing
node create-sample-data.js
```

## **📋 Manual Testing with Postman/curl**

### **1. Login as Admin**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin123!"
  }'
```

**Save the `accessToken` from the response.**

### **2. Create a Test Supervision Form**

```bash
curl -X POST http://localhost:3000/api/forms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "healthFacilityName": "Central District Hospital",
    "province": "Western Province",
    "district": "Central District",
    "visit1Date": "2024-01-15",
    "visit2Date": "2024-02-15",
    "visit3Date": "2024-03-15",
    "visit4Date": "2024-04-15",
    "recommendationsVisit1": "Need more diabetes medications and staff training",
    "recommendationsVisit2": "Medicine availability improved, equipment needs repair",
    "recommendationsVisit3": "Staff training completed, need more glucometer strips",
    "recommendationsVisit4": "All recommendations implemented successfully",
    "adminManagement": {
      "a1_visit_1": "N", "a1_visit_2": "Y", "a1_visit_3": "Y", "a1_visit_4": "Y",
      "a2_visit_1": "N", "a2_visit_2": "Y", "a2_visit_3": "Y", "a2_visit_4": "Y",
      "a3_visit_1": "N", "a3_visit_2": "N", "a3_visit_3": "Y", "a3_visit_4": "Y",
      "a1_comment": "Committee established and functioning well"
    },
    "logistics": {
      "b1_visit_1": "N", "b1_visit_2": "Y", "b1_visit_3": "Y", "b1_visit_4": "Y",
      "b2_visit_1": "N", "b2_visit_2": "Y", "b2_visit_3": "Y", "b2_visit_4": "Y",
      "amlodipine_5_10mg_v1": "N", "amlodipine_5_10mg_v2": "Y", "amlodipine_5_10mg_v3": "Y", "amlodipine_5_10mg_v4": "Y",
      "metformin_500mg_v1": "N", "metformin_500mg_v2": "Y", "metformin_500mg_v3": "Y", "metformin_500mg_v4": "Y",
      "b1_comment": "Medicine supply improved significantly"
    },
    "equipment": {
      "sphygmomanometer_v1": "Y", "sphygmomanometer_v2": "Y", "sphygmomanometer_v3": "Y", "sphygmomanometer_v4": "Y",
      "glucometer_v1": "N", "glucometer_v2": "Y", "glucometer_v3": "Y", "glucometer_v4": "Y",
      "weighing_scale_v1": "Y", "weighing_scale_v2": "Y", "weighing_scale_v3": "Y", "weighing_scale_v4": "Y"
    },
    "mhdcManagement": {
      "b6_visit_1": "N", "b6_visit_2": "Y", "b6_visit_3": "Y", "b6_visit_4": "Y",
      "b7_visit_1": "N", "b7_visit_2": "Y", "b7_visit_3": "Y", "b7_visit_4": "Y",
      "b8_visit_1": "Y", "b8_visit_2": "Y", "b8_visit_3": "Y", "b8_visit_4": "Y",
      "b6_comment": "MHDC materials available"
    },
    "serviceDelivery": {
      "ha_total_staff": 10, "ha_mhdc_trained": 5, "ha_fen_trained": 3,
      "sr_ahw_total_staff": 8, "sr_ahw_mhdc_trained": 4, "sr_ahw_fen_trained": 2,
      "ahw_total_staff": 6, "ahw_mhdc_trained": 3, "ahw_fen_trained": 1
    },
    "serviceStandards": {
      "c2_blood_pressure_v1": "Y", "c2_blood_pressure_v2": "Y", "c2_blood_pressure_v3": "Y", "c2_blood_pressure_v4": "Y",
      "c2_blood_sugar_v1": "N", "c2_blood_sugar_v2": "Y", "c2_blood_sugar_v3": "Y", "c2_blood_sugar_v4": "Y",
      "c3_visit_1": "Y", "c3_visit_2": "Y", "c3_visit_3": "Y", "c3_visit_4": "Y",
      "c3_comment": "Service standards improved"
    },
    "healthInformation": {
      "d1_visit_1": "Y", "d1_visit_2": "Y", "d1_visit_3": "Y", "d1_visit_4": "Y",
      "d2_visit_1": "N", "d2_visit_2": "Y", "d2_visit_3": "Y", "d2_visit_4": "Y",
      "d1_comment": "Health information systems maintained"
    },
    "integration": {
      "e1_visit_1": "Y", "e1_visit_2": "Y", "e1_visit_3": "Y", "e1_visit_4": "Y",
      "e2_visit_1": "N", "e2_visit_2": "Y", "e2_visit_3": "Y", "e2_visit_4": "Y",
      "e1_comment": "Integration services established"
    }
  }'
```

### **3. Test Facility History Endpoint**

```bash
curl -X GET "http://localhost:3000/api/forms/facility/Central%20District%20Hospital/history" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### **4. Test Facilities Summary Endpoint**

```bash
curl -X GET http://localhost:3000/api/forms/facilities/summary \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### **5. Generate Excel Export**

```bash
curl -X GET "http://localhost:3000/api/export/excel?startDate=2024-01-01&endDate=2024-12-31" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  --output supervision_forms_export.xlsx
```

### **6. Get Summary Statistics**

```bash
curl -X GET http://localhost:3000/api/export/summary \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## **📊 Postman Collection**

### **Environment Variables**
Set these in Postman:
- `base_url`: `http://localhost:3000`
- `admin_token`: (from login response)

### **Request Collection**

#### **1. Admin Login**
```
POST {{base_url}}/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "Admin123!"
}
```

#### **2. Create Form**
```
POST {{base_url}}/api/forms
Authorization: Bearer {{admin_token}}
Content-Type: application/json

[Use the JSON from Step 2 above]
```

#### **3. Get Facility History**
```
GET {{base_url}}/api/forms/facility/Central%20District%20Hospital/history
Authorization: Bearer {{admin_token}}
```

#### **4. Get Facilities Summary**
```
GET {{base_url}}/api/forms/facilities/summary
Authorization: Bearer {{admin_token}}
```

#### **5. Export Excel**
```
GET {{base_url}}/api/export/excel?startDate=2024-01-01&endDate=2024-12-31
Authorization: Bearer {{admin_token}}
```

#### **6. Get Summary Stats**
```
GET {{base_url}}/api/export/summary
Authorization: Bearer {{admin_token}}
```

## **🎯 Expected Results**

### **Login Response**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@supervision-app.com",
    "fullName": "System Administrator",
    "role": "admin"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### **Form Creation Response**
```json
{
  "message": "Supervision form created successfully",
  "form": {
    "id": 2,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "syncStatus": "local"
  }
}
```

### **Facility History Response**
```json
{
  "facilityName": "Central District Hospital",
  "totalVisits": 1,
  "visitHistory": [...],
  "trends": {
    "medicineAvailability": [...],
    "equipmentFunctionality": [...],
    "staffTraining": [...]
  }
}
```

### **Excel Export**
- Downloads a `.xlsx` file
- Contains main summary sheet
- Individual detail sheets for each form
- Visit-by-visit data for all 4 visits
- Professional formatting with headers

## **🔧 Troubleshooting**

### **Port 3000 Already in Use**
```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process
taskkill /PID <PID> /F
```

### **Database Connection Issues**
```bash
# Reset database
npm run migrate reset

# Create fresh data
npm run migrate sample
```

### **Permission Denied**
- Make sure you're using the admin token
- Check that the token hasn't expired
- Verify the Authorization header format

## **📁 Generated Files**

After running the tests, you should have:
- `supervision_forms_export.xlsx` - Complete Excel export
- Console output showing all test results

## **🎉 Success Indicators**

✅ Server starts without errors  
✅ Database connection successful  
✅ Admin login works  
✅ Form creation successful  
✅ Facility history retrieved  
✅ Excel file downloaded  
✅ Summary statistics generated  

**All endpoints working = Ready for production!** 🚀

---

## **📋 Field Codes Reference**

### **Database Field Naming Convention**

The system uses systematic field codes to organize supervision form questions:

| Code | Section | Questions |
|------|---------|-----------|
| `a1-a3` | **Administration & Management** | Health Facility Operation Committee, NCD discussions, Quarterly reviews |
| `b1-b5` | **Logistics** | Essential medicines, Blood glucometer, Urine strips, Equipment |
| `b6-b10` | **MHDC Management** | NCD leaflets, Awareness materials, Registers, Risk charts |
| `c3-c7` | **Service Standards** | Confidentiality, Home-bound services, Community care, School prevention |
| `d1-d5` | **Health Information** | OPD register, Dashboard, Monthly reporting, Staff counts |
| `e1-e3` | **Integration** | PEN programme awareness, Health education, Screening |

### **Field Structure**
```
[Section Code][Question Number]_[Visit Number]
Example: a1_visit_1, a1_visit_2, a1_visit_3, a1_visit_4, a1_comment
```

### **Excel Export Mapping**
- Database stores: `Y`/`N` values
- Excel displays: `Yes`/`No` for readability
- Empty visits show as blank cells
- Comments appear in separate column

### **Multi-Visit Tracking**
Each question supports up to 4 visits, allowing:
- Historical tracking of improvements
- Trend analysis across visits
- Progress monitoring over time

---

## **🧪 Test Scripts Overview**

### **quick-test.js**
- Basic functionality test
- Single form creation
- Error handling verification
- Quick validation of core features

### **test-endpoints.js**
- Comprehensive endpoint testing
- Multiple form creation
- Facility history testing
- User management testing
- Form update testing
- Robust error handling

### **test-export.js**
- Excel export functionality testing
- File download verification
- Content-type validation
- Filtered export testing
- Local file saving

### **create-sample-data.js**
- Sample data generation
- Multiple form creation
- Realistic test scenarios
- Data preparation for export testing

---

## **📊 Excel Export Features**

### **Export Capabilities**
- **Full Export**: All forms with complete details
- **Filtered Export**: By date range, user, province, district
- **Multi-Sheet**: Summary sheet + individual form sheets
- **Professional Formatting**: Headers, colors, proper spacing

### **Export Content**
- **Form Metadata**: ID, facility, province, district, doctor, dates
- **Visit Data**: All 4 visits for each question
- **Comments**: Additional notes for each question
- **Statistics**: Summary counts and trends

### **File Structure**
```
supervision_forms_export_YYYY-MM-DD.xlsx
├── Supervision Forms (Summary Sheet)
├── Form 1 Details
├── Form 2 Details
└── Form N Details
```

### **Data Transformation**
- `Y` → `Yes` (for readability)
- `N` → `No` (for readability)
- `NULL` → Empty cell
- Human-readable question labels
- Professional Excel formatting 