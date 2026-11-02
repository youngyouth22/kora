# 🌿 Kora — Objective Skin Tracking & Experiment Verdict Engine

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![YouCam AI](https://img.shields.io/badge/Powered%20By-YouCam%20Skin%20AI%20API-FF4081)](https://www.perfectcorp.com)
[![Mastra AI](https://img.shields.io/badge/AI%20Agent-Mastra%20Framework-6366F1)](https://github.com/youngyouth22/kora-skin-coach.git)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20BLoC-success)](https://bloclibrary.dev)
[![Tests](https://img.shields.io/badge/Tests-486%20passed%20(100%25)-brightgreen)](test/)
[![Analysis](https://img.shields.io/badge/Analyze-0%20issues-brightgreen)](analysis_options.yaml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Built for the **YouCam API Skin AI & eCommerce VTO Hackathon** hosted by **Perfect Corp.** on Devpost.

---

## 🌟 Overview

The skincare market is saturated with marketing claims, but consumers lack objective tools to evaluate what actually works for their unique skin. 

**Kora** transforms skincare from guesswork into evidence-based self-care. Combining **YouCam Skin AI** clinical-grade facial analysis with statistical experiment tracking and a specialized **Mastra AI Agent**, Kora helps users benchmark their skin, test cosmetic products over 4 to 8 weeks, and receive definitive, noise-filtered **verdicts** on product efficacy.

Designed with an **offline-first**, **privacy-first**, and **zero-dark-patterns** philosophy:
* 🔬 **100% Honest**: Shows genuine clinical raw scores — never arbitrary inflated scores.
* 🛡️ **Zero Client Secrets**: All YouCam API calls and AI completions run strictly server-side through authenticated Supabase Edge Functions.
* 🤖 **Autonomous Skincare Agent**: Context-aware AI coach powered by the [kora-skin-coach](https://github.com/youngyouth22/kora-skin-coach.git) agent built on the **Mastra** framework.
* 📶 **Offline-First**: Reads and writes instantly to local encrypted SQLite (Drift) with deterministic bi-directional cloud synchronization.
* 🤝 **Empathic Tone**: No guilt-tripping streaks, confirmshaming, or medical diagnoses.

---

## 📸 Key Features

### 1. Weekly Guided Skin Analysis (Powered by YouCam Skin AI)
* **Real-time Capture Quality Gate**: Evaluates lighting conditions, head orientation, and distance using Google MLKit before capturing to ensure reproducible scan quality.
* **16 Clinical Skin Dimensions**: Analyzes pores, texture, wrinkles, spots, redness, firmness, radiance, oiliness, moisture, eye bags, dark circles, and more.
* **Objective Raw Scores**: Rejects artificial score inflation, providing trustworthy benchmarks across weekly scans.

### 2. Cosmetic Experiment Tracker & Scientific Verdicts
* **4 to 8-Week Product Trials**: Isolates new serums, moisturizers, or exfoliants in targeted routines.
* **Noise-Threshold Algorithm**: Distinguishes true skin improvements or declines from natural weekly biological noise and camera variations.
* **Actionable Verdicts**: Provides definitive verdicts (*Clear Improvement*, *Pure Noise*, *Decline*, or *Inconclusive*) to help users decide whether to keep or drop a product.

### 3. Daily Skincare Routine & Idempotent Streak
* **AM / PM Step Checklists**: Tracks daily cleanser, toner, serum, moisturizer, and SPF compliance.
* **Graceful Streak Protection**: Includes 1 automatic monthly "Joker" to forgive missed days without breaking motivation.
* **Idempotent Historical Recalculation**: Recomputes streaks deterministically from raw logs and scans.

### 4. Amie — AI Skincare Coach (Mastra Agent)
* **Powered by Mastra**: Backed by a dedicated TypeScript agent microservice ([kora-skin-coach](https://github.com/youngyouth22/kora-skin-coach.git)) deployed on Render.
* **Context-Aware Assistance**: Direct integration with user scan history, ingredient interactions, and routine compliance.
* **Deterministic Safety Gate**: Red-flag detection rules prevent medical diagnosis, ensuring ethical guidance and active ingredient education (Retinol, Vitamin C, Niacinamide, AHA/BHA).

### 5. Seamless Account & Cross-Device Sync
* **Instant Guest Onboarding**: Users can immediately complete scans and track routines anonymously without mandatory sign-up walls.
* **One-Tap Google Account Linking**: Merges local Drift database records into cloud Supabase storage seamlessly.
* **RevenueCat Pro Subscriptions**: Full integration with RevenueCat for premium paywalls and entitlement management.

---

## 🤖 The AI Engine: Mastra Agent (`kora-skin-coach`)

The conversational intelligence in Kora is powered by a dedicated autonomous agent service built on the [Mastra](https://mastra.ai) framework:

* 📦 **Repository**: [https://github.com/youngyouth22/kora-skin-coach.git](https://github.com/youngyouth22/kora-skin-coach.git)
* 🌐 **Production Host**: `https://kora-skin-coach.onrender.com`
* 🔐 **Secure Cryptographic Authentication**:
  * Requests are signed with an authenticated `MASTRA_API_SECRET` token (`Authorization: Bearer <MASTRA_API_SECRET>`).
  * Injected with caller metadata: `x-user-jwt` and `x-user-id` to respect Supabase Row-Level Security (RLS).
  * The secret token is generated directly from the `kora-skin-coach` repository workspace and configured into the mobile app and Supabase Edge Functions.

---

## 🏗️ Architecture & Tech Stack

Kora strictly adheres to **Clean Architecture** with inward-pointing dependencies and **BLoC** state management.

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/        # Local Drift DB, Remote Edge Functions & Mastra Client
│   ├── models/             # Data transfer objects & JSON/Entity mappers
│   └── repositories/       # Concrete repository implementations
├── domain/
│   ├── entities/           # Pure Dart business models (zero framework dependencies)
│   ├── repositories/       # Abstract repository interfaces
│   └── usecases/           # Single-responsibility use cases
└── presentation/
    ├── bloc/               # FeatureBloc, FeatureEvent, FeatureState (Equatable)
    ├── pages/              # Screen widgets
    └── widgets/            # Reusable UI components
```

```mermaid
flowchart TD
    subgraph MobileApp[Kora Mobile App (Flutter)]
        UI[Presentation Layer / Flutter BLoC] -->|Executes| Domain[Domain Layer / Use Cases]
        Data[Data Layer / Repositories] -->|Implements| Domain
        Data --> LocalDB[(Drift SQLite Local Cache)]
        Data --> SyncEngine[Sync Engine & Outbox FIFO]
        Data --> KoraAiClient[KoraAiApiClient]
    end

    subgraph Backend[Cloud Infrastructure]
        SyncEngine -->|HTTPS / JWT Auth| EdgeFunctions[Supabase Edge Functions]
        EdgeFunctions -->|Private API Key| YouCam[YouCam Skin AI API]
        
        KoraAiClient -->|Bearer MASTRA_API_SECRET| MastraService[Mastra AI Agent Service\nkora-skin-coach]
        EdgeFunctions -->|SSE Stream / Secret Auth| MastraService
    end
```

### Core Technologies
* **Framework**: Flutter 3.x (Dart 3.x)
* **State Management**: `flutter_bloc` & `equatable`
* **Dependency Injection**: `get_it`
* **Local Database**: `drift` (SQLite) with custom DAOs & migrations
* **Cloud & Auth**: `supabase` & `google_sign_in`
* **AI Coach Backend**: [Mastra TypeScript Framework](https://github.com/youngyouth22/kora-skin-coach.git)
* **In-App Purchases**: `purchases_flutter` (RevenueCat)
* **On-Device Vision**: `google_mlkit_face_detection` & `camera`

---

## 🔒 Security, Privacy & API Integrity

* ❌ **No Client-Side Secrets**: Neither YouCam API keys nor master AI LLM tokens exist inside the Flutter client bundle. Reverse-engineering the APK/IPA reveals zero credentials.
* 🛡️ **Edge Functions Proxy**: All requests to YouCam endpoints (`scan_start`, `scan_run`, `scan_status`) execute server-side on Supabase Edge Functions with secret authentication.
* 🔑 **Mastra Token Verification**: Requests to the AI coach microservice require a matching `MASTRA_API_SECRET` token alongside a valid Supabase user JWT.
* 🔐 **Data Privacy**: Selfie images are stored exclusively in private storage buckets with temporary signed URLs (TTL < 15 minutes) and are immediately scrubbed upon account deletion.
* ⚖️ **Compliance**: Strict adherence to wellness boundaries — no diagnostic claims or forbidden medical terminology.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK `^3.13.2` or later
* Dart SDK `^3.x`
* Android Studio / Xcode for mobile emulation
* A Supabase project with Edge Functions enabled
* A deployed or local instance of [kora-skin-coach](https://github.com/youngyouth22/kora-skin-coach.git)

### 1. Clone the Repository
```bash
git clone https://github.com/youngyouth22/kora.git
cd kora
```

### 2. Environment Configuration
Create a `.env` file in the root directory:
```bash
cp .env.example .env
```
Fill in your credentials (matching `.env.example`):
```ini
# YouCam API Credentials (Server-side / Edge Functions template)
YOUCAM_GENERATE_KEY=your_youcam_generate_key_here
YOUCAM_SECRET_KEY=your_youcam_secret_key_here

# Kora Skin Coach AI Agent (Mastra Framework Backend)
# Source code: https://github.com/youngyouth22/kora-skin-coach.git
KORA_AI_BASE_URL=https://kora-skin-coach.onrender.com
# Secret token used to sign and authenticate client requests to the Mastra agent
MASTRA_API_SECRET=your_mastra_api_secret_here

# RevenueCat Webhook Authentication
REVENUECAT_WEBHOOK_AUTH=your_revenuecat_webhook_auth_secret_here

# Google Sign-In & Supabase OAuth
# Web Application Client ID from Google Cloud Console (required on Android Credential Manager)
GOOGLE_SERVER_CLIENT_ID=your_google_server_client_id.apps.googleusercontent.com
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run Code Generation (Drift DB)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Launch the Application
```bash
# Debug mode
flutter run

# Release mode (Android)
flutter run --release
```

---

## 🧪 Testing & Code Quality

Kora maintains a mandatory **Quality Loop** enforced across all features:

```bash
# 1. Format code (80-character line limit)
dart format lib test

# 2. Static analysis (zero errors, zero warnings)
flutter analyze --no-fatal-infos

# 3. Unit, Bloc, and Widget test suite
flutter test
```

### Test Suite Status
```
09:40 +486: All tests passed!
```
* **486 / 486 unit, repository, BLoC, and widget tests passing (100% green)**.
* Exhaustive coverage of domain algorithms:
  * Verdict calculation & biological noise-threshold filtering
  * Streak recalculation, joker consumption, and timezone changes
  * Outbox synchronization & offline-first SQLite conflict resolution (Outbox Wins)
  * Mastra API client signing and payload verification
  * Model ↔ Entity boundary mappers

---

## 👥 Hackathon Submission

* **Competition**: YouCam API Skin AI & eCommerce VTO Hackathon (Devpost)
* **APIs & AI Integrated**:
  * **YouCam Skin AI Diagnostic API**: 16 Clinical Parameters Facial Analysis
  * **Mastra AI Agent ([kora-skin-coach](https://github.com/youngyouth22/kora-skin-coach.git))**: Autonomous Skincare Routine & Ingredients Coach
* **Version**: 1.0.0

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
