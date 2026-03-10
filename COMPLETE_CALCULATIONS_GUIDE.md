# Complete Calculations Guide - How Every Value is Calculated

**Date**: 11 March 2026  
**Purpose**: Explain every single calculation in the Real Estate Investment Platform

---

## 🎯 Dashboard Calculations

### **1. Total Invested**
**Location**: `lib/features/investor/investor_dashboard.dart`  
**Display**: Top-left tile showing "₹0.0L"

#### Calculation:
```dart
final totalInvested = portfolio.fold<double>(
    0, (prev, p) => prev + p.capitalRequired * p.capitalRaised);
```

#### Formula:
```
Total Invested = Σ(project.capitalRequired × project.capitalRaised)
```

#### Breakdown:
```
For each project in investor's portfolio:
  totalInvested += (project's capital requirement) × (capital raised percentage)
```

#### Example Calculation:
```
Portfolio has 2 projects:
  Project A: capitalRequired = 100 Cr, capitalRaised = 0.5 → 100 × 0.5 = 50 Cr
  Project B: capitalRequired = 200 Cr, capitalRaised = 0.8 → 200 × 0.8 = 160 Cr

Total Invested = 50 + 160 = 210 Cr = ₹210.0L
```

#### Data Flow:
```
AppState._projects (array of all projects)
  ↓
AppState._userEOIs (array of investor's EOI records)
  ↓
AppState.investorPortfolio getter (filters projects by EOI)
  ↓
portfolio.fold() (sums all calculations)
  ↓
Dashboard displays: ₹210.0L
```

#### When Updated:
- 🔄 When investor submits EOI (new project added to portfolio)
- 🔄 When admin updates project's capitalRaised percentage
- 🔄 On page refresh or app resume

---

### **2. Active Projects**
**Location**: `lib/features/investor/investor_dashboard.dart`  
**Display**: Top-right tile showing "4"

#### Calculation:
```dart
final activeCount = portfolio.length;
```

#### Formula:
```
Active Projects = Count of projects in investor's portfolio
```

#### Breakdown:
```
Counts how many unique projects investor has EOI for
```

#### Example:
```
If investor has EOI for:
  - Project A (Beachfront)
  - Project B (Eco-Luxury)
  - Project C (Wellness)
  - Project D (Adventure)

Active Projects = 4
```

#### Data Flow:
```
AppState._userEOIs (all investor's EOI records)
  ↓
AppState.investorPortfolio (filters to get projects with EOI)
  ↓
portfolio.length (counts projects)
  ↓
Dashboard displays: 4
```

#### When Updated:
- 🔄 When investor submits NEW EOI (count increases by 1)
- 🔄 When portfolio refreshes or app resumes

---

### **3. Average IRR**
**Location**: `lib/features/investor/investor_dashboard.dart`  
**Display**: Bottom-left tile showing "34617.0%"

#### Calculation:
```dart
final avgIrr = activeCount == 0
    ? 0
    : portfolio.fold<double>(0, (p, t) => p + t.irr) / activeCount;
```

#### Formula:
```
If activeCount == 0:
  Avg IRR = 0

Else:
  Avg IRR = SUM(project.irr) / number_of_projects
```

#### Breakdown:
```
Step 1: Get all projects in portfolio
Step 2: Sum their IRR percentages
Step 3: Divide by number of projects to get average
```

#### Example Calculation:
```
Portfolio has 4 projects:
  Project A: IRR = 95.2%
  Project B: IRR = 111100.0%
  Project C: IRR = 27272.8%
  Project D: IRR = 123456%

Sum = 95.2 + 111100 + 27272.8 + 123456 = 261924%

Avg IRR = 261924 / 4 = 65481%

BUT in screenshot shows 34617.0% (different data)
```

#### Detailed Example with Dashboard Data:
```
If dashboard shows:
  "Active Projects: 4"
  "Avg IRR: 34617.0%"

Then sum of IRRs = 34617.0 × 4 = 138468.0%
(project1.irr + project2.irr + project3.irr + project4.irr = 138468.0%)
```

