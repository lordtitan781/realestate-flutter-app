# Missing Fields: Market Intelligence Data

**Date**: 11 March 2026  
**Issue**: projectedGrowth, demandIndex, and riskProfile are hardcoded, not fetched from backend

---

## 🚨 Current Problem

### What's Happening Now:

In `lib/models/project.dart`:
```dart
double get projectedGrowth => expectedROI;  // Using expectedROI as a fallback
int get demandIndex => 5;                   // HARDCODED to 5 always
String get riskProfile => 'Medium';         // HARDCODED to 'Medium' always
```

**Result**: 
- ✅ Projected Growth: Works (reuses expectedROI)
- ❌ Demand Index: Always shows 5/10 (never changes)
- ❌ Risk Profile: Always shows 'Medium' (never changes)

---

## 📋 What Needs to Be Added

### **1. Backend Project Entity**
**File**: `backend/src/main/java/com/example/realestate/model/Project.java`

#### Add These Fields:
```java
@Column(name = "projected_growth", nullable = false)
private double projectedGrowth = 0.0;

@Column(name = "demand_index", nullable = false)
private int demandIndex = 5;

@Column(name = "risk_profile", nullable = false)
private String riskProfile = "Medium";
```

#### Full Code to Add:
```java
package com.example.realestate.model;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.persistence.*;

@Entity
@Table(name = "projects")
public class Project {
    // ... existing fields ...

    @Column(name = "expected_irr", nullable = false)
    private double expectedIRR = 0.0;

    @Column(name = "projected_growth", nullable = false)
    private double projectedGrowth = 0.0;

    @Column(name = "demand_index", nullable = false)
    private int demandIndex = 5;

    @Column(name = "risk_profile", nullable = false)
    private String riskProfile = "Medium";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProjectStage stage;

    // ... rest of the file ...

    // Add getters and setters:
    public double getProjectedGrowth() { return projectedGrowth; }
    public void setProjectedGrowth(double projectedGrowth) { this.projectedGrowth = projectedGrowth; }

    public int getDemandIndex() { return demandIndex; }
    public void setDemandIndex(int demandIndex) { this.demandIndex = demandIndex; }

    public String getRiskProfile() { return riskProfile; }
    public void setRiskProfile(String riskProfile) { this.riskProfile = riskProfile; }
}
```

---

### **2. Database Migration**
**File**: `backend/src/main/resources/postgres_schema.sql`

#### Add Columns to projects Table:
```sql
ALTER TABLE projects ADD COLUMN IF NOT EXISTS projected_growth DOUBLE PRECISION NOT NULL DEFAULT 0.0;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS demand_index INTEGER NOT NULL DEFAULT 5;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS risk_profile VARCHAR(50) NOT NULL DEFAULT 'Medium';
```

#### Or Create Fresh Schema:
```sql
CREATE TABLE IF NOT EXISTS projects (
    id                  BIGSERIAL PRIMARY KEY,
    land_id             BIGINT REFERENCES lands(id) ON DELETE SET NULL,
    project_name        VARCHAR(255) NOT NULL,
    location            VARCHAR(255) NOT NULL,
    land_size           DOUBLE PRECISION NOT NULL DEFAULT 0,
    investment_required DOUBLE PRECISION NOT NULL DEFAULT 0,
    expected_roi        DOUBLE PRECISION NOT NULL DEFAULT 0,
    expected_irr        DOUBLE PRECISION NOT NULL DEFAULT 0,
    projected_growth    DOUBLE PRECISION NOT NULL DEFAULT 0,
    demand_index        INTEGER NOT NULL DEFAULT 5,
    risk_profile        VARCHAR(50) NOT NULL DEFAULT 'Medium',
    stage               VARCHAR(50) NOT NULL
);
```

---

### **3. Frontend Project Model**
**File**: `lib/models/project.dart`

