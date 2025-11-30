# Order Pro

Order Pro is a comprehensive Flutter application designed for managing orders, inventory, and staff. It features a robust system for tracking business activities, generating invoices, and managing staff salaries.


# Supervisor 

-**Marufa Sultana** - Lecturer
- [@marufacse](https://github.com/marufacse) - Supervisor
-**Course Name** - Software Engineering
-**University of Creative Technology, Chittagong**


## Contributors ✨

Thanks go to these wonderful people:

- **MD Ali Jaker** – Project Lead & Developer, Database Design, UI/UX
- [@MDAliJaker](https://github.com/MDAliJaker)
- **Azmira Khanam** – Project Testing and Improvement guides, Documentation
- [@AzmiraKhanam](https://github.com/AzmiraKhanam)
- **Ariful Hoque Emon** – Project Manager, UI/UX suggestions, Presentations
  
## Features

-   **Order Management**: Create, track, and manage customer orders.
-   **Inventory Management**: Keep track of stock levels and product details.
-   **Staff Management**: Manage staff profiles and salaries.
-   **Invoice Generation**: Generate professional PDF invoices with support for multiple currencies and business details.
-   **Data Visualization**: View business insights with integrated charts.
-   **Local Database**: Secure local data storage using SQLite.
-   **Multi-Currency Support**: Handle transactions in different currencies.

## Prerequisites

Before you begin, ensure you have met the following requirements:

-   **Flutter SDK**: Version >=3.0.0 <4.0.0 installed.
-   **Dart SDK**: Included with Flutter.
-   **IDE**: VS Code or Android Studio with Flutter and Dart plugins installed.
-   **Git**: For cloning the repository.

## Installation

1.  **Clone the Repository**

    ```bash
    git clone <repository-url>
    cd order_pro
    ```

2.  **Install Dependencies**

    Run the following command to install the required packages listed in `pubspec.yaml`:

    ```bash
    flutter pub get
    ```

## Running the Application

### Android

1.  Connect your Android device or start an emulator.
2.  Run the app:

    ```bash
    flutter run
    ```

### iOS (macOS only)

1.  Start the iOS Simulator.
2.  Run the app:

    ```bash
    flutter run
    ```

### Windows

1.  Enable Developer Mode in Windows Settings.
2.  Run the app:

    ```bash
    flutter run -d windows
    ```

## Building for Release

To build the application for release (e.g., Android APK):

```bash
flutter build apk --release
```

For Windows:

```bash
flutter build windows --release
```

## Project Structure

-   `lib/`: Contains the main source code.
    -   `main.dart`: Entry point of the application.
    -   `screens/`: UI screens for different features.
    -   `providers/`: State management providers.
    -   `models/`: Data models.
    -   `db/`: Database helper classes.
-   `pubspec.yaml`: Project configuration and dependencies.

## Dependencies

Key dependencies used in this project:

-   `provider`: State management.
-   `sqflite`: Local database.
-   `pdf` & `printing`: Invoice generation.
-   `fl_chart`: Charts and graphs.
-   `intl`: Internationalization and formatting.
-   `shared_preferences`: Simple data persistence.