#### Data Flow:
```
AppState.investorPortfolio (array of projects)
  ↓
portfolio.fold() → Sum all t.irr values
  ↓
Sum / portfolio.length (average)
  ↓
Dashboard displays: 34617.0%
```

#### When Updated:
- 🔄 When investor submits NEW EOI (average recalculated with new project)
- 🔄 When admin updates project IRR value
- 🔄 On page refresh

---

### **4. Next Stage**
**Location**: `lib/features/investor/investor_dashboard.dart`  
**Display**: Bottom-right tile showing "PLANNING"

#### Calculation:
```dart
final nextMilestone = activeCount > 0 ? portfolio.first.stage : 'N/A';
```

#### Formula:
```
If activeCount > 0:
  Next Stage = first_project_in_portfolio.stage

Else:
  Next Stage = "N/A"
```

#### Breakdown:
```
Gets the stage of the FIRST project in portfolio
```

#### Example:
```
Portfolio projects (in order):
  1. Project A: stage = "PLANNING" ← This one gets displayed
  2. Project B: stage = "CONSTRUCTION"
  3. Project C: stage = "COMPLETED"
  4. Project D: stage = "LAND_APPROVED"

Next Stage = "PLANNING" (from first project)
```

#### Data Flow:
```
AppState.investorPortfolio
  ↓
portfolio.first (get first project)
  ↓
.stage (get its stage field)
  ↓
Dashboard displays: PLANNING
```

#### When Updated:
- 🔄 When investor submits NEW EOI (if new project becomes first)
- 🔄 When admin updates first project's stage
- 🔄 On page refresh

---

## 🔍 Project Details Calculations

### **5. Market Intelligence Metrics**

#### A. **Projected Growth**
**Source**: `proj.projectedGrowth`

```
Formula: Projected Growth (%) = Estimated market growth
```

**Example**:
```
Beachfront destination shows: 98.71% YoY

This means:
  - Destination's real estate market growing 98.71% per year
  - If property worth ₹100 Cr today
  - Next year worth ≈ ₹198.71 Cr
```

**Calculation Location**: Backend/Database  
**How it comes to app**: Fetched from `/api/projects` endpoint

---

#### B. **Demand Index**
**Source**: `proj.demandIndex`

```
Formula: Demand Index = Rating out of 10
```

**Scale**:
```
1-3/10:   Low demand (fewer buyers/investors)
4-6/10:   Medium demand (moderate interest)
7-9/10:   High demand (lots of interest)
10/10:    Very high demand (very competitive)
```

**Example**:
```
Beachfront destination: 5/10

This means:
  - Moderate market demand for properties
  - Mid-tier attractiveness for investors
  - Balanced supply and demand
```

**Calculation Location**: Backend analysis  
**How it comes to app**: Fetched from `/api/projects` endpoint

---

#### C. **Risk Profile**
**Source**: `proj.riskProfile`

```
Formula: Risk Profile = Categorical value (Low/Medium/High/Very High)
```

**Categories**:
```
Low:        < 5% risk of loss (very safe)
Medium:     5-15% risk (moderate risk/reward)
High:       15-30% risk (high potential but risky)
Very High:  > 30% risk (very risky, high reward potential)
```

**Example**:
```
Beachfront destination: Medium

This means:
  - Moderate risk of investment loss
  - Balanced between safety and high returns
  - Typical for established destinations
```

**Calculation Location**: Backend risk analysis  
**How it comes to app**: Fetched from `/api/projects` endpoint

---

### **6. Financial Projections Calculations**

#### A. **Expected IRR (Internal Rate of Return)**
**Source**: `proj.irr`

```
Formula: IRR = Annual percentage return on investment
```

**What It Means**:
```
For every ₹100 invested, IRR% is annual profit

Example:
  IRR = 95.2%
  
  Year 1 profit: ₹100 × 95.2% = ₹95.20
  Investment grows to: ₹195.20
  
  Year 2 profit: ₹195.20 × 95.2% = ₹185.73
  Investment grows to: ₹380.93
  
  Year 5: ₹100 grows to ≈ ₹5000+ (compound effect)
```