#### Update the Class:
```dart
class Project {
  final int? id;
  final int? landId;
  final String projectName;
  final String location;
  final double landSize;
  final double investmentRequired;
  final double expectedROI;
  final double expectedIRR;
  final double projectedGrowth;      // ADD THIS
  final int demandIndex;              // ADD THIS
  final String riskProfile;           // ADD THIS
  final String stage;

  Project({
    this.id,
    this.landId,
    required this.projectName,
    required this.location,
    this.landSize = 0.0,
    this.investmentRequired = 0.0,
    this.expectedROI = 0.0,
    this.expectedIRR = 0.0,
    this.projectedGrowth = 0.0,       // ADD THIS
    this.demandIndex = 5,             // ADD THIS
    this.riskProfile = 'Medium',      // ADD THIS
    this.stage = 'LAND_APPROVED',
  });

  // backward-compatible getter used across the UI
  String get title => projectName;

  factory Project.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 5;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 5;
    }

    return Project(
      id: json['id'],
      landId: json['landId'] ?? json['land_id'],
      projectName: (json['projectName'] ?? json['title'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      landSize: parseDouble(json['landSize'] ?? json['land_size']),
      investmentRequired: parseDouble(json['investmentRequired'] ?? json['capitalRequired'] ?? json['capital_required']),
      expectedROI: parseDouble(json['expectedROI'] ?? json['expected_roi']),
      expectedIRR: parseDouble(json['expectedIRR'] ?? json['irr'] ?? json['expected_irr']),
      projectedGrowth: parseDouble(json['projectedGrowth'] ?? json['projected_growth']),  // ADD THIS
      demandIndex: parseInt(json['demandIndex'] ?? json['demand_index']),                 // ADD THIS
      riskProfile: (json['riskProfile'] ?? json['risk_profile'] ?? 'Medium') as String,   // ADD THIS
      stage: (json['stage'] ?? 'LAND_APPROVED') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (landId != null) 'landId': landId,
      'projectName': projectName,
      'location': location,
      'landSize': landSize,
      'investmentRequired': investmentRequired,
      'expectedROI': expectedROI,
      'expectedIRR': expectedIRR,
      'projectedGrowth': projectedGrowth,    // ADD THIS
      'demandIndex': demandIndex,            // ADD THIS
      'riskProfile': riskProfile,            // ADD THIS
      'stage': stage,
    };
  }

  // Backwards-compatible getters for existing UI (REMOVE HARDCODED VALUES)
  String get theme => 'General';
  String get description => '';
  String? get imageUrl => null;
  double get irr => expectedIRR;
  double get capitalRequired => investmentRequired;
  double get capitalRaised => 0.0;
}
```

---

## 📊 Step-by-Step Implementation

### **Step 1: Add Backend Fields (Java)**

Update `Project.java` to include:
```java
private double projectedGrowth = 0.0;
private int demandIndex = 5;
private String riskProfile = "Medium";

// Plus getters and setters for each
```

### **Step 2: Database Migration**

Run migration to add columns:
```sql
ALTER TABLE projects ADD COLUMN projected_growth DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE projects ADD COLUMN demand_index INTEGER DEFAULT 5;
ALTER TABLE projects ADD COLUMN risk_profile VARCHAR(50) DEFAULT 'Medium';
```

### **Step 3: Update Frontend Model**

Modify `lib/models/project.dart`:
- Add fields to constructor
- Update `fromJson()` to parse these fields
- Update `toJson()` to include these fields
- Remove hardcoded getters

### **Step 4: Test Data**

Insert test data in database:
```sql
INSERT INTO projects 
  (project_name, location, land_size, investment_required, 
   expected_roi, expected_irr, projected_growth, demand_index, 
   risk_profile, stage)
VALUES 
  ('333333 Project', 'Beachfront', 100, 787878787.0, 
   95.2, 95.237986572471, 98.71, 5, 'Medium', 'PLANNING');
```

---

## 🔍 Where These Values Are Used

### **Project Details Screen** (project_details.dart)
```dart
// Market Intelligence section
_analyticRow("Projected Growth", "${proj.projectedGrowth}% YoY", ...),
_analyticRow("Demand Index", "${proj.demandIndex}/10", ...),
_analyticRow("Risk Profile", proj.riskProfile, ...),
```

### **Data Source**
```
Backend Database → Project Entity → JSON Response → 
  → Flutter Model (fromJson) → Project Details Screen
```

---

## ✅ Before & After Comparison

### **Before (Current - Hardcoded)**
```
Projected Growth: 98.71% (displayed, comes from expectedROI)
Demand Index: 5/10 (ALWAYS 5, never changes)
Risk Profile: Medium (ALWAYS Medium, never changes)
```

### **After (With Database Fields)**
```
Projected Growth: 98.71% (from database projected_growth)
Demand Index: 7/10 (from database demand_index)
Risk Profile: High (from database risk_profile)

→ Can be different for each project
→ Can be updated by admin
→ Fetched fresh from backend
```

---

## 📝 Example Data After Implementation

### Project A:
```
Projected Growth: 98.71% YoY
Demand Index: 5/10
Risk Profile: Medium
```

### Project B:
```
Projected Growth: 45.3% YoY
Demand Index: 8/10
Risk Profile: High
```

### Project C:
```
Projected Growth: 120.5% YoY
Demand Index: 3/10
Risk Profile: Very High
```

---

## 🎯 Summary

| Component | Current | After Fix |
|-----------|---------|-----------|
| **Projected Growth** | Works (uses expectedROI) | ✅ Uses dedicated field |
| **Demand Index** | ❌ Hardcoded 5 | ✅ Dynamic from DB |
| **Risk Profile** | ❌ Hardcoded 'Medium' | ✅ Dynamic from DB |
| **Per Project Different?** | No (all same) | ✅ Yes (each can differ) |
| **Admin Updates?** | No | ✅ Yes (via admin screen) |

---

## 🚀 Action Items

- [ ] Add 3 fields to `Project.java` + getters/setters
- [ ] Run database migration to add columns
- [ ] Update `lib/models/project.dart` with new fields
- [ ] Test with sample data
- [ ] Update admin project creation form (if needed)
- [ ] Verify API returns new fields correctly

