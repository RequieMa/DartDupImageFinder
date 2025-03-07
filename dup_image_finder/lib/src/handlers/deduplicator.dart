// 核心去重逻辑
import 'dart:core';
import 'dart:typed_data';
import '../utils/bk_tree.dart';

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
    print('Start: Retrieving duplicates using BKTree algorithm');
    final builtTree = BKTree(_test, _distanceFunction);
    // print(builtTree);
    _getQueryResults(builtTree); // TODO: implement
    print('End: Retrieving duplicates using BKTree algorithm');
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
    print(args);
    args.forEach((var arg)=> _searcher(arg));  // TODO: to paralellize it
  }

  void _searcher(dataTuple) {
  // List _searcher(dataTuple) {
    final (:queryKey, :queryVal, :searchMethodObject, :threshold) = dataTuple;
    // final res = searchMethodObject.search(query: queryVal, tol: threshold);
    searchMethodObject.search(query: queryVal, tol: threshold);
    // final filteredRes = res.where((element) {
    //   return element.isNotEmpty && element[0] != queryKey;
    // }).toList();
    // return filteredRes;
  }

  // Map<String, dynamic> retrieveResults({bool score = false}) {
  //   final results = queryResultsMap();
  //   if (score)
  //     return results;
  //   else
  //     return null; // TODO: add return
  // }


}