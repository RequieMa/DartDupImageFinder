// 核心去重逻辑
class ImageDeduplicator {
  final BKTree _bkTree = BKTree(hammingDistance);
  final Map<String, String> _hashRegistry = {}; // 文件路径到哈希的映射
  final int _threshold;

  ImageDeduplicator({int threshold = 5}) : _threshold = threshold;

  Future<void> addImage(String imagePath) async {
    final hash = await _computeHash(imagePath);
    _hashRegistry[imagePath] = hash;
    _bkTree.insert(hash);
  }

  Future<Map<String, Set<String>>> findDuplicates() async {
    final duplicates = <String, Set<String>>{};
    
    for (final entry in _hashRegistry.entries) {
      final similarHashes = _bkTree.query(entry.value, _threshold);
      final similarPaths = similarHashes
        .expand((h) => _hashRegistry.keys.where((k) => _hashRegistry[k] == h))
        .toSet();
      
      if (similarPaths.length > 1) {
        duplicates[entry.key] = similarPaths;
      }
    }
    
    return duplicates;
  }

  Future<String> _computeHash(String imagePath) async {
    // 实现具体的AHash算法
    // 使用package:image进行图像处理
    return await Ahash.compute(imagePath);
  }
}