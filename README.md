# 🏛️ BiasMitra - Unbiased AI for Bharat

## 📚 Problem Statement

Artificial Intelligence systems used in government schemes often carry implicit biases that can disadvantage certain groups. **PM-KISAN**, **Scholarship Programs**, **Bank Loans**, and **Ujjwala Yojana** decisions rely on AI models that may discriminate based on caste, gender, income, or region.

## 🎯 Solution

**BiasMitra** is an AI fairness auditing platform that:
- ✅ **Detects** bias in government AI decision-making systems
- ✅ **Analyzes** data for discriminatory patterns
- ✅ **Reports** fairness metrics and risk levels
- ✅ **Mitigates** identified biases through recommendations

**Tagline**: "Unbiased AI for Bharat" 🇮🇳

---

## 💡 Features

### 🔐 Authentication
- Email/Password login & sign-up
- Google OAuth integration
- Secure Firebase Auth

### 📊 Dashboard
- Welcome personalized interface
- Government scheme selection
- Clean grid layout with scheme cards
- Real-time user information

### 🎨 Government Schemes Supported
1. **PM-KISAN** - Direct income support to farmers
2. **Scholarships** - Educational merit programs
3. **Bank Loans** - Credit distribution fairness
4. **Ujjwala Yojana** - LPG connection distribution

### 🔍 Bias Detection (Future Features)
- CSV/Excel data upload
- Pattern analysis with Gemini AI
- Fairness score calculation
- Risk level assessment
- Report generation & download
- PDF/Excel export

### 🎨 Beautiful UI with Indian Colors
- **Primary Blue** - Trust & Technology
- **Secondary Green** - Harmony & Growth
- **Accent Saffron** - Hope & Energy
- Icons.balance logo for fairness symbolism

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Web + Mobile) |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Database** | Cloud Firestore |
| **AI/ML** | Google Gemini API |
| **State Management** | Provider |
| **Data Viz** | FL Chart |
| **File Handling** | file_picker, CSV, PDF |
| **Accessibility** | Flutter TTS |

---

## 📱 Platforms

- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Android**
- ✅ **iOS**
- ✅ **Windows**
- ✅ **macOS**
- ✅ **Linux**

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.0+)
- Dart SDK
- Firebase Account
- Google Developer Account (for OAuth)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/bias-mitra.git
   cd Bias_Mitra
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   flutterfire configure --project=bias-mitra-solution-challenge
   ```
   See [SETUP.md](./SETUP.md) for detailed Firebase setup instructions.

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome

   # Android
   flutter run -d android

   # iOS
   flutter run -d ios
   ```

---

## 📂 Project Structure

```
bias_mitra/
├── lib/
│   ├── core/
│   │   ├── constants.dart        # Colors, strings, configs
│   │   └── theme.dart            # App theme & typography
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── signup_screen.dart
│   │   │   └── services/
│   │   │       └── auth_service.dart
│   │   └── dashboard/
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           └── scheme_card.dart
│   ├── firebase_options.dart     # Firebase config (auto-generated)
│   └── main.dart                 # App entry point
├── pubspec.yaml                  # Flutter dependencies
├── SETUP.md                       # Detailed setup guide
├── .env.example                  # Environment variables template
└── README.md                      # This file
```

---

## 🔑 Key Components

### 📌 Authentication Flow
```
User → Login/SignUp Screen → Firebase Auth → AuthWrapper → Dashboard
                                    ↓
                            Google Sign-In (optional)
```

### 📊 Firestore Database Structure
```
firestore/
├── users/{uid}/
│   ├── email: string
│   ├── name: string
│   └── createdAt: timestamp
├── audits/{auditId}/
│   ├── userId: string
│   ├── schemeName: string
│   ├── biasScore: number
│   ├── riskLevel: string (high/medium/low)
│   ├── dataFile: string (storage path)
│   └── createdAt: timestamp
└── reports/{reportId}/
    ├── auditId: string
    ├── findings: array
    └── recommendations: array
```

