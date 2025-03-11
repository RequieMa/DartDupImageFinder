import 'dart:core';
import '../utils/logger.dart';

final logger = returnLogger("BKTree");

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
  List<String> candList,
  bool validFlag,
  int distance,
});

class BKTree {
  final Map<String, String> _hashDict;
  final int Function(String, String) _distanceFunction;
  late final String _root;
  final List<String> _allKeys;
  final Map<String, BKTreeNode> _dictAll = {};
  late final List<String> _candidates;
  final bool _verbose;

  BKTree(hashDict, distanceFunction, {bool verbose = true}) : _hashDict = hashDict, 
  _distanceFunction = distanceFunction, _allKeys = hashDict.keys.toList(),
  _verbose = verbose {
    _root = _allKeys[0];
    _allKeys.removeAt(0);
    _dictAll[_root] = BKTreeNode(nodeName: _root, nodeValue: _hashDict[_root]!);
    _candidates = [_dictAll[_root]!.nodeName];
    constructTree();
  }

  void constructTree() {
    if (_verbose) {
      logger.info('Start: Construct the BK-Tree');
    }
    _allKeys.forEach((var key)=> _insertInTree(key, _root)); 
    if (_verbose) {
      logger.info(_allKeys);
      logger.info('End: Construct the BK-Tree');
    }
  }

  // void search({required String query, int tol = 5}) {
  List<dynamic> search({required String query, int tol = 5}) {
    final validRetrievals = [];
    final candidatesLocal = List<String>.from(_candidates); 
    while (candidatesLocal.isNotEmpty) {
      final candidateName = candidatesLocal.removeLast();
      final currentNode = _dictAll[candidateName]!;
      final (:candList, :validFlag, :distance) = _getNextCandidates(
        query: query,
        candidateObj: currentNode,
        tolerance: tol,
      );

      if (validFlag) {
        validRetrievals.add(
          {candidateName: distance.toInt()},
        );
      }
      candidatesLocal.addAll(candList);
    }
    return validRetrievals;
  }

  Candidate _getNextCandidates({
    required String query, 
    required BKTreeNode candidateObj, 
    required int tolerance
  }) {
    final distance = _distanceFunction(candidateObj.nodeValue, query);
    final validity = distance <= tolerance;
    final searchRangeDistance = [for (var i = distance - tolerance; i < distance + tolerance + 1; ++i) i].toSet();
    final candidateChildren = candidateObj.children;
    final candidates = candidateChildren.keys
        .where((key) => searchRangeDistance.contains(candidateChildren[key]))
        .toList();
    return (
      candList: candidates, 
      validFlag: validity, 
      distance: distance, 
    );
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