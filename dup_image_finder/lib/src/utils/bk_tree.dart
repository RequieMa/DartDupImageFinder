class BKTreeNode {
  final String hash;
  final Map<int, BKTreeNode> children = {};
  
  BKTreeNode(this.hash);
}

class BKTree {
  BKTreeNode? _root;
  final int Function(String, String) distanceFunction;

  BKTree(this.distanceFunction);

  void insert(String hash) {
    if (_root == null) {
      _root = BKTreeNode(hash);
    } else {
      _insert(_root!, hash);
    }
  }

  void _insert(BKTreeNode node, String hash) {
    final distance = distanceFunction(node.hash, hash);
    if (distance == 0) return; // 已存在相同哈希
    
    if (node.children.containsKey(distance)) {
      _insert(node.children[distance]!, hash);
    } else {
      node.children[distance] = BKTreeNode(hash);
    }
  }

  Set<String> query(String targetHash, int maxDistance) {
    final results = <String>{};
    if (_root == null) return results;
    
    final queue = Queue<BKTreeNode>.from([_root!]);
    
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      final currentDistance = distanceFunction(node.hash, targetHash);
      
      if (currentDistance <= maxDistance) {
        results.add(node.hash);
      }
      
      final minRange = currentDistance - maxDistance;
      final maxRange = currentDistance + maxDistance;
      
      node.children.forEach((distance, child) {
        if (distance >= minRange && distance <= maxRange) {
          queue.add(child);
        }
      });
    }
    
    return results;
  }
}