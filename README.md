# Industrial Monitor

A Flutter app for monitoring and tracking industrial unit parameters with a modern UI, local storage, and cloud sync capabilities.

## Features

### Authentication
- **Email/Password Login**: Secure authentication using Firebase
- **PIN Authentication**: Quick access with a 4-digit PIN
- **PIN Reset**: Simple recovery process for forgotten PINs

### Parameter Monitoring
- **Manual Input**: Easy entry of sensor readings (pressure, temperature, etc.)
- **Local Storage**: Persistent data storage using Hive
- **History Log**: Complete historical record of all parameter readings
- **Data Visualization**: Trend analysis with interactive charts

### Settings & Data Management
- **Theme Options**: Support for light and dark modes (synced with system settings)
- **Data Reset**: Option to clear all locally stored data
- **Cloud Sync**: Firebase integration for optional data backup

### UI Design
- **Modern Interface**: Clean, intuitive design using FlexTheme
- **Responsive Layout**: Optimized for both tablets and phones
- **Streamlined Navigation**: Easy access to all features via bottom navigation or drawer

## Tech Stack

- **Framework**: Flutter & Dart
- **Local Storage**: Hive
- **Authentication & Cloud Storage**: Firebase
- **Charts**: fl_chart

## Getting Started

### Prerequisites
- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/HassenGHR/rhm_operator.git
   ```

2. Navigate to the project directory:
   ```
   cd industrial_monitor
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Configure Firebase:
   - Create a new Firebase project
   - Add Android & iOS apps in Firebase console
   - Download and add configuration files
   - Enable Authentication (Email/Password) in Firebase console

5. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
industrial_monitor/
├── android/
├── ios/
├── lib/
│ ├── main.dart              # Entry point
│ ├── app.dart               # App configuration
│ ├── config/                # App-wide configuration
│ │ ├── theme.dart           # Theme settings
│ │ └── routes.dart          # Navigation routes
│ ├── models/                # Data models
│ │ ├── user.dart            # User model
│ │ ├── parameter.dart       # Parameter definitions
│ │ └── reading.dart         # Sensor readings model
│ ├── screens/               # UI screens
│ │ ├── auth/                # Authentication screens
│ │ ├── home/                # Main app screens
│ │ └── settings/            # App settings
│ ├── services/              # Business logic
│ │ ├── auth_service.dart    # Authentication handling
│ │ ├── storage_service.dart # Local data management
│ │ └── firebase_service.dart # Cloud services
│ ├── utils/                 # Utilities
│ │ ├── validators.dart      # Input validation
│ │ └── constants.dart       # App constants
│ └── widgets/               # Reusable components
```

## Usage

1. **Authentication**:
   - New users can register with email/password
   - Returning users can log in with email/password or PIN

2. **Adding Parameters**:
   - Navigate to the Dashboard tab
   - Use the "+" button to add a new reading
   - Input the parameter type and value

3. **Viewing History**:
   - Navigate to the History tab to view all readings
   - Filter by parameter type or date range

4. **Analyzing Trends**:
   - Navigate to the Charts tab
   - Select parameters to visualize
   - Adjust time period as needed

5. **Settings**:
   - Manage theme preferences
   - Enable/disable cloud sync
   - Reset local data if needed

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Hive](https://docs.hivedb.dev/)
- [Firebase](https://firebase.google.com/)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [FlexTheme](https://pub.dev/packages/flex_color_scheme)