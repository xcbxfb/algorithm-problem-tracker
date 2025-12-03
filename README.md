# Algorithm Problem Tracker

A cross-platform desktop application for tracking and managing algorithm problems solved across various coding platforms. Built with Flutter (frontend) and Go (backend) using FFI for seamless integration.

## Features

- ✅ **Problem Management**: Add, edit, delete, and view algorithm problems
- 🏷️ **Tag System**: Organize problems with custom knowledge point tags
- 🔍 **Advanced Filtering**: Filter by difficulty, platform, date, and tags
- 📊 **Statistics Dashboard**: Track your progress with detailed statistics
- 💾 **Export/Import**: Export data to CSV or JSON formats
- 🔄 **Backup/Restore**: Backup and restore your database
- 🎨 **Modern UI**: Clean, intuitive interface with Material 3 design
- 🌙 **Dark Mode**: Automatic dark mode support

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Go
- **Database**: SQLite
- **Integration**: FFI (Foreign Function Interface)

## Project Structure

```
AlgorithmProblemTracker/
├── backend/                    # Go backend
│   ├── cmd/lib/               # Shared library entry point
│   ├── internal/              # Internal packages
│   │   ├── database/          # Database layer
│   │   ├── models/            # Data models
│   │   ├── repository/        # Data access layer
│   │   └── service/           # Business logic
│   ├── pkg/api/               # FFI API
│   ├── go.mod                 # Go module definition
│   └── Makefile               # Build scripts
├── frontend/                   # Flutter frontend
│   ├── lib/
│   │   ├── models/            # Dart data models
│   │   ├── services/          # FFI bindings & services
│   │   ├── screens/           # UI screens
│   │   ├── widgets/           # Reusable widgets
│   │   └── main.dart          # App entry point
│   └── pubspec.yaml           # Flutter dependencies
└── README.md                  # This file
```

## Prerequisites

### Backend (Go)
- Go 1.21 or higher
- GCC (for CGO)
- Make

### Frontend (Flutter)
- Flutter SDK 3.9.2 or higher
- Dart SDK

## Building

### 1. Build the Go Backend

```bash
cd backend
make deps          # Download dependencies
make build-linux   # Build for Linux
# or
make build-windows # Build for Windows
# or
make build-macos   # Build for macOS
```

This will generate a shared library:
- Linux: `libalgorithm_tracker.so`
- Windows: `algorithm_tracker.dll`
- macOS: `libalgorithm_tracker.dylib`

### 2. Run the Flutter Frontend

```bash
cd frontend
flutter pub get    # Get dependencies
flutter run -d linux  # Run on Linux
# or
flutter run -d windows  # Run on Windows
# or
flutter run -d macos    # Run on macOS
```

## Usage

### Adding a Problem

1. Click the **"Add Problem"** floating action button
2. Fill in the problem details:
   - Name (required)
   - Platform (required)
   - Difficulty (Easy/Medium/Hard)
   - Solve time in minutes
   - Tags (select or create new)
   - Notes
   - Code snippet
3. Click the checkmark to save

### Filtering Problems

1. Click the filter icon in the search bar
2. Select filters:
   - Difficulty level
   - Platform name
   - Tags
3. Click **"Apply"** to filter

### Viewing Statistics

1. Click the bar chart icon in the app bar
2. View statistics by:
   - Total problems
   - Difficulty distribution
   - Platform distribution
   - Tag distribution
   - Average solve time

### Managing Tags

1. Click the label icon in the app bar
2. View all tags and their usage count
3. Delete tags as needed (removes from all problems)

### Export/Import Data

1. Go to Settings (gear icon)
2. Choose export format (JSON or CSV)
3. Select destination file
4. For import, select a JSON file

### Backup/Restore Database

1. Go to Settings
2. Click **"Backup Database"** to create a backup
3. Click **"Restore Database"** to restore from a backup file

## Database Schema

### Problems Table
- `id`: Primary key
- `name`: Problem name
- `platform`: Coding platform
- `difficulty`: Easy/Medium/Hard
- `solve_time`: Time taken in minutes
- `notes`: User notes
- `code_snippet`: Solution code
- `created_at`: Creation timestamp
- `updated_at`: Update timestamp

### Tags Table
- `id`: Primary key
- `name`: Tag name (unique)
- `created_at`: Creation timestamp

### Problem_Tags Table
- `problem_id`: Foreign key to problems
- `tag_id`: Foreign key to tags

## Development

### Running Tests

Backend:
```bash
cd backend
go test ./...
```

Frontend:
```bash
cd frontend
flutter test
```

### Building for Production

Backend:
```bash
cd backend
make build-linux  # or build-windows, build-macos
```

Frontend:
```bash
cd frontend
flutter build linux  # or windows, macos
```

## Troubleshooting

### Library Not Found Error

If you get a library loading error, ensure:
1. The Go shared library is built in the `backend/` directory
2. The library path in `ffi_bridge.dart` is correct
3. For Linux, you may need to set `LD_LIBRARY_PATH`

### Database Initialization Error

If the app fails to initialize:
1. Check file permissions in the application documents directory
2. Ensure SQLite is properly installed
3. Check the error message in the UI

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please open an issue on the project repository.
