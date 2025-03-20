import "dart:io";
import "package:image_hashing/image_hashing.dart";
import "handlers/deduplicator.dart";
import "utils/general_utils.dart";
import "utils/logger.dart";

final loggerHash = returnLogger("DupImageFinder");

/// Image deduplication system using perceptual hashing algorithms
/// 
/// Example usage:
/// ```dart
/// final finder = DupImageFinder(
///   useML: false,
///   hasher: DHash(),
/// );
/// ```
class DupImageFinder {
  final Hashing _hasher;
  // final Kernel _kernel; // for CNN methods
  final bool _useML;
  final bool _verbose;

  /// Creates an image deduplication processor
  ///
  /// [useML]: Enables machine learning approach (unsupported yet)
  /// [hasher]: Hashing algorithm implementation for feature extraction
  /// [verbose]: Enables detailed logging of processing pipeline
  DupImageFinder({
    required bool useML,
    required Hashing hasher,
    // Kernel kernel,
    bool verbose = true,
  })  : _useML = useML,
        _verbose = verbose,
        _hasher = hasher {
    // if (_useML) {
    //   try {
    //     // _kernel = kernel!;
    //   } on Exception catch (e) {
    //     print("Error: $e"); // Display error message
    //   }
    // } else {
    //   try {
    //     _hasher = hasher!;
    //   } on Exception catch (e) {
    //     print("Error: $e"); // Display error message
    //   }
    // }
  }

  /// Generates perceptual hashes for images in specified directory
  ///
  /// [imageDir]: Target directory containing images to process
  /// [recursive]: Enables recursive processing of subdirectories
  /// 
  /// Returns map of file paths to corresponding hash strings
  /// 
  /// Throws [ArgumentError] if directory path is invalid
  Map<String, String> encodeImages(String imageDir, {bool recursive = false}) {
    var directory = Directory(imageDir);
    if (!directory.existsSync()) {
      throw ArgumentError("Please provide a valid directory path!");
    }

    final filePaths = generateFiles(directory, recursive: recursive);

    if (_verbose) {
      loggerHash.info("Start: Calculating hashes...");
    }

    // TODO: Make this parallelized
    // List<String?> hashes = await parallelise(filePaths, workers);
    final hashMap = <String, String>{};
    for (var file in filePaths) {
      var encode = _hasher.encodeImage(file);
      if (encode != null) hashMap[file] = encode;
    }

    if (_verbose) {
      loggerHash.info("End: Calculating hashes!");
    }
    return hashMap;
  }

  /// Identifies duplicate images based on hash similarity
  ///
  /// [encodingMap]: Precomputed hash map from [encodeImages]
  /// [maxDistanceThreshold]: Maximum allowed Hamming distance for duplicates
  /// [scores]: Enables similarity scores in output results
  /// [searchMethod]: Search algorithm selection (bktree/brute_force)
  /// 
  /// Returns map of original files to their duplicate matches
  Map<String, dynamic> findDuplicates(
    Map<String, String> encodingMap, {
    int maxDistanceThreshold = 10,
    bool scores = false,
    // String? outfile, // TODO: get output json later
    String searchMethod = "bktree",
  }) {
    if (_verbose) {
      loggerHash
          .info("Start: Evaluating hamming distances for getting duplicates");
    }

    final int Function(String a, String b) hammingWrapper;
    if (_hasher is DHash) {
      hammingWrapper = (a, b) => hammingDistance(a, b, size: 128);
    } else {
      hammingWrapper = (a, b) => hammingDistance(a, b, size: 64);
    }

    final resultsSet = HashEval(
        test: encodingMap,
        queries: encodingMap,
        distanceFunction: hammingWrapper,
        verbose: _verbose,
        threshold: maxDistanceThreshold,
        searchMethod: searchMethod);
    final results = resultsSet.retrieveResults(scores: scores);

    if (_verbose) {
      loggerHash.info(
        "End: Evaluating hamming distances for getting duplicates",
      );
    }
    // if (outfile != null) {
    //   _saveResultsToFile(results, outfile);
    // }
    return results;
  }
}
