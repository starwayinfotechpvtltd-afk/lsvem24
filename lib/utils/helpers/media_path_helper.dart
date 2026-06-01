import 'dart:io';

/// Normalizes local file paths (Windows backslashes, trim).
String normalizeLocalPath(String path) => path.trim().replaceAll('\\', '/');

bool localFileExists(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  return File(normalizeLocalPath(path)).existsSync();
}

String localFilePath(String path) => File(normalizeLocalPath(path)).path;
