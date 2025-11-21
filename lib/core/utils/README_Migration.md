# Service Model Image Field Migration

This document explains how to add the `image` field to existing Service documents in Firestore.

## Overview

The Service model has been updated to include a new `image` field for storing service-specific images. This field is separate from the existing `brandImage` field.

## Model Changes

### Service Model (`lib/core/models/service.dart`)

Added new field:
```dart
final String image;
```

This field is now:
- ✅ Added to the constructor
- ✅ Added to the `toMap()` method  
- ✅ Added to the `fromMap()` factory method
- ✅ Used in the `services_list_widget.dart` for displaying service images

## Migration Functions

### Available Functions

1. **`testDataAddImageField()`** - Adds empty image field to all documents
2. **`testDataAddImageFieldWithDefaults()`** - Adds image field with category-based default images
3. **`verifyImageFieldMigration()`** - Verifies that all documents have the image field

### Usage

#### Method 1: Direct Function Call

```dart
import 'package:shop_app/core/utils/test_data_updater.dart';

// Add empty image fields
await TestDataUpdater.testDataAddImageField();

// OR add with default images based on category
await TestDataUpdater.testDataAddImageFieldWithDefaults();

// Verify migration was successful
await TestDataUpdater.verifyImageFieldMigration();
```

#### Method 2: Using Test UI (Recommended for Safety)

1. Navigate to the TestDataUpdateScreen
2. Use the buttons to run migration functions safely
3. Monitor the status and results

### Default Image Categories

The `testDataAddImageFieldWithDefaults()` function sets default images based on service categories:

- **Cleaning/تنظيف** → `https://example.com/default-cleaning-service.jpg`
- **Repair/إصلاح** → `https://example.com/default-repair-service.jpg`
- **Maintenance/صيانة** → `https://example.com/default-maintenance-service.jpg`
- **Installation/تركيب** → `https://example.com/default-installation-service.jpg`
- **Default** → `https://example.com/default-service.jpg`

> **Note:** Replace these URLs with actual image URLs from your storage.

## Safety Features

- ✅ **Batch Operations** - Uses Firestore batch writes for better performance
- ✅ **Duplicate Protection** - Won't add image field if it already exists
- ✅ **Debug Logging** - Provides detailed console output in debug mode
- ✅ **Error Handling** - Proper try-catch blocks with error reporting
- ✅ **Verification** - Includes verification function to check migration success

## Important Notes

⚠️ **WARNING: Use only in development/testing environment!**

- These functions modify ALL documents in the `services` collection
- Always backup your data before running migration functions
- Test on a small dataset first
- The TestDataUpdateScreen includes safety warnings

## Migration Steps

1. **Backup** your Firestore data
2. **Update** your app code with the new Service model
3. **Test** the migration on a development database first
4. **Run** the appropriate migration function:
   - Use `testDataAddImageField()` if you want to manually set images later
   - Use `testDataAddImageFieldWithDefaults()` if you want category-based defaults
5. **Verify** the migration with `verifyImageFieldMigration()`
6. **Update** any existing code that uses `brandImage` to use `image` where appropriate

## Files Modified

- `lib/core/models/service.dart` - Added image field
- `lib/core/utils/test_data_updater.dart` - Migration functions
- `lib/features/brand_details/widgets/services_list_widget.dart` - Updated to use new image field
- `lib/features/test_data_update/test_data_update_screen.dart` - UI for safe migration

## Troubleshooting

### Common Issues

1. **Permission Denied** - Ensure your Firebase rules allow updates to the services collection
2. **Network Timeout** - For large collections, consider processing in smaller batches
3. **Memory Issues** - The batch operations are designed to handle large datasets efficiently

### Verification Failed

If verification shows some documents are missing the image field:
1. Check the console output for specific document IDs
2. Re-run the migration function
3. Manually check those documents in Firebase Console

## Example Usage in Your App

```dart
// In your service card widget
Container(
  decoration: BoxDecoration(
    image: service.image.isNotEmpty
      ? DecorationImage(
          image: NetworkImage(service.image),
          fit: BoxFit.cover,
        )
      : null,
  ),
  child: service.image.isEmpty
    ? Icon(Icons.home_repair_service)
    : null,
)
```

This migration ensures all your existing Service documents have the new `image` field and your app can handle both old and new data formats seamlessly.