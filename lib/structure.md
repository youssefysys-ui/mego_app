password in supabase:Yugi4040@megoApp

lib/
│
├── core/                          # Global/shared code
│   ├── constants/                 # App-wide constants
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_assets.dart
│   │   └── app_styles.dart
│   │
│   ├── utils/                    # Shared functions/helpers
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart        # (StringExtension, DateExtension, etc.)
│   │
│   ├── widgets/                   # Shared/reusable widgets
│   │   ├── custom_button.dart
│   │   ├── custom_textfield.dart
│   │   └── loading_indicator.dart
│   │
│   ├── errors/                    # Error handling
│   │   ├── failure.dart
│   │   └── exceptions.dart
│   │
│   ├── network/                   # Networking layer
│   │   ├── api_client.dart
│   │   ├── endpoints.dart
│   │   └── interceptors.dart
│   │
│   ├── bindings/                  # Global GetX Bindings
│   │   └── initial_binding.dart
│   │
│   ├── routes/                    # GetX Routes & Pages
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   │
│   └── services/                  # Global GetX Services
│       ├── api_service.dart
│       ├── storage_service.dart
│       └── auth_service.dart
│
├── features/                      # App features
│   ├── auth/                      # Authentication feature
│   │   ├── controllers/           # GetX Controllers
│   │   │   └── auth_controller.dart

        - repo's
          - auth_repo.dart
          -auth_repo_impl.dart
│   │   │
│   │   ├── models/                # Data models
│   │   │   └── user_model.dart.    (if not need to be as shared model)
│   │   │
│   │   ├── views/                 # Screens/Pages
│   │   │   ├── login_view.dart
│   │   │   └── register_view.dart
│   │   │
│   │   ├── widgets/               # Feature-specific widgets
│   │   │   └── login_form.dart
│   │   │
│   │   └── bindings/              # GetX Bindings
│   │       └── auth_binding.dart
│   │
│   ├── home/                      # Example: Home feature
│   │   ├── controllers/
│   │   │   └── home_controller.dart
│   │   ├── models/
│   │   ├── views/
│   │   │   └── home_view.dart
│   │   ├── widgets/
│   │   │   └── home_header.dart
│   │   └── bindings/
│   │       └── home_binding.dart
│   │
│   └── ...                        # Other features
│
├── app.dart                       # Root App widget (GetMaterialApp, themes, routes)
└── main.dart                      # Entry point with GetX initialization



Error accepting offer: PostgrestException(message: new row for relation "ride_requests" violates check constraint "ride_requests_status_check", code: 23514, details: Failing row contains (67b6e83d-6daa-4bc4-b8e2-34262585be67, 98a9dadb-bf3b-4b54-b62d-28da4318d40e, 41.4689396, 44.785078, 42.1426914, 41.6737886, 676.31, 816, accepted, 2025-11-10 07:20:15.773007)., hint: null)