# Care247 — Customer Search App

A Flutter application for searching and browsing customer records against a mock REST API or bundled offline data. Built with a configuration-driven search form, structured state management with Provider, and a comprehensive automated test suite.

---

## Getting Started

### Prerequisites

- Flutter SDK (3.13+ / 3.47+ stable)
- Node.js & npm (for `json-server`, optional if using offline demo mode)

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Start the Mock API Server

Install `json-server` if you haven't already:

```bash
npm install -g json-server
```

Start the server using the provided `db.json`:

```bash
json-server --watch db.json --port 3001
```

The endpoint will be available at `http://localhost:3001/customers`.

### 3. Run the App

```bash
flutter run
```

### Network & Platform Notes

| Target | Host / Base URL |
|---|---|
| Android Emulator | `http://10.0.2.2:3001` |
| iOS Simulator / macOS / Web | `http://localhost:3001` |
| Physical Device | `http://<your-lan-ip>:3001` |

- **Auto-Discovery**: If the initial connection fails, `CustomerApi` automatically probes candidate hosts (`localhost`, `10.0.2.2`, and local LAN) to find the active server without requiring manual URL editing.
- **In-App Server Config**: Tap the server icon in the app bar to test connection latency, specify a custom URL, or switch to **Offline Demo Mode** (which reads directly from the bundled `db.json` asset with zero network dependencies).
- **Compile-time Override**: You can also pass `--dart-define=API_URL=http://<host>:3001` during `flutter run`.

---

## Architecture & Project Structure

The codebase is organized into clean functional layers separating data fetching, state, and UI:

```
lib/
├── config/
│   ├── app_config.dart             # API base URL, candidate hosts & platform resolution
│   └── search_config.dart          # Configuration-driven search field definitions
├── data/
│   ├── customer_api.dart           # HTTP client with timeout & auto-discovery fallback
│   └── customer_repository.dart    # Data repository, query filtering & offline asset loader
├── models/
│   ├── customer.dart               # Customer entity with JSON parsing & display getters
│   ├── address.dart                # Address entity
│   ├── phone.dart                  # Phone entity (with isPrimary flag)
│   └── email.dart                  # Email entity (with isPrimary flag)
├── screens/
│   ├── customer_search_screen.dart # Search form, server status & theme switcher
│   ├── customer_results_screen.dart# Search results list with pull-to-refresh
│   └── customer_detail_screen.dart # Customer detail view with contact & address sections
├── state/
│   ├── customer_search_state.dart  # Search flow state machine (ChangeNotifier)
│   └── theme_state.dart            # Light / Dark theme mode state
├── theme/
│   └── app_theme.dart              # Material 3 light and dark theme definitions
├── widgets/
│   ├── customer_list_item.dart     # Customer card component
│   ├── dynamic_field.dart          # Generic input renderer for text, date, and dropdown
│   ├── dynamic_search_form.dart    # Config-driven form layout & input controller manager
│   ├── empty_state_widget.dart     # Empty results placeholder
│   ├── error_state_widget.dart     # Error message card with retry action
│   ├── server_config_sheet.dart    # Bottom sheet for endpoint testing & demo mode toggle
│   └── theme_toggle_button.dart    # Dark/light theme toggle button
└── main.dart                       # App entry point & provider tree setup
```

### Data & State Flow

1. **State Management**: `CustomerSearchState` (`ChangeNotifier`) models the search lifecycle through explicit states:
   `initial` → `loading` → `success` | `empty` | `error`.
2. **Separation**: Screens and widgets trigger actions on `CustomerSearchState`. The state delegates data retrieval to `CustomerRepository`, which interfaces with `CustomerApi` or the bundled asset fallback. UI widgets never communicate with HTTP clients directly.
3. **Targeted Rebuilds**: Widgets use `Consumer<CustomerSearchState>` and `context.select(...)` so that only the widgets that depend on search status rebuild on state changes.

---

## Configuration-Driven Search Form

The search form is built dynamically from field definitions rather than hardcoded UI components.

### How It Works

Field metadata is declared in `lib/config/search_config.dart`:

```dart
enum FieldType { text, date, dropdown }

class FieldConfig {
  final String key;
  final FieldType type;
  final String label;
  final String? placeholder;
  final int renderOrder;
  final List<String>? options;
  // ...
}

final List<FieldConfig> searchConfig = [
  const FieldConfig(
    key: 'firstName',
    type: FieldType.text,
    label: 'First Name',
    placeholder: 'Enter first name',
    renderOrder: 1,
  ),
  const FieldConfig(
    key: 'lastName',
    type: FieldType.text,
    label: 'Last Name',
    placeholder: 'Enter last name',
    renderOrder: 2,
  ),
  const FieldConfig(
    key: 'dateOfBirth',
    type: FieldType.date,
    label: 'Date of Birth',
    placeholder: 'YYYY-MM-DD',
    renderOrder: 3,
  ),
];
```

