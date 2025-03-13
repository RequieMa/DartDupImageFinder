# Example
## Encoding Generation
Target: mixed_images/ukbench00120.jpg
Folder: mixed_images
Method: PHash, encode_image
PHash: '9fee256239984d71'

OpenCV for DCT
```dart
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:io';

void main() {
  // Load the image
  var image = cv.imread('path_to_your_image.png', cv.IMREAD_GRAYSCALE);

  // Convert the image to a floating-point array
  var imageFloat = image.convertTo(cv.CV_32F);

  // Perform DCT
  var dct = cv.dct(imageFloat);

  // Process the DCT coefficients as needed
  // ...

  // Optionally, perform inverse DCT to reconstruct the image
  var idct = cv.idct(dct);

  // Save the reconstructed image
  cv.imwrite('reconstructed_image.png', idct);
}
```

AHash: '81b8bc3c3c3c1e0a'
DHash, encode_images
{'ukbench00120_resize.jpg': '2b69707551f1b87a',
 'ukbench00120_rotation.jpg': '74d2d1717168acd0',
 'ukbench00120.jpg': '2b69707551f1b87a',
 'ukbench00120_hflip.jpg': '2b69f1517570e2a1',
 'ukbench09268.jpg': 'ac9c72f8e1c2c448'}

CNN, encode_image
array([[1.5847789 , 0.17494635, 0.        , ..., 1.0568997 , 0.00498394,
        0.6473189 ]], dtype=float32)
CNN, encode_images
{'ukbench00120.jpg': array([1.5847782 , 0.1749464 , 0.        , ..., 1.0568993 , 0.00498396,
        0.6473194 ], dtype=float32),
 'ukbench00120_hflip.jpg': array([1.8885472 , 0.2520814 , 0.06678697, ..., 0.89278036, 0.02286635,
        0.91840214], dtype=float32),
 'ukbench00120_resize.jpg': array([1.707229  , 0.19885841, 0.0129852 , ..., 1.4586834 , 0.00776921,
        0.83636326], dtype=float32),
 'ukbench00120_rotation.jpg': array([0.5142981 , 0.20380044, 0.        , ..., 0.02884004, 0.00844299,
        0.9559768 ], dtype=float32),
 'ukbench09268.jpg': array([0.4290448 , 0.24964048, 0.50022906, ..., 0.8208346 , 0.16613719,
        0.6475953 ], dtype=float32)}

## Find Duplicates
PHash, find_duplicates
{'ukbench00120_resize.jpg': [('ukbench00120.jpg', 0)],
 'ukbench00120_rotation.jpg': [],
 'ukbench00120.jpg': [('ukbench00120_resize.jpg', 0)],
 'ukbench00120_hflip.jpg': [],
 'ukbench09268.jpg': []}
PHash, find_duplicates_to_remove
['ukbench00120.jpg']

CNN, find_duplicates
{'ukbench00120.jpg': [('ukbench00120_hflip.jpg', 0.9672552),
  ('ukbench00120_resize.jpg', 0.98120844)],
 'ukbench00120_hflip.jpg': [('ukbench00120.jpg', 0.9672552),
  ('ukbench00120_resize.jpg', 0.95676106)],
 'ukbench00120_resize.jpg': [('ukbench00120.jpg', 0.98120844),
  ('ukbench00120_hflip.jpg', 0.95676106)],
 'ukbench00120_rotation.jpg': [],
 'ukbench09268.jpg': []}
CNN, find_duplicates_to_remove
['ukbench00120_hflip.jpg', 'ukbench00120_resize.jpg']

## Evaluation
ground_truth = {'ukbench00120.jpg': ['ukbench00120_hflip.jpg','ukbench00120_resize.jpg'],
 'ukbench00120_hflip.jpg': ['ukbench00120.jpg','ukbench00120_resize.jpg'],
 'ukbench00120_resize.jpg': ['ukbench00120.jpg','ukbench00120_hflip.jpg'],
 'ukbench00120_rotation.jpg': [],
 'ukbench09268.jpg': []}

```python
from imagededup.evaluation import evaluate
metrics = evaluate(ground_truth_map=ground_truth, retrieved_map=duplicates_cnn)
```
              precision    recall  f1-score   support

           0       0.78      1.00      0.88         7
           1       1.00      0.33      0.50         3

    accuracy                           0.80        10
   macro avg       0.89      0.67      0.69        10
weighted avg       0.84      0.80      0.76        10

