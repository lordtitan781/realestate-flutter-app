# Project Files Upload - Architecture & Flow Diagrams

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUTTER FRONTEND (iOS/Android)             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           Add Land Screen (add_land_screen.dart)        │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │                                                         │   │
│  │  State Variables:                                       │   │
│  │  - _nameCtrl (TextEditingController)                   │   │
│  │  - _locationCtrl (TextEditingController)               │   │
│  │  - _sizeCtrl (TextEditingController)                   │   │
│  │  - _selectedUtilities (List<String>)                   │   │
│  │  - _uploadedFiles (List<File>)      ← NEW!             │   │
│  │  - _zoning (String)                                    │   │
│  │                                                         │   │
│  │  Methods:                                              │   │
│  │  - _pickFiles()      ← NEW! (File picker)             │   │
│  │  - _removeFile()     ← NEW! (Remove file)             │   │
│  │  - build()           ← UPDATED (new UI)               │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│           │                                      │              │
│           ├──→ file_picker package (^7.0.0)      │              │
│           │    └─→ Native file browser            │              │
│           │                                       │              │
│           └─→ Material Design Components          │              │
│                ├─→ TextField                      │              │
│                ├─→ ElevatedButton                 │              │
│                ├─→ Container                      │              │
│                ├─→ ListView                       │              │
│                └─→ FilterChip                     │              │
│                                                   │              │
│  ┌──────────────────────────────────────────────┐│              │
│  │  File Upload Process                        ││              │
│  ├──────────────────────────────────────────────┤│              │
│  │                                              ││              │
│  │  1. User taps "Add Files" button             ││              │
│  │     ↓                                        ││              │
│  │  2. File picker opens (native)               ││              │
│  │     ↓                                        ││              │
│  │  3. User selects 1+ files                    ││              │
│  │     ↓                                        ││              │
│  │  4. Files added to _uploadedFiles list      ││              │
│  │     ↓                                        ││              │
│  │  5. UI updates with file list                ││              │
│  │     ↓                                        ││              │
│  │  6. User can remove individual files         ││              │
│  │     ↓                                        ││              │
│  │  7. User submits form                        ││              │
│  │     ↓                                        ││              │
│  │  8. File paths serialized (pipe-delimited)   ││              │
│  │     ↓                                        ││              │
│  │  9. Land object created with paths           ││              │
│  │     ↓                                        ││              │
│  │ 10. AppState adds land to backend            ││              │
│  │                                              ││              │
│  └──────────────────────────────────────────────┘│              │
│                                                   │              │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP POST
                            │ JSON Payload
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    SPRING BOOT BACKEND                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  @PostMapping("/api/lands")                                     │
│  LandController.addLand(Land land)                              │
│  │                                                              │
│  ├─→ Extract file paths from legalDocuments field               │
│  │    Format: /path/to/file1|/path/to/file2|/path/to/file3    │
│  │    Split by "|" delimiter                                    │
│  │                                                              │
│  ├─→ Validate each file path                                    │
│  │    - Check if file exists                                    │
│  │    - Check file size                                         │
│  │    - Validate file type (optional)                           │
│  │                                                              │
│  ├─→ Move files to permanent storage                            │
│  │    - Original: /tmp/...                                      │
│  │    - Final: /storage/projects/{landId}/...                   │
│  │                                                              │
│  ├─→ Update legalDocuments with final paths                     │
│  │    legalDocuments = "/storage/projects/123/file1|..."        │
│  │                                                              │
│  ├─→ Save Land object to database                               │
│  │    INSERT INTO lands (name, location, size, ...) VALUES (...)│
│  │                                                              │
│  └─→ Return success response (201 Created)                      │
│      JSON: { "id": 123, "name": "...", ... }                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                     DATABASE (MySQL/PostgreSQL)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  lands table                                                    │
│  ├─ id                                                          │
│  ├─ owner_id                                                    │
│  ├─ name                                                        │
│  ├─ location                                                    │
│  ├─ size                                                        │
│  ├─ zoning                                                      │
│  ├─ stage                                                       │
│  ├─ legal_documents (stored paths)                              │
│  │  Example: "/storage/projects/123/survey.pdf|..."             │
│  ├─ utilities                                                   │
│  ├─ review_status                                               │
│  └─ admin_notes                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow Diagram

