# 🎬 EOI to Portfolio - Visual Flowchart

## User Interface Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    INVESTOR HOME SCREEN                         │
│                  (Navigation Tabs)                              │
│                                                                 │
│  ┌──────────────┬──────────────┬──────────────┐                │
│  │  🏠 Home    │  🔍 Explore  │  💼 Portfolio│                │
│  └──────────────┴──────────────┴──────────────┘                │
│                         ↓                                       │
│                  [Explore Tab]                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    EXPLORE SCREEN                              │
│         (View All Available Projects)                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────┐           │
│  │ 🎨 Theme Filter: [All][Eco-Luxury][Wellness]  │           │
│  └─────────────────────────────────────────────────┘           │
│                                                                 │
│  ┌────────────────────────────────────────────┐                │
│  │ 🏗️ Premium Coastal Land Project            │                │
│  │                                            │                │
│  │ 📍 Bangalore, India  │ 5 acres             │                │
│  │ Stage: LAND_APPROVED                       │                │
│  │ Expected IRR: 15%                          │                │
│  │                                            │                │
│  │ ┌──────────────────────────────────────┐   │                │
│  │ │ ✓ EOI Submitted                      │   │ ← GREEN BADGE  │
│  │ └──────────────────────────────────────┘   │ (if submitted) │
│  │                                            │                │
│  │ [View Milestones →]                        │ ← Click Card   │
│  └────────────────────────────────────────────┘                │
│                      ↓                                         │
│  [More Projects...]                                           │
│                                                                 │
│  📋 Refresh Button (top right)                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (Tap Card)
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│               PROJECT DETAILS SCREEN                           │
│         (Full Project Information)                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────┐           │
│  │ ← Back    Destination Intelligence              │ 🏷️APPROVED│
│  └─────────────────────────────────────────────────┘           │
│                                                                 │
│  📊 Market Intelligence                                       │
│  ├─ Projected Growth: 8.5% YoY                                │
│  ├─ Demand Index: 8/10                                       │
│  └─ Risk Profile: Medium                                     │
│                                                                 │
│  💰 Financial Projections                                    │
│  ├─ Expected IRR: 15%                                        │
│  └─ Capital Required: ₹5 Cr                                  │
│                                                                 │
│  📅 Development Roadmap                                      │
│  ├─ ✓ Feasibility Study (DONE)                              │
│  ├─ ✓ Regulatory Approvals (DONE)                           │
│  ├─ ○ Construction Phase (PENDING)                          │
│  └─ ○ Operational Handover (PENDING)                        │
│                                                                 │
│  ⚠️  Compliance & Disclaimer                                 │
│  ┌──────────────────────────────────────────────┐            │
│  │ Real estate investments carry inherent risks.│            │
│  │ Projections based on market data.            │            │
│  │                                              │            │
│  │ ☐ I acknowledge the financial modelling     │            │
│  │   assumptions and risk profile               │            │
│  │                                              │            │
│  │ ← Checkbox (REQUIRED)                       │            │
│  └──────────────────────────────────────────────┘            │
│                                                                 │
│  [Submit Expression of Interest (EOI)]                       │
│   ↓ (Only enabled after checkbox)                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (After Clicking Submit)
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│               EOI SUBMISSION FLOW                              │
│                                                                 │
│  Step 1: Frontend Validation                                 │
│  ├─ ✓ Compliance checkbox accepted?                          │
│  └─ YES → Continue | NO → Show message & return             │
│                                                                 │
│  Step 2: Show Loading State                                  │
│  ├─ ⏳ Button becomes: [⌛ Loading...]                        │
│  ├─ ✓ Button disabled (prevent double-click)                │
│  └─ ✓ Checkbox disabled                                     │
│                                                                 │
│  Step 3: Submit to Backend                                   │
│  ├─ POST /api/eois                                           │
│  ├─ Body: { investorId: 5, projectId: 10 }                 │
│  └─ Headers: Authorization: Bearer {token}                  │
│                                                                 │
│  Step 4: Backend Processing                                  │
│  ├─ 📋 Receive EOI request                                   │
│  ├─ 🔍 Check: Does EOI already exist?                       │
│  │   Query: SELECT * FROM expressions_of_interest            │
│  │   WHERE investor_id = 5 AND project_id = 10              │
│  │                                                            │
│  │   ├─ Found → Return 409 CONFLICT ❌                      │
│  │   └─ Not Found → Save new EOI → Return 201 CREATED ✓    │
│  │                                                            │
│  ├─ 💾 Save: INSERT INTO expressions_of_interest(...)       │
│  └─ ✓ Return: { id: 1, investorId: 5, projectId: 10 }     │
│                                                                 │
│  Step 5: Frontend Response Handling                           │
│  │                                                            │
│  ├─ 🟢 201 SUCCESS RESPONSE                                  │
│  │   ├─ Hide loading spinner                                │
│  │   ├─ ✅ Show green message: "✓ EOI Submitted!"          │
│  │   ├─ 🔋 Fetch updated EOIs from backend                 │
│  │   ├─ 🎨 Update UI: _eoiSubmitted = true                 │
│  │   ├─ 📦 Show green status box:                          │
│  │   │     ┌──────────────────────────────────┐            │
│  │   │     │ ✓ EOI Submitted                  │            │
│  │   │     │ This project added to portfolio  │            │
│  │   │     └──────────────────────────────────┘            │
│  │   └─ 🚀 Auto-navigate to Portfolio (500ms delay)        │
│  │                                                            │
│  ├─ 🔴 409 CONFLICT RESPONSE (Already Submitted)            │
│  │   ├─ Hide loading spinner                                │
│  │   ├─ ⚠️  Show red message: "Already submitted"           │
│  │   ├─ 🔋 Set _eoiSubmitted = true (status exists)        │
│  │   ├─ 📦 Show green status box (it exists)               │
│  │   ├─ 🚀 Auto-navigate to Portfolio (500ms delay)        │
│  │   └─ ✓ UI shows: "Already submitted"                    │
│  │                                                            │
│  ├─ 🟡 ERROR RESPONSE (Network/Server Issue)               │
│  │   ├─ Hide loading spinner                                │
│  │   ├─ ⚠️  Show red message: "Failed to submit. Try again"│
│  │   ├─ 🔘 Button remains enabled (can retry)              │
│  │   └─ 📋 User can click again to retry                   │
│  │                                                            │
│  └─ Continue...                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                PORTFOLIO SCREEN                                │
│         (Auto-loaded after EOI submission)                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────┐           │
│  │ 💼 My Portfolio                          🔄     │           │
│  └─────────────────────────────────────────────────┘           │
│                                                                 │
│  ┌────────────────────────────────────────────┐                │
│  │ 🏗️  Premium Coastal Land Project           │                │
│  │                                            │                │
│  │ 📍 Bangalore, India                        │                │
│  │ 🏷️  Stage: LAND_APPROVED                  │                │
│  │                                            │                │
│  │ 💰 Investment: ₹50 Lakh                   │                │
│  │ 📊 Expected ROI: 15% per year             │                │
│  │ 📈 IRR: 8.53%                             │                │
│  │                                            │                │
│  │ [View Milestones →]                        │                │
│  └────────────────────────────────────────────┘                │
│                                                                 │
│  ← Back to Explore (or go home)                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                BACK TO EXPLORE SCREEN                          │
│         (Notice the GREEN Badge Now!)                          │
│                                                                 │
│  ┌────────────────────────────────────────────┐                │
│  │ 🏗️ Premium Coastal Land Project            │                │
│  │                                            │                │
│  │ 📍 Bangalore, India  │ 5 acres             │                │
│  │ Stage: LAND_APPROVED                       │                │
│  │ Expected IRR: 15%                          │                │
│  │                                            │                │
│  │ ╔══════════════════════════════════════╗   │                │
│  │ ║ ✓ EOI Submitted                      ║   │ ← BADGE SHOWS  │
│  │ ╚══════════════════════════════════════╝   │                │
│  │                                            │                │
│  │ [View Milestones →]                        │                │
│  └────────────────────────────────────────────┘                │
│                                                                 │
│  ✨ All other projects that DON'T have EOI                  │
│     will NOT show the badge                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Backend Data Flow

