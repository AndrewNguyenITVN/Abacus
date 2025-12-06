# 📱 CT312H: MOBILE PROGRAMMING

## Project Description

**Abacus** is a mobile spending management application built with Flutter. The system allows users to seamlessly track personal and group expenditures. Key features include user authentication, an interactive dashboard with financial summaries, transaction management, budget planning, and insightful reports with charts.

The application provides a comprehensive solution for managing personal finances with features such as:
- Real-time transaction tracking (Income/Expense)
- Category management with custom icons and colors
- Savings goals with progress tracking
- Spending alerts and notifications
- Monthly financial reports and analytics
- Responsive design supporting both portrait and landscape modes
- Dark/Light theme support

---

## Student Information

- **Course:** CT312H - Mobile Programming
- **Student 1:** Nguyễn Minh Nhựt - B2205896
- **Student 2:** Huỳnh Tấn Đạt - B2203438
- **Class:** CT312HM01
- **Semester:** 1, Academic Year 2025-2026

---

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio
- PocketBase backend server (or use hosted instance)

### 1. Clone the repository

```bash
git clone https://github.com/AndrewNguyenITVN/Abacus.git
cd abacus
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

Create a `.env` file in the root directory:

```env
POCKETBASE_URL=your_pocketbase_url_here
```

### 4. Setup PocketBase backend

- Set up a PocketBase instance (local or hosted)
- Create the `users` collection with fields: `id`, `username`, `email`, `name`, `password`, `verified`
- Update the `POCKETBASE_URL` in `.env` file

### 5. Initialize local database

The app will automatically create SQLite databases for:
- Categories (expense/income categories)
- Savings goals
- Notification history

### 6. Run the application

```bash
flutter run

```

---

## Technologies Used

### Core Framework
- **Flutter:** Cross-platform mobile development framework
- **Dart:** Programming language

### State Management
- **Provider:** State management solution for reactive UI updates

### Backend & Data Storage
- **PocketBase:** Backend-as-a-Service for user authentication and remote data
- **SQLite (sqflite):** Local database for categories, savings goals, and notifications
- **SharedPreferences:** Local storage for app settings and preferences

### Navigation & Routing
- **go_router:** Declarative routing and navigation

### UI & Utilities
- **intl:** Internationalization and date/number formatting
- **flutter_local_notifications:** Local push notifications
- **flutter_dotenv:** Environment variable management
- **http:** HTTP client for API calls

### Platform Support
- **Android:** Full support
- **iOS:** Full support

---

## Features

### 1. 🔐 Authentication
- User registration and login
- Secure session management with automatic token refresh
- Persistent login state
- Profile management with user information

### 2. 🏠 Home Dashboard
- Current balance display
- Total income and expense summary
- Spending ratio analysis with progress indicators
- Monthly comparison reports (sliding cards)
- Recent transactions list
- Savings goals overview

### 3. 💰 Transaction Management
- Add, edit, and delete transactions
- Income and expense classification
- Category assignment with visual icons
- Amount input with quick suggestions
- Transaction notes
- Monthly transaction summaries
- Responsive layout (portrait/landscape)

### 4. 📂 Category Management
- Custom expense and income categories
- Icon and color customization
- Default categories initialization
- Category-based transaction filtering

### 5. 🎯 Savings Goals
- Create and track financial goals
- Progress visualization with progress bars
- Add/withdraw funds from goals
- Deadline tracking
- Completion notifications
- Summary on home screen

### 6. 🔔 Notifications & Alerts
- Spending threshold alerts (customizable percentage)
- Savings goal completion notifications
- Notification history management
- Mark as read / delete notifications
- Settings for enabling/disabling alerts

### 7. 👤 Account Management
- View and edit user profile
- Update personal information (name, phone, address, date of birth, gender)
- Theme settings (Dark/Light mode)
- Notification preferences
- Logout functionality

### 8. 🎨 UI/UX Features
- Responsive design (Portrait & Landscape)
- Smooth animations and transitions
- Dark/Light theme support
- Custom splash screen
- Modern gradient designs
- Intuitive navigation

---

## Notes

- This project is designed for educational purposes as part of the CT312H Mobile Programming course
- Ensure PocketBase backend is running and accessible before using authentication features
- Local database is automatically initialized on first app launch
- Default categories are created automatically if the database is empty
