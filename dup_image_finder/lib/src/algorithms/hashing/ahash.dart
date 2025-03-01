import 'dart:typed_data';
import 'package:collection/collection.dart';
import './hashing_base.dart';

class AHash extends Hashing {
  AHash({bool verbose = true}) : super(verbose: verbose);

  @override
  int hashAlgo(Uint8List imageArray) {
    final avg = imageArray.average;
    final hashMat = imageArray.map((x) => x >= avg).toList();
    return toIntFromBoolList(hashMat);
  }
}

int toIntFromBoolList(List<bool> booleans) {
  var number = 0;
  for (final bool in booleans) {
    number = number << 1;
    if (bool) {
      number = number | 1;
    }
  }
  return number;
}