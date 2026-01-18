# VidyuSaathi

VidyuSaathi is a government-grade mobile application for Mahavitran, designed to assist citizens and officers in managing electricity services and issues.

## Tech Stack
- **Frontend**: Flutter (Material 3)
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)

## Features
- **Citizen**: Registration, Login, Report Issue (Location + Images), My Reports, Profile.
- **Officer**: Login (Unique ID), Dashboard (Metrics), Task Management (Strict Lifecycle), Notifications.

## Setup Instructions

1. **Firebase Setup**:
   - Create a project in Firebase Console.
   - Enable Authentication (Email/Password).
   - Enable Firestore Database.
   - Enable Storage.
   - Download `google-services.json` and place it in `android/app/`.
   - (Optional) Configure iOS `GoogleService-Info.plist`.

2. **Dependencies**:
   - Run `flutter pub get` to install dependencies.

3. **Run**:
   - Run `flutter run` to start the application.

## Project Structure
- `lib/core`: Theme, Constants.
- `lib/models`: Data models (User, Ticket).
- `lib/screens`: UI Screens (Auth, Citizen, Officer).
- `lib/services`: Firebase integrations.
- `functions`: Cloud Functions for notifications.

## Strict Implementation Notes
- **Lifecycle**: Ticket status transitions are manual and strict (Created -> Assigned -> ... -> Closed).
- **Roles**: Hierarchy and permissions are enforced as per requirements.
- **UI**: Uses Material 3 for a professional, government-grade aesthetic.
