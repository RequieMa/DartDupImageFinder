import 'package:test/test.dart';
import 'package:dup_image_finder/dup_image_finder.dart';

void main() {
  group('BK-Tree Node Tests', () {
    test('Correct initialization', () {
      final node = BKTreeNode(
        nodeName: 'test_node', 
        nodeValue: '1aef', 
        parentName: null
      );
      expect(node.nodeName, equals('test_node'));
      expect(node.nodeValue, equals('1aef'));
      expect(node.parentName, equals(null));
      expect(node.children.isEmpty, isTrue);
    });
  });

  group('BK-Tree Tests', () {
    final Map<String, String> hashDict = {
      'a': '9', 'b': 'D', 'c': 'A', 'd': 'F', 
      'e': '2', 'f': '6', 'g': '7', 'h': 'E'
    };
    final int Function(String, String) distFunc = Hashing.hammingDistance;

    test('Insert Tree', () {
      final tempDict = {'a': '9', 'b': 'D'};
      final bk = BKTree(tempDict, distFunc);
      expect(bk.getRoot(), equals('a'));
      expect(bk.getDictAll()['a']!.children.keys.toList(), contains('b'));
      expect(bk.getDictAll()['b']!.parentName, equals('a'));
    });

    test('Insert Tree Collision', () {
      final tempDict = {'a': '9', 'b': 'D', 'c': '8'};
      final bk = BKTree(tempDict, distFunc);
      expect(bk.getRoot(), equals('a'));
      expect(bk.getDictAll()[bk.getRoot()]!.children.length, equals(1));
      expect(bk.getDictAll()['b']!.children.keys.toList(), contains('c'));
    });

    test('Insert Tree Different Nodes', () {
      final tempDict = {'a': '9', 'b': 'D', 'c': 'F'};
      final bk = BKTree(tempDict, distFunc);
      expect(bk.getRoot(), equals('a'));
      expect(bk.getDictAll()[bk.getRoot()]!.children.length, equals(2));
      expect(bk.getDictAll()[bk.getRoot()]!.children.keys.toSet().containsAll({'b', 'c'}), isTrue);
    });

    test('Insert Tree Check Distance', () {
      final tempDict = {'a': '9', 'b': 'D', 'c': 'F'};
      final bk = BKTree(tempDict, distFunc);
      expect(bk.getRoot(), equals('a'));
      expect(bk.getDictAll()[bk.getRoot()]!.children['b'], equals(1));
      expect(bk.getDictAll()[bk.getRoot()]!.children['c'], equals(2));
    });

    test('Construct Tree', () {
      final bk = BKTree(hashDict, distFunc);
      expect(bk.getRoot(), equals('a'));
      final leafNodes = bk.getDictAll().keys.where(
        (k) => bk.getDictAll()[k]!.children.isEmpty
      ).toSet();
      const expectedLeafNodes = {'b', 'd', 'f', 'h'};
      expect(leafNodes, equals(expectedLeafNodes));
      expect(bk.getDictAll()[bk.getRoot()]!.children.length, equals(4));
      expect(bk.getDictAll()['c']!.children['d'], equals(2));
    });
  });
}