# Care247 — Customer Search Assignment

Flutter mobile application developed for the Care247 technical assessment. It provides customer lookup and profile viewing against a mock REST backend (or bundled offline dataset), built using a configuration-driven form architecture and Provider-based state management.

---

## Assumptions Made

As noted in the assignment brief, here are the core assumptions I made while designing and implementing the solution:

1. **Search Behavior & Criteria Combination**
   - When multiple search criteria are provided (e.g., First Name and Date of Birth), they are evaluated using **AND** logic—only customers matching all non-empty criteria are returned.
   - Text matching on names is case-insensitive and supports substring matching (e.g., searching "john" or "John" matches "Johnathan").
   - If the search is submitted with all fields left empty, the application returns all customers, allowing reviewers or users to browse the full dataset.

2. **Date Format Tolerance**
   - Mock data and user input can sometimes mix date formats (e.g., `YYYY-MM-DD` vs `DD/MM/YYYY`). I added a lightweight date normalizer in the repository layer to ensure date searches match reliably regardless of formatting differences.
   - For the UI, date input uses Flutter's native date picker rather than free-form typing, ensuring consistent formatting and avoiding user input errors.

3. **Configuration-Driven Form Extensibility**
   - Assumed the requirement for dynamic fields meant that adding, removing, or re-ordering search criteria should be possible purely by modifying a configuration list, without touching any widget or screen code.
   - Assumed search fields would span different input types (free text, calendar pickers, and predefined selection dropdowns), so I defined a `FieldType` enum supporting text, date, and dropdown inputs.

4. **Network & Testing Convenience**
   - Testing mobile apps against local `json-server` often runs into host routing issues (`localhost` works on desktop/iOS simulator, but Android emulator requires `10.0.2.2`, and physical phones require LAN IPs). To make testing painless for the reviewer, I implemented automatic host discovery and an in-app server configuration sheet.
   - I also assumed the reviewer might want to test the app without installing Node.js or running `json-server` at all. The app therefore includes an **Offline Demo Mode** that loads directly from the bundled `db.json` asset.

5. **Dataset Size & Pagination**
   - Given the mock dataset has 10 records, server-side pagination was omitted to keep the implementation focused and lean. However, I used `ListView.builder` for list rendering so item virtualization is in place for larger datasets.

---

## Quick Start

### Option A: Run with JSON Server (Full REST API flow)

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Start `json-server` on port 3001:**
   ```bash
   npm install -g json-server  # if not already installed
   json-server --watch db.json --port 3001
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Option B: Run without JSON Server (Offline Demo Mode)

You can run the app immediately without starting `json-server`:
```bash
flutter run
```
If the app cannot reach a running server, you can tap the database/server icon in the top-right app bar and switch to **Offline Demo Mode**. The app will load and search directly against the bundled `db.json` file.

### Platform Host Resolution

- **Android Emulator**: Automatically routes to `http://10.0.2.2:3001`.
- **iOS Simulator / Desktop / Web**: Routes to `http://localhost:3001`.
- **Physical Device**: You can set your machine's LAN IP via the in-app server dialog (top-right server icon) or pass `--dart-define=API_URL=http://<your-ip>:3001` at launch.

---

## Architecture & Code Structure

The project separates concerns into config, data, model, state, and presentation layers:

```
lib/
├── config/
│   ├── app_config.dart             # Base URLs, candidate host list & endpoint definitions
│   └── search_config.dart          # Configuration list defining the dynamic search fields
├── data/
│   ├── customer_api.dart           # HTTP client with timeout handling & candidate host failover
│   └── customer_repository.dart    # Search query filtering, date normalization & offline fallback
├── models/
│   ├── customer.dart               # Customer model with primary contact helper getters
│   ├── address.dart                # Address model
│   ├── phone.dart                  # Phone model (with isPrimary flag)
│   └── email.dart                  # Email model (with isPrimary flag)
├── screens/
│   ├── customer_search_screen.dart # Search form, server status indicator & theme switcher
│   ├── customer_results_screen.dart# Results list with pull-to-refresh
│   └── customer_detail_screen.dart # Customer detail screen with contact & address sections
├── state/
│   ├── customer_search_state.dart  # Search flow ChangeNotifier (initial, loading, success, empty, error)
│   └── theme_state.dart            # Light / Dark mode state management
├── theme/
│   └── app_theme.dart              # Material 3 light and dark theme configurations
├── widgets/
│   ├── customer_list_item.dart     # Customer summary card widget
│   ├── dynamic_field.dart          # Renders text, date picker, or dropdown based on FieldConfig
│   ├── dynamic_search_form.dart    # Manages controllers, focus nodes, and form submission
│   ├── empty_state_widget.dart     # Empty state placeholder
│   ├── error_state_widget.dart     # Error card with retry button
│   ├── server_config_sheet.dart    # Bottom sheet for server connectivity testing & demo toggle
│   └── theme_toggle_button.dart    # Animated theme mode toggle
└── main.dart                       # App entry point & Provider setup
```

