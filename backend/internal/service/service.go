package service

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"os"

	"github.com/algorithmtracker/backend/internal/models"
	"github.com/algorithmtracker/backend/internal/repository"
)

// Service handles business logic
type Service struct {
	repo *repository.Repository
}

// NewService creates a new service instance
func NewService() *Service {
	return &Service{
		repo: repository.NewRepository(),
	}
}

// CreateProblem creates a new problem with validation
func (s *Service) CreateProblem(problem *models.Problem) error {
	if err := s.validateProblem(problem); err != nil {
		return err
	}
	return s.repo.CreateProblem(problem)
}

// UpdateProblem updates a problem with validation
func (s *Service) UpdateProblem(problem *models.Problem) error {
	if err := s.validateProblem(problem); err != nil {
		return err
	}
	return s.repo.UpdateProblem(problem)
}

// DeleteProblem deletes a problem
func (s *Service) DeleteProblem(id int) error {
	return s.repo.DeleteProblem(id)
}

// GetProblem retrieves a problem by ID
func (s *Service) GetProblem(id int) (*models.Problem, error) {
	return s.repo.GetProblem(id)
}

// GetProblems retrieves problems with filtering
func (s *Service) GetProblems(filter *models.ProblemFilter) ([]models.Problem, error) {
	return s.repo.GetProblems(filter)
}

// CreateTag creates a new tag
func (s *Service) CreateTag(name string) (*models.Tag, error) {
	if name == "" {
		return nil, fmt.Errorf("tag name cannot be empty")
	}
	return s.repo.CreateTag(name)
}

// GetTags retrieves all tags
func (s *Service) GetTags() ([]models.Tag, error) {
	return s.repo.GetTags()
}

// DeleteTag deletes a tag
func (s *Service) DeleteTag(id int) error {
	return s.repo.DeleteTag(id)
}

// GetStatistics retrieves statistics
func (s *Service) GetStatistics() (*models.Statistics, error) {
	return s.repo.GetStatistics()
}

// ExportToJSON exports problems to JSON file
func (s *Service) ExportToJSON(filePath string) error {
	problems, err := s.repo.GetProblems(nil)
	if err != nil {
		return err
	}

	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	encoder.SetIndent("", "  ")
	return encoder.Encode(problems)
}

// ExportToCSV exports problems to CSV file
func (s *Service) ExportToCSV(filePath string) error {
	problems, err := s.repo.GetProblems(nil)
	if err != nil {
		return err
	}

	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write header
	header := []string{"ID", "Name", "Link", "Platform", "Difficulty", "SolveTime", "Tags", "Notes", "CreatedAt"}
	if err := writer.Write(header); err != nil {
		return err
	}

	// Write data
	for _, p := range problems {
		tags := ""
		for i, tag := range p.Tags {
			if i > 0 {
				tags += "; "
			}
			tags += tag.Name
		}

		record := []string{
			fmt.Sprintf("%d", p.ID),
			p.Name,
			p.Link,
			p.Platform,
			p.Difficulty,
			fmt.Sprintf("%d", p.SolveTime),
			tags,
			p.Notes,
			p.CreatedAt.Format("2006-01-02 15:04:05"),
		}
		if err := writer.Write(record); err != nil {
			return err
		}
	}

	return nil
}

// ImportFromJSON imports problems from JSON file
func (s *Service) ImportFromJSON(filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	var problems []models.Problem
	decoder := json.NewDecoder(file)
	if err := decoder.Decode(&problems); err != nil {
		return err
	}

	for _, problem := range problems {
		problem.ID = 0 // Reset ID to create new records
		if err := s.repo.CreateProblem(&problem); err != nil {
			return err
		}
	}

	return nil
}

// BackupDatabase backs up the database file
func (s *Service) BackupDatabase(dbPath, backupPath string) error {
	sourceFile, err := os.Open(dbPath)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	destFile, err := os.Create(backupPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, sourceFile)
	return err
}

// RestoreDatabase restores the database from a backup
func (s *Service) RestoreDatabase(dbPath, backupPath string) error {
	sourceFile, err := os.Open(backupPath)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	destFile, err := os.Create(dbPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, sourceFile)
	return err
}

// validateProblem validates problem data
func (s *Service) validateProblem(problem *models.Problem) error {
	if problem.Name == "" {
		return fmt.Errorf("problem name is required")
	}
	if problem.Platform == "" {
		return fmt.Errorf("platform is required")
	}
	if problem.Difficulty == "" {
		return fmt.Errorf("difficulty is required")
	}
	
	// Validate difficulty level
	validDifficulties := map[string]bool{
		"Easy":   true,
		"Medium": true,
		"Hard":   true,
	}
	if !validDifficulties[problem.Difficulty] {
		return fmt.Errorf("difficulty must be Easy, Medium, or Hard")
	}

	return nil
}
