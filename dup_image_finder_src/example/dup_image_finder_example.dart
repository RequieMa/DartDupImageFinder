import 'dart:io';
import 'package:dup_image_finder/dup_image_finder.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

void main() {
  var awesome = Awesome();
  print('awesome: ${awesome.isAwesome}');
  var image = cv.imread('example/example_img/cat.png', flags: cv.IMREAD_GRAYSCALE);
  var imageFloat = image.convertTo(cv.MatType.CV_32FC1);
  var dct = cv.dct(imageFloat);
  var idct = cv.idct(dct);
  cv.imwrite('example/example_img/reconstructed_image.png', idct);
}
