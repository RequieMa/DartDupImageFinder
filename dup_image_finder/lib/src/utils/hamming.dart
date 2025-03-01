int hammingDistance(String hash1, String hash2) {
  assert(hash1.length == hash2.length, 'Hashes must be same length');
  int distance = 0;
  for (int i = 0; i < hash1.length; i++) {
    if (hash1.codeUnitAt(i) != hash2.codeUnitAt(i)) {
      distance++;
    }
  }
  return distance;
}