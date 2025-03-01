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