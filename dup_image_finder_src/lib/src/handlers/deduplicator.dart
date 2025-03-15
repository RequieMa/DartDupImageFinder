import 'dart:core';
import '../utils/bk_tree.dart';
import '../utils/logger.dart';

final logger = returnLogger("DeDuplicator");

typedef QueryArgs = ({
  String queryKey,
  String queryVal,
  BKTree searchMethodObject,
  int threshold,
});

class HashEval {
  final Map<String, String> _test;
  final Map<String, String> _queries;
  final Function(String, String) _distanceFunction;
  final bool _verbose;
  final int _threshold;
  final Map<String, List<dynamic>> _queryResultsMap = {};

  HashEval({
    required Map<String, String> test,
    required Map<String, String> queries,
    required Function(String, String) distanceFunction,
    bool verbose = true,
    int threshold = 5,
    String searchMethod = 'bktree'
  }) : _test = test, _queries = queries, 
  _distanceFunction = distanceFunction,
  _verbose = verbose, _threshold = threshold {
    searchMethod == 'bktree' ? _fetchNearestNeighborsBKtree() : _fetchNearestNeighborsBruteForce();
  }

  void _fetchNearestNeighborsBKtree() {
    if (_verbose) {
      logger.info('Start: Retrieving duplicates using BKTree algorithm');
    }
    final builtTree = BKTree(_test, _distanceFunction);
    _getQueryResults(builtTree);
    if (_verbose) {
      logger.info('End: Retrieving duplicates using BKTree algorithm');
    }
  }

  void _fetchNearestNeighborsBruteForce() {

  }

  void _getQueryResults(_searchMethodObject) {
    final queryKeys = _queries.keys.toList();
    final queryValues = _queries.values.toList();
    final List<QueryArgs> args = List<QueryArgs>.generate(
      _queries.length,
      (index) => (
        queryKey: queryKeys[index], 
        queryVal: queryValues[index], 
        searchMethodObject: _searchMethodObject, 
        threshold: _threshold
      ),
    );
    // args.forEach((var arg)=> _searcher(arg));  // TODO: to paralellize it
    for (var i = 0; i < args.length; ++i) {
      final result =  _searcher(args[i]);
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

  List<dynamic> _searcher(dataTuple) {
    final (:queryKey, :queryVal, :searchMethodObject, :threshold) = dataTuple;
    final res = searchMethodObject.search(query: queryVal, tol: threshold);
    final filteredRes = res.where((element) => element.isNotEmpty && element[0] != queryKey).toList();
    return filteredRes;
  }

  Map<String, List<dynamic>> retrieveResults({bool scores = false}) {
  // void retrieveResults({bool scores = false}) {
    if (scores)
      return _queryResultsMap;
    else
      return Map<String, List<dynamic>>.fromEntries(
        _queryResultsMap.entries.map((entry) {
          final val = entry.value
              .map((map) => map.keys.single)
              .toList();
          return MapEntry(entry.key, val);
        })
      );
  }


}