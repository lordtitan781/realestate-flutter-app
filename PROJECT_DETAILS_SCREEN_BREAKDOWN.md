# Project Details Screen - Complete Breakdown

**Date**: 11 March 2026  
**Screen**: `lib/features/investor/project_details.dart`

---

## 📱 Screen Layout Overview

The Project Details screen (called "Destination Intelligence") displays comprehensive information about a project before an investor decides to submit an EOI.

```
┌─────────────────────────────────────────┐
│  ← Destination Intelligence     [PLANNING]
├─────────────────────────────────────────┤
│                                         │
│  333333 Project                [PLANNING]
│  Beachfront                             │
│                                         │
│  Market Intelligence                    │
│  📈 Projected Growth:  98.71% YoY       │
│  📊 Demand Index:      5/10             │
│  🛡️  Risk Profile:     Medium           │
│                                         │
│  Financial Projections                  │
│  📈 Expected IRR:      95.237986572471% │
│  💰 Capital Req.:      ₹787878787.0 Cr  │
│                                         │
│  Development Roadmap                    │
│  ✅ Land Approved              ✓        │
│  ✅ Investors Joined           ✓        │
│  🔵 Design Planning           (current) │
│  ⭕ Construction Started                 │
│  ⭕ Resort Completed                     │
│  ⭕ Tourists Arriving                    │
│                                         │
│  Disclaimer: Real estate investments... │
│  ☐ I acknowledge the financial...      │
│                                         │
│  [Submit Expression of Interest]        │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🔍 Detailed Section Breakdown

### **1. Header Section**
**Location**: Top of screen

```
333333 Project                           [PLANNING]
Beachfront
```

#### Components:
- **Project Title**: `proj.title` (e.g., "333333 Project")
- **Theme**: `proj.theme` (e.g., "Beachfront", "Eco-Luxury", "Wellness")
- **Stage Badge**: `proj.stage` (e.g., "PLANNING", "CONSTRUCTION", "COMPLETED")

#### Data Source:
```dart
Text(proj.title, style: Theme.of(context).textTheme.headlineMedium),
Text(proj.theme, style: TextStyle(color: secondary, fontWeight: FontWeight.bold)),
StageBadge(stage: proj.stage),
```

#### When Updated:
- ✅ On page load (from Project object passed to screen)
- 🔄 Never changes during screen lifetime (static project data)

---

### **2. Market Intelligence Module**
**Icon**: 📊 Analytics  
**Purpose**: Shows destination market data and competitive analysis

#### Components:

#### A. **Projected Growth (📈 trending_up icon)**
```
Projected Growth: 98.71% YoY
```
- **Data Source**: `proj.projectedGrowth`
- **Unit**: % Year-over-Year growth
- **What it means**: Expected annual growth rate of tourism/market in this destination
- **Color**: Green icon

#### B. **Demand Index (📊 leaderboard icon)**
```
Demand Index: 5/10
```
- **Data Source**: `proj.demandIndex`
- **Scale**: Out of 10 (rating)
- **What it means**: How much demand exists for real estate in this destination
- **Color**: Blue icon
- **Example**: 5/10 = Moderate demand, 8/10 = High demand

#### C. **Risk Profile (🛡️ shield icon)**
```
Risk Profile: Medium
```
- **Data Source**: `proj.riskProfile`
- **Values**: Low, Medium, High, Very High
- **What it means**: Investment risk level for this project
- **Color**: Orange icon
- **Impact**: Higher risk = potentially higher returns but more uncertainty

#### Code:
```dart
_sectionHeader(context, "Market Intelligence"),
Container(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      _analyticRow("Projected Growth", "${proj.projectedGrowth}% YoY", 
                   Icons.trending_up, Colors.green),
      const Divider(height: 24),
      _analyticRow("Demand Index", "${proj.demandIndex}/10", 
                   Icons.leaderboard, Colors.blue),
      const Divider(height: 24),
      _analyticRow("Risk Profile", proj.riskProfile, 
                   Icons.shield_outlined, Colors.orange),
    ],
  ),
)
```

#### When Updated:
- ✅ On page load (static project data)
- 🔄 Never changes during screen lifetime

---

### **3. Financial Projections Module**
**Icon**: 💰 Financial analytics  
**Purpose**: Shows investment returns and capital requirements

#### Components:

#### A. **Expected IRR (📈 pie_chart icon)**
```
Expected IRR: 95.237986572471%
```
- **Data Source**: `proj.irr`
- **Unit**: Annual percentage return (Internal Rate of Return)
- **What it means**: Expected annual percentage return on investment
- **Formula**: Projected returns / capital invested
- **Example**:
  - 95.2% IRR = For every ₹100 invested, expect ₹95.20 annual profit
  - 111100.0% IRR = Extremely high return (may be demo data)
  
#### B. **Capital Required (💰 account_balance icon)**
```
Capital Req.: ₹787878787.0 Cr
```
- **Data Source**: `proj.capitalRequired`
- **Unit**: Crores (Indian currency, 1 Cr = 10 million)
- **What it means**: How much capital this project needs to raise
- **Example**: ₹787878787.0 Cr = ₹7,878,787,870,000 (7.8 trillion rupees)

#### Code:
```dart
_sectionHeader(context, "Financial Projections"),
Row(
  children: [
    _miniStatCard(context, "Expected IRR", "${proj.irr}%", Icons.pie_chart),
    const SizedBox(width: 12),
    _miniStatCard(context, "Capital Req.", "₹${proj.capitalRequired} Cr", 
                  Icons.account_balance),
  ],
)
```

#### When Updated:
- ✅ On page load (static project data)
- 🔄 Never changes during screen lifetime

---

### **4. Development Roadmap Module**
**Icon**: 🚩 Milestone tracking  
**Purpose**: Shows project lifecycle and current progress

#### Components:

This shows **6 standardized milestones** that all tourism projects follow:

```
_allMilestones = [
  'Land Approved',        # Index 0
  'Investors Joined',     # Index 1
  'Design Planning',      # Index 2  ← Currently here (in-progress)
  'Construction Started', # Index 3
  'Resort Completed',     # Index 4
  'Tourists Arriving',    # Index 5
];
```

#### How Status is Determined:

**Current Project Stage**: "PLANNING"

**Stage-to-Index Mapping**:
```dart
{
  'LAND_APPROVED': 0,      ← Corresponds to milestone 0
  'FUNDING': 1,            ← Corresponds to milestone 1
  'PLANNING': 2,           ← Corresponds to milestone 2 (CURRENT)
  'CONSTRUCTION': 3,       ← Corresponds to milestone 3
  'COMPLETED': 4,          ← Corresponds to milestone 4
  'OPERATIONAL': 5,        ← Corresponds to milestone 5
}
```

#### Visual Representation:

For a project in "PLANNING" stage:

```
✅ Land Approved        (COMPLETED - index 0 <= 2)
✅ Investors Joined     (COMPLETED - index 1 <= 2)
🔵 Design Planning      (IN-PROGRESS - index 2 == 2)
⭕ Construction Started  (PENDING - index 3 > 2)
⭕ Resort Completed     (PENDING - index 4 > 2)
⭕ Tourists Arriving    (PENDING - index 5 > 2)
```

#### Milestone Tile Logic:

```dart
bool _isMilestoneCompleted(String milestone, String? stage) {
  // If current stage index >= milestone index = COMPLETED
  return milestoneIndex <= currentStageIndex;
}