```
┌─────────────────┐
│   Landowner     │
│   User App      │
└────────┬────────┘
         │
         │ 1. Opens "Add Land"
         ↓
    ┌────────────────────────────────────┐
    │  Add Land Screen                   │
    │  - Fill land details               │
    │  - Click "Add Files"               │
    └────┬─────────────────────────────────┘
         │
         │ 2. Click "Add Files"
         ↓
    ┌────────────────────────────────────┐
    │  File Picker Dialog                │
    │  (Native iOS/Android)              │
    └────┬─────────────────────────────────┘
         │
         │ 3. Select files
         ↓
    ┌────────────────────────────────────┐
    │  List<File> _uploadedFiles         │
    │  [File1, File2, File3, ...]        │
    └────┬─────────────────────────────────┘
         │
         │ 4. UI displays files
         ↓
    ┌────────────────────────────────────┐
    │  Upload List Display               │
    │  - File 1 (size)  [✕]             │
    │  - File 2 (size)  [✕]             │
    │  - File 3 (size)  [✕]             │
    │  [Add Files] button                │
    └────┬─────────────────────────────────┘
         │
         │ 5. User can add/remove files
         ↓
    ┌────────────────────────────────────┐
    │  Click "Submit for Evaluation"    │
    └────┬─────────────────────────────────┘
         │
         │ 6. Validate & Serialize
         ↓
    ┌────────────────────────────────────┐
    │  Format: path1|path2|path3|...    │
    │  Create Land object                │
    │  {                                 │
    │    name: "...",                    │
    │    location: "...",                │
    │    size: ...,                      │
    │    zoning: "...",                  │
    │    legalDocuments:                 │
    │      "/path/to/file1|               │
    │       /path/to/file2|               │
    │       /path/to/file3"               │
    │  }                                 │
    └────┬─────────────────────────────────┘
         │
         │ 7. HTTP POST /api/lands
         ↓
    ┌────────────────────────────────────┐
    │  Network Request                   │
    │  POST /api/lands                   │
    │  Content-Type: application/json    │
    │  Authorization: Bearer token       │
    └────┬─────────────────────────────────┘
         │
         │ 8. Server receives
         ↓
    ┌────────────────────────────────────┐
    │  Backend Processing                │
    │  1. Parse JSON                     │
    │  2. Extract file paths             │
    │  3. Validate each file             │
    │  4. Move to storage                │
    │  5. Update paths in object         │
    │  6. Save to database               │
    └────┬─────────────────────────────────┘
         │
         │ 9. Return 201 response
         ↓
    ┌────────────────────────────────────┐
    │  Success Response                  │
    │  {                                 │
    │    "id": 123,                      │
    │    "name": "...",                  │
    │    "legalDocuments": "final_paths" │
    │  }                                 │
    └────┬─────────────────────────────────┘
         │
         │ 10. Show success message
         ↓
    ┌────────────────────────────────────┐
    │  SnackBar:                         │
    │  "Land submitted with 3 file(s)"  │
    │                                    │
    │  Clear all fields                  │
    │  Return to dashboard               │
    └────────────────────────────────────┘
```

## 🎯 Component Structure

