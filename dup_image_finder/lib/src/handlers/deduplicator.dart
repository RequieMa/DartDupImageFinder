// 核心去重逻辑
class HashEval {
  HashEval({
    required Map<String, String> test,
    required Map<String, String> queries,
    required Function(String, String) distanceFunction,
    bool verbose = true,
    int threshold = 5,
    String searchMethod = 'bktree'
  }) : _test = test, _queries = queries, _distanceFunction = distanceFunction, _verbose = verbose, _threshold = threshold {
    _searchMethod = searchMethod == 'bktree' ? _fetchNearestNeighborsBKtree() : _fetchNearestNeighborsBruteForce();
  };

  void _fetchNearestNeighborsBKtree() {
    print('Start: Retrieving duplicates using BKTree algorithm');
    final builtTree = BKTree(_test, _distanceFunction); // TODO: implement BKTree data structure
    _getQueryResults(builtTree); // TODO: implement
    print('Start: Retrieving duplicates using BKTree algorithm');
  }

  Map<String, dynamic> retrieveResults({bool score = false}) {
    final results = queryResultsMap();
    if (score)
      return results;
    else
      return null; // TODO: add return
  }


}