### State Flow

- `CustomerSearchState` (`ChangeNotifier`) holds the current query criteria, search status (`initial`, `loading`, `success`, `empty`, `error`), and search results list.
- When the user taps "Search", the state calls `CustomerRepository.searchCustomers(criteria)`.
- The repository fetches records from `CustomerApi` (or bundled `db.json` if in demo mode) and applies the matching filters.
- UI widgets observe the state via `context.watch<CustomerSearchState>()` or `Consumer` to reactively render loading spinners, results, or error messages.

---

## Configuration-Driven Search Form

The search form is not hardcoded. Instead, fields are declared in `lib/config/search_config.dart`:

```dart
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

### Adding a New Search Field

To add a new field (for instance, **Marital Status** as a dropdown), add this single entry to `searchConfig` in `lib/config/search_config.dart`:

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

The `DynamicSearchForm` automatically sorts the fields by `renderOrder`, generates the corresponding input widget, manages its controller and focus node, and sends `maritalStatus` in the criteria map on submit. No changes are required in the UI screens or form widgets.

---

## Practical Flutter Considerations

- **Lifecycle & Resource Management**: Every `TextEditingController` and `FocusNode` created in the dynamic form is properly disposed in `dispose()`. State objects check `_isDisposed` before triggering notifications, and asynchronous UI callbacks check `context.mounted` before navigation.
- **Keyboard & Touch UX**:
  - The search screen is wrapped in a `GestureDetector` that dismisses the soft keyboard when tapping outside input fields.
  - Text fields use `TextInputAction.next` to smoothly move focus to the next field on enter.
  - The date field opens a native date picker modal with a clear icon to quickly reset the date.
- **Rendering Efficiency**: Customer results are displayed in a `ListView.builder` for on-demand rendering, and `const` constructors are utilized throughout to prevent unnecessary widget rebuilds.
- **Theme Support**: The app includes full Light and Dark theme modes (switchable from the top app bar).

---

## Trade-offs & Engineering Decisions

- **Provider vs BLoC/Riverpod**: I selected `Provider` + `ChangeNotifier` because it is straightforward, well-supported, and fits the scope of a 2-3 screen lookup app without the boilerplate, stream subscriptions, or code generation overhead that BLoC or Riverpod would require.
- **Client-Side Filtering vs JSON-Server Query Params**: `json-server` supports basic `_like` query parameters, but handling of case insensitivity and multi-format date queries can be unreliable across different platforms. The repository loads the dataset and applies deterministic filtering in Dart, including custom date normalization.
- **Manual Model Serialization**: I opted for hand-written `fromJson` / `toJson` methods instead of `json_serializable` or `freezed`. For 4 small models, this avoids adding `build_runner` dependencies and keeps build times fast.
- **Pagination**: Because the sample dataset contains only 10 items, pagination was left out. In a real-world app with large customer databases, I would implement cursor-based pagination with infinite scrolling in the repository and list view.

---

## Testing

The project includes **70 automated tests** across 7 test files:

- `test/models_test.dart`: Parsing, null-safety, primary contact getters (`fullName`, `primaryPhone`, `primaryEmail`), `toJson`, and equality.
- `test/search_config_test.dart`: Configuration sorting, completeness, and extensibility.
- `test/customer_search_state_test.dart`: State transitions (`initial` → `loading` → `success`/`empty`/`error`), criteria updates, reset, and repository mocking.
- `test/customer_repository_test.dart`: Filtering logic (name, date normalization, marital status) in live API and offline asset modes.
- `test/dynamic_field_test.dart`: Widget rendering of text, date, and dropdown fields, date picker dialog, and clear interactions.
- `test/customer_list_item_test.dart`: Customer card display, formatted dates, primary badges, tap callbacks, and missing data handling.
- `test/theme_state_test.dart`: Theme toggling logic and button rendering.

### Run all tests:

```bash
flutter test
```

---

## Time Spent

Total time spent: **~4.5 hours** (architecture, configuration-driven form, host auto-discovery & offline demo mode, theme support, and the test suite).
