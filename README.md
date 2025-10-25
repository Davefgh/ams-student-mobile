# AMS Student - Attendance Monitoring System

A modern Flutter application for student attendance monitoring with a beautiful glassmorphism UI design.

## 🎨 Features

- **Beautiful Login Screen**: Glassmorphism design with gradient background
- **Clean Architecture**: Well-organized project structure
- **Modern UI**: Material 3 design with custom theming
- **QR Code Scanning**: Mobile scanner integration for attendance
- **Push Notifications**: Local notifications support
- **Cross-Platform**: Support for Android, iOS, Web, Windows, macOS, and Linux

## 📱 Screenshots

The app features a stunning login screen with:
- Blue gradient background
- Glassmorphism login card
- Red diamond logo with school icon
- Clean input fields with proper validation
- Smooth animations and transitions

## 🏗️ Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and configuration
│   │   └── app_constants.dart
│   ├── theme/             # App theming
│   │   └── app_theme.dart
│   ├── services/           # Core services
│   └── utils/             # Utility functions
├── data/                   # Data layer
│   ├── local/             # Local data sources
│   └── remote/            # Remote data sources
├── features/               # Feature modules
│   ├── attendance/        # Attendance feature
│   ├── auth/              # Authentication feature
│   ├── classroom/         # Classroom feature
│   └── profile/           # Profile feature
├── models/                 # Data models
│   ├── attendance.dart
│   ├── student.dart
│   └── subject.dart
├── routes/                 # Navigation routes
│   └── app_routes.dart
├── screens/                # UI screens
│   ├── login_screen.dart
│   ├── student_home_screen.dart
│   ├── in_out_home_screen.dart
│   ├── notifications_screen.dart
│   └── task_letter_screen.dart
├── services/               # App services
│   ├── notification_service.dart
│   ├── notification_service_mobile.dart
│   └── notification_service_web.dart
├── widgets/                # Reusable widgets
│   ├── attendance_card.dart
│   ├── attendance_confirmation_modal.dart
│   ├── custom_button.dart
│   ├── functional_qr_scanner.dart
│   ├── qr_scanner_widget.dart
│   └── student_info_tile.dart
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ams_student
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🎨 Design System

### Colors
- **Primary Blue**: `#2A60B0`
- **Secondary Blue**: `#4A90E2`
- **Accent Red**: `#E53E3E`
- **Background White**: `#FFFFFF`
- **Text Dark**: `#2D3748`
- **Text Light**: `#718096`

### Typography
- **Font Family**: Inter
- **Headings**: Bold weights (600-700)
- **Body Text**: Normal weight (400)

### Spacing
- **XS**: 4px
- **S**: 8px
- **M**: 16px
- **L**: 24px
- **XL**: 32px
- **XXL**: 48px

### Border Radius
- **S**: 8px
- **M**: 12px
- **L**: 16px
- **XL**: 24px

## 🔧 Configuration

### Environment Setup
The app uses environment-specific configurations for different platforms.

### Dependencies
- `mobile_scanner`: QR code scanning
- `flutter_local_notifications`: Push notifications
- `intl`: Internationalization

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please contact the development team.

---

**AMS Student** - Modern attendance monitoring made simple.
