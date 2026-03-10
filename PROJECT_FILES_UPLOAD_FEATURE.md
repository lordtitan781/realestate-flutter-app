# Project Files Upload Feature - Landowner Add Land

## Overview
The landowner's add land page has been enhanced to allow uploading multiple project files with **high file size limits** and **no document count restrictions**. The previous "Legal documents summary" text field has been replaced with a comprehensive file upload system.

## What Changed

### 1. Frontend Changes: `lib/features/landowner/add_land_screen.dart`

#### Imports Added
```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
```

#### State Variables Updated
**Removed:**
- `final _legalDocsCtrl = TextEditingController();`

**Added:**
- `final List<File> _uploadedFiles = [];` - Stores all uploaded files

#### New Methods

##### `_pickFiles()` - File Selection Handler
```dart
Future<void> _pickFiles() async {
  // Uses file_picker to select multiple files
  // No file size restrictions
  // Supports all file types
  // Returns immediately with all selected files
}
```

**Features:**
- Multi-file selection enabled
- No file type restrictions (all file types allowed)
- No size limit imposed by Flutter code
- Error handling for file picker failures
- User feedback via SnackBar

##### `_removeFile(index)` - Remove Uploaded File
```dart
void _removeFile(int index) {
  setState(() {
    _uploadedFiles.removeAt(index);
  });
}
```

#### UI Changes

##### Project Files Upload Section
Replaces the old text field with a modern upload container:

**Features:**
- File count badge (blue pill showing "X file(s)")
- Descriptive text explaining what files to upload
- "Add Files" button with cloud upload icon
- Visual file list display with:
  - File name
  - File size in MB
  - Delete button (remove from upload list)
- Clean, organized layout with rounded borders
- Only shows file list after files are selected

**Visual Layout:**
```
┌─────────────────────────────────────────┐
│ Project Files              [2 file(s)]   │
├─────────────────────────────────────────┤
│ Upload all project-related documents    │
│ (plans, surveys, legal docs, etc.)     │
│                                         │
│ [Cloud Upload] Add Files                │
├─────────────────────────────────────────┤
│ Uploaded Files                          │
├─────────────────────────────────────────┤
│ [📄] survey_plan.pdf        (2.50 MB)  │ ✕
│ [📄] architectural_plan.dwg (5.75 MB)  │ ✕
└─────────────────────────────────────────┘
```

#### Form Submission Updated
**Validation:**
- Added field validation for Name, Location, Size
- Shows specific error messages

**File Processing:**
- Converts file paths to serialized string format
- Uses pipe character `|` as delimiter for multiple files
- Stores in `legalDocuments` field as: `path1|path2|path3|...`
- Backend can parse and process files accordingly

**Feedback:**
- Shows file count in success message: `"Land submitted with X file(s)"`
- Clears all fields including file list after successful submission

#### Cleanup
- Removed `_legalDocsCtrl` disposal from `dispose()` method
- Removed unused `_legalDocsCtrl` field

### 2. Dependency Changes: `pubspec.yaml`

**Added:**
```yaml
file_picker: ^7.0.0
```

This package provides:
- Native file picker for iOS and Android
- Multi-file selection support
- No built-in file size restrictions
- Cross-platform compatibility

## Technical Details

### File Size Handling
- **Flutter Level**: No restrictions imposed
- **File Picker Level**: No size limits configured
- **Backend Level**: Configure server-side limits as needed (nginx, Apache, Spring Boot)

### File Type Support
- All file types allowed (PDF, DWG, images, documents, spreadsheets, etc.)
- No validation on Flutter side
- Backend can implement specific file type validation if needed

### Document Count
- **No limit** on number of documents
- Users can upload as many files as needed
- Only limited by device storage and network

### File Path Storage
Files are stored as pipe-delimited paths in the `legalDocuments` field:
```
/path/to/file1.pdf|/path/to/file2.dwg|/path/to/file3.xlsx
```

**Backend Processing:**
```java
// Example backend parsing
String documentsJson = land.getLegalDocuments();
if (documentsJson != null) {
  String[] filePaths = documentsJson.split("\\|");
  for (String filePath : filePaths) {
    // Process each file
  }
}
```

## Usage Flow

### Landowner Perspective
1. Navigate to "Add Land" screen
2. Fill in land name, location, size, and zoning
3. In "Project Files" section, click "Add Files"
4. Select one or more files (unlimited quantity)
5. View uploaded files with their sizes
6. Remove files if needed by clicking ✕ button
7. Select utilities and click "Submit for Evaluation"
8. See confirmation with file count

### Admin Perspective
1. Admin can see `legalDocuments` field contains file paths
2. Backend processes files based on configured limits
3. Files stored on server as needed
4. Admin can view/manage files through admin dashboard

## Installation Steps

### 1. Update Dependencies
```bash
flutter pub get
```

This automatically installs:
- `file_picker: ^7.0.0`
- All transitive dependencies

### 2. Platform-Specific Setup (iOS)

**ios/Podfile** - May need to adjust settings:
```ruby
# Add to ios/Podfile if needed
platform :ios, '12.0'
```

