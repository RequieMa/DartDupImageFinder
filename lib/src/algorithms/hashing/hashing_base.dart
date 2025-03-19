import 'dart:io';
import 'dart:typed_data';
import 'dart:core';
import 'package:image/image.dart' as img;
import '../../utils/logger.dart';
import '../../utils/image_utils.dart';
import '../../utils/general_utils.dart';
import '../../handlers/deduplicator.dart';


final loggerHash = returnLogger("HashingBase");

class Hashing {
  static List<int> targetSize = [8, 8];
  final bool _verbose;

  Hashing({bool verbose = true}) : _verbose = verbose;
  
  String? encodeImage(String imageFile) {
    /// 生成单张图像的哈希值（仅支持文件路径输入）
    /// 
    /// [imageFile] 图像文件路径（必须存在）
    /// 
    /// 返回：16字符的十六进制哈希字符串
    /// 
    /// 示例：
    /// ```dart
    /// final hasher = Hashing();
    /// final hash = hasher.encodeImage('path/to/image.jpg');
    /// ```
    if (!File(imageFile).existsSync()) {
      throw ArgumentError('Image file does not exist: $imageFile');
    }

    try {
      final image = loadImage(
        imageFile, 
        targetSize: targetSize,
        isGrayscale: true
      );
      return hashFunc(image);
    } on img.ImageException catch (e) {
      if (_verbose) {
        loggerHash.severe('Decoding failed: ${e.message}');
      }
      return null;
    }
  }

  

  String hashFunc(Uint8List imageArray) {
    final hashVal = hashAlgo(imageArray);
    return Hashing.array2Hash(hashVal);
  }

  int hashAlgo(Uint8List imageArray) {
    throw UnimplementedError('Child must implement hashAlgo');
  }

  static String array2Hash(int hashVal) {
    final hexString = hashVal.toRadixString(16);
    return hexString;
  }

  static int hammingDistance(String a, String b) {
    _validateHex(a);
    _validateHex(b);
    String hash1Bin = BigInt.parse(
      a,
      radix: 16,
    ).toRadixString(2).padLeft(64, '0');
    String hash2Bin = BigInt.parse(
      b,
      radix: 16,
    ).toRadixString(2).padLeft(64, '0');
    final bigInt1 = BigInt.parse(hash1Bin, radix: 2);
    final bigInt2 = BigInt.parse(hash2Bin, radix: 2);

    final xorResult = bigInt1 ^ bigInt2;
    return xorResult.toRadixString(2).replaceAll('0', '').length;
  }

  
  } 

  // void _saveResultsToFile(Map<String, dynamic> results, String filename) {
  //   File file = File(filename);
  //   file.writeAsString(json.encode(results));
  // }
}

void _validateHex(String hex) {
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
    throw ArgumentError('Invalid hex characters');
  }
}