---

## 🎨 UI Preview

### Login Screen
- Large balance icon (🏛️)
- Email/Password fields
- Google Sign-In button
- Sign-up link

### Dashboard
- Personalized welcome message
- 4 scheme cards in grid:
  - 🌾 PM-KISAN (Blue)
  - 🎓 Scholarships (Green)
  - 🏦 Bank Loans (Saffron)
  - 🔥 Ujjwala Yojana (Purple)

### Scheme Cards
- Gradient backgrounds
- Icon representation
- Touch animation
- "Audit now" call-to-action

---

## 🔒 Security & Privacy

- ✅ Firebase Auth for secure login
- ✅ Firestore security rules for data protection
- ✅ HTTPS/TLS for data transmission
- ✅ No sensitive data stored locally
- ✅ OAuth 2.0 for Google Sign-In

**Note**: For production, implement proper security rules in Firestore.

---

## 📊 Fairness Metrics

**Fair AI Indicators**:
- Balanced approval rates across demographics
- No statistically significant disparities
- Equal opportunity assessment
- Transparency in decision criteria

**Bias Detection Thresholds**:
- 🔴 **High Risk**: > 0.7 (70%)
- 🟡 **Medium Risk**: 0.4-0.7 (40-70%)
- 🟢 **Low Risk**: < 0.4 (40%)

---

## 🤖 Gemini AI Integration (Future)

```dart
// Bias detection using Gemini API
final analysis = await _geminiService.analyzeBias(data);
// Returns: {
//   biasScore: 0.65,
//   riskLevel: 'medium',
//   findings: ['Gender bias detected in loans', ...],
//   recommendations: ['Adjust approval criteria', ...]
// }
```

---

## 📈 Roadmap

- [ ] **Phase 1**: Authentication & Dashboard (✅ Done)
- [ ] **Phase 2**: Data upload & CSV parsing
- [ ] **Phase 3**: Bias detection with Gemini AI
- [ ] **Phase 4**: Report generation & export
- [ ] **Phase 5**: Advanced analytics & visualizations
- [ ] **Phase 6**: Multi-language support (Hindi, Tamil, etc.)
- [ ] **Phase 7**: Mobile app store deployment
- [ ] **Phase 8**: AI model fine-tuning for Indian context

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Build for production
flutter build web --release
flutter build apk --release
flutter build ipa --release
```

---

## 🐛 Known Issues & Workarounds

| Issue | Status | Workaround |
|-------|--------|-----------|
| Google Sign-In on Web | 🟡 In Progress | Use localhost for dev, configure OAuth URI |
| Firestore cold start | 🟡 Known | Initialize at app startup |
| PDF export on Android | 🟢 Resolved | Use printing package |

---

## 📞 Support & Contribution

### Report a Bug
1. Go to [GitHub Issues](https://github.com/yourusername/bias-mitra/issues)
2. Click "New Issue"
3. Provide detailed reproduction steps

### Contribute
1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m 'Add feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit Pull Request

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Gemini API Docs](https://ai.google.dev/)
- [Material Design 3](https://m3.material.io/)
- [Solution Challenge 2026](https://solutionchallenge.withgoogle.com/)

---

## 📄 License

BiasMitra is open-source and developed for the Google Solution Challenge 2026.

**"Unbiased AI for Bharat"** 🇮🇳

---

## 👇 Quick Commands

```bash
# Setup & Installation
flutter pub get
flutterfire configure

# Development
flutter run -d chrome          # Web
flutter run -d android         # Android
flutter run -d ios             # iOS

# Build Production
flutter build web --release
flutter build apk --release
flutter build ipa --release

# Code Quality
flutter analyze
flutter format lib/
flutter pub outdated
```

---

**Made with ❤️ for Bharat** 🇮🇳
