# Care247 — Customer Search Application

A **Flutter** mobile application for searching, browsing, and viewing customer details, built as a technical assignment demonstrating production-minded Flutter engineering.

---

## Table of Contents

- [Setup and Run](#setup-and-run)
- [Architecture](#architecture)
- [Configuration-Driven Design](#configuration-driven-design)
- [Flutter Decisions](#flutter-decisions)
- [Trade-offs](#trade-offs)
- [Testing](#testing)
- [Time Spent](#time-spent)

---

## Setup and Run

### Prerequisites

| Tool           | Version Used       |
| -------------- | ------------------ |
| Flutter        | 3.47.7 (stable)   |
| Dart           | 3.13.5             |
| Node.js / npm  | Required for JSON Server |

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Start JSON Server (Mock API)

Install JSON Server if not already installed:

```bash
npm install -g json-server
```

Start the database:

```bash
json-server --watch db.json --port 3001
```

The API will be available at `http://localhost:3001/customers`.

### 3. Run the Application

```bash
flutter run
```

### API Configuration by Platform

| Platform           | Base URL                                  |
| ------------------ | ----------------------------------------- |
| Android Emulator   | `http://10.0.2.2:3001`                    |
| iOS Simulator      | `http://localhost:3001`                    |
| Physical Device    | `http://<your-local-ip>:3001`             |
| Web / Desktop      | `http://localhost:3001`                    |

The API base URL is configured centrally in [`lib/config/app_config.dart`](lib/config/app_config.dart) and auto-detects the platform. It is **not hardcoded** throughout the application.

---

## Architecture

### Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # API URL & environment configuration
│   └── search_config.dart       # Configuration-driven field definitions
├── models/
│   ├── customer.dart            # Customer model with fromJson/toJson
│   ├── address.dart             # Address model
│   ├── phone.dart               # Phone model
│   └── email.dart               # Email model
├── data/
│   ├── customer_api.dart        # Low-level HTTP client
│   └── customer_repository.dart # Repository mediating API and state
├── state/
│   └── customer_search_state.dart # ChangeNotifier-based state management
├── screens/
│   ├── customer_search_screen.dart  # Search form screen
│   ├── customer_results_screen.dart # Results list screen
│   └── customer_detail_screen.dart  # Customer detail screen
├── widgets/
│   ├── dynamic_search_form.dart # Config-driven form widget
│   ├── dynamic_field.dart       # Generic field renderer
│   ├── customer_list_item.dart  # Reusable list item card
│   ├── empty_state_widget.dart  # Reusable empty state
│   └── error_state_widget.dart  # Reusable error state with retry
└── main.dart                    # App entry point
```

### Separation of Concerns

The architecture follows a **three-layer separation**:

| Layer                | Responsibility                                      | Key Files                           |
| -------------------- | --------------------------------------------------- | ----------------------------------- |
| **Presentation**     | Widgets, screens, user interaction                  | `screens/`, `widgets/`              |
| **State**            | Application state, business logic, state transitions | `state/customer_search_state.dart`  |
| **Data**             | HTTP communication, API abstraction, data mapping   | `data/customer_api.dart`, `data/customer_repository.dart` |

- **Presentation** widgets never make API calls directly.
- **State** layer (ChangeNotifier) holds all application state and delegates data fetching to the repository.
- **Data** layer handles HTTP, JSON parsing, and error wrapping. The repository provides a clean interface to state.

### State Management Approach

**Provider + ChangeNotifier** was chosen because:

1. **Proportionate to scope** — this is a focused application with straightforward state needs. Provider is the official Flutter recommendation for apps of this complexity.
2. **Minimal dependency** — `provider` is maintained by the Flutter team and adds negligible overhead.
3. **Clear state transitions** — The `SearchStatus` enum explicitly models all states:

```
Initial → Loading → Success | Empty | Error
```

States are represented as:

| State     | Meaning                             |
| --------- | ----------------------------------- |
| `initial` | No search performed yet             |
| `loading` | API request in progress             |
| `success` | Results returned                    |
| `empty`   | No matching customers               |
| `error`   | Request failed (with error message) |

### Navigation

Standard Flutter `Navigator.push` with `MaterialPageRoute` for:
- Search → Results (after successful search)
- Results → Detail (on customer tap)
- Back navigation via AppBar back button

---

## Configuration-Driven Design

### How the Search Form is Generated

The search form is **entirely driven by configuration**. The flow is:

```
searchConfig (List<FieldConfig>)
        ↓
DynamicSearchForm (sorts by renderOrder, iterates)
        ↓
DynamicField (renders widget based on FieldType)
        ↓
User Input → Map<String, String> criteria
        ↓
CustomerSearchState → Repository → API
        ↓
Results
```

The configuration is defined in [`lib/config/search_config.dart`](lib/config/search_config.dart):

```dart
final List<FieldConfig> searchConfig = [
  FieldConfig(key: 'firstName', type: FieldType.text, label: 'First Name', ...),
  FieldConfig(key: 'lastName', type: FieldType.text, label: 'Last Name', ...),
  FieldConfig(key: 'dateOfBirth', type: FieldType.date, label: 'Date of Birth', ...),
];
```

### How to Add a New Search Field

To add **Marital Status** as a search field:

1. **Open** `lib/config/search_config.dart`
2. **Add** a new `FieldConfig` entry:

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

3. **Done.** No other code changes are needed.

### What Changes / What Doesn't

| Component                     | Change Needed? |
| ----------------------------- | -------------- |
| `search_config.dart`          | ✅ Add entry    |
| `DynamicSearchForm`           | ❌ No change    |
| `DynamicField`                | ❌ No change    |
| `CustomerSearchScreen`        | ❌ No change    |
| `CustomerSearchState`         | ❌ No change    |
| `CustomerRepository`          | ❌ No change    |
| `CustomerApi`                 | ❌ No change    |

The `FieldType` enum supports `text`, `date`, and `dropdown`. Adding a new type requires adding a builder case in `DynamicField`, but adding new fields of existing types requires **zero widget changes**.

---

## Flutter Decisions

### State Management

**Provider + ChangeNotifier** — selected for its simplicity, official support, and appropriateness for this application's scope. Avoids over-engineering with BLoC/Riverpod for a straightforward CRUD search flow.

`Consumer<CustomerSearchState>` is used for targeted widget rebuilds — only the parts of the UI that depend on search state are rebuilt when state changes.

### Widget Lifecycle Handling

- **Disposed guard**: `CustomerSearchState` tracks `_isDisposed` to prevent calling `notifyListeners()` after the widget tree has been torn down.
- **`context.mounted` check**: Before performing navigation after an async operation, the code checks `context.mounted` to ensure the widget is still in the tree.
- **Resource disposal**: `FocusNode` instances created in `DynamicSearchForm` are disposed in `dispose()`. The `CustomerRepository` and its underlying `http.Client` are disposed when the state is disposed.

### Async API Handling

- All API calls use `async`/`await` with proper `try`/`catch` blocks.
- The UI remains responsive during API calls — a `CircularProgressIndicator` is shown.
- Errors are caught at the API level and wrapped in typed `CustomerApiException` with user-friendly messages.
- Network errors (`SocketException`), client errors, and format errors are all handled gracefully.

### Rebuild / Performance Considerations

- **`Consumer` widgets** scope rebuilds to only the widgets that need the state.
- **`ListView.builder`** renders list items lazily — only visible items are built.
- **`AlwaysScrollableScrollPhysics`** ensures pull-to-refresh works even with few items.
- **`const` constructors** used throughout for widget reuse.
- **Sorted config cached** in `initState()` rather than re-sorted on every build.
- **Focus nodes** are created once in `initState()` and reused, not recreated per build.

### Keyboard and Form Behaviour

- **GestureDetector** on search screen dismisses keyboard when tapping outside fields.
- **`TextInputAction.next`** allows moving between text fields via the keyboard action button.
- **Date of Birth** uses `showDatePicker()` — no manual date typing required.
- **Focus management** moves focus to the next text field automatically on submit.
- **Keyboard dismissal** before date picker and before search/clear actions.
- **`SingleChildScrollView`** prevents keyboard from obscuring fields.

---

## Trade-offs

| Decision | Rationale |
|---|---|
| **Provider over BLoC/Riverpod** | Proportionate to the application's complexity. BLoC would add boilerplate without clear benefit for this scope. |
| **JSON Server `_like` for partial matching** | Simplifies the search implementation. In production, server-side search would be more robust. |
| **No pagination** | The sample dataset is small. In production, API pagination would be essential. |
| **No offline caching** | Kept the scope focused. A production app would benefit from local caching. |
| **Models use manual `fromJson`/`toJson`** | Avoids code-generation dependencies (`json_serializable`, `freezed`). For 4 models, manual serialization is clearer and has zero build overhead. |
| **No input validation** | Search fields accept any input. Validation would be added for production (e.g., name length limits). |
| **`http` package over `dio`** | Fewer dependencies. `http` is sufficient for simple GET requests. |

---

## Testing

### What is Tested

| Test File | What it Covers |
|---|---|
| `test/models_test.dart` | JSON parsing for all models (Customer, Address, Phone, Email), convenience getters (`fullName`, `primaryPhone`, `primaryEmail`), edge cases (empty lists, no primary), `toJson`, `copyWith`, equality |
| `test/search_config_test.dart` | Configuration completeness, field types, render order sorting, extensibility (adding new fields) |
| `test/customer_search_state_test.dart` | State transitions (initial → loading → success/empty/error), criterion updates, clear/reset, retry, mock repository interaction |
| `test/dynamic_field_test.dart` | Widget rendering for text fields, date fields (calendar icon, formatted display), dropdown fields |
| `test/customer_list_item_test.dart` | Customer summary display, formatted date, primary phone/email, tap interaction, graceful handling of missing data |

### How to Run Tests

```bash
flutter test
```

All **53 tests** should pass.

---

## External Dependencies

| Package    | Version | Justification |
|------------|---------|---------------|
| `http`     | ^1.3.0  | Standard HTTP client for REST API calls. Official Dart team package. |
| `provider` | ^6.1.5  | State management. Official Flutter recommendation. |
| `intl`     | ^0.20.0 | Date formatting (`DateFormat`). Part of the Dart ecosystem. |
| `mocktail` | ^1.0.5  | Test mocking (dev dependency only). Lightweight alternative to `mockito` without code generation. |

---

## Time Spent

Approximately **4–5 hours**.

---

## Final Checklist

- ✅ Flutter and Dart implementation
- ✅ `db.json` used as data source
- ✅ Strongly typed Customer models
- ✅ Configuration-driven search fields
- ✅ Search supports First Name, Last Name, Date of Birth
- ✅ New fields can be added without changing widget code
- ✅ Search results display required customer info
- ✅ Pull-to-refresh works
- ✅ Customer details display all required info
- ✅ Navigation works correctly
- ✅ Loading, empty, error states handled
- ✅ API/network failures handled gracefully
- ✅ Keyboard behaviour is appropriate
- ✅ Async operations are lifecycle-safe
- ✅ Controllers/listeners/resources disposed
- ✅ Efficient list rendering (ListView.builder)
- ✅ State management separated from UI
- ✅ Meaningful automated tests (53 tests)
- ✅ README with complete setup instructions
- ✅ README explains architecture and config approach
- ✅ README explains Flutter-specific decisions
- ✅ README records trade-offs and time spent
