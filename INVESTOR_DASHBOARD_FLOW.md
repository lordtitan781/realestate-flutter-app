# Investor Dashboard - Complete Flow & Timing Breakdown

**Date**: 11 March 2026

---

## 📊 Dashboard Overview

The **Investor Dashboard** is the main landing page when an investor logs in. It displays real-time portfolio metrics and recommendations based on the investor's budget preferences.

---

## 🎯 Key Tiles & When They Update

### **Tile 1: Total Invested**
**Icon**: 💰 Account Balance Wallet (Blue)  
**Value**: ₹0.0L (or actual amount)

#### When it Updates:
- ✅ **Page Load**: Calculated when dashboard first loads
- ✅ **EOI Submission**: When investor submits EOI for a project
- ✅ **Manual Refresh**: When investor pulls down to refresh
- ✅ **Portfolio Changes**: When projects are added/removed from portfolio

#### How it's Calculated:
```dart
final totalInvested = portfolio.fold<double>(
    0, (prev, p) => prev + p.capitalRequired * p.capitalRaised);
```

**Formula**: 
```
Total Invested = SUM(capitalRequired × capitalRaised) for all portfolio projects
```

**Trigger Points**:
1. Dashboard `build()` method called
2. `Consumer<AppState>` detects `appState.investorPortfolio` change
3. `totalInvested` variable recalculated
4. Widget rebuilds with new value

---

### **Tile 2: Active Projects**
**Icon**: 📋 Assignment (Orange)  
**Value**: 4 (or count of projects)

#### When it Updates:
- ✅ **Page Load**: Counts portfolio projects on load
- ✅ **EOI Submission**: Number increases when EOI submitted
- ✅ **Portfolio Tab Click**: Refreshed when viewing portfolio
- ✅ **App Resume**: Refreshed when returning to dashboard

#### How it's Calculated:
```dart
final activeCount = portfolio.length;
```

**Trigger Points**:
1. Investor submits EOI
2. `AppState.addToPortfolio()` calls `notifyListeners()`
3. `Consumer<AppState>` rebuilds
4. `portfolio.length` recalculated
5. Number increases by 1

---

### **Tile 3: Avg IRR**
**Icon**: 📈 Trending Up (Green)  
**Value**: 34617.0% (average expected IRR)

#### When it Updates:
- ✅ **Page Load**: Calculated on first load
- ✅ **EOI Submission**: Average recalculated with new project
- ✅ **Portfolio Changes**: Recalculated whenever portfolio changes

#### How it's Calculated:
```dart
final avgIrr = activeCount == 0
    ? 0
    : portfolio.fold<double>(0, (p, t) => p + t.irr) / activeCount;
```

**Formula**:
```
Avg IRR = SUM(project.irr) / number_of_projects

Example:
Project 1: 95.2% IRR
Project 2: 111100.0% IRR
Project 3: 27272.8% IRR
Project 4: 123456% IRR

Avg IRR = (95.2 + 111100 + 27272.8 + 123456) / 4 = 34617.0%
```

**Trigger Points**:
1. New EOI added to portfolio
2. `portfolio.fold()` runs with all projects
3. Average recalculated
4. Widget rebuilds with new value

---

### **Tile 4: Next Stage**
**Icon**: 🚩 Flag (Purple)  
**Value**: PLANNING (or next milestone stage)

#### When it Updates:
- ✅ **Page Load**: Gets first project's stage
- ✅ **EOI Submission**: If new project is added, stage may change
- ✅ **Project Stage Change**: When admin updates project stage
- ✅ **Portfolio Refresh**: Refreshed on app resume

#### How it's Calculated:
```dart
final nextMilestone = activeCount > 0 ? portfolio.first.stage : 'N/A';
```

**Logic**:
```
IF portfolio has projects:
  nextMilestone = first_project_in_portfolio.stage
ELSE:
  nextMilestone = "N/A"
```

**Trigger Points**:
1. Investor has at least 1 EOI
2. `portfolio.first.stage` retrieved
3. Stage from backend project data displayed
4. Updates whenever new EOI submitted (if new one is first)

---

## 📝 "Recommended for you" Section

**How it Works**: Filters all projects based on investor's budget range

#### When it Updates:
- ✅ **Page Load**: Filters on initial load
- ✅ **Budget Set**: When investor sets budget preferences
- ✅ **New Projects Added**: When admin adds new projects
- ✅ **Manual Refresh**: Pull to refresh

