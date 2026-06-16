part of '../../main.dart';

double fuzzyScore(String a, String b) {

  if (a.isEmpty || b.isEmpty) return 0;

  final aTokens = a.split(' ').toSet();

  final bTokens = b.split(' ').toSet();

  final intersection = aTokens.intersection(bTokens).length;

  final union = aTokens.union(bTokens).length;

  return union == 0 ? 0 : intersection / union;

}

