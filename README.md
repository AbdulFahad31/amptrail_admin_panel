# AmpTrail Admin Panel

## Overview

AmpTrail Admin Panel is a Flutter Web dashboard for managing EV charging station operations. It supports authenticated admin access, station creation and editing, booking history review, and operational summaries powered by Firebase Authentication and Cloud Firestore.

The app is designed as a focused internal operations tool: Firebase handles identity and realtime data, while Flutter Web provides a responsive desktop-first admin interface suitable for Vercel or Firebase Hosting deployment.

## Features

- Dashboard
- Station Management
- Booking Management
- User Monitoring
- Firebase Authentication
- Firestore Integration

## Technology Stack

- Flutter Web
- Dart
- Firebase Authentication
- Cloud Firestore
- Vercel
- Firebase Hosting

## Architecture

The project uses a simple layered Flutter structure:

- `main.dart` initializes Firebase and switches between the authenticated dashboard and login flow.
- `screens/` contains the admin workflows: login, signup, dashboard, station management, station form, and booking history.
- `services/` wraps Firebase Authentication and Firestore access.
- `models/` defines Firestore-backed station and booking data models.
- `widgets/` contains shared UI such as the sidebar navigation.
- `theme_constants.dart` and `theme_provider.dart` centralize the AmpTrail visual system.

Firestore access is scoped by the current admin user ID for station and booking views. Production authorization should also be enforced in Firestore Security Rules and, for larger teams, with role-based custom claims.

## Folder Structure

```text
amptrail_adminpanel/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── models/
│   │   ├── booking.dart
│   │   └── station.dart
│   ├── screens/
│   │   ├── add_station_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── history_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── station_list_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── firestore_service.dart
│   └── widgets/
│       └── sidebar.dart
├── web/
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── firebase.json
├── vercel.json
├── pubspec.yaml
└── README.md
```

## Installation

1. Install Flutter and enable web support.
2. Install a current Chrome or Chromium browser.
3. Clone the repository.
4. Install dependencies:

```bash
flutter pub get
```

5. Confirm Firebase configuration exists at `lib/firebase_options.dart`.

## Firebase Configuration

1. Create or open the Firebase project for AmpTrail.
2. Enable Firebase Authentication with email/password sign-in.
3. Create the Cloud Firestore database used by the app.
4. Register a web app in Firebase.
5. Generate FlutterFire configuration:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

6. Confirm `DefaultFirebaseOptions.currentPlatform` matches the Firebase project.
7. Configure Firestore Security Rules so only authorized admins can access their allowed station and booking documents.

## Running Locally

```bash
flutter pub get
flutter run -d chrome
```

## Build for Production

```bash
flutter build web --release
```

The production output is generated in `build/web/`.

## Deploy to Vercel

1. Build the web app:

```bash
flutter build web --release
```

2. Deploy `build/web` as the output directory.
3. Keep `vercel.json` at the project root so Flutter Web routes rewrite to `index.html`.
4. In Vercel, set the build command to `flutter build web --release` if Flutter is available in the build image, or deploy the prebuilt `build/web` output from CI.

## Deploy to Firebase Hosting

1. Install Firebase CLI:

```bash
npm install -g firebase-tools
```

2. Sign in:

```bash
firebase login
```

3. Build the app:

```bash
flutter build web --release
```

4. Deploy:

```bash
firebase deploy --only hosting
```

Ensure `firebase.json` points hosting to `build/web`.

## Security Notes

- Firebase web configuration is not a private secret, but Firestore data must be protected with strict Security Rules.
- Do not rely on client-side filtering alone for admin authorization.
- Add role-based access control with Firebase custom claims before adding multiple admin levels.
- Keep generated build files out of source control.
- Avoid storing service account keys, private API keys, `.env` files, or local credentials in the repository.
- Validate station ownership on every write in Security Rules.

## Future Enhancements

- Payment Integration
- Charger Health Monitoring
- Analytics Dashboard
- Notifications
- Multi-Admin Support
- Role-Based Access Control

## Contributors

Abdul Fahad M  
Aditya Manivannan

## License

MIT License
