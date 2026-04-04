Harshal Marathe
Mayur Chikhale
Vedant Mehar
Aum Mishra

# CivicCore (CivicSense)

Smart civic complaint management platform built with Flutter and Firebase.

## Project Overview

CivicCore is a multi-role complaint lifecycle system for urban service departments. It supports:

- Citizen complaint registration with geo-location and image capture
- Officer task handling with hierarchy-aware visibility
- Admin analytics, reports, escalations, and staff management
- SLA-aware escalation flows and clustering support

The app is configured for Firebase project:

- `civicsense-b653c` (from `firebase.json` and FlutterFire options)

## Main Roles

- Citizen (`CITIZEN`)
- Officer (`OFFICER` + department hierarchy roles)
- Admin (`ADMIN` / `OFFICE_ADMIN`)

## Key Features

### Citizen Module

- Report issue flow with image + GPS support
- Personal complaint history
- Profile and dashboard views

### Officer Module

- Officer dashboard and task management
- Hierarchy/department-based complaint visibility
- Status transitions and escalation participation

### Admin Module

- Complaints overview and actioning
- Escalation logs
- Staff management
- Analytics dashboard (charts)
- CSV reports download/export

### Authentication and Routing

- Firebase Authentication-based session model
- Auth wrapper routes user by role after app start
- Admin direct-open mode implemented in login flow (current behavior)

## Tech Stack

- Flutter (Dart, SDK `^3.9.0`)
- Firebase:
  - Auth
  - Cloud Firestore
  - Cloud Storage
  - Cloud Functions
  - Firebase Messaging
- Provider for state management
- Additional packages:
  - `fl_chart`, `geolocator`, `flutter_map`, `image_picker`, `path_provider`, `intl`, `uuid`

See full dependency list in [pubspec.yaml](pubspec.yaml).

## Repository Structure

Top-level highlights:

- [lib](lib)
- [android](android)
- [ios](ios)
- [web](web)
- [windows](windows)
- [linux](linux)
- [macos](macos)
- [functions](functions)
- [assets](assets)
- [test](test)

Important app areas:

- [lib/main.dart](lib/main.dart)
- [lib/screens/auth](lib/screens/auth)
- [lib/screens/citizen](lib/screens/citizen)
- [lib/screens/officer](lib/screens/officer)
- [lib/screens/admin](lib/screens/admin)
- [lib/services](lib/services)
- [lib/models](lib/models)
- [lib/widgets/auth_wrapper.dart](lib/widgets/auth_wrapper.dart)

## Firebase and Security

### Firebase Config Files

- [firebase.json](firebase.json)
- [firestore.rules](firestore.rules)
- [firestore.indexes.json](firestore.indexes.json)
- [storage.rules](storage.rules)
- [lib/firebase_options.dart](lib/firebase_options.dart)

### Notes

- Firestore rules currently allow public reads for `DEPARTMENTS`, `OFFICES`, and `USERS` to support pre-auth role/office/account selection flows.
- Admin/staff write behavior is guarded via helper checks in rules for authenticated admin users.

Review and harden rules for production before release.

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK compatible with Flutter
- Firebase CLI installed (`npm i -g firebase-tools`)
- Android Studio / Xcode / device emulators as needed

### Install Dependencies

```bash
flutter pub get
```

### Firebase Login and Project Selection

```bash
firebase login
firebase use --add
```

Recommended deploy style to avoid wrong target project:

```bash
firebase deploy --only firestore:rules --project civicsense-b653c
```

### Run the App

```bash
flutter run
```

## Build and Quality Commands

### Analyze

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Android Debug Build

```bash
flutter build apk --debug
```

## Data and Seed Assets

Project includes CSV assets/scripts used during development and admin/officer workflows:

- [officers_data.csv](officers_data.csv)
- [civic_complaints.csv](civic_complaints.csv)
- [unique_complaint.csv](unique_complaint.csv)
- [scripts](scripts)
- [tmp](tmp)

## Current Implementation Notes

- Office-wise admin scoping has been integrated into complaints/escalation/reporting flows.
- Admin login UI supports department and office selection.
- Admin direct-open flow is enabled currently from login (no credential prompt for admin path).

If you want production-safe behavior, disable direct-open mode and require credential auth for admin again.

## Troubleshooting

### Permission Denied on Office/Department Queries

- Ensure latest rules are deployed to the correct Firebase project:

```bash
firebase deploy --only firestore:rules --project civicsense-b653c
```

### Wrong Firebase Project Deployment

- Check default in `.firebaserc`
- Prefer explicit `--project civicsense-b653c` for deploy commands

## License

Internal/academic project usage unless otherwise specified.
