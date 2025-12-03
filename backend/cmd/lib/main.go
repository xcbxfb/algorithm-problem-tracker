package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"unsafe"

	"github.com/algorithmtracker/backend/pkg/api"
)

// InitDB initializes the database
//
//export InitDB
func InitDB(dbPath *C.char) *C.char {
	goDbPath := C.GoString(dbPath)
	result := api.InitDB(goDbPath)
	return C.CString(result)
}

// AddProblem adds a new problem
//
//export AddProblem
func AddProblem(jsonData *C.char) *C.char {
	goJsonData := C.GoString(jsonData)
	result := api.AddProblem(goJsonData)
	return C.CString(result)
}

// UpdateProblem updates an existing problem
//
//export UpdateProblem
func UpdateProblem(jsonData *C.char) *C.char {
	goJsonData := C.GoString(jsonData)
	result := api.UpdateProblem(goJsonData)
	return C.CString(result)
}

// DeleteProblem deletes a problem by ID
//
//export DeleteProblem
func DeleteProblem(id C.int) *C.char {
	result := api.DeleteProblem(int(id))
	return C.CString(result)
}

// GetProblem retrieves a problem by ID
//
//export GetProblem
func GetProblem(id C.int) *C.char {
	result := api.GetProblem(int(id))
	return C.CString(result)
}

// GetProblems retrieves problems with optional filtering
//
//export GetProblems
func GetProblems(filterJSON *C.char) *C.char {
	goFilterJSON := C.GoString(filterJSON)
	result := api.GetProblems(goFilterJSON)
	return C.CString(result)
}

// AddTag adds a new tag
//
//export AddTag
func AddTag(name *C.char) *C.char {
	goName := C.GoString(name)
	result := api.AddTag(goName)
	return C.CString(result)
}

// GetTags retrieves all tags
//
//export GetTags
func GetTags() *C.char {
	result := api.GetTags()
	return C.CString(result)
}

// DeleteTag deletes a tag by ID
//
//export DeleteTag
func DeleteTag(id C.int) *C.char {
	result := api.DeleteTag(int(id))
	return C.CString(result)
}

// GetStatistics retrieves problem statistics
//
//export GetStatistics
func GetStatistics() *C.char {
	result := api.GetStatistics()
	return C.CString(result)
}

// ExportData exports data to file
//
//export ExportData
func ExportData(format *C.char, filePath *C.char) *C.char {
	goFormat := C.GoString(format)
	goFilePath := C.GoString(filePath)
	result := api.ExportData(goFormat, goFilePath)
	return C.CString(result)
}

// ImportData imports data from file
//
//export ImportData
func ImportData(format *C.char, filePath *C.char) *C.char {
	goFormat := C.GoString(format)
	goFilePath := C.GoString(filePath)
	result := api.ImportData(goFormat, goFilePath)
	return C.CString(result)
}

// BackupDatabase backs up the database
//
//export BackupDatabase
func BackupDatabase(dbPath *C.char, backupPath *C.char) *C.char {
	goDbPath := C.GoString(dbPath)
	goBackupPath := C.GoString(backupPath)
	result := api.BackupDatabase(goDbPath, goBackupPath)
	return C.CString(result)
}

// RestoreDatabase restores the database from backup
//
//export RestoreDatabase
func RestoreDatabase(dbPath *C.char, backupPath *C.char) *C.char {
	goDbPath := C.GoString(dbPath)
	goBackupPath := C.GoString(backupPath)
	result := api.RestoreDatabase(goDbPath, goBackupPath)
	return C.CString(result)
}

// FreeString frees a C string allocated by Go
//
//export FreeString
func FreeString(str *C.char) {
	C.free(unsafe.Pointer(str))
}

func main() {
	// Required for building as a shared library
}