bool _isMilestoneInProgress(String milestone, String? stage) {
  // If milestone index == current stage index + 1 = IN-PROGRESS
  return milestoneIndex == currentStageIndex + 1;
}
```

#### Example Timeline:

**Project Stage Changes Over Time**:

```
Initial: LAND_APPROVED
  ✅ Land Approved
  ⭕ Investors Joined
  ⭕ Design Planning
  ...

↓ Admin updates to FUNDING

  ✅ Land Approved
  🔵 Investors Joined (now in-progress)
  ⭕ Design Planning
  ...

↓ Admin updates to PLANNING

  ✅ Land Approved
  ✅ Investors Joined
  🔵 Design Planning (now in-progress)
  ⭕ Construction Started
  ...

↓ Admin updates to CONSTRUCTION

  ✅ Land Approved
  ✅ Investors Joined
  ✅ Design Planning
  🔵 Construction Started (now in-progress)
  ⭕ Resort Completed
  ...

↓ Admin updates to COMPLETED

  ✅ Land Approved
  ✅ Investors Joined
  ✅ Design Planning
  ✅ Construction Started
  🔵 Resort Completed (now in-progress)
  ⭕ Tourists Arriving
```

#### Code:
```dart
_sectionHeader(context, "Development Roadmap"),
Container(
  child: Column(
    children: _allMilestones.map((milestone) {
      final isCompleted = _isMilestoneCompleted(milestone, proj.stage);
      final isInProgress = _isMilestoneInProgress(milestone, proj.stage);
      
      return MilestoneTile(
        title: milestone,
        completed: isCompleted,
        inProgress: isInProgress,
      );
    }).toList(),
  ),
)
```

#### When Updated:
- ✅ On page load (from current `proj.stage`)
- 🔄 Never changes during screen lifetime (unless user returns to this screen after admin updates the project - then it would show new stage)

---

### **5. Compliance & Disclaimer Module**
**Color**: Yellow/Amber  
**Purpose**: Legal acknowledgment before investment

```
┌─────────────────────────────────────────┐
│ Disclaimer: Real estate investments     │
│ carry inherent risks. Projections are   │
│ based on current market intelligence    │
│ and historical data.                    │
│                                         │
│ ☐ I acknowledge the financial           │
│   modelling assumptions and risk        │
│   profile.                              │
└─────────────────────────────────────────┘
```

#### Components:

**A. Disclaimer Text**:
```
"Disclaimer: Real estate investments carry inherent risks. 
Projections are based on current market intelligence and 
historical data."
```
- Static legal text
- Always displayed

**B. Compliance Checkbox**:
```
☐ I acknowledge the financial modelling assumptions and risk profile.
```

#### State Management:
```dart
bool _complianceAccepted = false;  // Initially unchecked

