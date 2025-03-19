int hammingDistance(String a, String b, {int bitCount = 64,}) {
  _validateHex(a);
  _validateHex(b);
  String hash1Bin = BigInt.parse(
    a,
    radix: 16,
  ).toRadixString(2).padLeft(bitCount, '0');
  String hash2Bin = BigInt.parse(
    b,
    radix: 16,
  ).toRadixString(2).padLeft(bitCount, '0');
  final bigInt1 = BigInt.parse(hash1Bin, radix: 2);
  final bigInt2 = BigInt.parse(hash2Bin, radix: 2);

  final xorResult = bigInt1 ^ bigInt2;
  return xorResult.toRadixString(2).replaceAll('0', '').length;
}

void _validateHex(String hex) {
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
    throw ArgumentError('Invalid hex characters');
  }
}