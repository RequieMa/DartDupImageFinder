# dup_image_finder

[![Pub Version](https://img.shields.io/pub/v/dup_image_finder)](https://pub.dev/packages/dup_image_finder) 
[![Pub Points](https://img.shields.io/pub/points/dup_image_finder)](https://pub.dev/packages/dup_image_finder/score)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue?style=flat-square)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/RequieMa/dup_image_finder/publish.yml)](https://github.com/RequieMa/dup_image_finder/actions)

A cross-platform pure Dart library for detecting duplicate images using various methods (e.g. hashing, CNN), supporting multiple image formats and efficient similarity comparison.

**Compatibility**: Dart `^3.6.0` 
<!-- | Flutter `^3.16.0` | [Other Requirements] -->

## 🚀 Getting Started

### Installation
**Method 1 (Recommended)**
With Dart:
```cmd
dart pub add dup_image_finder
```

With Flutter:
```cmd
flutter pub add dup_image_finder
```

**Method 2**
Add to `pubspec.yaml`:
```yaml
dependencies:
  dup_image_finder: ^0.1.1
```
Then run:
```bash
dart pub get
```

### Basic Usage
```dart
import 'package:dup_image_finder/dup_image_finder.dart';

final dupImageFinder = DupImageFinder(useML: false, hasher: AHash());
final hashMap = dupImageFinder.encodeImages("FolderName");
final result = dupImageFinder.findDuplicates(hashMap);
```

## 📦 Features

- **Core Feature 1**: Encode Images From A Folder
  - Allow to encode images recursively
  ```dart
  final hashMap = dupImageFinder.encodeImages("FolderName", recursive: true);
  ```

- **Core Feature 2**: Find Duplicated Images For The Folder
  - `hashMap` from `encodeImages`
  - `maxDistanceThreshold` defines the maximum bit difference
  - `scores` if true, the end-result will show how close the image is to the query image
  - `searchMethod` currently only support BK-Tree (Later will also support Brute Force)
  ```dart
  final result = dupImageFinder.findDuplicates(
    hashMap, maxDistanceThreshold: 10,
    scores: true, searchMethod: "bktree",
  );
  ```

## 🧪 Testing

<!-- ```bash
# Run tests with coverage
dart test --coverage=./coverage
```

| Metric          | Status                      |
|-----------------|-----------------------------|
| Test Coverage   | 100% (core logic)           |
| Static Analysis | Enforced via `pedantic`     |

--- -->

## 🤝 Contributing

### Workflow
1. Fork repository
2. Create feature branch:
   ```bash
   git checkout -b feat/your-feature
   ```
3. Follow [Conventional Commits](https://www.conventionalcommits.org):
   ```bash
   git commit -m "feat: add new validation method"
   ```

### Code Style
Follow the **Effective Dart** and `analysis_options.yaml`

## 📚 Documentation

<!-- | Resource         | Link                                   |
|------------------|----------------------------------------|
| API Reference    | [View Docs](https://pub.dev/documentation/your_package) |
| Example Project  | [/example](example/)                   |
| Tutorial Series  | [YouTube Playlist](https://youtube.com/your-channel) | -->

---

## 📜 License

BSD 3-Clause "New" or "Revised" License © 2025 RequieMa

Full text at [LICENSE](LICENSE)

## 🚧 Maintenance Status
Basic functionalities are under development. 

Please report issues via [GitHub Issues](https://github.com/RequieMa/dup_image_finder/issues)

## Acknowledgement
This project was conceptually inspired by:
- [imagededup](https://github.com/idealo/imagededup) - A Python library for finding duplicate images