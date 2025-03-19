// TODO: Put public facing types in this file.
import 'utils/general_utils.dart';
import 'utils/logger.dart';
import 'utils/hamming.dart';
import 'handlers/deduplicator.dart';

final loggerHash = returnLogger("DupImageFinder");

class DupImageFinder {
  final HashingBase _hasher;
  // final Kernel _kernel; // for CNN methods
  final bool _useML; 
  final bool _verbose;

  DupImageFinder({
    required bool useML,
    HashingBase hasher,
    // Kernel kernel,
    bool verbose = true,
  }) : _useML = useML, _verbose = verbose {
    if (useML) {
      try {
        // _kernel = kernel!;
      } catch (e) {
        print("Error: $e"); // Display error message
      }
    } else {
      try {
        _hasher = hasher!;
      } catch (e) {
        print("Error: $e"); // Display error message
      }
    }
  }

  // Future<Map<String, String>> encodeImages(String imageDir, {bool recursive = false, int workers = 4}) async {
  Map<String, String> encodeImages(String imageDir, {bool recursive = false}) {
    var directory = Directory(imageDir);
    if (!directory.existsSync()) {
      throw ArgumentError('Please provide a valid directory path!');
    }

    List<String> filePaths = generateFiles(directory, recursive);

    if (_verbose) {
      loggerHash.info('Start: Calculating hashes...');
    }

    // TODO: Make this parallelized
    // List<String?> hashes = await parallelise(filePaths, workers);
    final Map<String, String> hashMap = {};
    for (var file in filePaths) {
      var _encode = _hasher.encodeImage(file);
      if (_encode != null)
        hashMap[file] = _encode;
    }

    if (_verbose) {
      loggerHash.info('End: Calculating hashes!');
    }
    return hashMap;
  }

  Map<String, dynamic> findDuplicates(Map<String, String> encodingMap, {
    int maxDistanceThreshold = 10,
    bool scores = false,
    // String? outfile, // TODO: get output json later
    // String searchMethod = 'brute_force',
    String searchMethod = 'bktree',
  }) {
    if (_verbose) {
      loggerHash.info('Start: Evaluating hamming distances for getting duplicates');
    }

    
    
    final resultsSet = HashEval(
      test: encodingMap, 
      queries: encodingMap,
      distanceFunction: hammingDistance, 
      verbose: _verbose,
      threshold: maxDistanceThreshold,
      searchMethod: searchMethod
    );
    final results = resultsSet.retrieveResults(scores: scores);

    if (_verbose) {
      loggerHash.info('End: Evaluating hamming distances for getting duplicates');
    }

    // if (outfile != null) {
    //   _saveResultsToFile(results, outfile);
    // }
    return results;
}
