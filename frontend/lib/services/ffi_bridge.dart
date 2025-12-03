import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import '../models/models.dart';

// Type definitions for C functions
typedef InitDBNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> dbPath);
typedef InitDBDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> dbPath);

typedef AddProblemNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> jsonData);
typedef AddProblemDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> jsonData);

typedef UpdateProblemNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> jsonData);
typedef UpdateProblemDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> jsonData);

typedef DeleteProblemNative = ffi.Pointer<Utf8> Function(ffi.Int32 id);
typedef DeleteProblemDart = ffi.Pointer<Utf8> Function(int id);

typedef GetProblemNative = ffi.Pointer<Utf8> Function(ffi.Int32 id);
typedef GetProblemDart = ffi.Pointer<Utf8> Function(int id);

typedef GetProblemsNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> filterJSON);
typedef GetProblemsDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> filterJSON);

typedef AddTagNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> name);
typedef AddTagDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> name);

typedef GetTagsNative = ffi.Pointer<Utf8> Function();
typedef GetTagsDart = ffi.Pointer<Utf8> Function();

typedef DeleteTagNative = ffi.Pointer<Utf8> Function(ffi.Int32 id);
typedef DeleteTagDart = ffi.Pointer<Utf8> Function(int id);

typedef GetStatisticsNative = ffi.Pointer<Utf8> Function();
typedef GetStatisticsDart = ffi.Pointer<Utf8> Function();

typedef ExportDataNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> format, ffi.Pointer<Utf8> filePath);
typedef ExportDataDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> format, ffi.Pointer<Utf8> filePath);

typedef ImportDataNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> format, ffi.Pointer<Utf8> filePath);
typedef ImportDataDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> format, ffi.Pointer<Utf8> filePath);

typedef BackupDatabaseNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> dbPath, ffi.Pointer<Utf8> backupPath);
typedef BackupDatabaseDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> dbPath, ffi.Pointer<Utf8> backupPath);

typedef RestoreDatabaseNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> dbPath, ffi.Pointer<Utf8> backupPath);
typedef RestoreDatabaseDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> dbPath, ffi.Pointer<Utf8> backupPath);

typedef FreeStringNative = ffi.Void Function(ffi.Pointer<Utf8> str);
typedef FreeStringDart = void Function(ffi.Pointer<Utf8> str);

class FFIBridge {
  late final ffi.DynamicLibrary _lib;
  late final InitDBDart _initDB;
  late final AddProblemDart _addProblem;
  late final UpdateProblemDart _updateProblem;
  late final DeleteProblemDart _deleteProblem;
  late final GetProblemDart _getProblem;
  late final GetProblemsDart _getProblems;
  late final AddTagDart _addTag;
  late final GetTagsDart _getTags;
  late final DeleteTagDart _deleteTag;
  late final GetStatisticsDart _getStatistics;
  late final ExportDataDart _exportData;
  late final ImportDataDart _importData;
  late final BackupDatabaseDart _backupDatabase;
  late final RestoreDatabaseDart _restoreDatabase;
  late final FreeStringDart _freeString;

  String? _dbPath;

  FFIBridge() {
    _loadLibrary();
    _bindFunctions();
  }

  void _loadLibrary() {
    // Determine the library path based on platform
    String libraryPath;
    
    if (Platform.isLinux) {
      // Look for the library in the backend directory
      final currentDir = Directory.current.path;
      final backendLib = path.join(currentDir, '..', 'backend', 'libalgorithm_tracker.so');
      
      if (File(backendLib).existsSync()) {
        libraryPath = backendLib;
      } else {
        // Try relative to executable
        libraryPath = path.join(path.dirname(Platform.resolvedExecutable), 'lib', 'libalgorithm_tracker.so');
      }
    } else if (Platform.isWindows) {
      libraryPath = 'algorithm_tracker.dll';
    } else if (Platform.isMacOS) {
      libraryPath = 'libalgorithm_tracker.dylib';
    } else {
      throw UnsupportedError('Platform not supported');
    }

    try {
      _lib = ffi.DynamicLibrary.open(libraryPath);
    } catch (e) {
      throw Exception('Failed to load library from $libraryPath: $e');
    }
  }

