.PHONY: all build-linux build-windows build-macos clean test

# Build for Linux
build-linux:
	CGO_ENABLED=1 go build -buildmode=c-shared -o libalgorithm_tracker.so ./cmd/lib

# Build for Windows (requires mingw-w64)
build-windows:
	CGO_ENABLED=1 GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc go build -buildmode=c-shared -o algorithm_tracker.dll ./cmd/lib

# Build for macOS
build-macos:
	CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -buildmode=c-shared -o libalgorithm_tracker.dylib ./cmd/lib

# Build for current platform
build:
	CGO_ENABLED=1 go build -buildmode=c-shared -o libalgorithm_tracker.so ./cmd/lib

# Run tests
test:
	go test -v ./...

# Clean build artifacts
clean:
	rm -f libalgorithm_tracker.so libalgorithm_tracker.h
	rm -f algorithm_tracker.dll algorithm_tracker.h
	rm -f libalgorithm_tracker.dylib

# Download dependencies
deps:
	go mod download
	go mod tidy

# Default target
all: deps build-linux
