# OmniView — Universal File Viewer for Android

A Flutter app that opens and views 120+ file formats.

## ✅ What Actually Works

| Format Type | Viewer | Status |
|---|---|---|
| JPG, PNG, GIF, BMP, WEBP, AVIF, ICO | `photo_view` pinch-zoom | ✅ Full |
| SVG | `flutter_svg` — renders actual vector graphics | ✅ Full |
| PDF | `syncfusion_flutter_pdfviewer` | ✅ Full |
| MP4, MKV, MOV, AVI, WEBM, MTS, M2TS | `video_player` + `chewie` controls | ✅ Full |
| TXT, RTF, MD, TEX, EPS, PFA | Text viewer with font size control | ✅ Full |
| PY, JS, TS, JSON, HTML, CSS, SQL, ... | Syntax-highlighted code viewer | ✅ Full |
| CSV, TSV | Table viewer with sortable columns | ✅ Full |
| XLSX, XLS, XLSM, ODS | `excel` package — sheet tabs + table | ✅ Full |
| EPUB | `epub_view` — reflowable reader | ✅ Full |
| TTF, OTF, WOFF, WOFF2, TTC | Font preview + character map | ✅ Full |
| ZIP, TAR, GZ, TGZ | Archive file tree listing | ✅ Full |
| All others | Hex viewer (binary dump) | ⚠️ Hex |

### Formats needing system codec support (shown as hex fallback):
- RAW camera formats (CR2, CR3, NEF, ARW) — Android has no native RAW decoder
- RAR, 7Z — proprietary compression, no pure-Dart decoder
- MXF — professional broadcast container
- MOBI, AZW — DRM-protected Kindle formats  
- INDD, AI, CDR — proprietary design formats

---

## 🚀 Build & Run

### Prerequisites
- Flutter SDK 3.24+ (`flutter.dev`)
- Android Studio with Android SDK
- A physical Android device or emulator (API 21+)

### Steps

```bash
# 1. Clone / copy this project folder
cd omniview

# 2. Install dependencies
flutter pub get

# 3. Connect Android device (enable Developer Mode + USB Debugging)
flutter devices

# 4. Run on device
flutter run

# 5. Build release APK
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

### Install APK directly
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry, theme
├── utils/
│   └── format_registry.dart     # All 120+ format definitions
├── screens/
│   ├── home_screen.dart         # Category grid + file picker
│   ├── viewer_screen.dart       # Routes to correct viewer
│   └── viewers/
│       ├── image_viewer.dart    # photo_view pinch-zoom
│       ├── svg_viewer.dart      # flutter_svg renderer
│       ├── pdf_viewer.dart      # Syncfusion PDF
│       ├── video_viewer.dart    # chewie + video_player
│       ├── code_viewer.dart     # Syntax highlighting
│       ├── text_viewer.dart     # Plain text + font size
│       ├── spreadsheet_viewer.dart  # Excel/CSV table
│       ├── archive_viewer.dart  # ZIP/TAR file tree
│       ├── epub_viewer.dart     # EPUB reader
│       ├── font_viewer.dart     # Font preview
│       └── hex_viewer.dart      # Binary fallback
└── widgets/
    ├── category_card.dart
    └── format_search_delegate.dart
```

---

## Features
- 🔍 Global search across all 120+ formats
- 📂 Open from file manager, other apps, or in-app picker  
- 🖼️ Images: pinch-to-zoom, double-tap, pan
- 🎬 Video: full playback controls, seek bar, fullscreen
- 📊 Spreadsheets: sheet tabs, scrollable table
- 💻 Code: 20+ language syntax highlighting
- 📖 EPUB: reflowable reading with chapter navigation
- 🔤 Fonts: character map and sample text preview
- 📦 Archives: full file tree with sizes
- 🔢 Hex: fallback for any binary format