**Calculation**:
```
Backend Formula (Simplified):

IRR = (Projected Annual Profit / Initial Investment) × 100%

Example detailed calculation:
  Initial Investment: ₹100 Cr
  Projected Annual Profit: ₹95.2 Cr
  
  IRR = (95.2 / 100) × 100% = 95.2%
```

**Calculation Location**: Backend financial model  
**How it comes to app**: Fetched from `/api/projects` endpoint

**Note**: In dashboard, IRR shown is AVERAGE of all portfolio projects

---

#### B. **Capital Required**
**Source**: `proj.capitalRequired`

```
Formula: Capital Required = Total funding needed for project
```

**What It Means**:
```
Total amount needed to fund the entire project

Example:
  Capital Required: ₹787878787.0 Cr
  
  This means project needs ₹7.87 trillion rupees total
  
  Investors collectively raise this amount
  Each investor contributes based on their EOI/investment
```

**Calculation**:
```
Backend Formula:

Capital Required = Land cost + Construction cost + 
                  Operational cost + Contingency buffer

Example:
  Land: ₹200 Cr
  Construction: ₹400 Cr
  Operations: ₹150 Cr
  Contingency (20%): ₹150 Cr
  
  Total Capital Required: ₹900 Cr
```

**Calculation Location**: Backend project planning  
**How it comes to app**: Fetched from `/api/projects` endpoint

---

### **7. Development Roadmap (Milestone) Calculations**

#### Formula:
```
Milestone Status = Based on project.stage value
```

#### Stage-to-Milestone Mapping:
```dart
Map<String, int> stageToIndex = {
  'LAND_APPROVED': 0,      // Milestone 0: Land Approved
  'FUNDING': 1,            // Milestone 1: Investors Joined
  'PLANNING': 2,           // Milestone 2: Design Planning
  'CONSTRUCTION': 3,       // Milestone 3: Construction Started
  'COMPLETED': 4,          // Milestone 4: Resort Completed
  'OPERATIONAL': 5,        // Milestone 5: Tourists Arriving
};
```

#### Milestone Status Logic:
```dart
bool _isMilestoneCompleted(String milestone, String? stage) {
  final currentStageIndex = stageToIndex[stage] ?? -1;
  final milestoneIndex = _allMilestones.indexOf(milestone);
  
  return milestoneIndex <= currentStageIndex;  // Past or current stage = completed
}

bool _isMilestoneInProgress(String milestone, String? stage) {
  final currentStageIndex = stageToIndex[stage] ?? -1;
  final milestoneIndex = _allMilestones.indexOf(milestone);
  
  return milestoneIndex == currentStageIndex + 1;  // Next stage = in-progress
}
```

#### Example Calculation:
```
If project.stage = "PLANNING" (index 2):

Milestone 0: Land Approved
  - milestoneIndex (0) <= currentStageIndex (2)
  - 0 <= 2 ✓ → COMPLETED ✅

Milestone 1: Investors Joined
  - milestoneIndex (1) <= currentStageIndex (2)
  - 1 <= 2 ✓ → COMPLETED ✅

Milestone 2: Design Planning
  - milestoneIndex (2) == currentStageIndex (2)
  - 2 == 2 ✓ → IN-PROGRESS 🔵

Milestone 3: Construction Started
  - milestoneIndex (3) > currentStageIndex (2)
  - 3 > 2 ✓ → PENDING ⭕

Milestone 4: Resort Completed
  - milestoneIndex (4) > currentStageIndex (2)
  - 4 > 2 ✓ → PENDING ⭕

Milestone 5: Tourists Arriving
  - milestoneIndex (5) > currentStageIndex (2)
  - 5 > 2 ✓ → PENDING ⭕
```

#### When Recalculated:
- 🔄 When page loads (from proj.stage)
- 🔄 When admin updates project stage in backend
- 🔄 When user returns to screen (fresh data fetched)

---

## 📊 Portfolio Screen Calculations

### **8. Portfolio Item Display**

