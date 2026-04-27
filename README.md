<div align="center">

# 📱 ETF Oglasi

![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-success?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-Offline_Cache-lightgrey?logo=sqlite&logoColor=003B57)
![WorkManager](https://img.shields.io/badge/WorkManager-Background_Tasks-orange?logo=android)
![Notifications](https://img.shields.io/badge/Notifications-Enabled-brightgreen?logo=android)

<img src="readme_assets/demo.gif" alt="ETF Oglasi demo" width="300">

</div>

---

## 📌 Project Overview

**ETF Oglasi** is an Android application for viewing university announcements and class schedules with full offline support. Features smart push notifications, SQLite caching, multi-language localization, and dark/light theme. Built as a graduation thesis project.

---

## ✨ Features

- 📢 Browse categorized announcements with attachment download support
- 📅 View weekly and daily class schedules with current hour highlight
- 🔔 Schedule personalized push notifications with user-defined timers
- 📦 Offline caching of announcements and schedules via SQLite
- 🌐 Remote API fetching with automatic fallback to local storage
- ⚙️ User-defined default schedule preferences — by professor, room, study program, or year
- 🌙 Light and dark theme support
- 🌍 Multi-language support (Serbian / English)

---

## 🛠️ Tech Stack

| Technology            | Usage                                             |
| --------------------- | ------------------------------------------------- |
| Flutter / Dart        | Cross-platform mobile framework                   |
| Riverpod              | State management with StateNotifier               |
| SQLite (sqflite)      | Offline caching of announcements and schedules    |
| WorkManager           | Background API checks and notification scheduling |
| SharedPreferences     | Theme, locale, and timer preferences              |
| Flutter Localizations | SR / EN language support                          |

---

## 🏗️ Architecture

- Modular `/features` structure — announcements, schedules, settings
- Riverpod providers and `StateNotifier` for state control
- Repository pattern abstracting API and database logic
- Automatic fallback to local data when offline
- Periodic background sync configured by user-defined timers

---

## 🚀 Setup & Run

### Prerequisites

- Flutter SDK `>=3.4.3`
- Android Studio with Android SDK
- Physical Android device or emulator (Android 8.0+)

### 1. Clone the repository

```bash
git clone https://github.com/pero-grubac/ETFOglasi.git
cd ETFOglasi
```

### 2. Install dependencies

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the app

```bash
flutter run
```

---

## 📸 Screenshots

<table>
  <tr>
    <td><img src="readme_assets/home screen.png" alt="Home screen" width="180"/></td>
    <td><img src="readme_assets/announcements.png" alt="Announcements" width="180"/></td>
    <td><img src="readme_assets/announcement .png" alt="Single announcement" width="180"/></td>
    <td><img src="readme_assets/schedule.png" alt="Schedule" width="180"/></td>
  </tr>
  <tr>
    <td><img src="readme_assets/side bar.png" alt="Sidebar" width="180"/></td>
    <td><img src="readme_assets/settings.png" alt="Settings" width="180"/></td>
    <td><img src="readme_assets/notifications.png" alt="Notification setup" width="180"/></td>
    <td><img src="readme_assets/notification.png" alt="System notification" width="180"/></td>
  </tr>
</table>