#### How it's Calculated:
```dart
final minBudget = appState.minBudget;  // User's min investment
final maxBudget = appState.maxBudget;  // User's max investment

final recommended = appState.projects.where((p) {
  final cost = p.investmentRequired;
  if (minBudget != null && cost < minBudget) return false;
  if (maxBudget != null && cost > maxBudget) return false;
  return true;
}).take(3).toList();  // Top 3 matches
```

**Filter Logic**:
```
Show projects where:
  project.investmentRequired >= minBudget AND
  project.investmentRequired <= maxBudget

Limit to 3 projects max
```

**Example**:
- Investor's min budget: ₹5 Cr
- Investor's max budget: ₹50 Cr
- Project A cost: ₹10 Cr → ✅ SHOWN (within range)
- Project B cost: ₹3 Cr → ❌ HIDDEN (below min)
- Project C cost: ₹100 Cr → ❌ HIDDEN (above max)

#### User Interaction:
- 👆 **Tap on card**: Opens `ProjectDetails` screen
- 📲 Shows full project info, IRR, projections
- ✅ Can submit EOI from there

---

## 🔄 Complete User Journey Timeline

### **Step 1: Dashboard Loads (Initial)**
```
Timeline: t=0ms
Actions:
  1. InvestorDashboard widget built
  2. Consumer<AppState> initialized
  3. appState.investorPortfolio fetched
  4. All 4 tiles calculated:
     - totalInvested = 0 (no EOI yet)
     - activeCount = 0
     - avgIrr = 0
     - nextMilestone = "N/A"
  5. Dashboard displays empty state

Data State:
  - portfolio = []
  - recommended = [Project1, Project2, Project3]
```

---

### **Step 2: User Navigates to Explore**
```
Timeline: t=1s
Actions:
  1. User taps "Explore" tab
  2. ExploreScreen loads
  3. Projects displayed with EOI badges (all showing "Not submitted")
  4. Dashboard kept in memory but not visible

State:
  - appState still has old data
  - No updates to dashboard (not in view)
```

---

### **Step 3: User Selects Project & Views Details**
```
Timeline: t=5s
Actions:
  1. User clicks project card
  2. ProjectDetails screen opens
  3. Shows project info, compliance disclaimer
  4. User reviews milestones, IRR, risk profile
  5. Dashboard NOT updated (not visible)

State:
  - appState unchanged
  - Dashboard still shows portfolio = []
```

---

### **Step 4: User Submits EOI** ⭐ CRITICAL POINT
```
Timeline: t=15s
Actions:
  1. User checks compliance checkbox
  2. User taps "Submit Expression of Interest"
  3. AppState.addToPortfolio(project) called:
     a) POST request sent: /api/eois with { investorId, projectId }
     b) Backend creates record in expressions_of_interest table
     c) Backend returns 201 CREATED response
     d) AppState.addToPortfolio() does:
        - Calls ApiService.getInvestorEOIs()
        - Fetches ALL EOIs for investor
        - Calls ApiService.getProjects()
        - Fetches updated project data
        - Calls notifyListeners()
  4. SUCCESS: "EOI Submitted" message shown (green)
  5. Navigator.pop() called after 500ms
  6. User returns to ExploreScreen

Data State AFTER EOI:
  - portfolio NOW has [Project]
  - activeCount = 1
  - totalInvested = recalculated
  - avgIrr = project.irr
  - nextMilestone = project.stage
```

---

### **Step 5: User Returns to Dashboard**
```
Timeline: t=20s
Actions:
  1. User taps "Dashboard" tab
  2. Dashboard already in memory
  3. Consumer<AppState> detects state changed from Step 4
  4. Dashboard build() method called AGAIN
  5. All 4 tiles RECALCULATED with new data:
     
     BEFORE:                    AFTER:
     Total: ₹0.0L        →      ₹X.XL
     Active: 0           →      1
     Avg IRR: 0%         →      95.2%
     Next Stage: N/A     →      PLANNING

  6. Recommended section regenerated (same projects, no change)

UI Changes:
  ✅ Tiles animate in with new values
  ✅ Numbers update
  ✅ Colors remain same
```

---

