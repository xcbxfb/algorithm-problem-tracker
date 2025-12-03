package api

import (
	"encoding/json"
	"fmt"

	"github.com/algorithmtracker/backend/internal/database"
	"github.com/algorithmtracker/backend/internal/models"
	"github.com/algorithmtracker/backend/internal/service"
)

var svc *service.Service

// InitDB initializes the database
func InitDB(dbPath string) string {
	if err := database.Initialize(dbPath); err != nil {
		return errorResponse(err.Error())
	}
	
	svc = service.NewService()
	return successResponse("Database initialized successfully", nil)
}

// AddProblem adds a new problem
func AddProblem(jsonData string) string {
	var problem models.Problem
	if err := json.Unmarshal([]byte(jsonData), &problem); err != nil {
		return errorResponse(fmt.Sprintf("Invalid JSON: %v", err))
	}

	if err := svc.CreateProblem(&problem); err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Problem added successfully", problem)
}

// UpdateProblem updates an existing problem
func UpdateProblem(jsonData string) string {
	var problem models.Problem
	if err := json.Unmarshal([]byte(jsonData), &problem); err != nil {
		return errorResponse(fmt.Sprintf("Invalid JSON: %v", err))
	}

	if err := svc.UpdateProblem(&problem); err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Problem updated successfully", problem)
}

// DeleteProblem deletes a problem by ID
func DeleteProblem(id int) string {
	if err := svc.DeleteProblem(id); err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Problem deleted successfully", nil)
}

// GetProblem retrieves a problem by ID
func GetProblem(id int) string {
	problem, err := svc.GetProblem(id)
	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Problem retrieved successfully", problem)
}

// GetProblems retrieves problems with optional filtering
func GetProblems(filterJSON string) string {
	var filter *models.ProblemFilter
	
	if filterJSON != "" && filterJSON != "{}" {
		filter = &models.ProblemFilter{}
		if err := json.Unmarshal([]byte(filterJSON), filter); err != nil {
			return errorResponse(fmt.Sprintf("Invalid filter JSON: %v", err))
		}
	}

	problems, err := svc.GetProblems(filter)
	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Problems retrieved successfully", problems)
}

// AddTag adds a new tag
func AddTag(name string) string {
	tag, err := svc.CreateTag(name)
	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Tag added successfully", tag)
}

// GetTags retrieves all tags
func GetTags() string {
	tags, err := svc.GetTags()
	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Tags retrieved successfully", tags)
}

// DeleteTag deletes a tag by ID
func DeleteTag(id int) string {
	if err := svc.DeleteTag(id); err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Tag deleted successfully", nil)
}

// GetStatistics retrieves problem statistics
func GetStatistics() string {
	stats, err := svc.GetStatistics()
	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Statistics retrieved successfully", stats)
}

// ExportData exports data to file
func ExportData(format, filePath string) string {
	var err error
	
	switch format {
	case "json":
		err = svc.ExportToJSON(filePath)
	case "csv":
		err = svc.ExportToCSV(filePath)
	default:
		return errorResponse("Invalid format. Use 'json' or 'csv'")
	}

	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Data exported successfully", nil)
}

// ImportData imports data from file
func ImportData(format, filePath string) string {
	var err error
	
	switch format {
	case "json":
		err = svc.ImportFromJSON(filePath)
	default:
		return errorResponse("Only JSON import is supported")
	}

	if err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Data imported successfully", nil)
}

// BackupDatabase backs up the database
func BackupDatabase(dbPath, backupPath string) string {
	if err := svc.BackupDatabase(dbPath, backupPath); err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Database backed up successfully", nil)
}

// RestoreDatabase restores the database from backup
func RestoreDatabase(dbPath, backupPath string) string {
	// Close current database connection
	database.Close()
	
	if err := svc.RestoreDatabase(dbPath, backupPath); err != nil {
		return errorResponse(err.Error())
	}

	// Reinitialize database
	if err := database.Initialize(dbPath); err != nil {
		return errorResponse(err.Error())
	}

	return successResponse("Database restored successfully", nil)
}

// Helper functions

func successResponse(message string, data interface{}) string {
	response := models.Response{
		Success: true,
		Message: message,
		Data:    data,
	}
	
	jsonData, _ := json.Marshal(response)
	return string(jsonData)
}

func errorResponse(message string) string {
	response := models.Response{
		Success: false,
		Message: message,
	}
	
	jsonData, _ := json.Marshal(response)
	return string(jsonData)
}
