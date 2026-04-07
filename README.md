# Ftarna - Breakfast Ordering App 🍳

A fast, modern, and reliable breakfast ordering app for teams built with Flutter and Firebase.

## Features

### User Features
- ✅ Login via email/password
- ✅ Select menu items with quantity
- ✅ Submit order
- ✅ View own order
- ✅ Repeat last order
- ✅ Receive notifications

### Admin Features
- ✅ Open / Close Session
- ✅ Manage Menu (Add / Edit / Archive items)
- ✅ View all orders with aggregated items summary
- ✅ Mark as Paid / Cancel orders
- ✅ Enter delivery fee or total bill

### Multi-language Support
- 🇺🇸 English
- 🇪🇬 Arabic (العربية)

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Firebase Auth** - Email authentication
- **Cloud Firestore** - Real-time database
- **Firebase Cloud Messaging** - Push notifications
- **Bloc/Cubit** - State management
- **Clean Architecture** - Layered architecture pattern

## Setup Instructions

### 1. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication → Email/Password sign-in
3. Enable Cloud Firestore
4. Add your apps and download config files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

### 2. Install & Run

```bash
flutter pub get
flutter run
```

### 3. Create Admin User

After creating a user, set `isAdmin: true` in Firestore `users` collection.