{'map': 0.6,
 'ndcg': 0.8,
 'jaccard': 0.6,
 'precision': array([0.77777778, 1.        ]),
 'recall': array([1.        , 0.33333333]),
 'f1_score': array([0.875, 0.5  ]),
 'support': array([7, 3])}


Mean Average Precision (MAP)
Mean Normalized Discounted Cumulative Gain (NDCG)
Jaccard Index
Per class Precision (class 0 = non-duplicate image pairs, class 1 = duplicate image pairs)
Per class Recall (class 0 = non-duplicate image pairs, class 1 = duplicate image pairs)
Per class f1-score (class 0 = non-duplicate image pairs, class 1 = duplicate image pairs)

There is a difference between the way information retrieval metrics(map, ndcg, jaccard index) and classification metrics(precision, recall, f1-score) treat the symmetric relationships in duplicates

# Source
## pHash Algo
```dart
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:io';

void main() {
  // Load the image
  var image = cv.imread('path_to_your_image.png', cv.IMREAD_GRAYSCALE);

  // Convert the image to a floating-point array
  var imageFloat = image.convertTo(cv.CV_32F);

  // Perform 2D DCT
  var dctCoef = cv.dct(imageFloat);

  // Retain top left 8 by 8 DCT coefficients
  int extractHeight = 8; // Replace with self.__coefficient_extract[0]
  int extractWidth = 8;  // Replace with self.__coefficient_extract[1]
  var dctReducedCoef = dctCoef.submat(0, extractHeight, 0, extractWidth);

  // Flatten the DCT coefficients and exclude the DC term (0th term) 
  // Regarding the DC term (0th term), it refers to the first coefficient in the DCT result. 
  // This coefficient represents the average value (or the mean) of the entire image.
  var flattenedCoef = dctReducedCoef.reshape(1, extractHeight * extractWidth).toList();
  flattenedCoef.removeAt(0);

  // Calculate the median of the coefficients
  flattenedCoef.sort();
  double medianCoefVal = flattenedCoef[flattenedCoef.length ~/ 2];

  // Create a mask of all coefficients greater than the median
  var hashMat = dctReducedCoef >= medianCoefVal;

  // Process the hashMat as needed
  // ...
}
```
## dHash Algo


## Evaluation
```python
def evaluate(
    ground_truth_map: Dict = None, retrieved_map: Dict = None, metric: str = 'all'
):
    # _check_map_correctness(ground_truth_map, retrieved_map) ## maybe later
    # if metric is 'all'
    ir_metrics = get_all_metrics(ground_truth_map, retrieved_map)
    class_metrics = classification_metrics(ground_truth_map, retrieved_map)
    ir_metrics.update(class_metrics)
    return ir_metrics
```

```dart
Map<String, dynamic> evaluate({
  required Map<String, List<String>> groundTruthMap,
  required Map<String, List<String>> retrievedMap,
  String metric = 'all',
}) {
  // Assuming getAllMetrics and classificationMetrics are defined elsewhere
  Map<String, dynamic> irMetrics = getAllMetrics(groundTruthMap, retrievedMap);
  Map<String, dynamic> classMetrics = classificationMetrics(groundTruthMap, retrievedMap);

  // Update irMetrics with classMetrics
  irMetrics.addAll(classMetrics);

  return irMetrics;
}
```

## Metrics
### Information Retrieval
--------------------------------
NDGC: **Normalized Discounted cumulative gain** is often used to measure effectiveness of search engine algorithms and related applications.
Using a **graded relevance** scale of documents in a search-engine result set, DCG sums the usefulness, or *gain*, of the results discounted by their position in the result list

Two assumptions are made in using DCG and its related measures.
- Highly relevant documents are more useful when appearing earlier in a search engine result list (have *higher ranks*)
- Highly relevant documents are more useful than marginally relevant documents, which are in turn more useful than non-relevant documents.

**Relevance** denotes how well a retrieved document or set of documents meets the information need of the user

$$
nDCG_p = \frac{DCG_p}{IDCG_p}\\
DCG_p = \sum_{i = 1}^{|REL_p|} \frac{2^{rel_i} - 1}{\log_2 (i + 1)}\\
IDCG_p = \sum_{i = 1}^{p} \frac{2^{rel_i} - 1}{\log_2 (i + 1)}\\
$$

$rel_i$ is the graded relevance of the result at position $i$

$p$ is a particular rank position

IDCG is **ideal discounted cumulative gain**

