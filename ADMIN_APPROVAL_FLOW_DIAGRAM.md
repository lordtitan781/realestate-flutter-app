# Admin Land Approval - Visual Flow Diagram

## Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Admin Dashboard                                 │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐    │
│  │ Pending Lands    │ │ Project Mgmt     │ │ Milestones       │    │
│  │ (count: X)       │ │                  │ │                  │    │
│  └────────┬─────────┘ └──────────────────┘ └──────────────────┘    │
│           │                                                         │
│           │ Click                                                   │
│           ▼                                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │        Land Approval Screen (List View)                     │   │
│  │  Title: "Pending Land Approvals"     [↻]                   │   │
│  │  ─────────────────────────────────────────────────────────   │   │
│  │  ┌─────────────────────────────────────────────────┐        │   │
│  │  │ 🏠 Land 1                        [PENDING] →    │        │   │
│  │  │ 📍 Location 1                                   │        │   │
│  │  │ Size: 5 acres | Zoning: Tourism | Stage: ...   │        │   │
│  │  └─────────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────────┐        │   │
│  │  │ 🏠 Land 2                        [PENDING] →    │        │   │
│  │  │ 📍 Location 2                                   │        │   │
│  │  │ Size: 10 acres | Zoning: Mixed | Stage: ...    │        │   │
│  │  └─────────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────────┐        │   │
│  │  │ 🏠 Land 3                        [PENDING] →    │        │   │
│  │  │ 📍 Location 3                                   │        │   │
│  │  │ Size: 8 acres | Zoning: Ag | Stage: ...        │        │   │
│  │  └─────────────────────────────────────────────────┘        │   │
│  │                                                              │   │
│  │  [Click any card to view full details]                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│           │                                                         │
│           │ Click on land card                                     │
│           ▼                                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │     Land Details Approval Screen (Detail View)              │   │
│  │  Title: "Land Details - Approval"                           │   │
│  │  ─────────────────────────────────────────────────────────   │   │
│  │                                                              │   │
│  │  📋 [PENDING Badge] Land Name                               │   │
│  │                                                              │   │
│  │  LOCATION DETAILS                                            │   │
│  │  ├─ 📍 Location: "Bangalore, India"                         │   │
│  │  └─ 📐 Size: "5 acres"                                      │   │
│  │                                                              │   │
│  │  PROPERTY DETAILS                                            │   │
│  │  ├─ 🏢 Zoning: "Tourism / Hospitality"                      │   │
│  │  └─ 📊 Stage: "Pending Approval"                            │   │
│  │                                                              │   │
│  │  UTILITIES AVAILABLE                                         │   │
│  │  ├─ [✓ Road Access]  ├─ [✓ Water]                           │   │
│  │  ├─ [✓ Electricity]  ├─ [✓ Sewage]                          │   │
│  │                                                              │   │
│  │  LEGAL DOCUMENTS                                             │   │
│  │  ├─ [Document box showing legal summary...]                 │   │
│  │                                                              │   │
│  │  SUMMARY                                                     │   │
│  │  ├─ Owner ID: 123                                            │   │
│  │  └─ Status: PENDING                                          │   │
│  │                                                              │   │
│  │  ─────────────────────────────────────────────────────────   │   │
│  │  [✅ Approve Land]       [❌ Reject]                         │   │
│  │                                                              │   │
│  │  (Admin chooses action)                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│           │                      │                                 │
│           │                      │                                 │
│    Approve│                      │Reject                           │
│           │                      │                                 │
│           ▼                      ▼                                 │
│  ┌────────────────┐    ┌──────────────────────┐                   │
│  │ API Call:      │    │ Dialog:              │                   │
│  │ - Approve Land │    │ "Reject Reason?"     │                   │
│  │ - Create       │    │ [Input Field]        │                   │
│  │   Project      │    │ [Cancel] [Reject]    │                   │
│  │                │    └──────────────────────┘                   │
│  └────────┬───────┘              │                                │
│           │                      │ Reason provided                │
│           │                      ▼                                │
│           │           ┌──────────────────────┐                    │
│           │           │ API Call:            │                    │
│           │           │ - Reject Land        │                    │
│           │           │ - Store Notes        │                    │
│           │           └────────┬─────────────┘                    │
│           │                    │                                  │
│           └────────┬───────────┘                                  │
│                    │                                              │
│                    ▼ Success                                      │
│           ┌──────────────────────┐                                │
│           │ Success Snackbar     │                                │
│           │ "Land Approved!"     │                                │
│           │ or                   │                                │
│           │ "Land Rejected"      │                                │
│           └────────┬─────────────┘                                │
│                    │                                              │
│                    │ Pop back                                     │
│                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │        Land Approval Screen (List View - Refreshed)        │   │
│  │  ─────────────────────────────────────────────────────────   │   │
│  │  ┌─────────────────────────────────────────────────┐        │   │
│  │  │ 🏠 Land 2                        [PENDING] →    │        │   │
│  │  │ 📍 Location 2                                   │        │   │
│  │  │ Size: 10 acres | Zoning: Mixed | Stage: ...    │        │   │
│  │  └─────────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────────┐        │   │
│  │  │ 🏠 Land 3                        [PENDING] →    │        │   │
│  │  │ 📍 Location 3                                   │        │   │
│  │  │ Size: 8 acres | Zoning: Ag | Stage: ...        │        │   │
│  │  └─────────────────────────────────────────────────┘        │   │
│  │                                                              │   │
│  │  [Approved/Rejected land disappeared]                        │   │
│  │  [List auto-refreshed]                                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│           │                                                       │
│           └────► (Cycle continues for other pending lands)       │
│                                                                   │
└─────────────────────────────────────────────────────────────────────┘


