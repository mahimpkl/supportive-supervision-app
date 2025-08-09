# Database Field Codes Explanation (a1, b1, c1, etc.)

## 🏗️ **Systematic Naming Convention**

The `a1`, `b1`, `c1`, etc. are **field codes** that systematically organize your supervision form questions. This naming convention makes it easy to:
- **Categorize questions** by section
- **Track multiple visits** for each question
- **Maintain consistency** across the database
- **Map to human-readable labels** in the Excel export

---

## 📋 **Code Structure Breakdown**

### **Format: `[Section Code][Question Number]_[Visit Number]`**

| Component | Example | Meaning |
|-----------|---------|---------|
| **Section Code** | `a`, `b`, `c`, `d`, `e` | Identifies the form section |
| **Question Number** | `1`, `2`, `3`, etc. | Specific question within that section |
| **Visit Number** | `visit_1`, `visit_2`, `visit_3`, `visit_4` | Which visit the response is for |
| **Comment** | `_comment` | Additional notes for that question |

---

## 🗂️ **Section Codes Explained**

### **A-Series: Administration and Management**
```sql
-- Table: admin_management_responses
a1_visit_1, a1_visit_2, a1_visit_3, a1_visit_4, a1_comment
a2_visit_1, a2_visit_2, a2_visit_3, a2_visit_4, a2_comment
a3_visit_1, a3_visit_2, a3_visit_3, a3_visit_4, a3_comment
```

**Maps to:**
- `a1` → "Health Facility Operation Committee"
- `a2` → "Committee discusses NCD service provisions"
- `a3` → "Health facility discusses NCD quarterly"

### **B-Series: Logistics and Equipment**
```sql
-- Table: logistics_responses
b1_visit_1, b1_visit_2, b1_visit_3, b1_visit_4, b1_comment
b2_visit_1, b2_visit_2, b2_visit_3, b2_visit_4, b2_comment
b3_visit_1, b3_visit_2, b3_visit_3, b3_visit_4, b3_comment
b4_visit_1, b4_visit_2, b4_visit_3, b4_visit_4, b4_comment
b5_visit_1, b5_visit_2, b5_visit_3, b5_visit_4, b5_comment
```

**Maps to:**
- `b1` → "Essential NCD medicines available"
- `b2` → "Blood glucometer functioning"
- `b3` → "Urine protein strips used"
- `b4` → "Urine ketone strips used"
- `b5` → "Essential equipment available"

### **B-Series Extended: MHDC Management**
```sql
-- Table: mhdc_management_responses
b6_visit_1, b6_visit_2, b6_visit_3, b6_visit_4, b6_comment
b7_visit_1, b7_visit_2, b7_visit_3, b7_visit_4, b7_comment
b8_visit_1, b8_visit_2, b8_visit_3, b8_visit_4, b8_comment
b9_visit_1, b9_visit_2, b9_visit_3, b9_visit_4, b9_comment
b10_visit_1, b10_visit_2, b10_visit_3, b10_visit_4, b10_comment
```

**Maps to:**
- `b6` → "MHDC NCD management leaflets available"
- `b7` → "NCD awareness materials available"
- `b8` → "NCD register availability"
- `b9` → "WHO-ISH CVD Risk Prediction Chart available"
- `b10` → "WHO-ISH CVD Risk Chart in use"

### **C-Series: Service Standards**
```sql
-- Table: service_standards_responses
c3_visit_1, c3_visit_2, c3_visit_3, c3_visit_4, c3_comment
c4_visit_1, c4_visit_2, c4_visit_3, c4_visit_4, c4_comment
c5_visit_1, c5_visit_2, c5_visit_3, c5_visit_4, c5_comment
c6_visit_1, c6_visit_2, c6_visit_3, c6_visit_4, c6_comment
c7_visit_1, c7_visit_2, c7_visit_3, c7_visit_4, c7_comment
```

**Maps to:**
- `c3` → "Examination room confidentiality"
- `c4` → "Home-bound NCD services"
- `c5` → "Community-based NCD care"
- `c6` → "School-based NCD prevention"
- `c7` → "Patient tracking mechanism"

### **D-Series: Health Information**
```sql
-- Table: health_information_responses
d1_visit_1, d1_visit_2, d1_visit_3, d1_visit_4, d1_comment
d2_visit_1, d2_visit_2, d2_visit_3, d2_visit_4, d2_comment
d3_visit_1, d3_visit_2, d3_visit_3, d3_visit_4, d3_comment
d4_visit_1, d4_visit_2, d4_visit_3, d4_visit_4, d4_comment
d5_visit_1, d5_visit_2, d5_visit_3, d5_visit_4, d5_comment
```

