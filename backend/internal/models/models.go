package models

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

// CustomTime wraps time.Time to handle multiple time formats
type CustomTime struct {
	time.Time
}

// UnmarshalJSON implements json.Unmarshaler interface
func (ct *CustomTime) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), "\"")
	if s == "null" || s == "" {
		ct.Time = time.Now()
		return nil
	}

	// Try multiple time formats
	formats := []string{
		time.RFC3339,
		time.RFC3339Nano,
		"2006-01-02T15:04:05.999999999",
		"2006-01-02T15:04:05.999999",
		"2006-01-02T15:04:05.999",
		"2006-01-02T15:04:05",
		"2006-01-02 15:04:05",
	}

	var err error
	for _, format := range formats {
		ct.Time, err = time.Parse(format, s)
		if err == nil {
			return nil
		}
	}

	// If all formats fail, use current time
	ct.Time = time.Now()
	return nil
}

// MarshalJSON implements json.Marshaler interface
func (ct CustomTime) MarshalJSON() ([]byte, error) {
	return json.Marshal(ct.Time.Format(time.RFC3339))
}

// Scan implements sql.Scanner interface
func (ct *CustomTime) Scan(value interface{}) error {
	if value == nil {
		ct.Time = time.Time{}
		return nil
	}

	switch v := value.(type) {
	case time.Time:
		ct.Time = v
		return nil
	case []byte:
		t, err := time.Parse(time.RFC3339, string(v))
		if err != nil {
			// Try parsing as standard SQL format if RFC3339 fails
			t, err = time.Parse("2006-01-02 15:04:05", string(v))
		}
		ct.Time = t
		return err
	case string:
		t, err := time.Parse(time.RFC3339, v)
		if err != nil {
			t, err = time.Parse("2006-01-02 15:04:05", v)
		}
		ct.Time = t
		return err
	default:
		return fmt.Errorf("cannot scan type %T into CustomTime", value)
	}
}

// Value implements driver.Valuer interface
func (ct CustomTime) Value() (driver.Value, error) {
	return ct.Time, nil
}

// Problem represents an algorithm problem record
type Problem struct {
	ID          int        `json:"id"`
	Name        string     `json:"name"`
	Link        string     `json:"link"`
	Platform    string     `json:"platform"`
	Difficulty  string     `json:"difficulty"`
	SolveTime   int        `json:"solve_time"` // in minutes
	Notes       string     `json:"notes"`
	CodeSnippet string     `json:"code_snippet"`
	Tags        []Tag      `json:"tags"`
	CreatedAt   CustomTime `json:"created_at"`
	UpdatedAt   CustomTime `json:"updated_at"`
}

// Tag represents a knowledge point tag
type Tag struct {
	ID        int        `json:"id"`
	Name      string     `json:"name"`
	CreatedAt CustomTime `json:"created_at"`
}

// ProblemFilter represents filter criteria for querying problems
type ProblemFilter struct {
	Difficulty  string   `json:"difficulty,omitempty"`
	Platform    string   `json:"platform,omitempty"`
	Tags        []string `json:"tags,omitempty"`
	StartDate   string   `json:"start_date,omitempty"`
	EndDate     string   `json:"end_date,omitempty"`
	SearchQuery string   `json:"search_query,omitempty"`
}

// Statistics represents problem statistics
type Statistics struct {
	TotalProblems    int            `json:"total_problems"`
	ByDifficulty     map[string]int `json:"by_difficulty"`
	ByPlatform       map[string]int `json:"by_platform"`
	ByTag            map[string]int `json:"by_tag"`
	AverageSolveTime float64        `json:"average_solve_time"`
}

// Response represents a generic API response
type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}
