# Quick Start Guide

## Prerequisites

- Go 1.21+ with GCC
- Flutter 3.9.2+
- Linux desktop environment

## Quick Start (3 steps)

### 1. Verify Backend Library

The backend library is already built. Verify it exists:

```bash
ls -lh backend/libalgorithm_tracker.so
```

If it doesn't exist, build it:

```bash
cd backend
make build-linux
cd ..
```

### 2. Get Flutter Dependencies

```bash
cd frontend
flutter pub get
cd ..
```

### 3. Run the Application

```bash
cd frontend
flutter run -d linux
```

## First Time Usage

1. The app will automatically create a database in `~/.local/share/algorithm_tracker/`
2. Click the **"+ Add Problem"** button to add your first problem
3. Fill in the problem details and save
4. Explore the features:
   - 🔍 Search and filter problems
   - 📊 View statistics (bar chart icon)
   - 🏷️ Manage tags (label icon)
   - ⚙️ Export/Import data (settings icon)

## Common Commands

### Run the app
```bash
cd frontend && flutter run -d linux
```

### Rebuild backend (if needed)
```bash
cd backend && make clean && make build-linux
```

### Clean and rebuild frontend
```bash
cd frontend && flutter clean && flutter pub get && flutter run -d linux
```

## Troubleshooting

### "Library not found" error

Set the library path:
```bash
export LD_LIBRARY_PATH=$PWD/backend:$LD_LIBRARY_PATH
cd frontend && flutter run -d linux
```

### Database permission error

Create the directory:
```bash
mkdir -p ~/.local/share/algorithm_tracker
chmod 755 ~/.local/share/algorithm_tracker
```

## Features Overview

- ✅ Add/Edit/Delete problems
- ✅ Tag system for knowledge points
- ✅ Filter by difficulty, platform, tags
- ✅ Search by name
- ✅ Statistics dashboard
- ✅ Export to JSON/CSV
- ✅ Import from JSON
- ✅ Database backup/restore
- ✅ Dark mode support

## Next Steps

See [README.md](README.md) for detailed documentation.

See [walkthrough.md](../../../.gemini/antigravity/brain/be8ef31b-3608-4d6f-9573-9f2a040a56cb/walkthrough.md) for complete project walkthrough.
