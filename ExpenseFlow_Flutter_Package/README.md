# ExpenseFlow — Offline-First High-Performance Expense Tracker

A modern, offline-first mobile expense tracker built with Flutter, SQLite, Material 3, and Glassmorphism. Engineered for 60fps animations, interactive drill-down analytics, customizable dynamic themes, biometric lock, tactile haptic feedback, and CSV/PDF financial report export.

---

## Key Highlights

- **100% Offline SQLite Architecture**: Zero cloud dependencies, zero latency. Optimized B-Tree indexes on date, category, and mount for instantaneous aggregation queries.
- **Interactive Analytics & Drill-Down**:
  - **Animated Pie Chart**: Touch-responsive slice expansion with badges.
  - **Itemized Drill-Down**: Tapping any slice opens a glassmorphic bottom sheet detailing all transactions for that category.
  - **Spline Trend Line Chart**: Smooth cubic curves with Daily, Monthly, and Yearly view toggles.
- **Theme Engine (5 Presets + Custom Color Creator)**:
  - Presets: *Emerald Wealth*, *Midnight Sapphire*, *Obsidian Gold*, *Rose Luxury*, *Cyber Amethyst*.
  - *Custom Theme Creator*: Pick arbitrary Primary & Accent colors to dynamically re-theme the entire application.
  - Dark / Light Glassmorphism modes with backdrop blur (ImageFilter.blur).
- **Tactile UX & Gestures**:
  - Dismissible swipe-to-delete with red glass background, tactile vibration, and instant undo snackbar.
  - Haptic feedback on buttons, inputs, and chart interactions with a dedicated settings toggle.
  - Animated Splash Screen with biometric authentication gate.
- **Security & Data Portability**:
  - Biometric App Lock (Fingerprint / Face ID).
  - RFC 4180 CSV export.
  - Multi-page formatted PDF report with executive summary KPIs, category breakdown table, and itemized ledger.

---

## Project Structure

`
expense_flow/
├── pubspec.yaml
├── README.md
├── lib/
│   ├── main.dart                                # MultiProvider app entrypoint
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart              # SQLite schema & storage keys
│   │   │   └── categories.dart                 # Category models, colors & icons
│   │   ├── theme/
│   │   │   ├── app_theme.dart                  # Material 3 ThemeData generator
│   │   │   ├── theme_presets.dart              # 5 Built-in presets definitions
│   │   │   ├── theme_provider.dart             # Dynamic theme state manager
│   │   │   └── glass_container.dart            # Glassmorphism container widget
│   │   ├── services/
│   │   │   ├── database_service.dart           # High-speed SQLite CRUD & rollups
│   │   │   ├── haptic_service.dart             # Centralized tactile feedback
│   │   │   ├── biometric_service.dart          # Local Auth biometrics manager
│   │   │   └── export_service.dart             # CSV & Multi-page PDF generator
│   ├── models/
│   │   ├── expense.dart                        # Expense entity model
│   │   ├── category_stat.dart                  # Aggregated category metrics
│   │   └── trend_point.dart                    # Time-series trend data point
│   ├── providers/
│   │   ├── expense_provider.dart               # Expense & analytics state
│   │   └── settings_provider.dart              # Haptics, biometrics & currency
│   └── screens/
│       ├── splash/
│       │   └── splash_screen.dart              # Animated splash & auth gate
│       ├── main_navigation_screen.dart         # Floating glass bottom bar
│       ├── dashboard/
│       │   ├── analytics_dashboard_screen.dart # Interactive analytics dashboard
│       │   └── widgets/
│       │       ├── interactive_pie_chart.dart  # Fl_chart pie with touch & badges
│       │       ├── trend_line_chart.dart       # Spline curve line chart
│       │       ├── drill_down_sheet.dart       # Slice itemized records sheet
│       │       └── metric_card.dart            # Glassmorphism KPI card
│       ├── transactions/
│       │   ├── transaction_list_screen.dart    # Search & date filtered ledger
│       │   ├── add_edit_expense_sheet.dart     # Frictionless expense input modal
│       │   └── widgets/
│       │       └── expense_tile.dart           # Swipe-to-delete expense tile
│       ├── theme/
│       │   └── theme_customizer_screen.dart    # 5 Presets + Custom Color picker
│       └── settings/
│           └── settings_screen.dart            # Security, Haptics, CSV/PDF export
`

---

## Building & Compiling the Shareable APK

### 1. Prerequisites
- Flutter SDK >=3.0.0
- Android Studio / Android SDK (API 34+)

### 2. Install Dependencies
`ash
flutter pub get
`

### 3. Build Universal Release APK
To compile a universal APK that can be shared and installed directly on any Android phone:
`ash
flutter build apk --release
`
The output APK will be located at:
uild/app/outputs/flutter-apk/app-release.apk

### 4. Build Optimized ABI-Split APKs (Smaller file size)
`ash
flutter build apk --split-per-abi
`
Generated APKs (e.g. pp-arm64-v8a-release.apk) will be in uild/app/outputs/flutter-apk/.

---

## Android Permissions (Added automatically via plugins)
- USE_BIOMETRIC / USE_FINGERPRINT for Biometric Lock (local_auth)
- VIBRATE for Haptic Feedback (HapticFeedback)
- WRITE_EXTERNAL_STORAGE / READ_EXTERNAL_STORAGE for CSV & PDF export sharing