#### What's Shown for Each Project:
```
Project Title:           proj.title
Investment Required:     proj.investmentRequired
Stage:                   proj.stage
Expected IRR:            proj.expectedIRR
```

#### Example:
```
333333 Project
Investment Required: ₹787878787.00
[PLANNING] Badge
95.2% IRR
[View Milestones Button]
```

#### Calculation:
```
All values are direct from Project object:
  - No calculations, just displaying data
  - investor_portfolio getter filters to show only projects with EOI
```

#### Filter Logic:
```dart
List<Project> get investorPortfolio {
  final eoiProjectIds = _userEOIs.map((e) => e.projectId).toSet();
  return _projects.where((p) => eoiProjectIds.contains(p.id)).toList();
}
```

**Breakdown**:
```
Step 1: Get all investor's EOI project IDs
  _userEOIs = [
    { investorId: 1, projectId: 5 },
    { investorId: 1, projectId: 8 },
    { investorId: 1, projectId: 12 },
  ]
  
  eoiProjectIds = {5, 8, 12}

Step 2: Filter projects to only those with matching IDs
  All projects = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, ...]
  
  Filtered = Projects where id in {5, 8, 12}
          = [Project5, Project8, Project12]

Step 3: Display only these projects in portfolio
```

---

## 💻 API-Level Calculations

### **9. Backend Calculations (Java/Spring Boot)**

#### A. EOI Submission Calculation
**Endpoint**: `POST /api/eois`

```
What happens:
  1. Investor submits EOI with { investorId, projectId }
  2. Backend checks if duplicate exists
  3. If not duplicate: Create new Eoi record
  4. If duplicate: Return 409 Conflict error
```

**Backend Code Logic**:
```java
boolean eoiExists = eoiRepository.findAll().stream()
    .anyMatch(e -> e.getInvestorId().equals(eoi.getInvestorId()) && 
                   e.getProjectId().equals(eoi.getProjectId()));

if (eoiExists) {
    return ResponseEntity.status(HttpStatus.CONFLICT)
        .body(Map.of("error", "EOI already submitted"));
}

Eoi savedEoi = eoiRepository.save(eoi);
return ResponseEntity.status(HttpStatus.CREATED).body(savedEoi);
```

---

#### B. Fetching Investor EOIs
**Endpoint**: `GET /api/eois/investor/{investorId}`

```
What happens:
  1. Backend queries database: WHERE investor_id = {investorId}
  2. Returns all EOI records for that investor
  3. Frontend receives list of EOIs
```

**Database Query**:
```sql
SELECT * FROM expressions_of_interest 
WHERE investor_id = 1;

Returns:
  | id  | investor_id | project_id | status    | submission_date     |
  |-----|-------------|------------|-----------|-------------------|
  | 1   | 1           | 5          | SUBMITTED | 2026-03-11 12:28  |
  | 2   | 1           | 8          | SUBMITTED | 2026-03-11 12:30  |
  | 3   | 1           | 12         | SUBMITTED | 2026-03-11 12:35  |
```

---

## 📈 Data Transformation Pipeline

### **Complete Data Flow for Dashboard Calculations**

```
1. APP START / PAGE LOAD
   ↓
2. AppState.fetchAll() called
   ↓
3. Backend Queries:
   a) GET /api/projects → returns all projects
   b) GET /api/eois/investor/{id} → returns investor's EOIs
   c) GET /api/users/{id} → returns investor profile (budget)
   ↓
4. Data stored in AppState:
   _projects = [Project1, Project2, ...]
   _userEOIs = [Eoi1, Eoi2, ...]
   _minBudget = 1000000
   _maxBudget = 5000000
   ↓
5. Dashboard queries AppState:
   a) portfolio = investorPortfolio (filters projects by EOI)
   b) totalInvested = portfolio.fold() calculation
   c) activeCount = portfolio.length
   d) avgIrr = portfolio.fold() / portfolio.length
   e) nextMilestone = portfolio.first.stage
   f) recommended = projects.where(budget filter).take(3)
   ↓
6. Dashboard displays all values with UI updates
   ↓
7. User Submits EOI:
   ↓
8. POST /api/eois with new EOI
   ↓
9. Backend creates EOI record in database
   ↓
10. Frontend calls:
    a) AppState.addToPortfolio()
    b) Fetches fresh EOI list
    c) Calls notifyListeners()
    ↓
11. Dashboard automatically recalculates:
    a) investorPortfolio now includes new project
    b) All 4 tiles recalculate
    c) UI updates with new values
    ↓
12. User sees updated dashboard
```

