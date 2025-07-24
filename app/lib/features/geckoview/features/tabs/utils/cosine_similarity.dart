import 'dart:math';

/// Calculates cosine similarity between two lists of floats
/// The lists don't need to be normalized
///
/// [a] first list
/// [b] second list
/// Returns cosine similarity value
double cosSim(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw ArgumentError("Lists should have same lengths");
  }
  if (a.isEmpty) {
    return 0;
  }

  double dotProduct = 0;
  double mA = 0;
  double mB = 0;

  for (int i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    mA += a[i] * a[i];
    mB += b[i] * b[i];
  }

  mA = sqrt(mA);
  mB = sqrt(mB);

  return mA == 0 || mB == 0 ? 0 : dotProduct / (mA * mB);
}
