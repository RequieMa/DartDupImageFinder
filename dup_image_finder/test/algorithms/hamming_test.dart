import 'package:test/test.dart';
import 'package:dup_image_finder/dup_image_finder.dart';

void main() {
  group('Hex Hamming Distance Tests', () {
    test('相同全零哈希', () {
      expect(Hashing.hammingDistance('0000000000000000', '0000000000000000'), equals(0));
    });

    test('相同随机哈希', () {
      expect(Hashing.hammingDistance('0123456789abcdef', '0123456789abcdef'), equals(0));
    });

    test('完全不同的哈希', () {
      expect(Hashing.hammingDistance('0000000000000000', 'ffffffffffffffff'), equals(64));
    });

    test('单字符差异测试', () {
      expect(Hashing.hammingDistance('aaaaaaaaaaaaaaa9', 'aaaaaaaaaaaaaaaa'), equals(2)); // 十六进制9(1001) vs a(1010)
    });

    test('中间字符差异测试', () {
      expect(Hashing.hammingDistance('1234567812345678', '1234567892345678'), equals(1)); // 12 vs 92
    });

    test('不同大小写输入', () {
      expect(Hashing.hammingDistance('ABCDEF1234567890', 'abcdef1234567890'), equals(0)); // 不区分大小写
    });

    test('长度不足输入，应补齐', () {
      expect(Hashing.hammingDistance('123', '456'), equals(7));
    });

    test('非法字符输入', () {
      expect(() => Hashing.hammingDistance('ghijklmnopqrstuv', '0000000000000000'), throwsA(isA<ArgumentError>()));
    });
  });
}