```
AddLandScreen (StatefulWidget)
│
└─ _AddLandScreenState
   │
   ├─ State Variables
   │  ├─ _nameCtrl: TextEditingController
   │  ├─ _locationCtrl: TextEditingController
   │  ├─ _sizeCtrl: TextEditingController
   │  ├─ _selectedUtilities: List<String>
   │  ├─ _uploadedFiles: List<File>          ← NEW
   │  └─ _zoning: String
   │
   ├─ Methods
   │  ├─ dispose()
   │  ├─ _pickFiles()                         ← NEW
   │  ├─ _removeFile(int)                     ← NEW
   │  ├─ build(BuildContext)
   │  └─ _buildUtilityChip(String)
   │
   └─ UI Structure
      │
      ├─ Scaffold
      │  │
      │  ├─ AppBar
      │  │  └─ title: "Add New Land"
      │  │
      │  └─ SafeArea
      │     │
      │     └─ Padding
      │        │
      │        └─ ListView
      │           │
      │           ├─ Title Text
      │           │
      │           ├─ Land Name TextField
      │           │
      │           ├─ Location TextField
      │           │
      │           ├─ Size TextField
      │           │
      │           ├─ Zoning Dropdown
      │           │
      │           ├─ Project Files Section         ← NEW
      │           │  │
      │           │  └─ Container
      │           │     │
      │           │     ├─ Header Row
      │           │     │  ├─ "Project Files" text
      │           │     │  └─ File count badge    ← NEW
      │           │     │
      │           │     ├─ Description text
      │           │     │
      │           │     ├─ "Add Files" button     ← NEW
      │           │     │
      │           │     └─ File List (if any)     ← NEW
      │           │        │
      │           │        └─ ListView.builder
      │           │           │
      │           │           └─ ListTile-like
      │           │              ├─ Icon
      │           │              ├─ Filename
      │           │              ├─ Filesize
      │           │              └─ Delete button
      │           │
      │           ├─ Utilities section
      │           │  └─ Wrap<FilterChip>
      │           │
      │           └─ Submit button
      │
      └─ External Dependencies
         ├─ file_picker (v7.0.0)
         ├─ provider (AppState)
         └─ Material Design
```

## 🔄 State Management Flow

```
┌─────────────────────────────────────────────┐
│      Initial State                          │
├─────────────────────────────────────────────┤
│  _uploadedFiles: []                         │
│  _nameCtrl: ""                              │
│  _locationCtrl: ""                          │
│  _sizeCtrl: ""                              │
│  _selectedUtilities: []                     │
└─────────────────────────────────────────────┘
         │
         │ User taps "Add Files"
         ↓
┌─────────────────────────────────────────────┐
│      File Picker Opened                     │
├─────────────────────────────────────────────┤
│  FilePicker.platform.pickFiles()            │
│  allowMultiple: true                        │
│  type: FileType.any                         │
└─────────────────────────────────────────────┘
         │
         │ User selects files
         ↓
┌─────────────────────────────────────────────┐
│      Files Selected                         │
├─────────────────────────────────────────────┤
│  FilePicker returns: List<PlatformFile>     │
│  forEach file in results:                   │
│    _uploadedFiles.add(File(file.path))      │
│  setState(() {})  ← UI Updates              │
└─────────────────────────────────────────────┘
         │
         │ UI rebuilds
         ↓
┌─────────────────────────────────────────────┐
│      UI Shows Files                         │
├─────────────────────────────────────────────┤
│  Badge shows: "_uploadedFiles.length"       │
│  ListView shows: file details               │
│  Delete buttons: enabled                    │
└─────────────────────────────────────────────┘
         │
         │ User can remove file
         ↓
┌─────────────────────────────────────────────┐
│      File Removed                           │
├─────────────────────────────────────────────┤
│  _removeFile(index):                        │
│    _uploadedFiles.removeAt(index)           │
│    setState(() {})  ← UI Updates            │
└─────────────────────────────────────────────┘
         │
         │ User submits form
         ↓
┌─────────────────────────────────────────────┐
│      Validation                             │
├─────────────────────────────────────────────┤
│  if _nameCtrl.text.trim().isEmpty:          │
│    Show error                               │
│  if _locationCtrl.text.trim().isEmpty:      │
│    Show error                               │
│  if _sizeCtrl.text.trim().isEmpty:          │
│    Show error                               │
│  else:                                      │
│    Proceed to submission                    │
└─────────────────────────────────────────────┘
         │
         │ Serialize files
         ↓
┌─────────────────────────────────────────────┐
│      File Serialization                     │
├─────────────────────────────────────────────┤
│  documentPaths =                            │
│    _uploadedFiles.map((f) => f.path)        │
│  documentsJson =                            │
│    documentPaths.join('|')                  │
│                                             │
│  Result: "path1|path2|path3"               │
└─────────────────────────────────────────────┘
         │
         │ Create Land object
         ↓
┌─────────────────────────────────────────────┐
│      Land Object                            │
├─────────────────────────────────────────────┤
│  Land(                                      │
│    name: _nameCtrl.text,                    │
│    location: _locationCtrl.text,            │
│    size: double.parse(_sizeCtrl.text),      │
│    zoning: _zoning,                         │
│    legalDocuments: documentsJson,    ← NEW  │
│    utilities: _selectedUtilities            │
│  )                                          │
└─────────────────────────────────────────────┘
         │
         │ Call AppState.addLand()
         ↓
┌─────────────────────────────────────────────┐
│      Backend Submission                     │
├─────────────────────────────────────────────┤
│  context.read<AppState>().addLand(newLand)  │
│  │                                          │
│  └─ HTTP POST /api/lands                    │
│     └─ Backend processes files              │
└─────────────────────────────────────────────┘
         │
         │ Success
         ↓
┌─────────────────────────────────────────────┐
│      Reset State                            │
├─────────────────────────────────────────────┤
│  _nameCtrl.clear()                          │
│  _locationCtrl.clear()                      │
│  _sizeCtrl.clear()                          │
│  _uploadedFiles.clear()                     │
│  _selectedUtilities.clear()                 │
│  _zoning = 'Tourism / Hospitality'          │
│  setState(() {})                            │
│                                             │
│  Show SnackBar: "Submitted with X files"   │
└─────────────────────────────────────────────┘
```

