import 'dart:core';
import 'dart:typed_data';

class BKTreeNode {
  final String nodeName;
  final String nodeValue;
  final String? parentName;
  final Map<String, int> children = {};

  BKTreeNode({
    required this.nodeName,
    required this.nodeValue,
    this.parentName,
  });
}

typedef Candidate = ({
  List candList,
  bool validFlag,
  Map resDist,
});

class BKTree {
  final Map<String, String> _hashDict;
  final int Function(String, String) _distanceFunction;
  late final String _root;
  final List<String> _allKeys;
  final Map<String, BKTreeNode> _dictAll = {};
  late final List<String> _candidates;

  BKTree(hashDict, distanceFunction) : _hashDict = hashDict, 
  _distanceFunction = distanceFunction, 
  _allKeys = hashDict.keys.toList() {
    _root = _allKeys[0];
    _allKeys.removeAt(0);
    _dictAll[_root] = BKTreeNode(nodeName: _root, nodeValue: _hashDict[_root]!);
    // print(_dictAll);
    _candidates = [_dictAll[_root]!.nodeName];
    // print(_candidates);
    constructTree();
  }

  void constructTree() {
    _allKeys.forEach((var key)=> _insertInTree(key, _root)); 
  }

  void search({required String query, int tol = 5}) {
  // List search({required String query, int tol = 5}) {
    final validRetrievals = [];
    final candidatesLocal = List<String>.from(_candidates); 
    print(validRetrievals);
    print(candidatesLocal);
    while (candidatesLocal.isNotEmpty) {
      final candidateName = candidatesLocal.removeLast();
      final currentNode = _dictAll[candidateName]!;
      _getNextCandidates(
        query: query,
        candidateObj: currentNode,
        tolerance: tol,
      );
      // final (:candList, :validFlag, :resDist) = _getNextCandidates(
      //   query: query,
      //   candidateObj: currentNode,
      //   tolerance: tol,
      // );

      // if (validFlag) {
      //   validRetrievals.add(
      //     MapEntry(candidateName, resDist.toInt()),
      //   );
      // }
      // candidatesLocal.addAll(candList);
    }
    // return validRetrievals;
  }

  // Candidate _getNextCandidates({
  void _getNextCandidates({
    required String query, 
    required BKTreeNode candidateObj, 
    required int tolerance
  }) {
    final dist = _distanceFunction(candidateObj.nodeValue, query);
    print(dist);
    final validFlag = dist <= tolerance ? 1 : 0;
    print(validFlag);
    // TODO: Continue from here
  }

  int _insertInTree(String key, String currentNode) {
    final distCurrentNode = _distanceFunction(
      _hashDict[key]!, _dictAll[currentNode]!.nodeValue
    );
    final conditionInsertCurrentNodeChild = (
      _dictAll[currentNode]!.children.entries.isEmpty 
    ) || (
      !_dictAll[currentNode]!.children.values.contains(distCurrentNode)
    );

    if (conditionInsertCurrentNodeChild) {
      _dictAll[currentNode]!.children[key] = distCurrentNode;
      _dictAll[key] = BKTreeNode(
        nodeName: key, nodeValue: _hashDict[key]!, parentName: currentNode
      );
    } 
    else {
      var nodeToAddTo;
      for (var entry in _dictAll[currentNode]!.children.entries) {
        var i = entry.key;
        var value = entry.value;
        if (value == distCurrentNode) {
          nodeToAddTo = i;
          break;
        }
      }
      _insertInTree(key, nodeToAddTo);
    }
    return 0;
  }
}