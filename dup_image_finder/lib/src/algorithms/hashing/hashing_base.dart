import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../utils/image_utils.dart';
import '../../utils/general_utils.dart';

class Hashing {
  final List<int> _targetSize = [8, 8];
  final bool _verbose;

  Hashing({bool verbose = true}) : _verbose = verbose;
  
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
  String? encodeImage(String imageFile) {
    if (!File(imageFile).existsSync()) {
      throw ArgumentError('Image file does not exist: $imageFile');
    }

    try {
      final image = loadImage(
        imageFile, 
        targetSize: _targetSize,
        isGrayscale: true
      );
      return _hashFunc(image);
    } on img.ImageException catch (e) {
      if (_verbose) 
        print('Decoding failed: ${e.message}');
      return null;
    }
  }

  Future<Map<String, String>> encodeImages(String imageDir, 
    {bool recursive=false, int workers=4,}) async {
  final files = generateFiles(imageDir, recursive: recursive);

  final hashes = await parallelise(
    function: encodeImage,
    data: files,
    verbose: true,
    numWorkers: (Platform.numberOfProcessors/2).ceil(),
  );

//   final pool = WorkerPool(workers, isolateStart: _isolateStart);

//   try {
//     final results = await Future.wait(
//       files.map((file) async {
//         final imageData = await pool.execute(_HashTask(
//           filePath: file,
//           targetSize: _targetSize
//         ));
//         return imageData != null ? _hashFunc(imageData) : null;
//       })
//     );
//     return Map.fromIterables(files, results);
//   } finally {
//     pool.close();
//   }
  final relativeNames = generateRelativeNames(imageDir, files);
  final initialMap = Map<String, String?>.fromIterables(relativeNames, hashes);
  final hashMap = Map<String, String>.fromEntries(
    initialMap.entries.where((entry) => entry.value != null)
  );
  return hashMap;
}

  // void findDuplicates(encodingMap)

  String _hashFunc(Uint8List imageArray) {
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

// static void _isolateStart(SendPort sendPort) {
//   final channel = Channel<dynamic>.connectSend(sendPort);
//   channel.register('process_image', (Map<String, dynamic> params) {
//     // Isolate only handles image loading, actual hashing remains in main thread
//     final image = loadImage(
//       params['filePath'],
//       targetSize: List<int>.from(params['targetSize']),
//       isGrayscale: true
//     );
//     return image; // Return raw pixel data for main thread processing
//   });
// }

// void _validateHex(String hex) {
//   if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
//     throw ArgumentError('Invalid hex characters');
//   }
// }



// class _HashTask extends Task<_HashTask, Uint8List?> {
//   final String filePath;
//   final List<int> targetSize;

//   _HashTask({required this.filePath, required this.targetSize});

//   @override
//   Uint8List? execute() => Channel.withIsolatePool('process_image', params: {
//     'filePath': filePath,
//     'targetSize': targetSize
//   });
// }