Checkbox(
  value: _complianceAccepted,
  onChanged: _eoiSubmitted ? null : (val) => setState(() => _complianceAccepted = val!),
)
```

#### Key Behavior:
- ❌ **Disabled if EOI already submitted** (`_eoiSubmitted == true`)
- ✅ **Enabled if EOI not submitted** (`_eoiSubmitted == false`)
- User MUST check this before submitting EOI

#### Code:
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.amber.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.amber.shade200),
  ),
  child: Column(
    children: [
      const Text("Disclaimer: Real estate investments..."),
      const SizedBox(height: 8),
      Row(
        children: [
          Checkbox(
            value: _complianceAccepted,
            onChanged: _eoiSubmitted ? null : (val) => setState(() => _complianceAccepted = val!),
          ),
          const Expanded(
            child: Text("I acknowledge the financial modelling..."),
          ),
        ],
      ),
    ],
  ),
)
```

#### When Updated:
- ⏹️ Only changes when user clicks checkbox
- ❌ Cannot change after EOI submitted

---

### **6. EOI Submission Module (Bottom)**
**Purpose**: Final action to submit Expression of Interest

#### Two Possible States:

#### **State A: EOI NOT Yet Submitted**

```
[Submit Expression of Interest Button]
```

Button appearance:
```dart
ElevatedButton(
  onPressed: (_complianceAccepted && !_isSubmitting) ? _submitEOI : null,
  child: _isSubmitting
      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
      : const Text('Submit Expression of Interest (EOI)'),
)
```

**Conditions**:
- ✅ Enabled: `_complianceAccepted == true` AND `_isSubmitting == false`
- ❌ Disabled: Compliance not checked OR already submitting
- ⏳ Loading: Shows spinner during submission

**What happens when clicked**:
1. `_submitEOI()` method called
2. Checks compliance acceptance
3. Calls `AppState.addToPortfolio(project)`
4. Posts EOI to backend
5. Shows success message (green)
6. Sets `_eoiSubmitted = true`
7. Pops screen after 500ms

---

#### **State B: EOI ALREADY Submitted**

```
┌─────────────────────────────────────────┐
│ ✅ EOI Submitted                        │
│                                         │
│ This project has been added to your     │
│ portfolio                               │
└─────────────────────────────────────────┘
```

Code:
```dart
if (_eoiSubmitted)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green.shade300),
    ),
    child: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EOI Submitted', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              const Text('This project has been added to your portfolio', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  )
else
  // Show submit button
```

**What it means**:
- 🎉 EOI was successfully submitted
- ✅ Project is now in your portfolio
- 🔒 Cannot submit again (checkbox disabled)
- ← Back button in AppBar takes you back

---

## 🔄 Complete User Interaction Flow

### **Scenario 1: First Time Viewing Project**

