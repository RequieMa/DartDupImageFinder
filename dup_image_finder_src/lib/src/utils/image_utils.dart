import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List loadImage(String imageFile, { 
    List<int>? targetSize=null, 
    bool isGrayscale=false, 
}) {
  var image = img.decodeImage(File(imageFile).readAsBytesSync());
  if (image == null) {
      throw FormatException('Unsupported image format');
  }
  image = _convertToRgb(image);

  if (targetSize != null)
      image = img.copyResize(
          image,
          width: 8, height: 8,
          interpolation: img.Interpolation.cubic
      );

  if (isGrayscale)
      image = img.grayscale(image);
  return image.toUint8List();
}

img.Image _convertToRgb(img.Image image) {
  if (image.numChannels == 3) 
    return image;
  return image.convert(numChannels: 3);
}
