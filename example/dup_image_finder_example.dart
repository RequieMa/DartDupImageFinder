import "package:dup_image_finder/dup_image_finder.dart";
import "package:image_hashing/image_hashing.dart";

void main() async {
  final dupImageFinder = DupImageFinder(useML: false, hasher: AHash());
  final hashMap = dupImageFinder.encodeImagesFromDir("example/example_img/");
  print(hashMap);
  final result = dupImageFinder.findDuplicates(hashMap);
  print(result);
}