```
┌────────────────────────────────────────────────────────────────┐
│                   BACKEND PROCESSING                           │
└────────────────────────────────────────────────────────────────┘

Step 1: Receive Request
┌─────────────────────────────┐
│ POST /api/eois              │
│ Content-Type: application/json
│                             │
│ {                           │
│   "investorId": 5,          │
│   "projectId": 10           │
│ }                           │
└─────────────────────────────┘
        ↓
Step 2: EoiController.submitEOI()
┌─────────────────────────────────────────────────┐
│ @PostMapping                                    │
│ public ResponseEntity<?> submitEOI(             │
│     @RequestBody Eoi eoi) {                     │
│                                                 │
│   // Log received request                       │
│   System.out.println(                           │
│     ">>> Submitting EOI for investor: "         │
│     + eoi.getInvestorId() +                     │
│     " project: " + eoi.getProjectId()           │
│   );                                            │
└─────────────────────────────────────────────────┘
        ↓
Step 3: Check for Duplicates
┌──────────────────────────────────────────────┐
│ // Query database for existing EOI           │
│                                              │
│ boolean eoiExists = eoiRepository.findAll()  │
│   .stream()                                  │
│   .anyMatch(e ->                             │
│     e.getInvestorId()                        │
│       .equals(eoi.getInvestorId()) &&        │
│     e.getProjectId()                         │
│       .equals(eoi.getProjectId())            │
│   );                                         │
│                                              │
│ SQL Behind the Scenes:                       │
│ SELECT * FROM expressions_of_interest        │
│ WHERE investor_id = 5                        │
│   AND project_id = 10;                       │
└──────────────────────────────────────────────┘
        ↓
        ├─────────────────────────────┬──────────────────────────┐
        │                             │                          │
   ❌ EXISTS                    ✅ NOT EXISTS
        │                             │
        ↓                             ↓
┌──────────────────────┐   ┌─────────────────────────────┐
│ Return 409 CONFLICT  │   │ Save new EOI to database    │
│                      │   │                             │
│ {                    │   │ eoiRepository.save(eoi);    │
│   "error":           │   │                             │
│   "EOI already..."   │   │ SQL: INSERT INTO            │
│   "message":         │   │ expressions_of_interest     │
│   "You have already  │   │ (investor_id, project_id...)│
│   submitted an..."   │   │ VALUES (5, 10, ...);        │
│ }                    │   │                             │
│                      │   │ ↓                           │
└──────────────────────┘   │ Return 201 CREATED         │
        ↓                  │                             │
    HTTP 409              │ {                           │
    (Conflict)            │   "id": 1,                 │
                          │   "investorId": 5,         │
                          │   "projectId": 10,         │
                          │   "status": "SUBMITTED",   │
                          │   "submissionDate":        │
                          │     "2026-03-10T10:30"     │
                          │ }                          │
                          │                             │
                          └─────────────────────────────┘
                                     ↓
                                HTTP 201
                              (Created)
```

