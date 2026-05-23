# Labour Party

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg) ![Flutter](https://img.shields.io/badge/flutter-3.24.0-02569B.svg?logo=flutter) ![Architecture](https://img.shields.io/badge/architecture-Clean-success.svg) ![Database](https://img.shields.io/badge/database-Hive-orange.svg) ![Platform](https://img.shields.io/badge/platform-Android-3DDC84.svg?logo=android)

**Labour Party** is an enterprise-grade, **100% offline-first** Flutter application engineered to manage and track labour trips. It is strictly built with robust offline reliability to provide consistent on-site operation, regardless of internet connectivity.

## 📱 App Introduction

This application was engineered to completely eradicate the problem of managing work trips and labor allocations in environments where cloud-based tools fail due to unstable or nonexistent internet connections.

Built exclusively with a local-first philosophy, Labour Party ensures absolute data integrity through device-bound storage and deterministic trip numbering rules. It bridges the gap between field mobility and stable record-keeping, serving as a dedicated companion for dispatching and on-site workforce management.

## ✨ Features

- **Dashboard:** A central hub showing the current active session, morning and evening trip splits, total trip counts, and real-time labour presence.
- **Trip Continuity Engine:** A robust, automated system that intelligently calculates trip chronologies, protecting historical trips and seamlessly continuing trip counts from Morning sessions into Evening sessions.
- **Labour Tracking:** Real-time logging of individual labor presence per trip with one-tap auto-copy mechanisms to quickly instantiate subsequent trips with the same workforce configurations.
- **Backup & Restore:** Military-grade local JSON data exporting and importing capabilities. Employs comprehensive memory loading verifications before modifying databases, preventing catastrophic data loss or corruption.
- **Details:** Granular views detailing historical trips, work configurations, and individual labor details.
- **Settings:** Extensive management for platform rules, configurations, and data restoration endpoints.
- **Offline Operation:** Guaranteed 100% local operation via Hive boxes, absolutely zero dependencies on cloud infrastructure or APIs.

## 🏗️ Architecture Overview

The repository adheres stringently to **Clean Architecture** patterns to ensure maximum long-term maintainability.

- **Presentation:** Thin UI widgets utilizing pure Material 3 and professional glassmorphism that only render data.
- **State Management:** Fully managed by `flutter_bloc`. BLoC orchestrates all workflows and state changes safely and synchronously.
- **Domain:** Houses pure business rules inside UseCases (`CalculateNextTripNumberUseCase`). UI widgets contain zero business logic.
- **Data:** Implements local repositories feeding off **Hive**. Safe backup handling is done purely in-memory before persistent writes.

## 🛠️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Manash07Bhoi/LABOUR-PARTY-2.git
   cd LABOUR-PARTY-2
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation (if modifying data models):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application:**
   ```bash
   flutter run --release
   ```

## 📁 Project Structure

```text
lib/
├── config/             # Environment, Routing, and DI logic (get_it)
├── core/               # Shared utilities, Hive setup, and base architectures
├── features/           # Feature-based folder structure
│   ├── dashboard/      # Primary dashboard and visual stats
│   ├── details/        # Historical data visualization and specific trip lists
│   ├── settings/       # App settings, backups, restorations
│   └── work/           # Work/Trip allocation, UseCases, BLoCs, and Repositories
└── theme/              # Centralized Material 3 premium UI logic
```

## 🧪 Testing

The testing suite acts as the final gatekeeper for production releases.

- **Run all tests:**
  ```bash
  flutter test
  ```
- **Directory Structure:** Tests are strictly segregated into `unit/`, `widget/`, and `integration/`.

## 📦 Release

Builds must occur post RCA (Release Candidate Acceptance).

- **Build APK:**
  ```bash
  flutter build apk --release
  ```
- **Build AppBundle:**
  ```bash
  flutter build appbundle
  ```

## 📚 Documentation Links

Comprehensive engineering documentation has been prepared to ensure seamless hand-offs and product continuity.

- [**Product Overview**](docs/PRODUCT_OVERVIEW.md)
- [**Architecture**](docs/ARCHITECTURE.md)
- [**Business Rules**](docs/BUSINESS_RULES.md)
- [**Database**](docs/DATABASE.md)
- [**Design System**](docs/DESIGN_SYSTEM.md)
- [**Memory Bank**](docs/MEMORY_BANK.md)
- [**Release**](docs/RELEASE.md)
- [**Testing**](docs/TESTING.md)
- **[See all docs in `docs/`](docs/)**

## 👥 Credits
Engineered by the Labour Party Development Team.
