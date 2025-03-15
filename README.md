# DartDupImageFinder
Find duplicate images using Dart

<!-- # <package_name>  -->

<!-- [![pub package](https://img.shields.io/pub/v/<package_name>.svg)](https://pub.dev/packages/<package_name>) -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Dart library for finding **duplicate images** using perceptual hashing algorithms.  
Optimized for Flutter asset management and mobile platforms.

**Key Features**:
- 🖼️ Supports PNG/JPG/ image formats
<!-- - WebP -->
<!-- - ⚡ Parallel computing via Dart Isolate -->
- 📱 Pure Dart implementation (no native dependencies)
- 🔍 Dual mode: Precise DL Model & Fast hashing

<!-- ![Demo GIF](docs/demo.gif) 添加示例GIF -->

<!-- ## 安装
在`pubspec.yaml`中添加： -->
<!-- ```yaml
dependencies:
  <package_name>: ^1.0.0
```
Or run:
```bash
dart pub add <package_name>
``` -->
<!-- # Quick Start -->

<!-- # Algorithm Details
Perceptual Hashing Workflow

Image Preprocessing: Grayscale conversion & downsampling using package:image
Hash Generation: Custom DCT-based hashing implementation
Similarity Calculation: Optimized Hamming distance computation

# Performance Optimizations
Parallel Processing: Isolate-based parallel computing
Memory Management: Chunked image loading for large files
Cache System: Persistent hash storage support
Project Structure -->

## Inspiration
This project was conceptually inspired by:
- [imagededup](https://github.com/idealo/imagededup) - A Python library for finding duplicate images

## Key Differences
- Pure Dart implementation (no Python/C++ dependencies)
- Optimized for mobile/flutter asset management
- Implemented perceptual hash with Dart's image package

# Need to implement
1. Perceptual Hashing + BK-tree
2. Histogram Comparison + Ball Tree
  - Histogram Comparison distances
    - Euclidean Distance - con: Sensitive to changes in lighting and contrast and scale
    - Chi-square Distance - con: Sensitive to bins with low counts
    - Bhattacharyya Distance - Effective for measuring distribution overlap and robust to variations but complex to compute
  - Image Color Space
    - Lab
    - HSV
3. Mean Squared Error (MSE) + Array (Threshold < 1000)
4. Structural Similarity Index (SSIM) + Quad-tree
5. Fuzzy Matching + BK-tree or Trie
6. Feature Matching + k-d Tree or FLANN (Fast Library for Approximate Nearest Neighbors)
 - ORB
 - SIFT
7. Deep Learning Methods + Hash Table or ANN (Approximate Nearest Neighbor) Index, like FAISS (Facebook AI Similarity Search)

# Dart Library
1. Image related
  - https://pub.dev/packages/easy_image_viewer 
  - https://pub.dev/packages/swipe_image_gallery
  - https://pub.dev/packages/form_builder_image_picker
  - https://pub.dev/packages/image
  - https://pub.dev/packages/image_gallery_saver_plus
  - https://pub.dev/packages/universal_image
  - https://pub.dev/packages/image_fade
  - https://pub.dev/packages/image_compare_slider
  - https://pub.dev/packages/photo_manager
  - https://pub.dev/packages/fan_carousel_image_slider
  - https://pub.dev/packages/opencv_dart

2. Others
  - https://pub.dev/packages/flutter_storage_path
  - https://pub.dev/packages/animated_introduction
  - https://pub.dev/packages/image_firework
  - https://pub.dev/packages/lakos
  - https://pub.dev/packages/onnxruntime

3. Wavelet (Currently not available with Dart and OpenCV)
  - https://stackoverflow.com/questions/24536552/how-to-combine-pywavelet-and-opencv-for-image-processing

# Benchmark using part of
https://www.kaggle.com/datasets/barelydedicated/airbnb-duplicate-image-detection/code 

<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.

# Benchmark using part of
https://www.kaggle.com/datasets/barelydedicated/airbnb-duplicate-image-detection/code 