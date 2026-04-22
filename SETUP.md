# BiasMitra - Setup Guide

## 📱 Project Overview
**BiasMitra** is an AI fairness auditing platform for Solution Challenge 2026, designed to detect and mitigate bias in AI decisions for government schemes.

- **Tech Stack**: Flutter (Web + Mobile)
- **Backend**: Firebase (Auth, Firestore, Gemini)
- **Color Scheme**: Indian Heritage (Saffron 🧡, Green 💚, Blue 💙)
- **Tagline**: "Unbiased AI for Bharat"

---

## 🚀 Quick Start

### Step 1: Install Flutter & Dependencies (if not already done)

```bash
# Check if Flutter is installed
flutter --version

# If not installed, download from https://flutter.dev/docs/get-started/install

# Update Flutter
flutter upgrade
```

### Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a new project"** or select an existing one
3. Enter project name: `bias-mitra-solution-challenge`
4. Enable Google Analytics (optional)
5. Click **Create Project**

### Step 3: Configure Firebase for Flutter

```bash
# Install FlutterFire CLI (if not installed)
dart pub global activate flutterfire_cli

# Configure Firebase for all platforms
flutterfire configure --project=bias-mitra-solution-challenge

# Select platforms:
# - Android (yes)
# - iOS (yes)
# - Web (yes)
# - Windows (yes, optional but recommended)
```

This command will automatically generate `firebase_options.dart` with your Firebase credentials, replacing the template file.

### Step 4: Enable Firebase Authentication

In [Firebase Console](https://console.firebase.google.com):

1. Navigate to **Authentication** → **Sign-in method**
2. Enable:
   - ✅ **Email/Password**
   - ✅ **Google** (set up OAuth credentials)
   - ⚠️ For Google Sign-In, add your app URLs to authorized domains

### Step 5: Create Firestore Database

In [Firebase Console](https://console.firebase.google.com):

1. Go to **Firestore Database**
2. Click **Create Database**
3. Select **Start in test mode** (for development)
4. Choose region: `asia-south1` (India)
5. Click **Enable**

### Step 6: Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click **Create API Key**
3. Copy the key
4. Create a `.env` file in project root (for production apps):
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

### Step 7: Install Dependencies

```bash
# Navigate to project directory
cd Bias_Mitra

# Get all Flutter packages
flutter pub get

# Build for web (optional, for web development)
flutter pub global activate webdev
```

### Step 8: Run the App

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web (Chrome):**
```bash
flutter run -d chrome
```

**For Windows:**
```bash
flutter run -d windows
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants.dart        # Colors, strings, configuration
│   └── theme.dart            # Material theme configuration
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart       # Login UI
│   │   │   └── signup_screen.dart      # Sign-up UI
│   │   └── services/
│   │       └── auth_service.dart       # Firebase auth logic
│   └── dashboard/
│       ├── screens/
│       │   └── dashboard_screen.dart   # Main dashboard
│       └── widgets/
│           └── scheme_card.dart        # Reusable scheme card
├── firebase_options.dart     # Firebase configuration (auto-generated)
└── main.dart                 # App entry point
```

---

## 🎨 UI/UX Highlights

### Color Palette
- **Primary Blue** (`#1E3A8A`): Trust & Technology
- **Secondary Green** (`#10B981`): Harmony & Growth
- **Accent Saffron** (`#FF6B35`): Hope & Energy

### Screens
1. **Login Screen**: Beautiful authentication with balance icon 🏛️
2. **Sign-Up Screen**: User registration
3. **Dashboard Screen**: Grid of government schemes (PM-KISAN, Scholarships, Bank Loans, Ujjwala)
4. **Scheme Cards**: Interactive cards with gradients & animations

---

## 🔐 Firebase Security Rules (for production)

For **Authentication Rules** in Firestore:
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only owner can read/write
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Audits collection - only owner can read/write
    match /audits/{document=**} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^2.24.0 | Firebase initialization |
| `firebase_auth` | ^4.14.0 | Authentication |
| `google_sign_in` | ^6.1.0 | Google OAuth |
| `cloud_firestore` | ^4.14.0 | Database |
| `google_generative_ai` | ^0.4.0 | Gemini AI |
| `provider` | ^6.0.0 | State management |
| `google_fonts` | ^6.1.0 | Typography |
| `fl_chart` | ^0.64.0 | Data visualization |
| `file_picker` | ^6.1.0 | File selection |
| `csv` | ^5.1.0 | CSV parsing |
| `pdf` | ^3.10.0 | PDF export |
| `flutter_tts` | ^0.10.0 | Text-to-speech |

---

## 🐛 Troubleshooting

### Issue: `firebase_options.dart` not found
**Solution**: Run `flutterfire configure` again

### Issue: Google Sign-In fails on Web
**Solution**:
1. Go to Firebase Console → Project Settings
2. Add your dev server URLs to authorized redirect URIs
3. Example: `http://localhost:7357`, `http://localhost:54321`

### Issue: Firestore permission denied
**Solution**: Check Firestore security rules (use test mode for development)

### Issue: Build fails on Windows
**Solution**:
```bash
flutter clean
flutter pub get
flutter run -d windows
```

---

## 📋 Next Steps

1. ✅ Complete Firebase setup
2. 🔄 Implement audit functionality
3. 🧠 Integrate Gemini API for bias detection
4. 📊 Add data visualization
5. 🎯 Deploy to Firebase Hosting (Web)
6. 📱 Build APK/IPA for mobile

---

## 🤝 Contributing

Follow clean code principles:
- Use meaningful variable names
- Add comments for complex logic
- Follow Flutter naming conventions
- Test across platforms before merging

---

## 📝 License

BiasMitra - Developed for Solution Challenge 2026

**"Unbiased AI for Bharat" 🇮🇳**