**Maps to:**
- `d1` → "NCD OPD register updated"
- `d2` → "NCD dashboard updated"
- `d3` → "Monthly reporting"
- `d4` → "Number of people seeking NCD services"
- `d5` → "Dedicated healthcare worker for NCD"

### **E-Series: Integration**
```sql
-- Table: integration_responses
e1_visit_1, e1_visit_2, e1_visit_3, e1_visit_4, e1_comment
e2_visit_1, e2_visit_2, e2_visit_3, e2_visit_4, e2_comment
e3_visit_1, e3_visit_2, e3_visit_3, e3_visit_4, e3_comment
```

**Maps to:**
- `e1` → "Health workers aware of PEN programme"
- `e2` → "Health education provided"
- `e3` → "Screening for raised blood pressure/sugar"

---

## 🔄 **Complete Field Mapping Example**

### **Database Field → Excel Question Mapping:**

| Database Field | Excel Question | Visit 1 | Visit 2 | Visit 3 | Visit 4 | Comments |
|----------------|----------------|---------|---------|---------|---------|----------|
| `a1_visit_1` | Health Facility Operation Committee | Yes | Yes | (empty) | (empty) | Committee functioning well |
| `a1_visit_2` | Health Facility Operation Committee | Yes | Yes | (empty) | (empty) | Committee functioning well |
| `a1_visit_3` | Health Facility Operation Committee | Yes | Yes | (empty) | (empty) | Committee functioning well |
| `a1_visit_4` | Health Facility Operation Committee | Yes | Yes | (empty) | (empty) | Committee functioning well |
| `a1_comment` | Health Facility Operation Committee | Yes | Yes | (empty) | (empty) | Committee functioning well |

---

## 🎯 **Why This Naming Convention?**

### **1. Easy Database Management:**
```sql
-- Easy to query specific sections
SELECT a1_visit_1, a2_visit_1, a3_visit_1 FROM admin_management_responses;

-- Easy to query specific visits
SELECT a1_visit_1, a1_visit_2, a1_visit_3, a1_visit_4 FROM admin_management_responses;
```

### **2. Consistent Structure:**
- Every question has the same pattern
- Easy to add new questions
- Predictable field names

### **3. Multi-Visit Tracking:**
- Each question can be answered for up to 4 visits
- Historical tracking of improvements
- Trend analysis capabilities

### **4. Section Organization:**
- `a` = Administration
- `b` = Logistics/Equipment/MHDC
- `c` = Service Standards
- `d` = Health Information
- `e` = Integration

---

## 📊 **Data Flow Example**

### **Step 1: Database Storage**
```sql
-- Raw data in database
a1_visit_1 = 'Y'
a1_visit_2 = 'Y'
a1_visit_3 = NULL
a1_visit_4 = NULL
a1_comment = 'Committee functioning well'
```

### **Step 2: Code Mapping**
```javascript
// In export.js
{ key: 'a1', label: 'Health Facility Operation Committee' }
```

### **Step 3: Excel Output**
```
Question: Health Facility Operation Committee
Visit 1: Yes
Visit 2: Yes
Visit 3: (empty)
Visit 4: (empty)
Comments: Committee functioning well
```

---

## 🔍 **Special Cases**

### **Equipment Table (Different Structure):**
```sql
-- Table: equipment_responses
sphygmomanometer_v1, sphygmomanometer_v2, sphygmomanometer_v3, sphygmomanometer_v4
glucometer_v1, glucometer_v2, glucometer_v3, glucometer_v4
weighing_scale_v1, weighing_scale_v2, weighing_scale_v3, weighing_scale_v4
```

**Note:** Equipment uses descriptive names instead of codes because each piece of equipment is unique.

### **Service Delivery Table (Numeric Data):**
```sql
-- Table: service_delivery_responses
ha_total_staff INTEGER,
ha_mhdc_trained INTEGER,
sr_ahw_total_staff INTEGER,
sr_ahw_mhdc_trained INTEGER
```

**Note:** Service delivery stores numeric counts, not Y/N responses.

---

## 💡 **Benefits of This System**

1. **Scalability**: Easy to add new questions or sections
2. **Consistency**: All questions follow the same pattern
3. **Queryability**: Easy to write database queries
4. **Maintainability**: Clear structure for developers
5. **Flexibility**: Supports multiple visits and comments
6. **Exportability**: Easy to map to Excel with human-readable labels

This systematic approach ensures your supervision forms are well-organized, easy to maintain, and provide rich data for analysis! 