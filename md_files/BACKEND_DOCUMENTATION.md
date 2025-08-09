# Supervision App Backend Documentation

## 🏗️ **System Architecture Overview**

The supervision app is designed for healthcare facility supervision and monitoring of NCD (Non-Communicable Diseases) services. The system tracks multiple visits to healthcare facilities and monitors various aspects of service delivery.

---

## 📊 **Database Structure & Logic**

### **1. Core Tables Overview**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `users` | User management | Authentication, roles, profiles |
| `supervision_forms` | Main form data | Facility info, visit dates, recommendations |
| `admin_management_responses` | Administrative oversight | Committee meetings, NCD discussions |
| `logistics_responses` | Medicine & supply tracking | Drug availability, equipment status |
| `equipment_responses` | Medical equipment | Device functionality, maintenance |
| `mhdc_management_responses` | MHDC program management | Charts, materials, documentation |
| `service_delivery_responses` | Staff training data | Training counts, staff qualifications |
| `service_standards_responses` | Service quality standards | Protocol adherence, quality metrics |
| `health_information_responses` | Health information systems | Data management, reporting |
| `integration_responses` | Service integration | Cross-service coordination |

---

## 🔍 **Detailed Table Analysis**

### **1. Users Table**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'user',
  full_name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT true
);
```

**Logic:**
- **Authentication System**: Secure login with bcrypt password hashing
- **Role-Based Access**: `admin` vs `user` roles for different permissions
- **User Management**: Track active/inactive users, creation/update timestamps

### **2. Supervision Forms Table**
```sql
CREATE TABLE supervision_forms (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  health_facility_name VARCHAR(200) NOT NULL,
  province VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  visit_1_date DATE, visit_2_date DATE, visit_3_date DATE, visit_4_date DATE,
  form_created_at TIMESTAMP NOT NULL,
  sync_status VARCHAR(20) DEFAULT 'local',
  supervisor_signature TEXT,
  facility_representative_signature TEXT,
  recommendations_visit_1 TEXT, recommendations_visit_2 TEXT,
  recommendations_visit_3 TEXT, recommendations_visit_4 TEXT
);
```

**Logic:**
- **Multi-Visit Tracking**: Up to 4 visits per facility (v1, v2, v3, v4)
- **Geographic Organization**: Province/District for regional analysis
- **Sync System**: `local` vs `synced` status for offline capability
- **Digital Signatures**: Supervisor and facility representative signatures
- **Recommendations**: Action items for each visit

### **3. Admin Management Responses**
```sql
CREATE TABLE admin_management_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  a1_visit_1 VARCHAR(1), a1_visit_2 VARCHAR(1), a1_visit_3 VARCHAR(1), a1_visit_4 VARCHAR(1),
  a1_comment TEXT,
  a2_visit_1 VARCHAR(1), a2_visit_2 VARCHAR(1), a2_visit_3 VARCHAR(1), a2_visit_4 VARCHAR(1),
  a2_comment TEXT,
  a3_visit_1 VARCHAR(1), a3_visit_2 VARCHAR(1), a3_visit_3 VARCHAR(1), a3_visit_4 VARCHAR(1),
  a3_comment TEXT
);
```

**Logic:**
- **A1**: NCD Committee functionality and meetings
- **A2**: NCD discussion inclusion in monthly meetings
- **A3**: Quarterly NCD discussion frequency
- **Y/N System**: `Y` = Yes, `N` = No for each visit
- **Comments**: Detailed observations for each metric

### **4. Logistics Responses (Medicines & Supplies)**
```sql
CREATE TABLE logistics_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  -- Blood Pressure Medications
  amlodipine_5_10mg_v1, amlodipine_5_10mg_v2, amlodipine_5_10mg_v3, amlodipine_5_10mg_v4,
  enalapril_2_5_10mg_v1, enalapril_2_5_10mg_v2, enalapril_2_5_10mg_v3, enalapril_2_5_10mg_v4,
  losartan_25_50mg_v1, losartan_25_50mg_v2, losartan_25_50mg_v3, losartan_25_50mg_v4,
  hydrochlorothiazide_12_5_25mg_v1, hydrochlorothiazide_12_5_25mg_v2, hydrochlorothiazide_12_5_25mg_v3, hydrochlorothiazide_12_5_25mg_v4,
  chlorthalidone_6_25_12_5mg_v1, chlorthalidone_6_25_12_5mg_v2, chlorthalidone_6_25_12_5mg_v3, chlorthalidone_6_25_12_5mg_v4,
  -- Statins (Cholesterol Medications)
  atorvastatin_5mg_v1, atorvastatin_5mg_v2, atorvastatin_5mg_v3, atorvastatin_5mg_v4,
  atorvastatin_10mg_v1, atorvastatin_10mg_v2, atorvastatin_10mg_v3, atorvastatin_10mg_v4,
  atorvastatin_20mg_v1, atorvastatin_20mg_v2, atorvastatin_20mg_v3, atorvastatin_20mg_v4,
  other_statins_v1, other_statins_v2, other_statins_v3, other_statins_v4,
  -- Diabetes Medications
  metformin_500mg_v1, metformin_500mg_v2, metformin_500mg_v3, metformin_500mg_v4,
  metformin_1000mg_v1, metformin_1000mg_v2, metformin_1000mg_v3, metformin_1000mg_v4,
  glimepiride_1_2mg_v1, glimepiride_1_2mg_v2, glimepiride_1_2mg_v3, glimepiride_1_2mg_v4,
  gliclazide_40_80mg_v1, gliclazide_40_80mg_v2, gliclazide_40_80mg_v3, gliclazide_40_80mg_v4,
  glipizide_2_5_5mg_v1, glipizide_2_5_5mg_v2, glipizide_2_5_5mg_v3, glipizide_2_5_5mg_v4,
  sitagliptin_50mg_v1, sitagliptin_50mg_v2, sitagliptin_50mg_v3, sitagliptin_50mg_v4,
  pioglitazone_5mg_v1, pioglitazone_5mg_v2, pioglitazone_5mg_v3, pioglitazone_5mg_v4,
  empagliflozin_10mg_v1, empagliflozin_10mg_v2, empagliflozin_10mg_v3, empagliflozin_10mg_v4,
  -- Insulin
  insulin_soluble_v1, insulin_soluble_v2, insulin_soluble_v3, insulin_soluble_v4,
  insulin_nph_v1, insulin_nph_v2, insulin_nph_v3, insulin_nph_v4,
  other_hypoglycemic_agents_v1, other_hypoglycemic_agents_v2, other_hypoglycemic_agents_v3, other_hypoglycemic_agents_v4,
  -- Other Medications
  dextrose_25_solution_v1, dextrose_25_solution_v2, dextrose_25_solution_v3, dextrose_25_solution_v4,
  aspirin_75mg_v1, aspirin_75mg_v2, aspirin_75mg_v3, aspirin_75mg_v4,
  clopidogrel_75mg_v1, clopidogrel_75mg_v2, clopidogrel_75mg_v3, clopidogrel_75mg_v4,
  metoprolol_succinate_12_5_25_50mg_v1, metoprolol_succinate_12_5_25_50mg_v2, metoprolol_succinate_12_5_25_50mg_v3, metoprolol_succinate_12_5_25_50mg_v4,
  isosorbide_dinitrate_5mg_v1, isosorbide_dinitrate_5mg_v2, isosorbide_dinitrate_5mg_v3, isosorbide_dinitrate_5mg_v4,
  other_drugs_v1, other_drugs_v2, other_drugs_v3, other_drugs_v4,
  -- Equipment Checks
  b2_visit_1, b2_visit_2, b2_visit_3, b2_visit_4, b2_comment,
  b3_visit_1, b3_visit_2, b3_visit_3, b3_visit_4, b3_comment,
  b4_visit_1, b4_visit_2, b4_visit_3, b4_visit_4, b4_comment,
  b5_visit_1, b5_visit_2, b5_visit_3, b5_visit_4, b5_comment
);
```

**Logic:**
- **Medication Tracking**: Specific drugs with dosages for NCD management
- **Visit-Based Monitoring**: `_v1`, `_v2`, `_v3`, `_v4` for each visit
- **Drug Categories**:
  - **Blood Pressure**: Amlodipine, Enalapril, Losartan, Hydrochlorothiazide, Chlorthalidone
  - **Statins**: Atorvastatin (5mg, 10mg, 20mg), Other statins
  - **Diabetes**: Metformin, Glimepiride, Gliclazide, Glipizide, Sitagliptin, Pioglitazone, Empagliflozin
  - **Insulin**: Soluble, NPH, Other hypoglycemic agents
  - **Other**: Dextrose, Aspirin, Clopidogrel, Metoprolol, Isosorbide
- **Equipment Checks**: B2-B5 for supply and equipment status

### **5. Equipment Responses**
```sql
CREATE TABLE equipment_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  sphygmomanometer_v1, sphygmomanometer_v2, sphygmomanometer_v3, sphygmomanometer_v4,
  weighing_scale_v1, weighing_scale_v2, weighing_scale_v3, weighing_scale_v4,
  measuring_tape_v1, measuring_tape_v2, measuring_tape_v3, measuring_tape_v4,
  peak_expiratory_flow_meter_v1, peak_expiratory_flow_meter_v2, peak_expiratory_flow_meter_v3, peak_expiratory_flow_meter_v4,
  oxygen_v1, oxygen_v2, oxygen_v3, oxygen_v4,
  oxygen_mask_v1, oxygen_mask_v2, oxygen_mask_v3, oxygen_mask_v4,
  nebulizer_v1, nebulizer_v2, nebulizer_v3, nebulizer_v4,
  pulse_oximetry_v1, pulse_oximetry_v2, pulse_oximetry_v3, pulse_oximetry_v4,
  glucometer_v1, glucometer_v2, glucometer_v3, glucometer_v4,
  glucometer_strips_v1, glucometer_strips_v2, glucometer_strips_v3, glucometer_strips_v4,
  lancets_v1, lancets_v2, lancets_v3, lancets_v4,
  urine_dipstick_v1, urine_dipstick_v2, urine_dipstick_v3, urine_dipstick_v4,
  ecg_v1, ecg_v2, ecg_v3, ecg_v4,
  other_equipment_v1, other_equipment_v2, other_equipment_v3, other_equipment_v4
);
```

**Logic:**
- **Essential Equipment**: Blood pressure monitors, scales, measuring tapes
- **Diagnostic Tools**: Peak flow meters, pulse oximeters, glucometers
- **Emergency Equipment**: Oxygen, masks, nebulizers
- **Testing Supplies**: Glucometer strips, lancets, urine dipsticks
- **Advanced Equipment**: ECG machines, other specialized equipment

### **6. MHDC Management Responses**
```sql
CREATE TABLE mhdc_management_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  b6_visit_1, b6_visit_2, b6_visit_3, b6_visit_4, b6_comment,
  b7_visit_1, b7_visit_2, b7_visit_3, b7_visit_4, b7_comment,
  b8_visit_1, b8_visit_2, b8_visit_3, b8_visit_4, b8_comment,
  b9_visit_1, b9_visit_2, b9_visit_3, b9_visit_4, b9_comment,
  b10_visit_1, b10_visit_2, b10_visit_3, b10_visit_4, b10_comment
);
```

**Logic:**
- **MHDC Program**: Management of NCD program materials and charts
- **B6-B10**: Different aspects of MHDC management
- **Chart Updates**: Regular updates and maintenance
- **Material Availability**: Accessibility of program materials
- **Documentation**: Proper record keeping and documentation

### **7. Service Delivery Responses**
```sql
CREATE TABLE service_delivery_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  -- Health Assistant (HA) Staff
  ha_total_staff INTEGER, ha_mhdc_trained INTEGER, ha_fen_trained INTEGER, ha_other_ncd_trained INTEGER,
  -- Senior Auxiliary Health Worker (Sr AHW)
  sr_ahw_total_staff INTEGER, sr_ahw_mhdc_trained INTEGER, sr_ahw_fen_trained INTEGER, sr_ahw_other_ncd_trained INTEGER,
  -- Auxiliary Health Worker (AHW)
  ahw_total_staff INTEGER, ahw_mhdc_trained INTEGER, ahw_fen_trained INTEGER, ahw_other_ncd_trained INTEGER,
  -- Senior Auxiliary Nurse Midwife (Sr ANM)
  sr_anm_total_staff INTEGER, sr_anm_mhdc_trained INTEGER, sr_anm_fen_trained INTEGER, sr_anm_other_ncd_trained INTEGER,
  -- Auxiliary Nurse Midwife (ANM)
  anm_total_staff INTEGER, anm_mhdc_trained INTEGER, anm_fen_trained INTEGER, anm_other_ncd_trained INTEGER,
  -- Other Staff
  others_total_staff INTEGER, others_mhdc_trained INTEGER, others_fen_trained INTEGER, others_other_ncd_trained INTEGER
);
```

**Logic:**
- **Staff Categories**: Different healthcare worker categories
- **Training Tracking**: MHDC, FEN (Family Planning), Other NCD training
- **Capacity Building**: Monitor training coverage and gaps
- **Staffing Levels**: Total staff vs trained staff ratios

### **8. Service Standards Responses**
```sql
CREATE TABLE service_standards_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  -- C2 Services provided as per PEN protocol
  c2_blood_pressure_v1, c2_blood_pressure_v2, c2_blood_pressure_v3, c2_blood_pressure_v4,
  c2_blood_sugar_v1, c2_blood_sugar_v2, c2_blood_sugar_v3, c2_blood_sugar_v4,
  c2_bmi_measurement_v1, c2_bmi_measurement_v2, c2_bmi_measurement_v3, c2_bmi_measurement_v4,
  c2_waist_circumference_v1, c2_waist_circumference_v2, c2_waist_circumference_v3, c2_waist_circumference_v4,
  c2_cvd_risk_estimation_v1, c2_cvd_risk_estimation_v2, c2_cvd_risk_estimation_v3, c2_cvd_risk_estimation_v4,
  c2_urine_protein_measurement_v1, c2_urine_protein_measurement_v2, c2_urine_protein_measurement_v3, c2_urine_protein_measurement_v4,
  c2_peak_expiratory_flow_rate_v1, c2_peak_expiratory_flow_rate_v2, c2_peak_expiratory_flow_rate_v3, c2_peak_expiratory_flow_rate_v4,
  c2_egfr_calculation_v1, c2_egfr_calculation_v2, c2_egfr_calculation_v3, c2_egfr_calculation_v4,
  c2_brief_intervention_v1, c2_brief_intervention_v2, c2_brief_intervention_v3, c2_brief_intervention_v4,
  c2_foot_examination_v1, c2_foot_examination_v2, c2_foot_examination_v3, c2_foot_examination_v4,
  c2_oral_examination_v1, c2_oral_examination_v2, c2_oral_examination_v3, c2_oral_examination_v4,
  c2_eye_examination_v1, c2_eye_examination_v2, c2_eye_examination_v3, c2_eye_examination_v4,
  c2_health_education_v1, c2_health_education_v2, c2_health_education_v3, c2_health_education_v4,
  -- Additional standards
  c3_visit_1, c3_visit_2, c3_visit_3, c3_visit_4, c3_comment,
  c4_visit_1, c4_visit_2, c4_visit_3, c4_visit_4, c4_comment,
  c5_visit_1, c5_visit_2, c5_visit_3, c5_visit_4, c5_comment,
  c6_visit_1, c6_visit_2, c6_visit_3, c6_visit_4, c6_comment,
  c7_visit_1, c7_visit_2, c7_visit_3, c7_visit_4, c7_comment
);
```

**Logic:**
- **PEN Protocol**: Package of Essential NCD interventions
- **C2 Services**: Core clinical services provided
- **Vital Signs**: Blood pressure, blood sugar, BMI, waist circumference
- **Risk Assessment**: CVD risk estimation, eGFR calculation
- **Clinical Examinations**: Foot, oral, eye examinations
- **Health Education**: Patient education and counseling
- **Quality Standards**: C3-C7 for additional quality metrics

### **9. Health Information Responses**
```sql
CREATE TABLE health_information_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  d1_visit_1, d1_visit_2, d1_visit_3, d1_visit_4, d1_comment,
  d2_visit_1, d2_visit_2, d2_visit_3, d2_visit_4, d2_comment,
  d3_visit_1, d3_visit_2, d3_visit_3, d3_visit_4, d3_comment,
  d4_visit_1, d4_visit_2, d4_visit_3, d4_visit_4, d4_comment,
  d5_visit_1, d5_visit_2, d5_visit_3, d5_visit_4, d5_comment
);
```

**Logic:**
- **D1-D5**: Different aspects of health information systems
- **Data Management**: Patient records, reporting systems
- **Information Flow**: Data collection, processing, and reporting
- **System Integration**: Health information system functionality

### **10. Integration Responses**
```sql
CREATE TABLE integration_responses (
  id SERIAL PRIMARY KEY,
  form_id INTEGER REFERENCES supervision_forms(id),
  e1_visit_1, e1_visit_2, e1_visit_3, e1_visit_4, e1_comment,
  e2_visit_1, e2_visit_2, e2_visit_3, e2_visit_4, e2_comment,
  e3_visit_1, e3_visit_2, e3_visit_3, e3_visit_4, e3_comment
);
```

**Logic:**
- **E1-E3**: Service integration aspects
- **Cross-Service Coordination**: Integration between different health services
- **Referral Systems**: Patient referral mechanisms
- **Service Linkage**: Connection between NCD and other health services

---

## 🔄 **Data Flow Logic**

### **1. Multi-Visit Tracking System**
- **Visit Pattern**: `_v1`, `_v2`, `_v3`, `_v4` for each metric
- **Progress Monitoring**: Track improvements over time
- **Trend Analysis**: Compare performance across visits
- **Intervention Impact**: Measure effectiveness of recommendations

### **2. Y/N Response System**
- **Standardization**: `Y` = Yes, `N` = No for consistent data
- **Binary Logic**: Simple yes/no for easy analysis
- **Comment Fields**: Detailed observations for context
- **Data Aggregation**: Easy to count and analyze

### **3. Hierarchical Data Structure**
```
supervision_forms (1) → (Many) response_tables
├── admin_management_responses
├── logistics_responses
├── equipment_responses
├── mhdc_management_responses
├── service_delivery_responses
├── service_standards_responses
├── health_information_responses
└── integration_responses
```

### **4. Sync System Logic**
- **Local Status**: Forms created offline
- **Synced Status**: Forms uploaded to central server
- **Offline Capability**: Work without internet connection
- **Data Integrity**: Prevent data loss during sync

---

## 📈 **Analytics & Reporting Logic**

### **1. Facility Performance Tracking**
- **Visit Frequency**: How often facilities are supervised
- **Improvement Trends**: Progress over multiple visits
- **Compliance Rates**: Adherence to standards
- **Resource Availability**: Medicine and equipment status

### **2. Regional Analysis**
- **Province/District Comparison**: Geographic performance
- **Resource Distribution**: Medicine and equipment availability by region
- **Training Coverage**: Staff training by location
- **Service Quality**: Standards adherence by area

### **3. Medicine & Supply Analytics**
- **Availability Tracking**: Which medicines are consistently available
- **Stock Management**: Supply chain monitoring
- **Critical Gaps**: Missing essential medicines
- **Cost Analysis**: Medicine availability vs cost

### **4. Staff Training Analysis**
- **Training Coverage**: Percentage of trained staff
- **Capacity Gaps**: Areas needing more training
- **Staff Categories**: Training by staff type
- **Training Impact**: Correlation with service quality

---

## 🛠️ **Technical Implementation Logic**

### **1. Database Design Principles**
- **Normalization**: Separate tables for different response types
- **Referential Integrity**: Foreign key relationships
- **Scalability**: Handle large numbers of forms and visits
- **Performance**: Optimized queries for reporting

### **2. API Design Logic**
- **RESTful Structure**: Standard HTTP methods
- **Authentication**: JWT token-based security
- **Authorization**: Role-based access control
- **Validation**: Input validation and sanitization

### **3. Export System Logic**
- **Excel Generation**: Multi-sheet Excel files
- **Data Formatting**: Y/N to Yes/No conversion
- **Filtering**: Date range, location, user filters
- **Comprehensive Reports**: All sections in separate sheets

### **4. Sync System Logic**
- **Conflict Resolution**: Handle concurrent edits
- **Data Validation**: Ensure data integrity
- **Incremental Sync**: Only sync changed data
- **Error Handling**: Graceful sync failures

---

## 🎯 **Business Logic Summary**

### **Purpose**
The system monitors healthcare facility performance in delivering NCD services, tracking:
- Medicine availability
- Equipment functionality
- Staff training
- Service quality standards
- Administrative oversight

### **Key Metrics**
- **Compliance Rates**: Adherence to protocols
- **Resource Availability**: Medicine and equipment status
- **Training Coverage**: Staff qualification levels
- **Service Quality**: Standards implementation
- **Improvement Trends**: Progress over time

### **Reporting Capabilities**
- **Facility Reports**: Individual facility performance
- **Regional Reports**: Geographic comparisons
- **Trend Analysis**: Progress over multiple visits
- **Resource Analysis**: Medicine and equipment availability
- **Training Reports**: Staff qualification status

This comprehensive system provides detailed insights into healthcare facility performance and helps identify areas for improvement in NCD service delivery. 