---

## State Management Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    APP STATE (provider)                         │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Private Variables:                                       │  │
│  │                                                          │  │
│  │ List<Project> _projects = [];                           │  │
│  │ List<Eoi> _userEOIs = [];          ← IMPORTANT!        │  │
│  │ int? _currentUserId;                                    │  │
│  │ String? _currentUserRole;                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Public Getter:                                           │  │
│  │                                                          │  │
│  │ List<Project> get investorPortfolio {                   │  │
│  │   final eoiProjectIds =                                 │  │
│  │     _userEOIs.map((e) => e.projectId).toSet();          │  │
│  │   return _projects                                      │  │
│  │     .where((p) => eoiProjectIds.contains(p.id))         │  │
│  │     .toList();                                          │  │
│  │ }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Public Methods:                                          │  │
│  │                                                          │  │
│  │ Future<bool> addToPortfolio(Project project) async {   │  │
│  │   • Create new Eoi object                              │  │
│  │   • Submit to backend                                  │  │
│  │   • Fetch updated _userEOIs                            │  │
│  │   • Refresh _projects                                  │  │
│  │   • notifyListeners() → UI updates                     │  │
│  │   • return success;                                    │  │
│  │ }                                                        │  │
│  │                                                          │  │
│  │ bool hasEOIForProject(int projectId) {                 │  │
│  │   return _userEOIs.any((e) =>                           │  │
│  │     e.projectId == projectId);                          │  │
│  │ }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

                            ↓

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    PROJECT DETAILS WIDGET                       │
│                   (Listens to AppState)                         │
│                                                                 │
│  State Variables:                                              │
│  • bool _complianceAccepted = false;                          │
│  • bool _eoiSubmitted = false;       ← EOI status             │
│  • bool _isSubmitting = false;       ← Loading state          │
│                                                                 │
│  initState():                                                  │
│  └─ _checkIfEOIExists()                                       │
│     └─ appState.hasEOIForProject(projectId)                  │
│        └─ Check cached _userEOIs                             │
│           └─ setState(_eoiSubmitted = ...)                   │
│                                                                 │
│  _submitEOI():                                                 │
│  └─ appState.addToPortfolio(project)                         │
│     └─ Backend call                                          │
│        ├─ Success: setState(_eoiSubmitted = true)            │
│        └─ Error: setState(_eoiSubmitted = true) + show msg   │
│                                                                 │
│  UI Rendering:                                                │
│  • Show submit button only if !_eoiSubmitted                 │
│  • Show green status box only if _eoiSubmitted               │
│  • Disable checkbox if _eoiSubmitted                         │
│  • Show loading spinner if _isSubmitting                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

                            ↓

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    PROJECT CARD WIDGET                          │
│                   (Listens to AppState)                         │
│                                                                 │
│  Consumer<AppState>(                                           │
│    builder: (context, appState, _) {                          │
│      final hasEOI = appState.hasEOIForProject(id);           │
│                                                                 │
│      if (hasEOI) {                                            │
│        // Show green "✓ EOI Submitted" badge                 │
│        // Positioned at top-right                            │
│      }                                                         │
│    }                                                           │
│  )                                                             │
│                                                                 │
│  Triggers Badge Update:                                       │
│  • notifyListeners() called in addToPortfolio()              │
│  • Consumer rebuilds                                         │
│  • Badge appears/disappears based on state                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Dependency Graph

