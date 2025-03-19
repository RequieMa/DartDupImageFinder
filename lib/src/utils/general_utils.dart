import "dart:io";
import "dart:core";
import "package:path/path.dart" as path;

List<String> generateFiles(Directory imageDir, bool recursive) {
  // var searchPattern = recursive ? "**/*" : "*";
  List<FileSystemEntity> files = imageDir
      .listSync(recursive: recursive)
      .where((entity) =>
          entity is File && !path.basename(entity.path).startsWith("."))
      .toList();
  return files.map((file) => file.path).toList();
}

List<String> generateRelativeNames(String imageDir, List<String> files) {
  final absImageDir = Directory(imageDir).absolute.path;
  return files.map((file) {
    final absFilePath = File(file).absolute.path;
    return path.relative(absFilePath, from: absImageDir);
  }).toList();
}