**ios/Runner/Info.plist** - File picker requires document picker permissions:
```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>App needs access to documents to upload project files</string>
```

### 3. Platform-Specific Setup (Android)

**android/app/build.gradle** - Usually automatic, but verify:
```gradle
android {
    compileSdkVersion 34  // or higher
    ...
}
```

**android/app/src/main/AndroidManifest.xml** - Usually automatic:
- READ_EXTERNAL_STORAGE permission added automatically
- INTERNET permission required for file operations

## Backend Integration Guide

### Option 1: Store File Paths (Current Implementation)
Files stored as pipe-delimited paths:
```java
@PostMapping("/api/lands")
public ResponseEntity<?> addLand(@RequestBody Land land) {
    String filePaths = land.getLegalDocuments();
    if (filePaths != null && !filePaths.isEmpty()) {
        String[] paths = filePaths.split("\\|");
        // Process each file path
        for (String path : paths) {
            // Read file from temporary location
            // Process/validate file
            // Move to permanent storage
        }
    }
    
    // Save land to database
    return ResponseEntity.ok(landRepository.save(land));
}
```

### Option 2: Base64 Encode Files (Recommended for Large Files)
```java
@PostMapping("/api/lands/with-files")
public ResponseEntity<?> addLandWithFiles(
        @RequestParam String landData,
        @RequestParam List<MultipartFile> files) {
    
    Land land = objectMapper.readValue(landData, Land.class);
    
    for (MultipartFile file : files) {
        // Validate file size and type
        if (file.getSize() > MAX_FILE_SIZE) {
            return ResponseEntity.badRequest()
                .body("File exceeds maximum size");
        }
        
        // Save to storage
        String storagePath = saveFile(file);
        // Store path reference in database
    }
    
    land.setLegalDocuments(storagePath);
    return ResponseEntity.ok(landRepository.save(land));
}
```

### Option 3: Add Multipart Upload Endpoint
Create dedicated endpoint for file uploads:
```java
@PostMapping("/api/lands/{landId}/upload-files")
public ResponseEntity<?> uploadFiles(
        @PathVariable Long landId,
        @RequestParam List<MultipartFile> files) {
    
    List<String> uploadedPaths = new ArrayList<>();
    
    for (MultipartFile file : files) {
        // Validate and save
        String path = storageService.save(file);
        uploadedPaths.add(path);
    }
    
    // Update land with file references
    Land land = landRepository.findById(landId).orElseThrow();
    String filePathsJson = String.join("|", uploadedPaths);
    land.setLegalDocuments(filePathsJson);
    
    landRepository.save(land);
    return ResponseEntity.ok(uploadedPaths);
}
```

## Testing Checklist

### Mobile Testing
- [ ] Can select single file
- [ ] Can select multiple files simultaneously
- [ ] File names display correctly
- [ ] File sizes calculate correctly
- [ ] Can remove file from list
- [ ] Can add more files after removing some
- [ ] Can submit form with multiple files
- [ ] Success message shows correct file count
- [ ] Can upload large files (100MB+)
- [ ] Can upload various file types

### Edge Cases
- [ ] Selecting no files and submitting (should work - files optional)
- [ ] Uploading files with special characters in name
- [ ] Uploading corrupted files
- [ ] Network interruption during submission
- [ ] Very large file sets (50+ files)

### Admin Testing
- [ ] File paths correctly stored in database
- [ ] Files accessible for admin review
- [ ] File metadata (size, name) preserved
- [ ] Old text-based legal document references still work

## Limitations & Future Enhancements

### Current Limitations
1. File paths stored as pipe-delimited strings
2. No file preview before upload
3. No progress indicator for large uploads
4. No drag-and-drop support
5. No file size limit enforced on Flutter side

### Future Enhancements
1. **File Preview** - Show thumbnails for images/PDFs
2. **Drag & Drop** - Support dragging files into upload area
3. **Progress Indicator** - Show upload progress for large files
4. **File Validation** - Check file types/sizes before upload
5. **Cloud Storage** - Integrate AWS S3 or similar for file storage
6. **Virus Scanning** - Scan files before saving
7. **File Compression** - Compress large files automatically
8. **Version Control** - Track file version history
9. **OCR Processing** - Extract text from documents
10. **Archive Support** - Auto-extract ZIP files

## Troubleshooting

### Issue: File picker not opening
**Solution:** Check platform-specific permissions are set correctly

### Issue: Large files not uploading
**Solution:** Configure server-side upload limits in backend framework

### Issue: File paths not saved correctly
**Solution:** Verify backend is parsing pipe-delimited paths correctly

### Issue: Missing file_picker dependency
**Solution:** Run `flutter pub get` to install missing package

### Issue: Permission denied error on Android
**Solution:** Check `android/app/src/main/AndroidManifest.xml` has READ_EXTERNAL_STORAGE permission

## Summary

The landowner add land feature now provides:
✅ **Multiple file upload** - No quantity limits
✅ **High file size support** - No Flutter-level restrictions
✅ **User-friendly UI** - Clear file management interface
✅ **Flexible storage** - Backend can implement preferred strategy
✅ **Extensible design** - Ready for future enhancements
