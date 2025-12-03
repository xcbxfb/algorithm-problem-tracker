package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/algorithmtracker/backend/internal/database"
	"github.com/algorithmtracker/backend/internal/models"
)

// Repository handles data access operations
type Repository struct {
	db *sql.DB
}

// NewRepository creates a new repository instance
func NewRepository() *Repository {
	return &Repository{
		db: database.GetDB(),
	}
}

// CreateProblem creates a new problem record
func (r *Repository) CreateProblem(problem *models.Problem) error {
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Insert problem
	now := models.CustomTime{Time: time.Now()}
	result, err := tx.Exec(`
		INSERT INTO problems (name, link, platform, difficulty, solve_time, notes, code_snippet, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, problem.Name, problem.Link, problem.Platform, problem.Difficulty, problem.SolveTime, 
	   problem.Notes, problem.CodeSnippet, now.Time, now.Time)
	
	if err != nil {
		return err
	}

	problemID, err := result.LastInsertId()
	if err != nil {
		return err
	}
	problem.ID = int(problemID)

	// Insert tags
	for _, tag := range problem.Tags {
		tagID, err := r.getOrCreateTag(tx, tag.Name)
		if err != nil {
			return err
		}

		_, err = tx.Exec(`
			INSERT INTO problem_tags (problem_id, tag_id)
			VALUES (?, ?)
		`, problemID, tagID)
		
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

// UpdateProblem updates an existing problem record
func (r *Repository) UpdateProblem(problem *models.Problem) error {
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Update problem
	_, err = tx.Exec(`
		UPDATE problems 
		SET name = ?, link = ?, platform = ?, difficulty = ?, solve_time = ?, 
		    notes = ?, code_snippet = ?, updated_at = ?
		WHERE id = ?
	`, problem.Name, problem.Link, problem.Platform, problem.Difficulty, problem.SolveTime,
	   problem.Notes, problem.CodeSnippet, time.Now(), problem.ID)
	
	if err != nil {
		return err
	}

	// Delete existing tag associations
	_, err = tx.Exec("DELETE FROM problem_tags WHERE problem_id = ?", problem.ID)
	if err != nil {
		return err
	}

	// Insert new tags
	for _, tag := range problem.Tags {
		tagID, err := r.getOrCreateTag(tx, tag.Name)
		if err != nil {
			return err
		}

		_, err = tx.Exec(`
			INSERT INTO problem_tags (problem_id, tag_id)
			VALUES (?, ?)
		`, problem.ID, tagID)
		
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

// DeleteProblem deletes a problem by ID
func (r *Repository) DeleteProblem(id int) error {
	_, err := r.db.Exec("DELETE FROM problems WHERE id = ?", id)
	return err
}

// GetProblem retrieves a problem by ID
func (r *Repository) GetProblem(id int) (*models.Problem, error) {
	problem := &models.Problem{}
	
	err := r.db.QueryRow(`
		SELECT id, name, link, platform, difficulty, solve_time, notes, code_snippet, created_at, updated_at
		FROM problems WHERE id = ?
	`, id).Scan(&problem.ID, &problem.Name, &problem.Link, &problem.Platform, &problem.Difficulty,
		&problem.SolveTime, &problem.Notes, &problem.CodeSnippet, &problem.CreatedAt, &problem.UpdatedAt)
	
	if err != nil {
		return nil, err
	}

	// Load tags
	tags, err := r.getTagsForProblem(problem.ID)
	if err != nil {
		return nil, err
	}
	problem.Tags = tags

	return problem, nil
}

// GetProblems retrieves problems with optional filtering
func (r *Repository) GetProblems(filter *models.ProblemFilter) ([]models.Problem, error) {
	query := `
		SELECT DISTINCT p.id, p.name, p.link, p.platform, p.difficulty, p.solve_time, 
		       p.notes, p.code_snippet, p.created_at, p.updated_at
		FROM problems p
	`
	
	var conditions []string
	var args []interface{}

	// Join with tags if filtering by tags
	if filter != nil && len(filter.Tags) > 0 {
		query += `
			INNER JOIN problem_tags pt ON p.id = pt.problem_id
			INNER JOIN tags t ON pt.tag_id = t.id
		`
		placeholders := make([]string, len(filter.Tags))
		for i, tag := range filter.Tags {
			placeholders[i] = "?"
			args = append(args, tag)
		}
		conditions = append(conditions, fmt.Sprintf("t.name IN (%s)", strings.Join(placeholders, ",")))
	}

	// Apply filters
	if filter != nil {
		if filter.Difficulty != "" {
			conditions = append(conditions, "p.difficulty = ?")
			args = append(args, filter.Difficulty)
		}
		if filter.Platform != "" {
			conditions = append(conditions, "p.platform = ?")
			args = append(args, filter.Platform)
		}
		if filter.SearchQuery != "" {
			conditions = append(conditions, "p.name LIKE ?")
			args = append(args, "%"+filter.SearchQuery+"%")
		}
		if filter.StartDate != "" {
			conditions = append(conditions, "p.created_at >= ?")
			args = append(args, filter.StartDate)
		}
		if filter.EndDate != "" {
			conditions = append(conditions, "p.created_at <= ?")
			args = append(args, filter.EndDate)
		}
	}

	if len(conditions) > 0 {
		query += " WHERE " + strings.Join(conditions, " AND ")
	}

	query += " ORDER BY p.created_at DESC"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var problems []models.Problem
	for rows.Next() {
		var p models.Problem
		err := rows.Scan(&p.ID, &p.Name, &p.Link, &p.Platform, &p.Difficulty, &p.SolveTime,
			&p.Notes, &p.CodeSnippet, &p.CreatedAt, &p.UpdatedAt)
		if err != nil {
			return nil, err
		}

		// Load tags for each problem
		tags, err := r.getTagsForProblem(p.ID)
		if err != nil {
			return nil, err
		}
		p.Tags = tags

		problems = append(problems, p)
	}

	return problems, nil
}

// CreateTag creates a new tag
func (r *Repository) CreateTag(name string) (*models.Tag, error) {
	result, err := r.db.Exec(`
		INSERT INTO tags (name, created_at)
		VALUES (?, ?)
	`, name, time.Now())
	
	if err != nil {
		return nil, err
	}

	id, err := result.LastInsertId()
	if err != nil {
		return nil, err
	}

	return &models.Tag{
		ID:        int(id),
		Name:      name,
		CreatedAt: models.CustomTime{Time: time.Now()},
	}, nil
}

// GetTags retrieves all tags
func (r *Repository) GetTags() ([]models.Tag, error) {
	rows, err := r.db.Query("SELECT id, name, created_at FROM tags ORDER BY name")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tags []models.Tag
	for rows.Next() {
		var tag models.Tag
		err := rows.Scan(&tag.ID, &tag.Name, &tag.CreatedAt)
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}

	return tags, nil
}

// DeleteTag deletes a tag by ID
func (r *Repository) DeleteTag(id int) error {
	_, err := r.db.Exec("DELETE FROM tags WHERE id = ?", id)
	return err
}

// GetStatistics retrieves problem statistics
func (r *Repository) GetStatistics() (*models.Statistics, error) {
	stats := &models.Statistics{
		ByDifficulty: make(map[string]int),
		ByPlatform:   make(map[string]int),
		ByTag:        make(map[string]int),
	}

	// Total problems
	err := r.db.QueryRow("SELECT COUNT(*) FROM problems").Scan(&stats.TotalProblems)
	if err != nil {
		return nil, err
	}

	// By difficulty
	rows, err := r.db.Query("SELECT difficulty, COUNT(*) FROM problems GROUP BY difficulty")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var difficulty string
		var count int
		if err := rows.Scan(&difficulty, &count); err != nil {
			return nil, err
		}
		stats.ByDifficulty[difficulty] = count
	}

	// By platform
	rows, err = r.db.Query("SELECT platform, COUNT(*) FROM problems GROUP BY platform")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var platform string
		var count int
		if err := rows.Scan(&platform, &count); err != nil {
			return nil, err
		}
		stats.ByPlatform[platform] = count
	}

	// By tag
	rows, err = r.db.Query(`
		SELECT t.name, COUNT(DISTINCT pt.problem_id)
		FROM tags t
		LEFT JOIN problem_tags pt ON t.id = pt.tag_id
		GROUP BY t.id, t.name
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var tagName string
		var count int
		if err := rows.Scan(&tagName, &count); err != nil {
			return nil, err
		}
		stats.ByTag[tagName] = count
	}

	// Average solve time
	err = r.db.QueryRow("SELECT COALESCE(AVG(solve_time), 0.0) FROM problems WHERE solve_time > 0").Scan(&stats.AverageSolveTime)
	if err != nil && err != sql.ErrNoRows {
		return nil, err
	}

	return stats, nil
}

// Helper functions

func (r *Repository) getOrCreateTag(tx *sql.Tx, name string) (int, error) {
	var tagID int
	err := tx.QueryRow("SELECT id FROM tags WHERE name = ?", name).Scan(&tagID)
	
	if err == sql.ErrNoRows {
		// Tag doesn't exist, create it
		result, err := tx.Exec("INSERT INTO tags (name, created_at) VALUES (?, ?)", name, time.Now())
		if err != nil {
			return 0, err
		}
		id, err := result.LastInsertId()
		if err != nil {
			return 0, err
		}
		return int(id), nil
	} else if err != nil {
		return 0, err
	}

	return tagID, nil
}

func (r *Repository) getTagsForProblem(problemID int) ([]models.Tag, error) {
	rows, err := r.db.Query(`
		SELECT t.id, t.name, t.created_at
		FROM tags t
		INNER JOIN problem_tags pt ON t.id = pt.tag_id
		WHERE pt.problem_id = ?
		ORDER BY t.name
	`, problemID)
	
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tags []models.Tag
	for rows.Next() {
		var tag models.Tag
		err := rows.Scan(&tag.ID, &tag.Name, &tag.CreatedAt)
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}

	return tags, nil
}
