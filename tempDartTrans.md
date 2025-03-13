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
```dart
Map<String, dynamic> getAllMetrics(Map<String, List<String>> groundTruth, Map<String, List<String>> retrieved) {
  return {
    'map': meanMetric(groundTruth, retrieved, metric: 'map'),
    'ndcg': meanMetric(groundTruth, retrieved, metric: 'ndcg'),
    'jaccard': meanMetric(groundTruth, retrieved, metric: 'jaccard'),
  };
}

double meanMetric(Map<String, List<String>> groundTruth, Map<String, List<String>> retrieved, {required String metric}) {
  metric = metric.toLowerCase();
  Map<String, Function> metricLookup = {
    'map': avgPrec,
    'ndcg': ndcg,
    'jaccard': jaccardSimilarity,
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

  int countRealCorrect = correctDuplicates.length;
  List<int> relevance = retrievedDuplicates.map((i) => correctDuplicates.contains(i) ? 1 : 0).toList();
  List<int> relevanceCumsum = List<int>.generate(relevance.length, (i) => relevance.sublist(0, i + 1).reduce((a, b) => a + b));
  List<double> precK = List<double>.generate(relevance.length, (k) => relevanceCumsum[k] / (k + 1));
  List<double> precAndRelevance = List<double>.generate(relevance.length, (k) => relevance[k] * precK[k]);
  double avgPrecision = precAndRelevance.reduce((a, b) => a + b) / countRealCorrect;

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
    List<double> relevanceDenominator = List<double>.generate(rel.length, (k) => log(k + 2) / ln2);
    List<double> dcgTerms = List<double>.generate(rel.length, (k) => relevanceNumerator[k] / relevanceDenominator[k]);
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

double jaccardSimilarity(List<String> correctDuplicates, List<String> retrievedDuplicates) {
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