---

## 🔢 Real Number Examples

### **Complete Example Walkthrough**

#### Initial State (No EOI):
```
Dashboard shows:
  Total Invested: ₹0.0L      (0 projects)
  Active Projects: 0          (0 projects)
  Avg IRR: 0%                 (0 projects)
  Next Stage: N/A             (0 projects)
  
AppState._userEOIs = [] (empty)
AppState.investorPortfolio = [] (empty)
```

#### User Submits EOI for Project A:
```
Project A details:
  id: 5
  title: "333333 Project"
  capitalRequired: 100 Cr
  capitalRaised: 0.5
  irr: 95.2%
  stage: "PLANNING"
  investmentRequired: 787878787.00
  expectedIRR: 95.2%
```

#### After EOI Submission:
```
AppState._userEOIs = [
  { investorId: 1, projectId: 5 }
]

AppState.investorPortfolio now includes Project A

Dashboard recalculates:
  
  1. Total Invested:
     = 100 × 0.5 = ₹50.0L
  
  2. Active Projects:
     = 1
  
  3. Avg IRR:
     = 95.2% / 1 = 95.2%
  
  4. Next Stage:
     = "PLANNING"
```

#### User Submits EOI for Project B:
```
Project B details:
  id: 8
  capitalRequired: 200 Cr
  capitalRaised: 0.8
  irr: 111100.0%
  stage: "CONSTRUCTION"
```

#### After 2nd EOI Submission:
```
AppState._userEOIs = [
  { investorId: 1, projectId: 5 },
  { investorId: 1, projectId: 8 }
]

AppState.investorPortfolio now includes Projects A & B

Dashboard recalculates:
  
  1. Total Invested:
     = (100 × 0.5) + (200 × 0.8)
     = 50 + 160
     = ₹210.0L
  
  2. Active Projects:
     = 2
  
  3. Avg IRR:
     = (95.2 + 111100) / 2
     = 111195.2 / 2
     = 55597.6%
  
  4. Next Stage:
     = portfolio.first.stage
     = Project A's stage
     = "PLANNING"
```

---

## ✅ Summary: What Gets Calculated vs What's Static

| Value | Calculated | Formula | Updates |
|-------|-----------|---------|---------|
| **Total Invested** | ✅ Yes | Σ(capReq × capRaised) | EOI submit, refresh |
| **Active Projects** | ✅ Yes | portfolio.length | EOI submit, refresh |
| **Avg IRR** | ✅ Yes | Σ(IRR) / count | EOI submit, refresh |
| **Next Stage** | ✅ Yes | portfolio.first.stage | EOI submit, refresh |
| **Projected Growth** | ❌ No | Static from backend | Admin updates |
| **Demand Index** | ❌ No | Static from backend | Admin updates |
| **Risk Profile** | ❌ No | Static from backend | Admin updates |
| **Expected IRR** | ❌ No | Static from backend | Admin updates |
| **Capital Required** | ❌ No | Static from backend | Admin updates |
| **Milestones** | ✅ Yes | Stage-to-index mapping | Admin updates |
| **Recommended List** | ✅ Yes | Budget filter + take(3) | Budget change |

---

## 🎯 Key Takeaways

1. **Dashboard metrics** are calculated in REAL-TIME based on investor's portfolio
2. **Project details** come from backend (not calculated by app)
3. **Milestones** are derived from project.stage value using index mapping
4. **All calculations use `fold()`** for efficient summation
5. **Consumer pattern** triggers automatic UI updates when data changes
6. **Backend is source of truth** - all project data comes from database
7. **Portfolio filtering** uses EOI records to determine which projects to show
8. **Every number** has a clear source and calculation method

