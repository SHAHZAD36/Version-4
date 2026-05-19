# Chaudhary Traders - Snack Distribution Management App

A production-ready Android application built with Flutter for a snack distribution business in Pakistan.

## Features

- **Authentication**: PIN-based login and biometric support.
- **Dashboard**: Real-time analytics, sales summaries, and low stock alerts.
- **Product Management**: Full inventory control with stock auto-updates.
- **Customer Management**: Ledger tracking and balance management.
- **Sales Management**: Invoice generation and automated stock/balance updates.
- **Cash Collection**: Recording payments and updating customer balances.
- **Expense Management**: Tracking business costs.
- **Cash Book**: Daily cash reconciliation.
- **Reports**: Professional PDF and Excel reports for sales, stock, and profit/loss.
- **Offline Support**: Fully functional offline using SQLite.
- **Bilingual**: Supports Urdu and English.

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Architecture**: Clean Architecture (Modular)
- **UI**: Material 3

## Setup Instructions

1.  **Prerequisites**:
    - Flutter SDK (latest stable)
    - Android Studio / VS Code
    - Android Emulator or Physical Device

2.  **Installation**:
    ```bash
    git clone <repository-url>
    cd chaudhary_traders
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

4.  **Default Login**:
    - PIN: `1234`

## Project Structure

- `lib/core`: Common utilities, constants, and themes.
- `lib/features`: Modular feature implementations (Auth, Dashboard, Products, etc.).
- `lib/features/<feature>/data`: Models and repository implementations.
- `lib/features/<feature>/domain`: Entities and repository interfaces.
- `lib/features/<feature>/presentation`: UI screens, widgets, and providers.

## Building for Production

To generate a release APK:
```bash
flutter build apk --release
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.
