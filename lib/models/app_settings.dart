import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Appearance
  String _theme = 'Simple Light';
  bool _darkMode = false;
  bool _followSystemTheme = true;
  String _animationIntensity = 'Full';
  String _layoutDensity = 'Comfortable';
  String _iconSize = 'Medium';

  // Previews
  bool _enableThumbnails = true;
  bool _imgThumbs = true;
  bool _vidThumb = true;
  bool _pdfThumbs = true;
  bool _albumCovers = true;
  bool _apkIcons = true;
  bool _archiveThumbs = true;
  String _thumbnailQuality = 'Balanced';
  bool _wifiOnlyThumbs = false;
  bool _chargeOnlyThumbs = false;

  // Layout
  String _defaultLayout = 'List';
  bool _rememberLayout = true;
  bool _showStorageBars = true;
  bool _showItemCount = true;
  bool _showExtensions = true;
  bool _showFileSize = true;
  bool _showDateModified = true;
  bool _showTimeModified = false;
  bool _showTypeLabel = false;
  bool _showFullPath = false;
  String _sizeFormat = 'Human readable';
  String _dateFormat = 'Relative';

  // General
  String _startupLocation = 'Internal storage';
  bool _openLastSession = false;
  String _defaultOpenAction = 'Open file';
  bool _singleTapOpen = true;
  bool _showHiddenFiles = false;
  bool _dimHiddenFiles = true;
  bool _autoRefresh = true;

  // Safety
  bool _confirmDelete = true;
  bool _confirmOverwrite = true;
  bool _confirmLargeMove = true;
  int _largeFileThreshold = 500;
  bool _showProgressDialog = true;

  // Search
  bool _searchSubfolders = true;
  bool _searchHidden = false;
  bool _rememberSearches = true;

  // Archives
  String _defaultArchiveFormat = 'ZIP';
  String _archiveCompressionLevel = 'Balanced';
  String _defaultEncryption = 'None';
  bool _autoExtractDownloads = false;
  bool _deleteSourceAfterCompress = false;

  // Performance
  bool _bgIndexing = true;
  bool _autoScanMedia = true;
  String _parallelOps = '2';
  bool _lowMemoryMode = false;

  // Gestures
  String _longPressDuration = 'Default';
  bool _enableSwipe = true;
  String _swipeLeft = 'Delete';
  String _swipeRight = 'Details';
  bool _hapticFeedback = true;

  // Advanced
  bool _debugLogs = false;
  bool _experimentalFeatures = false;

  // Getters
  String get theme => _theme;
  bool get darkMode => _darkMode;
  bool get followSystemTheme => _followSystemTheme;
  String get animationIntensity => _animationIntensity;
  String get layoutDensity => _layoutDensity;
  String get iconSize => _iconSize;
  bool get enableThumbnails => _enableThumbnails;
  bool get imgThumbs => _imgThumbs;
  bool get vidThumb => _vidThumb;
  bool get pdfThumbs => _pdfThumbs;
  bool get albumCovers => _albumCovers;
  bool get apkIcons => _apkIcons;
  bool get archiveThumbs => _archiveThumbs;
  String get thumbnailQuality => _thumbnailQuality;
  bool get wifiOnlyThumbs => _wifiOnlyThumbs;
  bool get chargeOnlyThumbs => _chargeOnlyThumbs;
  String get defaultLayout => _defaultLayout;
  bool get rememberLayout => _rememberLayout;
  bool get showStorageBars => _showStorageBars;
  bool get showItemCount => _showItemCount;
  bool get showExtensions => _showExtensions;
  bool get showFileSize => _showFileSize;
  bool get showDateModified => _showDateModified;
  bool get showTimeModified => _showTimeModified;
  bool get showTypeLabel => _showTypeLabel;
  bool get showFullPath => _showFullPath;
  String get sizeFormat => _sizeFormat;
  String get dateFormat => _dateFormat;
  String get startupLocation => _startupLocation;
  bool get openLastSession => _openLastSession;
  String get defaultOpenAction => _defaultOpenAction;
  bool get singleTapOpen => _singleTapOpen;
  bool get showHiddenFiles => _showHiddenFiles;
  bool get dimHiddenFiles => _dimHiddenFiles;
  bool get autoRefresh => _autoRefresh;
  bool get confirmDelete => _confirmDelete;
  bool get confirmOverwrite => _confirmOverwrite;
  bool get confirmLargeMove => _confirmLargeMove;
  int get largeFileThreshold => _largeFileThreshold;
  bool get showProgressDialog => _showProgressDialog;
  bool get searchSubfolders => _searchSubfolders;
  bool get searchHidden => _searchHidden;
  bool get rememberSearches => _rememberSearches;
  String get defaultArchiveFormat => _defaultArchiveFormat;
  String get archiveCompressionLevel => _archiveCompressionLevel;
  String get defaultEncryption => _defaultEncryption;
  bool get autoExtractDownloads => _autoExtractDownloads;
  bool get deleteSourceAfterCompress => _deleteSourceAfterCompress;
  bool get bgIndexing => _bgIndexing;
  bool get autoScanMedia => _autoScanMedia;
  String get parallelOps => _parallelOps;
  bool get lowMemoryMode => _lowMemoryMode;
  String get longPressDuration => _longPressDuration;
  bool get enableSwipe => _enableSwipe;
  String get swipeLeft => _swipeLeft;
  String get swipeRight => _swipeRight;
  bool get hapticFeedback => _hapticFeedback;
  bool get debugLogs => _debugLogs;
  bool get experimentalFeatures => _experimentalFeatures;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _theme = _prefs.getString('theme') ?? 'Simple Light';
    _darkMode = _prefs.getBool('darkMode') ?? false;
    _followSystemTheme = _prefs.getBool('followSystemTheme') ?? true;
    _animationIntensity = _prefs.getString('animationIntensity') ?? 'Full';
    _layoutDensity = _prefs.getString('layoutDensity') ?? 'Comfortable';
    _iconSize = _prefs.getString('iconSize') ?? 'Medium';
    _enableThumbnails = _prefs.getBool('enableThumbnails') ?? true;
    _imgThumbs = _prefs.getBool('imgThumbs') ?? true;
    _vidThumb = _prefs.getBool('vidThumb') ?? true;
    _pdfThumbs = _prefs.getBool('pdfThumbs') ?? true;
    _albumCovers = _prefs.getBool('albumCovers') ?? true;
    _apkIcons = _prefs.getBool('apkIcons') ?? true;
    _archiveThumbs = _prefs.getBool('archiveThumbs') ?? true;
    _thumbnailQuality = _prefs.getString('thumbnailQuality') ?? 'Balanced';
    _wifiOnlyThumbs = _prefs.getBool('wifiOnlyThumbs') ?? false;
    _chargeOnlyThumbs = _prefs.getBool('chargeOnlyThumbs') ?? false;
    _defaultLayout = _prefs.getString('defaultLayout') ?? 'List';
    _rememberLayout = _prefs.getBool('rememberLayout') ?? true;
    _showStorageBars = _prefs.getBool('showStorageBars') ?? true;
    _showItemCount = _prefs.getBool('showItemCount') ?? true;
    _showExtensions = _prefs.getBool('showExtensions') ?? true;
    _showFileSize = _prefs.getBool('showFileSize') ?? true;
    _showDateModified = _prefs.getBool('showDateModified') ?? true;
    _showTimeModified = _prefs.getBool('showTimeModified') ?? false;
    _showTypeLabel = _prefs.getBool('showTypeLabel') ?? false;
    _showFullPath = _prefs.getBool('showFullPath') ?? false;
    _sizeFormat = _prefs.getString('sizeFormat') ?? 'Human readable';
    _dateFormat = _prefs.getString('dateFormat') ?? 'Relative';
    _startupLocation = _prefs.getString('startupLocation') ?? 'Internal storage';
    _openLastSession = _prefs.getBool('openLastSession') ?? false;
    _defaultOpenAction = _prefs.getString('defaultOpenAction') ?? 'Open file';
    _singleTapOpen = _prefs.getBool('singleTapOpen') ?? true;
    _showHiddenFiles = _prefs.getBool('showHiddenFiles') ?? false;
    _dimHiddenFiles = _prefs.getBool('dimHiddenFiles') ?? true;
    _autoRefresh = _prefs.getBool('autoRefresh') ?? true;
    _confirmDelete = _prefs.getBool('confirmDelete') ?? true;
    _confirmOverwrite = _prefs.getBool('confirmOverwrite') ?? true;
    _confirmLargeMove = _prefs.getBool('confirmLargeMove') ?? true;
    _largeFileThreshold = _prefs.getInt('largeFileThreshold') ?? 500;
    _showProgressDialog = _prefs.getBool('showProgressDialog') ?? true;
    _searchSubfolders = _prefs.getBool('searchSubfolders') ?? true;
    _searchHidden = _prefs.getBool('searchHidden') ?? false;
    _rememberSearches = _prefs.getBool('rememberSearches') ?? true;
    _defaultArchiveFormat = _prefs.getString('defaultArchiveFormat') ?? 'ZIP';
    _archiveCompressionLevel = _prefs.getString('archiveCompressionLevel') ?? 'Balanced';
    _defaultEncryption = _prefs.getString('defaultEncryption') ?? 'None';
    _autoExtractDownloads = _prefs.getBool('autoExtractDownloads') ?? false;
    _deleteSourceAfterCompress = _prefs.getBool('deleteSourceAfterCompress') ?? false;
    _bgIndexing = _prefs.getBool('bgIndexing') ?? true;
    _autoScanMedia = _prefs.getBool('autoScanMedia') ?? true;
    _parallelOps = _prefs.getString('parallelOps') ?? '2';
    _lowMemoryMode = _prefs.getBool('lowMemoryMode') ?? false;
    _longPressDuration = _prefs.getString('longPressDuration') ?? 'Default';
    _enableSwipe = _prefs.getBool('enableSwipe') ?? true;
    _swipeLeft = _prefs.getString('swipeLeft') ?? 'Delete';
    _swipeRight = _prefs.getString('swipeRight') ?? 'Details';
    _hapticFeedback = _prefs.getBool('hapticFeedback') ?? true;
    _debugLogs = _prefs.getBool('debugLogs') ?? false;
    _experimentalFeatures = _prefs.getBool('experimentalFeatures') ?? false;
    notifyListeners();
  }

  void setSetting(String key, dynamic value) {
    switch (key) {
      case 'theme': _theme = value; break;
      case 'darkMode': _darkMode = value; break;
      case 'followSystemTheme': _followSystemTheme = value; break;
      case 'animationIntensity': _animationIntensity = value; break;
      case 'layoutDensity': _layoutDensity = value; break;
      case 'iconSize': _iconSize = value; break;
      case 'enableThumbnails': _enableThumbnails = value; break;
      case 'imgThumbs': _imgThumbs = value; break;
      case 'vidThumb': _vidThumb = value; break;
      case 'pdfThumbs': _pdfThumbs = value; break;
      case 'albumCovers': _albumCovers = value; break;
      case 'apkIcons': _apkIcons = value; break;
      case 'archiveThumbs': _archiveThumbs = value; break;
      case 'thumbnailQuality': _thumbnailQuality = value; break;
      case 'wifiOnlyThumbs': _wifiOnlyThumbs = value; break;
      case 'chargeOnlyThumbs': _chargeOnlyThumbs = value; break;
      case 'defaultLayout': _defaultLayout = value; break;
      case 'rememberLayout': _rememberLayout = value; break;
      case 'showStorageBars': _showStorageBars = value; break;
      case 'showItemCount': _showItemCount = value; break;
      case 'showExtensions': _showExtensions = value; break;
      case 'showFileSize': _showFileSize = value; break;
      case 'showDateModified': _showDateModified = value; break;
      case 'showTimeModified': _showTimeModified = value; break;
      case 'showTypeLabel': _showTypeLabel = value; break;
      case 'showFullPath': _showFullPath = value; break;
      case 'sizeFormat': _sizeFormat = value; break;
      case 'dateFormat': _dateFormat = value; break;
      case 'startupLocation': _startupLocation = value; break;
      case 'openLastSession': _openLastSession = value; break;
      case 'defaultOpenAction': _defaultOpenAction = value; break;
      case 'singleTapOpen': _singleTapOpen = value; break;
      case 'showHiddenFiles': _showHiddenFiles = value; break;
      case 'dimHiddenFiles': _dimHiddenFiles = value; break;
      case 'autoRefresh': _autoRefresh = value; break;
      case 'confirmDelete': _confirmDelete = value; break;
      case 'confirmOverwrite': _confirmOverwrite = value; break;
      case 'confirmLargeMove': _confirmLargeMove = value; break;
      case 'largeFileThreshold': _largeFileThreshold = value; break;
      case 'showProgressDialog': _showProgressDialog = value; break;
      case 'searchSubfolders': _searchSubfolders = value; break;
      case 'searchHidden': _searchHidden = value; break;
      case 'rememberSearches': _rememberSearches = value; break;
      case 'defaultArchiveFormat': _defaultArchiveFormat = value; break;
      case 'archiveCompressionLevel': _archiveCompressionLevel = value; break;
      case 'defaultEncryption': _defaultEncryption = value; break;
      case 'autoExtractDownloads': _autoExtractDownloads = value; break;
      case 'deleteSourceAfterCompress': _deleteSourceAfterCompress = value; break;
      case 'bgIndexing': _bgIndexing = value; break;
      case 'autoScanMedia': _autoScanMedia = value; break;
      case 'parallelOps': _parallelOps = value; break;
      case 'lowMemoryMode': _lowMemoryMode = value; break;
      case 'longPressDuration': _longPressDuration = value; break;
      case 'enableSwipe': _enableSwipe = value; break;
      case 'swipeLeft': _swipeLeft = value; break;
      case 'swipeRight': _swipeRight = value; break;
      case 'hapticFeedback': _hapticFeedback = value; break;
      case 'debugLogs': _debugLogs = value; break;
      case 'experimentalFeatures': _experimentalFeatures = value; break;
    }
    _prefs.setString(key, value is String ? value : value.toString());
    if (value is bool) _prefs.setBool(key, value);
    if (value is int) _prefs.setInt(key, value);
    notifyListeners();
  }

  void resetToDefaults() {
    _prefs.clear();
    _theme = 'Simple Light';
    _darkMode = false;
    _followSystemTheme = true;
    _animationIntensity = 'Full';
    _layoutDensity = 'Comfortable';
    _iconSize = 'Medium';
    _enableThumbnails = true;
    _imgThumbs = true;
    _vidThumb = true;
    _pdfThumbs = true;
    _albumCovers = true;
    _apkIcons = true;
    _archiveThumbs = true;
    _thumbnailQuality = 'Balanced';
    _wifiOnlyThumbs = false;
    _chargeOnlyThumbs = false;
    _defaultLayout = 'List';
    _rememberLayout = true;
    _showStorageBars = true;
    _showItemCount = true;
    _showExtensions = true;
    _showFileSize = true;
    _showDateModified = true;
    _showTimeModified = false;
    _showTypeLabel = false;
    _showFullPath = false;
    _sizeFormat = 'Human readable';
    _dateFormat = 'Relative';
    _startupLocation = 'Internal storage';
    _openLastSession = false;
    _defaultOpenAction = 'Open file';
    _singleTapOpen = true;
    _showHiddenFiles = false;
    _dimHiddenFiles = true;
    _autoRefresh = true;
    _confirmDelete = true;
    _confirmOverwrite = true;
    _confirmLargeMove = true;
    _largeFileThreshold = 500;
    _showProgressDialog = true;
    _searchSubfolders = true;
    _searchHidden = false;
    _rememberSearches = true;
    _defaultArchiveFormat = 'ZIP';
    _archiveCompressionLevel = 'Balanced';
    _defaultEncryption = 'None';
    _autoExtractDownloads = false;
    _deleteSourceAfterCompress = false;
    _bgIndexing = true;
    _autoScanMedia = true;
    _parallelOps = '2';
    _lowMemoryMode = false;
    _longPressDuration = 'Default';
    _enableSwipe = true;
    _swipeLeft = 'Delete';
    _swipeRight = 'Details';
    _hapticFeedback = true;
    _debugLogs = false;
    _experimentalFeatures = false;
    notifyListeners();
  }
}