Example in https://en.wikipedia.org/wiki/Discounted_cumulative_gain
--------------------------------
Jaccard index: taking the ratio of two sizes (areas or volumes), the intersection size divided by the union size, also called intersection over union (IoU)

$$
J(A, B) = \frac{|A \cap B|}{|A \cup B|} = \frac{|A \cap B|}{|A| + |B| - |A \cap B|}\\
$$

Not like the original Python code, it should not be called Jaccard Similarity according to https://en.wikipedia.org/wiki/Jaccard_index

```dart
Map<String, dynamic> getAllMetrics(Map<String, List<String>> groundTruth, Map<String, List<String>> retrieved) {
  return {
    'map': meanMetric(groundTruth, retrieved, metric: 'map'),
    'ndcg': meanMetric(groundTruth, retrieved, metric: 'ndcg'),
    'jaccard': meanMetric(groundTruth, retrieved, metric: 'jaccard'),
  };
}

double meanMetric(Map<String, List<String>> groundTruth, Map<String, List<String>> retrieved, {required String metric}) {
  Map<String, Function> metricLookup = {
    'map': avgPrec,
    'ndcg': ndcg,
    'jaccard': jaccardIndex,
  };

  Function metricFunc = metricLookup[metric]!;
  List<double> metricVals = [];

  for (String key in groundTruth.keys) {
    metricVals.add(metricFunc(groundTruth[key]!, retrieved[key]!));
  }

  return metricVals.reduce((a, b) => a + b) / metricVals.length;
}

double avgPrec(List<String> correctDuplicates, List<String> retrievedDuplicates) {
  if (retrievedDuplicates.isEmpty && correctDuplicates.isEmpty) {
    return 1.0;
  }

  if (retrievedDuplicates.isEmpty || correctDuplicates.isEmpty) {
    return 0.0;
  }

  List<int> relevance = retrievedDuplicates.map((i) => correctDuplicates.contains(i) ? 1 : 0).toList();
  List<int> relevanceCumsum = List<int>.generate(relevance.length, (i) => relevance.sublist(0, i + 1).reduce((a, b) => a + b));
  List<double> precK = List<double>.generate(relevance.length, (k) => relevanceCumsum[k] / (k + 1));
  List<double> precAndRelevance = List<double>.generate(relevance.length, (k) => relevance[k] * precK[k]);
  double avgPrecision = precAndRelevance.reduce((a, b) => a + b) / correctDuplicates.length;
  return avgPrecision;
}

double ndcg(List<String> correctDuplicates, List<String> retrievedDuplicates) {
  if (retrievedDuplicates.isEmpty && correctDuplicates.isEmpty) {
    return 1.0;
  }

  if (retrievedDuplicates.isEmpty || correctDuplicates.isEmpty) {
    return 0.0;
  }

  double dcg(List<int> rel) {
    List<double> relevanceNumerator = rel.map((k) => pow(2, k) - 1).toList();
    List<double> relevanceDenominator = List<double>.generate(rel.length, (i) => log(i + 2) / ln2);
    List<double> dcgTerms = List<double>.generate(rel.length, (i) => relevanceNumerator[i] / relevanceDenominator[i]);
    double dcgAtK = dcgTerms.reduce((a, b) => a + b);

    return dcgAtK;
  }

  List<int> relevance = retrievedDuplicates.map((i) => correctDuplicates.contains(i) ? 1 : 0).toList();
  double dcgK = dcg(relevance);

  if (dcgK == 0) {
    return 0.0;
  }

  double idcgK = dcg(List<int>.from(relevance)..sort((a, b) => b.compareTo(a)));
  return dcgK / idcgK;
}

double jaccardIndex(List<String> correctDuplicates, List<String> retrievedDuplicates) {
  if (retrievedDuplicates.isEmpty && correctDuplicates.isEmpty) {
    return 1.0;
  }

  if (retrievedDuplicates.isEmpty || correctDuplicates.isEmpty) {
    return 0.0;
  }

  Set<String> setCorrectDuplicates = Set<String>.from(correctDuplicates);
  Set<String> setRetrievedDuplicates = Set<String>.from(retrievedDuplicates);

  Set<String> intersectionDups = setRetrievedDuplicates.intersection(setCorrectDuplicates);
  Set<String> unionDups = setRetrievedDuplicates.union(setCorrectDuplicates);

  double jaccSim = intersectionDups.length / unionDups.length.toDouble();
  return jaccSim;
}
```

