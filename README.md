
# 🎓 AMS Student - Attendance Monitoring System

> A modern Flutter mobile application for students to manage their attendance efficiently and seamlessly.

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Screenshots

| Login | Dashboard | Scanner | Profile |
|-------|-----------|---------|---------|
| ![Login](screenshots/login.png) | ![Dashboard](screenshots/dashboard.png) | ![Scanner](screenshots/scanner.png) | ![Profile](screenshots/profile.png) |

## ✨ Features

### 🔐 Authentication
- Secure login with username/password
- Session management
- Auto-logout on token expiration

### 📊 Dashboard
- View all enrolled subjects
- See upcoming classes
- Track attendance history
- Subject details (schedule, room, instructor)
- Real-time updates

### 📷 QR Code Scanner
- Fast and accurate QR scanning
- Strict validation (full QR code detection)
- Instant attendance recording
- Visual feedback on success/failure
- Camera permission handling

### 👤 Profile Management
- View personal information
- Edit profile (first name, last name, username)
- View student ID and email
- Change password
- Notification settings
- Logout functionality

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a clear separation of concerns:

```
lib/
├── core/           # App configuration & utilities
├── data/           # Models, repositories & services
├── presentation/   # UI screens & widgets
└── routes/         # Navigation
```

### Design Pattern
- **MVVM (Model-View-ViewModel)** for state management
- **Repository Pattern** for data access
- **Service Layer** for business logic

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ams_student.git
   cd ams_student
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **Update API endpoint** in `lib/data/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'https://your-api-url.com/api';
   ```

2. **Configure assets** in `pubspec.yaml`:
   ```yaml
   assets:
     - assets/images/
     - assets/icons/
   ```

## 📦 Dependencies

### Core Dependencies
- **mobile_scanner** (^6.0.10) - QR code scanning
- **flutter_local_notifications** (^18.0.1) - Push notifications
- **intl** (^0.19.0) - Internationalization & date formatting
- **provider** (^6.1.1) - State management
- **http** (^1.2.0) - HTTP requests
- **shared_preferences** (^2.2.2) - Local storage

### Dev Dependencies
- **flutter_lints** (^5.0.0) - Code quality

## 🗂️ Project Structure

```
ams_student/
│
├── lib/
│   ├── core/               # Core functionality
│   │   ├── constants/      # App constants
│   │   ├── theme/          # App theme
│   │   └── utils/          # Utility functions
│   │
│   ├── data/               # Data layer
│   │   ├── models/         # Data models
│   │   ├── repositories/   # Data repositories
│   │   └── services/       # API & local services
│   │
│   ├── presentation/       # UI layer
│   │   ├── screens/        # App screens
│   │   └── widgets/        # Reusable widgets
│   │
│   └── routes/             # Navigation
│
├── assets/                 # Images, icons, etc.
├── test/                   # Unit & widget tests
└── pubspec.yaml           # Project dependencies
```

## 🎨 UI/UX Design

### Color Palette
- **Primary**: `#1E3A8A` (Deep Blue)
- **Secondary**: `#3B82F6` (Blue)
- **Accent**: `#60A5FA` (Light Blue)
- **Background**: `#F8FAFC` (Light Gray)
- **Text**: `#1E3A8A` (Deep Blue)

### Design System
- Modern glassmorphism effects
- Smooth animations and transitions
- Consistent spacing (8px grid)
- Material Design 3 components
- Responsive layouts (mobile, tablet, desktop)

## 🔧 Development

### Run in Debug Mode
```bash
flutter run --debug
```

### Run in Release Mode
```bash
flutter run --release
```

### Build APK
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

### Run Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
dart format .
```

## 📱 Platform Support

| Platform | Status | Version |
|----------|--------|---------|
| Android  | ✅ Supported | API 21+ |
| iOS      | ✅ Supported | iOS 12+ |
| Web      | ⏳ Coming Soon | - |
| Desktop  | ⏳ Coming Soon | - |

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Comment complex logic
- Write unit tests for new features

## 🐛 Bug Reports

Found a bug? Please open an issue with:
- Description of the bug
- Steps to reproduce
- Expected behavior
- Screenshots (if applicable)
- Device information

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Your Name** - Lead Developer - [@yourusername](https://github.com/yourusername)

## 📧 Contact

For questions or support, please contact:
- Email: your.email@example.com
- GitHub: [@yourusername](https://github.com/yourusername)
- Website: [your-website.com](https://your-website.com)

## 🙏 Acknowledgments

- ACLC College for the project opportunity
- Flutter team for the amazing framework
- Open source community for the packages used

## 📱 Download

### Android
[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png" alt="Get it on Google Play" height="80">](https://play.google.com/store)

### iOS
[<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on App Store" height="54">](https://apps.apple.com)

---

<p align="center">Made with ❤️ by [Your Name]</p>
<p align="center">© 2024 ACLC College. All rights reserved.</p>