```
┌────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE LAYERS                         │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│              UI LAYER (Widgets)              │
│                                              │
│  • ExploreScreen                            │
│  • ProjectDetails                           │
│  • ProjectCard                              │
│  • PortfolioScreen                          │
└────────────────┬────────────────────────────┘
                 │
                 │ reads()
                 ↓
┌────────────────────────────────────────────┐
│         STATE MANAGEMENT (Provider)         │
│                                            │
│  • AppState (ChangeNotifier)               │
│    ├─ _lands                               │
│    ├─ _projects                            │
│    ├─ _userEOIs         ← KEY             │
│    └─ public methods                       │
│       ├─ addToPortfolio() ← MAIN          │
│       ├─ hasEOIForProject()               │
│       └─ checkEOIExists()                 │
└────────────────┬────────────────────────────┘
                 │
                 │ calls
                 ↓
┌────────────────────────────────────────────┐
│          SERVICE LAYER (API)                │
│                                            │
│  • ApiService                              │
│    ├─ submitEOI()      ← MODIFIED         │
│    ├─ checkEOIExists() ← NEW             │
│    ├─ getInvestorEOIs()                   │
│    └─ getProjects()                       │
└────────────────┬────────────────────────────┘
                 │
                 │ HTTP calls
                 ↓
┌────────────────────────────────────────────┐
│        BACKEND (Spring Boot)                │
│                                            │
│  • EoiController                           │
│    ├─ POST /api/eois ← ENHANCED          │
│    ├─ GET /api/eois                       │
│    ├─ GET /api/eois/investor/{id}        │
│    └─ GET /api/eois/check/{inv}/{proj}   │
│       ├─ ← NEW                           │
└────────────────┬────────────────────────────┘
                 │
                 │ queries
                 ↓
┌────────────────────────────────────────────┐
│        DATABASE (MySQL/PostgreSQL)          │
│                                            │
│  • expressions_of_interest table           │
│    ├─ id (PK)                             │
│    ├─ investor_id (FK)                    │
│    ├─ project_id (FK)                     │
│    ├─ status                              │
│    ├─ submission_date                     │
│    └─ UNIQUE(investor_id, project_id)     │
└────────────────────────────────────────────┘
```