### Classification
```dart 
import 'dart:collection';
import 'package:ml_metrics/ml_metrics.dart';

Map<String, dynamic> classificationMetrics(
    Map<String, List<String>> groundTruth, 
    Map<String, List<String>> retrieved
) {
  var allPairs = makeAllUniquePossiblePairs(groundTruth);
  var positivePairs = makePositiveDuplicatePairs(groundTruth, retrieved);
  var groundTruthPairs = positivePairs[0];
  var retrievedPairs = positivePairs[1];

  var labels = prepareLabels(allPairs, groundTruthPairs, retrievedPairs);
  var yTrue = labels[0];
  var yPred = labels[1];

  var metrics = metricScore(yTrue, yPred);
  return metrics;
}

List<List<String>> makeAllUniquePossiblePairs(Map<String, List<String>> groundTruthDict) {
  var allFiles = groundTruthDict.keys.toList();
  final List<List<String>> allTuples = [];

  for (var i in allFiles) {
    for (var j in allFiles) {
      if (i != j) {
        allTuples.add([i, j]);
      }
    }
  }

  return getUniqueOrderedTuples(allTuples);
}

List<List<T>> getUniqueOrderedTuples<T>(List<List<T>> uniqueTuples) {
  final Set<List<T>> uniqueSet = {};
  for (var tuple in uniqueTuples) {
    var sortedTuple = List<T>.from(tuple)..sort();
    uniqueSet.add(sortedTuple);
  }
  return uniqueSet.toList();
}

List<List<List<String>>> makePositiveDuplicatePairs(
    Map<String, List<String>> groundTruth, 
    Map<String, List<String>> retrieved
) {
  final List<List<List<String>>> pairs = [];

  for (var mapping in [groundTruth, retrieved]) {
    final List<<List<String>>> validPairs = [];

    for (var entry in mapping.entries) {
      final k = entry.key;
      final v = entry.value;
      validPairs.addAll(v.map((e) => [k, e]));
    }
    pairs.add(getUniqueOrderedTuples(validPairs));
  }

  return pairs;
}

List<List<int>> prepareLabels(
    List<List<String>> completePairs, 
    List<List<String>> groundTruthPairs, 
    List<List<String>> retrievedPairs
) {
  var groundTruthSet = groundTruthPairs.map((e) => e.toSet()).toSet();
  var retrievedSet = retrievedPairs.map((e) => e.toSet()).toSet();

  var yTrue = completePairs.map((pair) => groundTruthSet.contains(pair.toSet()) ? 1 : 0).toList();
  var yPred = completePairs.map((pair) => retrievedSet.contains(pair.toSet()) ? 1 : 0).toList();

  return [yTrue, yPred];
}

Map<String, List<double>> metricScore(List<int> yTrue, List<int> yPred) {
  int truePositiveClass1 = 0;
  int falsePositiveClass1 = 0;
  int falseNegativeClass1 = 0;

  int truePositiveClass0 = 0;
  int falsePositiveClass0 = 0;
  int falseNegativeClass0 = 0;

  for (int i = 0; i < yTrue.length; i++) {
    if (yPred[i] == 1) {
      if (yTrue[i] == 1) {
        truePositiveClass1++;
      } else {
        falsePositiveClass1++;
      }
    } else {
      if (yTrue[i] == 1) {
        falseNegativeClass1++;
      } else {
        truePositiveClass0++;
      }
    }
  }

  double precisionClass1 = truePositiveClass1 / (truePositiveClass1 + falsePositiveClass1);
  double recallClass1 = truePositiveClass1 / (truePositiveClass1 + falseNegativeClass1);
  double f1Class1 = 2 * (precisionClass1 * recallClass1) / (precisionClass1 + recallClass1);

  double precisionClass0 = truePositiveClass0 / (truePositiveClass0 + falsePositiveClass0);
  double recallClass0 = truePositiveClass0 / (truePositiveClass0 + falseNegativeClass0);
  double f1Class0 = 2 * (precisionClass0 * recallClass0) / (precisionClass0 + recallClass0);

  return {
    'precision': [precisionClass0, precisionClass1],
    'recall': [recallClass0, recallClass1],
    'f1_score': [f1Class0, f1Class1],
    'support': [truePositiveClass0 + falseNegativeClass0, truePositiveClass1 + falseNegativeClass1],
  };
}
```

class-0 refers to non-duplicate image pairs.

class-1 refers to duplicate image pairs.