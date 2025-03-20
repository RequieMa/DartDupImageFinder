import "dart:core";
import "package:bk_tree/bk_tree.dart";
import "../utils/logger.dart";

/// Logger instance for DeDuplicator
final logger = returnLogger("DeDuplicator");

/// Query arguments structure for hash similarity search
/// Represents parameters for individual hash comparison queries
typedef QueryArgs = ({
  /// - [queryKey]: Unique identifier for the query item
  /// - [queryVal]: Hash value to compare against the dataset
  /// - [searchMethodObject]: BK-Tree instance containing hashes
  /// - [threshold]: Maximum allowed distance for matches
  String queryKey,
  String queryVal,
  BKTree searchMethodObject,
  int threshold,
});

/// Hash similarity evaluator implementing BK-Tree search algorithm
///
/// Handles both exact and approximate hash matching strategies using:
/// - Configurable distance metrics
/// - Threshold-based similarity filtering
/// - Multiple search method implementations
class HashEval {
  final Map<String, String> _test;
  final Map<String, String> _queries;
  final int Function(String, String) _distanceFunction;
  final int _threshold;
  final Map<String, List<dynamic>> _queryResultsMap = {};
  final bool _verbose;

  /// Creates hash evaluator instance
  ///
  /// [test]: Reference dataset for comparison (Map of IDs to hashes)
  /// [queries]: Query dataset to analyze (Map of IDs to hashes)
  /// [distanceFunction]: Distance metric implementation
  /// [threshold]: Maximum allowed hash distance for matches
  /// [searchMethod]: Algorithm selection (bktree/brute_force)
  /// [bitCount]: Hash bit-length specification (64/128)
  /// [verbose]: Enables detailed processing logs when true
  HashEval({
    required Map<String, String> test,
    required Map<String, String> queries,
    required int Function(String, String) distanceFunction,
    int threshold = 5,
    String searchMethod = "bktree",
    int bitCount = 64,
    bool verbose = true,
  })  : _test = test,
        _queries = queries,
        _distanceFunction = distanceFunction,
        _threshold = threshold,
        _verbose = verbose {
    searchMethod == "bktree"
        ? _fetchNearestNeighborsBKtree()
        : _fetchNearestNeighborsBruteForce();
  }

  void _fetchNearestNeighborsBKtree() {
    if (_verbose) {
      logger.info("Start: Retrieving duplicates using BKTree algorithm");
    }
    final builtTree = BKTree(_test, _distanceFunction);
    _getQueryResults(builtTree);
    if (_verbose) {
      logger.info("End: Retrieving duplicates using BKTree algorithm");
    }
  }

  void _fetchNearestNeighborsBruteForce() {}

  void _getQueryResults(BKTree searchMethodObject) {
    final queryKeys = _queries.keys.toList();
    final queryValues = _queries.values.toList();
    final args = List<QueryArgs>.generate(
      _queries.length,
      (index) => (
        queryKey: queryKeys[index],
        queryVal: queryValues[index],
        searchMethodObject: searchMethodObject,
        threshold: _threshold
      ),
    );
    // args.forEach((var arg)=> _searcher(arg));  // TODO: to paralellize it
    for (var i = 0; i < args.length; ++i) {
      final result = _searcher(args[i]);
      final target = queryKeys[i];
      result.removeWhere((map) => map.containsKey(target));
      result.sort((a, b) {
        final aVal = a.values.toList()[0] as Comparable;
        final bVal = b.values.toList()[0] as Comparable;
        return aVal.compareTo(bVal);
      });
      _queryResultsMap[target] = result;
    }
  }

  List<dynamic> _searcher(QueryArgs dataTuple) {
    final (:queryKey, :queryVal, :searchMethodObject, :threshold) = dataTuple;
    final res =
        searchMethodObject.search(queryHash: queryVal, tolerance: threshold);
    final filteredRes = res
        .where((element) => element.isNotEmpty && element[0] != queryKey)
        .toList();
    return filteredRes;
  }

  /// Retrieves processed similarity results
  ///
  /// [scores]: Controls result format:
  /// - `true`: Returns matches with similarity scores
  /// - `false`: Returns matches without scores
  ///
  /// Returns map containing:
  /// - Keys: Query item identifiers
  /// - Values: Lists of matching items (with/without scores)
  Map<String, List<dynamic>> retrieveResults({bool scores = false}) {
    if (scores) {
      return _queryResultsMap;
    } else {
      return Map<String, List<dynamic>>.fromEntries(
        _queryResultsMap.entries.map((entry) {
          final val = entry.value.map((map) => map.keys.single).toList();
          return MapEntry(entry.key, val);
        }),
      );
    }
  }
}
