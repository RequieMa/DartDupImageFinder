import 'package:dup_image_finder/dup_image_finder.dart';
// 命令行使用示例
void main() async {
  // print(loadImage("example/example_img/cat.png"));
  // print(loadImage("example/example_img/gray21.512.tiff", targetSize: [8, 8], isGrayscale: true));
  var hasher = AHash();
  // final hash = hasher.encodeImage("example/example_img/gray21.512.tiff");
  // print(hash);
  final hashMap = hasher.encodeImages("example/example_img/");
  print(hashMap);
}