---

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                 ERROR HANDLING SCENARIOS                        │
└─────────────────────────────────────────────────────────────────┘

SCENARIO 1: Duplicate EOI Submission
─────────────────────────────────────
User clicks submit button again (or new session, same project)
                ↓
Backend: Check for existing EOI
                ├─ FOUND → Return 409 CONFLICT
                ↓
Frontend Catches Exception
    "EOI already submitted for this project"
                ↓
    ├─ Show red SnackBar
    ├─ Set _eoiSubmitted = true
    └─ Show green status box: "Already submitted"


SCENARIO 2: Network Error
─────────────────────────
User submits EOI but network fails
                ↓
ApiService throws exception
                ↓
Frontend catches exception
    "Failed to submit EOI"
                ↓
    ├─ Show red SnackBar
    ├─ Keep _eoiSubmitted = false
    ├─ Keep button enabled
    └─ User can try again


SCENARIO 3: Server Error (500)
──────────────────────────────
Backend throws exception
                ↓
Frontend catches exception
    "Failed to submit EOI"
                ↓
    ├─ Show red SnackBar
    ├─ Keep button enabled
    └─ User can try again


SCENARIO 4: Invalid Data
─────────────────────────
Backend receives invalid data
                ↓
Backend returns 400 Bad Request
                ↓
Frontend catches exception
    "Invalid request data"
                ↓
    ├─ Show red SnackBar
    └─ Keep button enabled
```

---

## Database Uniqueness Constraint

```
┌─────────────────────────────────────────────────────────────────┐
│              DATABASE CONSTRAINT EXPLANATION                    │
└─────────────────────────────────────────────────────────────────┘

UNIQUE Key: (investor_id, project_id)
────────────────────────────────────

Purpose: Prevent duplicate EOI submissions

Example:
┌─────────┬──────────────┬────────────┬─────────┬─────────────┐
│ id      │ investor_id  │ project_id │ status  │ submit_date │
├─────────┼──────────────┼────────────┼─────────┼─────────────┤
│ 1       │ 5            │ 10         │ SUBMIT  │ 2026-03-10  │ ← Exists
│ 2       │ 5            │ 11         │ SUBMIT  │ 2026-03-10  │ ← Different project
│ 3       │ 6            │ 10         │ SUBMIT  │ 2026-03-10  │ ← Different investor
│ X       │ 5            │ 10         │ SUBMIT  │ 2026-03-10  │ ← NOT ALLOWED ❌
└─────────┴──────────────┴────────────┴─────────┴─────────────┘

Scenario 1: Investor 5 tries to submit EOI for Project 10 AGAIN
──────────────────────────────────────────────────────────────
Database Check:
  SELECT * FROM expressions_of_interest
  WHERE investor_id = 5 AND project_id = 10

Result: 1 row found
Action: REJECT duplicate → Database constraint violation
Return: 409 Conflict to Frontend


Scenario 2: Investor 6 submits EOI for Project 10
─────────────────────────────────────────────────
Database Check:
  SELECT * FROM expressions_of_interest
  WHERE investor_id = 6 AND project_id = 10

Result: No rows found
Action: ALLOW new EOI → Insert new row (id=4)
Return: 201 Created to Frontend


Scenario 3: Investor 5 submits EOI for Project 11 (different)
──────────────────────────────────────────────────────────────
Database Check:
  SELECT * FROM expressions_of_interest
  WHERE investor_id = 5 AND project_id = 11

Result: No rows found
Action: ALLOW new EOI → Insert new row (id=5)
Return: 201 Created to Frontend

This investor now has 2 EOIs (projects 10 and 11)
```

---

This covers all visual flows for the EOI to Portfolio feature! 🎉