- `DynamicSearchForm` takes the configuration list, sorts items by `renderOrder`, and creates a `DynamicField` for each entry.
- `DynamicField` builds the appropriate widget based on `FieldType` (`TextField` for text, interactive date-picker field with clear button for dates, or `DropdownButtonFormField` for dropdowns).
- The form manages text editing controllers, focus nodes, and keyboard actions (`TextInputAction.next`), aggregating active user inputs into a `Map<String, String>` passed to the search callback.

### Adding a New Search Field

To add a new field (such as **Marital Status**):

1. Add an entry to `searchConfig` in `lib/config/search_config.dart`:

```dart
const FieldConfig(
  key: 'maritalStatus',
  type: FieldType.dropdown,
  label: 'Marital Status',
  placeholder: 'Select marital status',
  renderOrder: 4,
  options: ['Single', 'Married', 'Divorced', 'Widowed'],
),
```

2. That's it. `DynamicSearchForm` and `DynamicField` automatically render the dropdown, manage its value, and pass `{'maritalStatus': '...'}` into the query map without any changes to screen or widget code.

---

## Implementation Details

- **Lifecycle & Resource Cleanup**:
  - Focus nodes and text controllers initialized in `DynamicSearchForm` are disposed in `dispose()`.
  - `CustomerSearchState` tracks an `_isDisposed` flag to prevent calling `notifyListeners()` after disposal.
  - Async operations verify `context.mounted` before triggering navigation.
- **Form & Keyboard UX**:
  - Tapping outside text fields unfocuses the current input and dismisses the keyboard.
  - Text fields use `TextInputAction.next` with automatic focus progression to the next field.
  - Date selection uses the Material date picker modal rather than requiring manual date string typing.
- **Rendering Performance**:
  - Results use `ListView.builder` for lazy, on-demand item rendering.
  - `const` constructors are used across all static widgets to minimize rebuild overhead.
  - Sorted field configuration is cached on form initialization instead of re-sorting on every build.

---

## Trade-offs & Decisions

- **Provider over BLoC / Riverpod**: For an application of this scope, `Provider` + `ChangeNotifier` provides clear separation of concerns without the boilerplate, streams management, or code generation overhead that BLoC or Riverpod would introduce.
- **Repository-Side Query Filtering**: While `json-server` provides basic `_like` query parameters, its handling of case sensitivity and date variations is inconsistent across environments. The repository fetches the dataset and performs client-side filtering with date normalization (handling both `YYYY-MM-DD` and `DD/MM/YYYY`), ensuring reliable search behavior.
- **Manual Model Serialization**: Built models with handwritten `fromJson` and `toJson` methods instead of bringing in `json_serializable` and `build_runner`. For four compact models, this keeps build times instant and avoids code-generation dependencies.
- **Pagination**: Omitted due to the small size of the mock dataset (10 records). In a production environment with larger datasets, cursor-based pagination with infinite scrolling would be added to the repository and list view.
- **Offline Fallback / Demo Mode**: Added a bundled asset fallback so reviewers can immediately run and test the app without setting up Node.js or `json-server`.

---

## Testing

The project includes 70 automated tests covering models, state management, repository logic, and widget rendering.

### Test Suites

- `test/models_test.dart`: Parsing, null-safety, convenience getters (`fullName`, `primaryPhone`, `primaryEmail`), `toJson`, and value equality across all models.
- `test/search_config_test.dart`: Configuration completeness, render ordering, and extensible field handling.
- `test/customer_search_state_test.dart`: State machine transitions (`initial` → `loading` → `success` / `empty` / `error`), criteria updates, reset, and repository mocking.
- `test/customer_repository_test.dart`: Filtering logic (first name, last name, date normalization, marital status) in live API mode and offline asset mode.
- `test/dynamic_field_test.dart`: Widget tests for text, date, and dropdown fields, date picker dialog interaction, and clearing values.
- `test/customer_list_item_test.dart`: Customer card display, formatted dates, primary contact badges, tap callbacks, and graceful missing-data handling.
- `test/theme_state_test.dart`: Theme toggling logic and theme switcher button rendering.

### Running Tests

```bash
flutter test
```

---

## Time Spent

Total time spent: ~4.5 hours (including configuration-driven architecture, API auto-discovery & offline demo mode, UI theme support, and automated test coverage).
