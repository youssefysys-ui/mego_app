# Project Architecture & Implementation Plan

This document provides a comprehensive overview of the **MEGO Client App** architecture. It serves as the single source of truth for understanding how the application is structured, how features are implemented, and how data flows between components.

## 🛠 Technology Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Backend**: Supabase (Database, Auth) & Firebase (Auth - Phone/Google)
- **Architecture**: Feature-based MVC/MVVM (View - Controller - Repository)

---

## 📂 Directory Structure

The project follows a **Feature-First** architecture, keeping related code together.

```
lib/
├── core/                  # Shared components used across the entire app
│   ├── bindings/          # Global Dependency Injection (GetX Bindings)
│   ├── constants/         # App constants (URLs, keys)
│   ├── services/          # Global services (e.g., RideRestoration)
│   ├── shared_models/     # Data models (User, Ride, Order)
│   ├── shared_widgets/    # Reusable UI components
│   ├── res/               # Resources (Colors, Images, Strings)
│   └── utils/             # Helper functions and extensions
│
├── features/              # Feature-specific code
│   ├── auth/              # Authentication feature
│   │   ├── login/
│   │   │   ├── views/     # UI Screens
│   │   │   ├── controllers/ # Business Logic
│   │   │   └── repo/      # Data Access Layer
│   │   └── ...
│   ├── home/              # Home screen feature
│   └── ...
│
└── main.dart              # App Entry Point & Initialization
```

---

## 🏗 Architecture Layers

### 1. View (UI Layer)
- **Location**: `lib/features/<feature_name>/views/`
- **Responsibility**: Displays the UI and captures user input.
- **Implementation**:
  - Uses standard Flutter widgets.
  - Connects to Controllers using `Get.find<Controller>()` or `GetView<Controller>`.
  - **Reactivity**: Uses `Obx(() => ...)` to listen to changes in Controller state.

### 2. Controller (Business Logic Layer)
- **Location**: `lib/features/<feature_name>/controllers/`
- **Responsibility**:
  - Manages state (using `.obs` variables).
  - Contains business logic.
  - Handles user events from the View.
  - Calls Repositories or Services to fetch/save data.
- **Implementation**:
  - Extends `GetxController`.
  - Dependencies are injected via `Get.put()` or Bindings.

### 3. Repository / Service (Data Layer)
- **Location**: `lib/features/<feature_name>/repo/` or `lib/core/services/`
- **Responsibility**:
  - Handles direct interaction with Supabase or Firebase.
  - Abstraction over the database/API.
- **Implementation**:
  - `Supabase.instance.client` is used to make DB calls.
  - Returns raw data or Models to the Controller.

---

## 🔄 Data Flow Example: Login Feature

Here is how a typical feature works, using **Login** as an example:

1.  **User Action**: User enters phone number and clicks "Login" in `LoginView`.
2.  **View -> Controller**: `LoginView` calls `controller.login()`.
3.  **Controller Logic**:
    - `LoginController` validates input.
    - Calls `_firebaseAuth.verifyPhoneNumber` for OTP.
    - Upon verification, it gets a Firebase Credential.
4.  **Controller -> Backend**:
    - `LoginController` (or Repo) checks if the user exists in Supabase:
      ```dart
      supabase.from('users').select().eq('phone', phone).maybeSingle()
      ```
    - If user exists: Logs them in.
    - If new user: Navigates to `CompleteProfileView`.
5.  **State Update**: Controller updates `isLoading` (observable), causing the View to show/hide a loading spinner via `Obx`.
6.  **Navigation**: On success, Controller calls `Get.offAll(() => HomeView())`.

---

## 🧩 Core Components

### Dependency Injection (Bindings)
- **File**: `lib/core/bindings/binding.dart`
- **Usage**: `MyBinding` class implements `Bindings`. It initializes global controllers and repositories when the app starts.
  ```dart
  Get.lazyPut<HomeController>(() => HomeController());
  ```

### Supabase Integration
- **Initialization**: In `main.dart`:
  ```dart
  await Supabase.initialize(url: '...', anonKey: '...');
  ```
- **Usage**: Accessed via `Supabase.instance.client` in Controllers or Repositories.

### Navigation
- Managed by GetX.
- **Routes**: Defined in `GetMaterialApp` or used dynamically:
  ```dart
  Get.to(() => NextScreen());
  Get.offAll(() => HomeScreen()); // Clear stack
  ```

### Models
- **Location**: `lib/core/shared_models/`
- **Usage**: Plain Dart classes with `fromJson` and `toJson` methods to map Supabase responses to objects.

---

## 📝 Rules for Future Development

1.  **Do NOT modify existing logic** unless explicitly requested.
2.  **Follow the structure**: New features must have their own folder in `features/` with `views` and `controllers`.
3.  **Use GetX**: For state management, navigation, and dependency injection.
4.  **Use Supabase**: For all database operations.