```
Step 1: Page Loads
  ↓
  - Project data loaded from widget parameter
  - _checkIfEOIExists() called
  - _eoiSubmitted = false
  - _complianceAccepted = false
  ↓
  UI State:
    All sections display
    Button: [Submit Expression of Interest] (DISABLED - red)
    Checkbox: ☐ (unchecked)

Step 2: User Reads Information
  ↓
  - Reviews Market Intelligence
  - Studies Financial Projections
  - Views Development Roadmap
  - Reads Disclaimer
  ↓
  No state changes

Step 3: User Checks Compliance Checkbox
  ↓
  _complianceAccepted = true
  ↓
  UI State:
    Checkbox: ☑ (checked)
    Button: [Submit Expression of Interest] (ENABLED - green)

Step 4: User Clicks Submit Button
  ↓
  _isSubmitting = true
  Button shows spinner
  ↓
  Backend processes EOI:
    1. Validates investor ID
    2. Checks duplicate (409 if exists)
    3. Creates EOI record
    4. Returns 201 Created
  ↓
  _eoiSubmitted = true
  Success message: "✓ Expression of Interest submitted..."
  ↓
  UI State:
    [Submit Button] replaced with green success box
    "✅ EOI Submitted - This project has been added to your portfolio"
    Checkbox: ☑ (disabled now)
  ↓
  After 500ms:
    Navigator.pop() → returns to ExploreScreen
```

### **Scenario 2: Viewing Project After Already Submitted EOI**

```
Step 1: Page Loads
  ↓
  - Project data loaded
  - _checkIfEOIExists() checks AppState
  - Returns: true (EOI already submitted)
  - _eoiSubmitted = true
  ↓
  UI State:
    Checkbox: ☑ (disabled)
    Button: NOT shown
    Green success box shown instead:
      "✅ EOI Submitted"
      "This project has been added to your portfolio"
```

---

## 📊 Data Flow Diagram

```
ProjectDetails Screen Opened with Project object
  ↓
initState() → _checkIfEOIExists()
  ↓
AppState.hasEOIForProject(projectId)
  ↓
Checks local _userEOIs list
  ↓
Returns true/false
  ↓
setState() → _eoiSubmitted = true/false
  ↓
build() called:
  - If _eoiSubmitted == false → Show submit button
  - If _eoiSubmitted == true → Show success message

User clicks Submit Button
  ↓
_submitEOI() called
  ↓
Checks _complianceAccepted
  ↓
AppState.addToPortfolio(project)
  ↓
ApiService.submitEOI(eoi) → POST /api/eois
  ↓
Backend returns 201 Created
  ↓
AppState.notifyListeners()
  ↓
setState() → _eoiSubmitted = true
  ↓
UI updates:
  - Button hidden
  - Green success box shown
  - Checkbox disabled

After 500ms:
  ↓
Navigator.pop()
  ↓
Returns to ExploreScreen
  ↓
Dashboard auto-updates (if viewed later)
  - Tiles recalculate
  - Shows new portfolio count
```

---

## 🎨 Visual Status Indicators

### Milestone Tile Status:

| Icon | Status | Meaning | When |
|------|--------|---------|------|
| ✅ | Completed | Milestone passed | Past stages |
| 🔵 | In Progress | Currently happening | Current stage |
| ⭕ | Pending | Not yet started | Future stages |

### Button Status:

| State | Appearance | Why |
|-------|-----------|-----|
| DISABLED (Red) | Greyed out | Compliance not checked |
| ENABLED (Green) | Clickable | Compliance checked |
| LOADING | Spinner | Processing submission |
| HIDDEN | N/A | EOI already submitted |

### Checkbox Status:

| State | Appearance | Why | Can Edit |
|-------|-----------|-----|----------|
| Unchecked | ☐ | Initial state | Yes |
| Checked | ☑ | User accepted | Yes |
| Checked (Disabled) | ☑ (grey) | EOI submitted | No |

---

## ✅ Summary

| Section | Purpose | Updates | Static |
|---------|---------|---------|--------|
| **Header** | Show project title & stage | On load | ✅ Static |
| **Market Intelligence** | Show destination analytics | On load | ✅ Static |
| **Financial Projections** | Show investment returns | On load | ✅ Static |
| **Development Roadmap** | Show project progress | On load | ✅ Static |
| **Compliance** | Get investor acknowledgment | On checkbox | 🔄 Dynamic |
| **EOI Submission** | Submit investment interest | On button click | 🔄 Dynamic |

**Key Takeaway**: Most of the screen is static project information. The only dynamic elements are the compliance checkbox and EOI submission button, which change based on user interaction and previous EOI submissions.