[Meanwhile in Investor's App]

┌──────────────────────────────────────────┐
│     Investor App                         │
│                                          │
│  Dashboard                               │
│  ┌────────────────────────────────────┐  │
│  │ [Explore Projects]                 │  │
│  └────────┬─────────────────────────────  │
│           │                              │
│           ▼                              │
│  ┌────────────────────────────────────┐  │
│  │  Explore Screen                    │  │
│  │  ─────────────────────────────────  │  │
│  │  [All | Eco | Wellness | Beach]    │  │
│  │                                    │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │ 🏗️  NEW: Land 1 Project      │  │  │
│  │  │ 📍 Bangalore, India           │  │  │
│  │  │ 5 acres | Stage: LAND_APPROVED│  │  │
│  │  │ 12% IRR                       │  │  │
│  │  │ [View Details]                │  │  │
│  │  └──────────────────────────────┘  │  │
│  │                                    │  │
│  │  [Investor clicks to view]         │  │
│  └────────┬─────────────────────────────  │
│           │                              │
│           ▼                              │
│  ┌────────────────────────────────────┐  │
│  │  Project Details                  │  │
│  │  ─────────────────────────────────  │  │
│  │  Title: Land 1 Project             │  │
│  │  Location: Bangalore, India        │  │
│  │  Size: 5 acres                     │  │
│  │                                    │  │
│  │  [Market Analysis, Financials...]  │  │
│  │                                    │  │
│  │  [✓] I acknowledge risks...        │  │
│  │                                    │  │
│  │  [Submit Expression of Interest]   │  │
│  └────────┬─────────────────────────────  │
│           │                              │
│           │ Investor submits EOI         │
│           ▼                              │
│  ┌────────────────────────────────────┐  │
│  │  Portfolio Screen                 │  │
│  │  ─────────────────────────────────  │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │ 🏗️  Land 1 Project           │  │  │
│  │  │ Investment Required: ₹X Cr   │  │  │
│  │  │ Stage: LAND_APPROVED          │  │  │
│  │  │ 12% IRR                       │  │  │
│  │  │ [View Milestones]             │  │  │
│  │  └──────────────────────────────┘  │  │
│  └──────────────────────────────────────  │
│                                          │
└──────────────────────────────────────────┘
```

## Data Flow Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA FLOW SEQUENCE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. ADMIN APPROVES LAND                                          │
│    Admin clicks "Approve Land"                                  │
│         │                                                       │
│         ▼                                                       │
│    AppState.approveLand(landId, name, location)                │
│         │                                                       │
│         ├─► await API: PUT /admin/approve/{landId}             │
│         │   ✅ Land.reviewStatus = "APPROVED"                  │
│         │                                                       │
│         ├─► await API: POST /projects/create                   │
│         │   ✅ Creates Project with:                           │
│         │       - landId: {landId}                             │
│         │       - projectName: "{name} Project"                │
│         │       - location: {location}                         │
│         │       - stage: "LAND_APPROVED"                       │
│         │                                                       │
│         ├─► await API: GET /projects                           │
│         │   ✅ Fetches all projects                            │
│         │                                                       │
│         ├─► notifyListeners()                                  │
│         │                                                       │
│         └─► Navigator.pop(context, true)                       │
│             ✅ Returns to LandApprovalScreen with refresh       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 2. INVESTOR SEES PROJECT                                        │
│    Investor opens "Explore Themes"                              │
│         │                                                       │
│         ▼                                                       │
│    ExploreScreen.initState()                                    │
│         │                                                       │
│         ├─► await AppState.fetchAll()                          │
│         │   ✅ Fetches all projects                            │
│         │   ✅ New project appears in list                     │
│         │                                                       │
│         └─► setState()                                         │
│             ✅ Displays projects                               │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 3. INVESTOR SUBMITS EOI                                         │
│    Investor clicks "Submit Expression of Interest"              │
│         │                                                       │
│         ▼                                                       │
│    AppState.addToPortfolio(project)                             │
│         │                                                       │
│         ├─► Create EOI object                                   │
│         │   - investorId: {currentUserId}                       │
│         │   - projectId: {projectId}                            │
│         │                                                       │
│         ├─► await API: POST /eois                              │
│         │   ✅ EOI stored in backend                            │
│         │                                                       │
│         ├─► await API: GET /eois/investor/{investorId}         │
│         │   ✅ Fetch latest EOIs                               │
│         │                                                       │
│         ├─► await API: GET /projects                           │
│         │   ✅ Refresh projects                                │
│         │                                                       │
│         ├─► notifyListeners()                                  │
│         │                                                       │
│         └─► Navigator.pop(context)                             │
│             ✅ Returns to previous screen                      │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 4. INVESTOR VIEWS PORTFOLIO                                     │
│    Investor opens "My Portfolio"                                │
│         │                                                       │
│         ▼                                                       │
│    PortfolioScreen.initState()                                  │
│         │                                                       │
│         ├─► await AppState.fetchAll()                          │
│         │   ✅ Fetches EOIs                                    │
│         │   ✅ Fetches projects                                │
│         │                                                       │
│         ▼                                                       │
│    investorPortfolio getter                                     │
│         │                                                       │
│         ├─► Get all EOI project IDs                             │
│         ├─► Filter projects by ID match                         │
│         │                                                       │
│         └─► Return matching projects                            │
│             ✅ Portfolio displays projects                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT                         │
│                      (AppState)                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Properties:                                                │
│  ├─ _lands: List<Land>          (all lands)                 │
│  ├─ _projects: List<Project>    (all projects)              │
│  ├─ _userEOIs: List<EOI>        (user's EOIs)               │
│  ├─ _currentUserId: int?        (logged in user ID)         │
│  └─ _currentUserRole: String?   (ADMIN/INVESTOR/LANDOWNER)  │
│                                                             │
│  Getters:                                                   │
│  ├─ pendingLands → lands.where(status=PENDING)              │
│  ├─ approvedLands → lands.where(status=APPROVED)            │
│  ├─ projects → _projects                                    │
│  └─ investorPortfolio → projects matched with EOIs          │
│                                                             │
│  Methods:                                                   │
│  ├─ approveLand(id, name, location)                         │
│  ├─ adminRejectLand(id, adminNotes)                         │
│  ├─ addToPortfolio(project)                                 │
│  ├─ fetchPendingFromServer()                                │
│  └─ fetchAll()                                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
         │                              │
         │                              │
         ▼                              ▼
┌──────────────────────────┐   ┌──────────────────────────┐
│  LandApprovalScreen      │   │ LandDetailsApproval      │
├──────────────────────────┤   ├──────────────────────────┤
│ Shows list of pending    │   │ Shows complete land      │
│ lands as cards           │   │ details with actions     │
│                          │   │                          │
│ - Card builder           │   │ - Header with status     │
│ - List refresh           │   │ - Location section       │
│ - Navigation to detail   │   │ - Property section       │
│ - Auto-refresh on init   │   │ - Utilities              │
│                          │   │ - Legal docs             │
│                          │   │ - Summary                │
│                          │   │ - Approve/Reject buttons │
│                          │   │ - Rejection dialog       │
└──────────────────────────┘   └──────────────────────────┘
         ▲                              │
         │                              │
         └──────── Result Passing ──────┘
              (bool: approved/rejected)
```

## API Endpoints Used

```
APPROVAL WORKFLOW:
│
├─ PUT /api/admin/approve/{landId}
│  └─► Updates Land.reviewStatus = "APPROVED"
│
├─ POST /api/projects/create
│  └─► Creates Project with landId reference
│
├─ GET /api/projects
│  └─► Fetches all projects for display
│
├─ GET /api/admin/pending-lands
│  └─► Fetches pending lands for admin
│
└─ PUT /api/admin/reject/{landId}
   └─► Rejects land and stores admin notes

INVESTOR WORKFLOW:
│
├─ POST /api/eois
│  └─► Submits Expression of Interest
│
├─ GET /api/eois/investor/{investorId}
│  └─► Fetches investor's EOIs
│
└─ GET /api/projects
   └─► Fetches all projects
```

This architecture ensures:
✅ Clean separation of concerns
✅ Proper state management
✅ Seamless data flow
✅ User-friendly UI/UX
✅ Scalable design