  void _bindFunctions() {
    _initDB = _lib.lookupFunction<InitDBNative, InitDBDart>('InitDB');
    _addProblem = _lib.lookupFunction<AddProblemNative, AddProblemDart>('AddProblem');
    _updateProblem = _lib.lookupFunction<UpdateProblemNative, UpdateProblemDart>('UpdateProblem');
    _deleteProblem = _lib.lookupFunction<DeleteProblemNative, DeleteProblemDart>('DeleteProblem');
    _getProblem = _lib.lookupFunction<GetProblemNative, GetProblemDart>('GetProblem');
    _getProblems = _lib.lookupFunction<GetProblemsNative, GetProblemsDart>('GetProblems');
    _addTag = _lib.lookupFunction<AddTagNative, AddTagDart>('AddTag');
    _getTags = _lib.lookupFunction<GetTagsNative, GetTagsDart>('GetTags');
    _deleteTag = _lib.lookupFunction<DeleteTagNative, DeleteTagDart>('DeleteTag');
    _getStatistics = _lib.lookupFunction<GetStatisticsNative, GetStatisticsDart>('GetStatistics');
    _exportData = _lib.lookupFunction<ExportDataNative, ExportDataDart>('ExportData');
    _importData = _lib.lookupFunction<ImportDataNative, ImportDataDart>('ImportData');
    _backupDatabase = _lib.lookupFunction<BackupDatabaseNative, BackupDatabaseDart>('BackupDatabase');
    _restoreDatabase = _lib.lookupFunction<RestoreDatabaseNative, RestoreDatabaseDart>('RestoreDatabase');
    _freeString = _lib.lookupFunction<FreeStringNative, FreeStringDart>('FreeString');
  }

  ApiResponse _callNative(ffi.Pointer<Utf8> result) {
    final jsonString = result.toDartString();
    _freeString(result);
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ApiResponse.fromJson(json);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: $e',
      );
    }
  }

  Future<void> initDatabase(String dbPath) async {
    _dbPath = dbPath;
    final dbPathPtr = dbPath.toNativeUtf8();
    final result = _initDB(dbPathPtr);
    malloc.free(dbPathPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to initialize database');
    }
  }

  Future<Problem> addProblem(Problem problem) async {
    final jsonData = jsonEncode(problem.toJson());
    final jsonDataPtr = jsonData.toNativeUtf8();
    final result = _addProblem(jsonDataPtr);
    malloc.free(jsonDataPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to add problem');
    }
    
    return Problem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Problem> updateProblem(Problem problem) async {
    final jsonData = jsonEncode(problem.toJson());
    final jsonDataPtr = jsonData.toNativeUtf8();
    final result = _updateProblem(jsonDataPtr);
    malloc.free(jsonDataPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to update problem');
    }
    
    return Problem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProblem(int id) async {
    final result = _deleteProblem(id);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete problem');
    }
  }

  Future<Problem> getProblem(int id) async {
    final result = _getProblem(id);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to get problem');
    }
    
    return Problem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Problem>> getProblems({ProblemFilter? filter}) async {
    final filterJson = filter != null && !filter.isEmpty
        ? jsonEncode(filter.toJson())
        : '{}';
    final filterJsonPtr = filterJson.toNativeUtf8();
    final result = _getProblems(filterJsonPtr);
    malloc.free(filterJsonPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to get problems');
    }
    
    final List<dynamic> problemsJson = response.data as List<dynamic>? ?? [];
    return problemsJson
        .map((json) => Problem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Tag> addTag(String name) async {
    final namePtr = name.toNativeUtf8();
    final result = _addTag(namePtr);
    malloc.free(namePtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to add tag');
    }
    
    return Tag.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Tag>> getTags() async {
    final result = _getTags();
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to get tags');
    }
    
    final List<dynamic> tagsJson = response.data as List<dynamic>? ?? [];
    return tagsJson
        .map((json) => Tag.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteTag(int id) async {
    final result = _deleteTag(id);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete tag');
    }
  }

  Future<Statistics> getStatistics() async {
    final result = _getStatistics();
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to get statistics');
    }
    
    return Statistics.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> exportData(String format, String filePath) async {
    final formatPtr = format.toNativeUtf8();
    final filePathPtr = filePath.toNativeUtf8();
    final result = _exportData(formatPtr, filePathPtr);
    malloc.free(formatPtr);
    malloc.free(filePathPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to export data');
    }
  }

  Future<void> importData(String format, String filePath) async {
    final formatPtr = format.toNativeUtf8();
    final filePathPtr = filePath.toNativeUtf8();
    final result = _importData(formatPtr, filePathPtr);
    malloc.free(formatPtr);
    malloc.free(filePathPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to import data');
    }
  }

  Future<void> backupDatabase(String backupPath) async {
    if (_dbPath == null) {
      throw Exception('Database not initialized');
    }
    
    final dbPathPtr = _dbPath!.toNativeUtf8();
    final backupPathPtr = backupPath.toNativeUtf8();
    final result = _backupDatabase(dbPathPtr, backupPathPtr);
    malloc.free(dbPathPtr);
    malloc.free(backupPathPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to backup database');
    }
  }

  Future<void> restoreDatabase(String backupPath) async {
    if (_dbPath == null) {
      throw Exception('Database not initialized');
    }
    
    final dbPathPtr = _dbPath!.toNativeUtf8();
    final backupPathPtr = backupPath.toNativeUtf8();
    final result = _restoreDatabase(dbPathPtr, backupPathPtr);
    malloc.free(dbPathPtr);
    malloc.free(backupPathPtr);
    
    final response = _callNative(result);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to restore database');
    }
  }
}
