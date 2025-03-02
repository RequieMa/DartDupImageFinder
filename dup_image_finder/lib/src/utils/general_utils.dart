import 'dart:io';
import 'dart:async';
import 'package:worker_pool/worker_pool.dart';
import 'package:path/path.dart' as path;
import 'package:progress/progress.dart';

List<String> generateFiles(String imageDir, {bool recursive = false}) {
  final dir = Directory(imageDir);
  if (!dir.existsSync()) {
    throw ArgumentError('Directory not found: $imageDir');
  }

  try {
    return dir.listSync(recursive: recursive)
        .where((entity) {
          if (entity is! File) return false;
          final fileName = path.basename(entity.path);
          return !fileName.startsWith('.');
        })
        .map((entity) => entity.absolute.path)
        .toList();
  } on FileSystemException catch (e) {
    throw Exception('Directory listing failed: ${e.message}');
  }
}

List<String> generateRelativeNames(String imageDir, List<String> files) {
  final absImageDir = Directory(imageDir).absolute.path;
  return files.map((file) {
    final absFilePath = File(file).absolute.path;
    return path.relative(absFilePath, from: absImageDir);
  }).toList();
}

Future<List<R?>> parallelise<R, T>({
  required FutureOr<R?> Function(T) function,
  required List<T> data,
  bool verbose = true,
  int numWorkers = 4,
  Map<String, dynamic> parameters = const {},
}) async {
  numWorkers = numWorkers.clamp(1, Platform.numberOfProcessors);
  final pool = WorkerPool(numWorkers, isolateStart: _isolateStart);
  final progress = verbose ? Progress('Processing: ', data.length) : null;
  final results = <R?>[];

  try {
    await Future.wait(
      data.map((item) async {
        final result = await pool.execute(ParallelTask<T, R>(
          item: item,
          function: function,
          parameters: parameters,
        ));
        verbose ? progress?.update(1) : null;
        return result;
      }),
      eagerError: true,
    ).then((values) => results.addAll(values));
  } finally {
    pool.close();
    verbose ? progress?.finish() : null;
  }

  return results.whereType<R?>().toList();
}

static void _isolateStart(SendPort sendPort) {
  final channel = Channel<dynamic>.connectSend(sendPort);
  channel.register('parallel_task', (Map<String, dynamic> params) {
    try {
      final function = _functionMap[params['functionKey']];
      return function(params['item'], params['parameters']);
    } catch (e) {
      return null; // Or rethrow for error propagation
    }
  });
}

// Function registry for isolate safety
final _functionMap = <String, Function>{
  'hash_processor': _processItem,
  // Add other functions here
};

static R? _processItem<T, R>(T item, Map<String, dynamic> params) {
  // Your actual processing logic here
  // Example: return params['function'](item) as R;
}

class ParallelTask<T, R> extends Task<ParallelTask<T, R>, R?> {
  final T item;
  final String functionKey;
  final Map<String, dynamic> parameters;

  ParallelTask({
    required this.item,
    required String functionKey,
    required this.parameters,
  }) : functionKey = functionKey;

  @override
  R? execute() => Channel.withIsolatePool('parallel_task', params: {
        'functionKey': functionKey,
        'item': item,
        'parameters': parameters,
      });
}