### **Step 6: Portfolio Lifecycle Observer Triggers**
```
Timeline: t=25s (when app regains focus)
Actions:
  1. User navigates away (home screen, another app)
  2. App state = AppLifecycleState.paused
  3. Dashboard lifecycle halts
  
Timeline: t=30s (when app returns)
Actions:
  1. User returns to app
  2. App state = AppLifecycleState.resumed
  3. Portfolio screen's didChangeAppLifecycleState() triggered
  4. appState.fetchAll() called automatically
  5. Latest data fetched from backend
  6. Dashboard tiles update if any changes

Code that runs:
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final appState = context.read<AppState>();
      if (appState.currentUserId != null && 
          appState.currentUserRole == 'INVESTOR') {
        appState.fetchAll();  // ← Refresh happens here
      }
    }
  }
```

---

## 🔔 All Update Triggers

| Trigger | When | What Updates | Speed |
|---------|------|--------------|-------|
| **Page Load** | Dashboard first opens | All 4 tiles | 1-2s |
| **EOI Submission** | User submits EOI | All 4 tiles | 0.5s |
| **App Resume** | App comes to foreground | All 4 tiles | 1-3s |
| **Manual Refresh** | Pull down to refresh | All 4 tiles | 1-2s |
| **Portfolio Tab Click** | User taps Portfolio | Portfolio list | Instant |
| **Admin Updates Project** | Admin changes stage/status | Next Stage tile | On next load |
| **Budget Preference Change** | Investor sets new budget | Recommended list | Instant |

---

## 💾 Data Flow Diagram

```
Investor Submits EOI
         ↓
   AppState.addToPortfolio()
         ↓
   ApiService.submitEOI()
         ↓
   Backend: POST /api/eois (201 Created)
         ↓
   ApiService.getInvestorEOIs()
         ↓
   Backend: GET /api/eois/investor/{id}
         ↓
   _userEOIs updated in AppState
         ↓
   appState.investorPortfolio getter recalculates
         ↓
   notifyListeners() called
         ↓
   Consumer<AppState> in Dashboard detects change
         ↓
   Dashboard.build() called again
         ↓
   All 4 tiles recalculated with new values
         ↓
   UI updates (animation/redraw)
         ↓
   User sees updated dashboard
```

---

## 📲 What Each Section Shows

### **Top: Welcome Section**
```
"Welcome back,"
"Investor Dashboard"

+ Optional budget badge if budget set:
  🎚️ ₹1000000.0 - ₹5000000.0
```

**Updates**: Only on budget change (rare)

---

### **Middle: 4 Tiles**
```
┌─────────────────────────────┐
│ 💰 Total Invested │ 📋 Active │
│ ₹0.0L              │ 4         │
└─────────────────────────────┘
┌─────────────────────────────┐
│ 📈 Avg IRR      │ 🚩 Next Stage │
│ 34617.0%        │ PLANNING      │
└─────────────────────────────┘
```

**Updates**: Every time portfolio changes (EOI submitted, etc.)

---

### **Bottom: Recommended & Insights**
```
Recommended for you
  • 333333 Project (₹787878787.00 • 95.2% IRR)
  • n Project (₹5.00 • 111100.0% IRR)
  • the Project (₹122222.00 • 27272.8% IRR)

[Investment Insights Box]
"The tourism sector is seeing 12% growth..."
```

**Updates**: When new projects added by admin or budget changes

---

## ✅ Summary

| Component | Initial Load | After EOI | On Resume | On Refresh |
|-----------|--------------|-----------|-----------|-----------|
| Total Invested | 0 | ✅ Updates | ✅ Updates | ✅ Updates |
| Active Projects | 0 | ✅ +1 | ✅ Synced | ✅ Synced |
| Avg IRR | 0% | ✅ Updates | ✅ Updates | ✅ Updates |
| Next Stage | N/A | ✅ Updates | ✅ Updates | ✅ Updates |
| Recommended | 3 projects | 😐 Same | 😐 Same | ✅ Refreshes |
| Welcome Text | Static | Static | Static | Static |

---

## 🎬 Key Moments in Dashboard Lifecycle

1. **Created**: Dashboard loaded first time → All values = 0
2. **EOI Submitted**: Values jump from 0 to real data
3. **New EOI Added**: All tiles recalculate with new project included
4. **Admin Updates Stage**: "Next Stage" tile may change (on next load)
5. **App Paused**: Dashboard frozen (not calculating anything)
6. **App Resumed**: Dashboard auto-refreshes if open
7. **New Budget Set**: Recommended list regenerated
8. **Project Details Return**: Dashboard already has latest data (was already updated by notifyListeners)

