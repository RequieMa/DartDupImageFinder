import "dart:core";
import "dart:io";
import "package:path/path.dart" as path;

/// Generates a list of file paths from specified directory
///
/// Scans the given directory and returns file paths that meet:
/// - Are regular files (not directories)
/// - Don't start with '.' (hidden files)
/// - Optionally includes subdirectories when [recursive] is true
///
/// [imageDir]: Root directory to scan
/// [recursive]: Enables recursive subdirectory scanning
///
/// Returns `List<String>` containing absolute file paths
List<String> generateFiles(
  Directory imageDir, {
  bool recursive = false,
}) {
  final files = imageDir
      .listSync(recursive: recursive)
      .where(
        (entity) =>
            entity is File && !path.basename(entity.path).startsWith("."),
      )
      .toList();
  return files.map((file) => file.path).toList();
}

/// Converts absolute file paths to relative paths from base directory
///
/// Takes a list of absolute file paths and converts them to paths relative
/// to the specified [imageDir]. Handles path normalization across platforms.
///
/// [imageDir]: Base directory for relative path calculation
/// [files]: List of absolute file paths to convert
///
/// Returns `List<String>` of platform-agnostic relative paths
///
/// Example:
/// ```dart
/// final relatives = generateRelativeNames(
///   'photos/',
///   ['photos/1.jpg', 'photos/albums/2.png']
/// );
/// // Returns ['1.jpg', 'albums/2.png']
/// ```
List<String> generateRelativeNames(String imageDir, List<String> files) {
  final absImageDir = Directory(imageDir).absolute.path;
  return files.map((file) {
    final absFilePath = File(file).absolute.path;
    return path.relative(absFilePath, from: absImageDir);
  }).toList();
}
