# 1. Set Up Your Project
Create a New Directory:

Create a new directory for your library. You can name it whatever you like.
Initialize the Project:

Open a terminal and navigate to your new directory.
Run the following command to create a new Dart package:
```cmd
dart create -t package-simple my_library
```

Replace my_library with your desired library name.
# 2. Structure Your Library
Your library should have a well-organized structure. Here's a basic example:
```md
my_library/
├── lib/
│   ├── src/
│   │   └── my_library_base.dart
│   └── my_library.dart
├── test/
│   └── my_library_test.dart
├── pubspec.yaml
└── README.md
```
# 3. Write Your Library Code
- lib/my_library.dart:

This is the main entry point for your library. It should export the necessary files.
```dart
library my_library;

export 'src/my_library_base.dart';
```
- lib/src/my_library_base.dart:

This file contains the core functionality of your library.
```dart
class MyLibrary {
  String greet(String name) => 'Hello, $name!';
}
```
# 4. Add Dependencies
Open the pubspec.yaml file and add any dependencies your library needs. For example:
```yaml
name: my_library
description: A simple Dart library.
version: 0.0.1
environment:
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  # Add your dependencies here
```
# 5. Write Tests
Create test files in the test directory to ensure your library works as expected.
- test/my_library_test.dart:
```dart
import 'package:my_library/my_library.dart';
import 'package:test/test.dart';

void main() {
  test('greet returns a greeting message', () {
    final myLibrary = MyLibrary();
    expect(myLibrary.greet('World'), 'Hello, World!');
  });
}
```
# 6. Publish Your Library (Optional)
If you want to share your library with others, you can publish it to pub.dev.
Run the following command to publish your library:
```cmd
dart pub publish
```
# Summary
1. Set up your project directory and initialize it.
2. Organize your library structure.
3. Write your library code.
4. Add dependencies in pubspec.yaml.
5. Write tests to ensure your library works correctly.
6. Optionally, publish your library to pub.dev.

## Reference
[Dart Package](https://dart.dev/tools/pub/publishing)


# Steps to Rename Your Git Repository
Rename Repository: On GitHub, you can rename your repository directly from the repository settings.
Update Remote URL: After renaming, update the remote URL in your local Git configuration.
## Example Commands
1. Rename Repository on GitHub:
- Go to your repository on GitHub.
- Click on "Settings".
- Change the repository name to match your library name.
2. Update Remote URL Locally:
```cmd
git remote set-url origin https://github.com/yourusername/new-repo-name.git
```

Change License to The 3-Clause BSD License