## 🎨 UI State Transitions

```
State 1: Empty (Initial)
┌─────────────────────────────────────────┐
│ Project Files              [0 file(s)]  │
├─────────────────────────────────────────┤
│ Upload all project docs...              │
│                                         │
│ [☁️  ] Add Files                       │
└─────────────────────────────────────────┘

         ↓ User clicks "Add Files"

State 2: Selecting
┌─────────────────────────────────────────┐
│ [Native File Picker - Dialog]           │
│ Select files to upload                  │
│                                         │
│ ☐ file1.pdf                            │
│ ☑ survey.pdf ✓                         │
│ ☑ plan.dwg ✓                           │
│                                         │
│ [Open] [Cancel]                        │
└─────────────────────────────────────────┘

         ↓ User confirms selection

State 3: Files Added
┌─────────────────────────────────────────┐
│ Project Files              [2 file(s)]  │
├─────────────────────────────────────────┤
│ Upload all project docs...              │
│                                         │
│ [☁️  ] Add Files                       │
├─────────────────────────────────────────┤
│ Uploaded Files                          │
├─────────────────────────────────────────┤
│ 📄 survey.pdf          (2.50 MB)   [✕] │
│ 📄 plan.dwg            (5.75 MB)   [✕] │
└─────────────────────────────────────────┘

         ↓ User adds more or submits

State 4A: After Remove
┌─────────────────────────────────────────┐
│ Project Files              [1 file(s)]  │
├─────────────────────────────────────────┤
│ Upload all project docs...              │
│                                         │
│ [☁️  ] Add Files                       │
├─────────────────────────────────────────┤
│ Uploaded Files                          │
├─────────────────────────────────────────┤
│ 📄 survey.pdf          (2.50 MB)   [✕] │
└─────────────────────────────────────────┘

State 4B: After Submit
┌─────────────────────────────────────────┐
│ SnackBar:                               │
│ "Land submitted with 2 file(s)"        │
│                                         │
│ Form cleared ← Ready for new entry      │
└─────────────────────────────────────────┘
```

---

This architecture is designed to be:
- **Scalable:** No file count or size limits
- **User-Friendly:** Clear file management UI
- **Flexible:** Backend can implement custom processing
- **Maintainable:** Separated concerns, clear data flow
- **Extensible:** Ready for future enhancements
