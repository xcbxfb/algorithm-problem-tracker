package database

import (
	"database/sql"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
)

var db *sql.DB

// Initialize initializes the database connection and creates tables
func Initialize(dbPath string) error {
	var err error
	db, err = sql.Open("sqlite3", dbPath)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}

	// Enable foreign keys
	if _, err := db.Exec("PRAGMA foreign_keys = ON"); err != nil {
		return fmt.Errorf("failed to enable foreign keys: %w", err)
	}

	// Create tables
	if err := createTables(); err != nil {
		return fmt.Errorf("failed to create tables: %w", err)
	}

	return nil
}

// GetDB returns the database instance
func GetDB() *sql.DB {
	return db
}

// Close closes the database connection
func Close() error {
	if db != nil {
		return db.Close()
	}
	return nil
}

// createTables creates all necessary database tables
func createTables() error {
	schema := `
	CREATE TABLE IF NOT EXISTS problems (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		link TEXT DEFAULT '',
		platform TEXT NOT NULL,
		difficulty TEXT NOT NULL,
		solve_time INTEGER DEFAULT 0,
		notes TEXT,
		code_snippet TEXT,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
		updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS tags (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT UNIQUE NOT NULL,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS problem_tags (
		problem_id INTEGER,
		tag_id INTEGER,
		PRIMARY KEY (problem_id, tag_id),
		FOREIGN KEY (problem_id) REFERENCES problems(id) ON DELETE CASCADE,
		FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
	);

	CREATE INDEX IF NOT EXISTS idx_problems_difficulty ON problems(difficulty);
	CREATE INDEX IF NOT EXISTS idx_problems_platform ON problems(platform);
	CREATE INDEX IF NOT EXISTS idx_problems_created_at ON problems(created_at);
	CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
	`

	_, err := db.Exec(schema)
	if err != nil {
		return err
	}

	// Migration: Add link column if it doesn't exist
	// We ignore the error because it will fail if the column already exists
	// This is a simple migration strategy for SQLite
	db.Exec("ALTER TABLE problems ADD COLUMN link TEXT DEFAULT ''")
	
	return nil
}
