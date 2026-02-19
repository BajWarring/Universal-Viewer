# Omni File Manager

A fully functional Flutter file manager for Android, matching the HTML UI design exactly.

## Features

- **Real file system browsing** - Internal storage + SD card support
- **Selection mode** with select all / deselect / invert
- **Sort** by name, size, date, type (asc/desc)
- **Grid & List views** per settings
- **Context menu** (long press or ⋮) with: Open, Open With, Compress, Copy, Cut, Rename, Delete, Share, Details
- **Pinned folders** shortcuts on Home screen
- **Recent files** showing last modified files
- **Search** across the filesystem
- **Settings** - 12 categories matching HTML exactly:
  - Appearance & Themes (10 themes with carousel picker)
  - Previews & Thumbnails
  - Layout & Display
  - General Behavior
  - Safety & Confirmations
  - Search
  - Archives
  - Performance & Storage
  - Permissions
  - Gestures & Interaction
  - Advanced / Developer options
  - About
- **Permission screen** on first launch (handles Android 9 through 14+)
- **Dark mode** + Pure Black + 10 color themes
- **Compress modal** with format, encryption, password
- **Rename modal** with smart selection (excludes extension)
- **Details modal** with file info
- **Create folder** dialog

## Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Build for Android
flutter build apk --release
```

## Required Packages

```
provider: ^6.1.2          - State management
permission_handler: ^11.3.1  - Runtime permissions  
path_provider: ^2.1.3     - Device paths
path: ^1.9.0              - Path operations
open_file: ^3.3.2         - Open files with system apps
share_plus: ^10.0.0       - Share files
flutter_animate: ^4.5.0   - Animations
google_fonts: ^6.2.1      - Inter font
shared_preferences: ^2.3.2  - Settings persistence
mime: ^1.0.5              - File type detection
intl: ^0.19.0             - Date formatting
archive: ^3.6.1           - ZIP operations
```

## Android Permissions

The `AndroidManifest.xml` includes:
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` (legacy)
- `MANAGE_EXTERNAL_STORAGE` (Android 11+, full access)
- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` / `READ_MEDIA_AUDIO` (Android 13+)
- `READ_MEDIA_VISUAL_USER_SELECTED` (Android 14+)
- `VIBRATE` for haptic feedback
- `ACCESS_NETWORK_STATE` for Wi-Fi thumbnail setting
- `FOREGROUND_SERVICE` for background indexing

## Project Structure

```
lib/
├── main.dart                        # Entry + permission gate
├── models/
│   └── app_settings.dart            # All 50+ settings
├── screens/
│   ├── main_shell.dart              # Bottom nav shell
│   ├── home_screen.dart             # Home with pinned/recent
│   ├── files_screen.dart            # Main file browser
│   ├── recent_screen.dart           # Recent files
│   ├── permission_screen.dart       # First-launch permissions
│   └── settings/
│       └── settings_screen.dart     # Full settings (12 categories)
├── utils/
│   ├── app_theme.dart               # Themes & colors
│   ├── file_system_service.dart     # FS operations
│   └── storage_service.dart         # Storage device info
└── widgets/
    ├── file_item_tile.dart          # List view item
    ├── file_item_grid_card.dart     # Grid view item
    ├── bottom_sheet_menu.dart       # Context menu sheet
    ├── compress_modal.dart          # Archive creation
    ├── rename_modal.dart            # Rename + Details + CreateFolder
    ├── details_modal.dart           # Re-export
    └── create_folder_dialog.dart    # Re-export

android/
├── app/src/main/
│   ├── AndroidManifest.xml          # All permissions
│   └── res/xml/file_paths.xml       # FileProvider paths
```
