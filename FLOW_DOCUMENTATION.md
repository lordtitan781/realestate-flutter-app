# Real Estate App - Land to Project Flow Documentation

## Fixed Issue
**Problem**: When a land owner submits land through `add_land_screen` and admin approves it in `admin_dashboard`, the land was not appearing in the investor's `explore_screen` and was not being added to their portfolio.

## Solution Implemented

### 1. Updated `appState.approveLand()` method
**File**: `lib/shared/app_state.dart`

**Changes**:
- Modified the project creation to include `landId: landId` linking the project to the approved land
- Changed the project `stage` from 'Feasibility' to 'LAND_APPROVED' for consistency
- Added `_projects = await ApiService.getProjects()` after project creation to ensure all users see the new project immediately
- Added `notifyListeners()` to trigger UI updates

**Before**:
```dart
final newProject = Project(
  projectName: '$landName Project',
  location: location,
  stage: 'Feasibility',
  // ... other fields
);
```

**After**:
```dart
final newProject = Project(
  landId: landId,
  projectName: '$landName Project',
  location: location,
  stage: 'LAND_APPROVED',
  // ... other fields
);
```

### 2. Updated `land_approval_screen.dart`
**File**: `lib/features/admin/land_approval_screen.dart`

**Changes**:
- Added `await appState.fetchPendingFromServer()` after approval to refresh the pending lands list
- Updated the success message to indicate that the project is now available to investors
- Ensures the pending lands list is refreshed for better UX

**Before**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('${land.name} approved and project created!')),
);
```

**After**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('${land.name} approved! Project created and available to investors.')),
);
// Refresh the list after approval
await appState.fetchPendingFromServer();
```

## Complete User Flow

### 1. **Land Owner Submits Land**
   - Land Owner goes to `add_land_screen`
   - Fills in land details (name, location, size, zoning, utilities, legal docs)
   - Clicks "Submit for Evaluation"
   - Land is created with status 'Pending Approval'

### 2. **Admin Approves Land**
   - Admin views `land_approval_screen` → Pending Lands
   - Sees list of pending land submissions
   - Clicks ✓ (approve) button on a land
   - `approveLand()` is called which:
     1. Updates land review status to 'APPROVED' via API
     2. Creates a new Project linked to the approved land (with `landId`)
     3. Fetches all projects to ensure they're in the app state
     4. Refreshes the pending lands list

### 3. **Investor Sees Project**
   - Investor opens `explore_screen`
   - Calls `appState.fetchAll()` which fetches all projects
   - New approved land project appears in the projects list
   - Investor can filter by theme using the chip selector

### 4. **Investor Adds Project to Portfolio**
   - Investor clicks on a project card
   - Opens `project_details` screen
   - Accepts compliance and clicks "Submit Expression of Interest (EOI)"
   - Calls `appState.addToPortfolio(project)`
   - Creates an EOI linking investor to the project
   - Project is added to investor's `investorPortfolio`

### 5. **Investor Views Portfolio**
   - Investor opens `portfolio_screen`
   - Sees all projects they've submitted EOIs for (their portfolio)
   - Can click on projects to view milestones and details

## Data Model Relationships

```
Land (Pending Approval)
    ↓ [Admin Approves]
Land (APPROVED status)
    ↓ [Creates Project with landId]
Project (LAND_APPROVED stage)
    ↓ [Investor submits EOI]
EOI (links Investor → Project)
    ↓ [Shows in portfolio]
Investor Portfolio
```

## Key Components

- **AppState** (`lib/shared/app_state.dart`):
  - `approveLand()`: Approves land and creates project
  - `addProject()`: Adds project to backend and state
  - `addToPortfolio()`: Investor submits EOI for a project
  - `investorPortfolio`: Getter that filters projects investor has EOIs for

- **API Endpoints Used**:
  - `PUT /api/lands/{id}/review`: Update land review status
  - `POST /api/projects/create`: Create new project
  - `GET /api/projects`: Fetch all projects
  - `GET /api/admin/pending-lands`: Fetch pending lands for admin
  - `POST /api/eois`: Submit EOI

## Testing Checklist

- [ ] Land owner can submit land in add_land_screen
- [ ] Land appears in admin's pending lands list
- [ ] Admin can approve land
- [ ] After approval, project is visible in explore_screen (without refresh)
- [ ] Investor can click project and view details
- [ ] Investor can submit EOI for the project
- [ ] Project appears in investor's portfolio
- [ ] Multiple approved lands create multiple projects all visible to investors
- [ ] Refresh button in explore_screen still works correctly
