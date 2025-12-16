import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get_x_storage/get_x_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class BenchmarkBase {
  final String name;
  final int operationCount;

  BenchmarkBase(this.name, {this.operationCount = 1000});

  Future<void> setup();
  Future<void> teardown();

  Future<void> writeOperations();
  Future<void> readOperations();

  Future<double> runOperation(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds / 1000.0;
  }

  Future<void> report() async {
    if (kDebugMode) {
      print('Starting benchmark: $name');
    }

    await setup();

    final writeTime = await runOperation(writeOperations);
    if (kDebugMode) {
      print('$name - Write operations took $writeTime seconds');
    }

    final readTime = await runOperation(readOperations);
    if (kDebugMode) {
      print('$name - Read operations took $readTime seconds');
    }

    await teardown();
  }
}

class GetStorageBenchmark extends BenchmarkBase {
  GetStorageBenchmark() : super('GetStorage Benchmark');
  late GetStorage storage;

  @override
  Future<void> setup() async {
    await GetStorage.init();
    storage = GetStorage();
  }

  @override
  Future<void> writeOperations() async {
    for (int i = 0; i < operationCount; i++) {
      storage.write('key$i', 'value$i');
    }
  }

  @override
  Future<void> readOperations() async {
    for (int i = 0; i < operationCount; i++) {
      storage.read('key$i');
    }
  }

  @override
  Future<void> teardown() async {
    await storage.erase();
  }
}

class HiveBenchmark extends BenchmarkBase {
  HiveBenchmark() : super('Hive Benchmark');
  late Box box;

  @override
  Future<void> setup() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    box = await Hive.openBox('testBox');
  }

  @override
  Future<void> writeOperations() async {
    for (int i = 0; i < operationCount; i++) {
      await box.put('key$i', 'value$i');
    }
  }

  @override
  Future<void> readOperations() async {
    for (int i = 0; i < operationCount; i++) {
      box.get('key$i');
    }
  }

  @override
  Future<void> teardown() async {
    await box.clear();
    await box.close();
  }
}

class SQLiteBenchmark extends BenchmarkBase {
  SQLiteBenchmark() : super('SQLite Benchmark');
  late Database database;

  @override
  Future<void> setup() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Test (
            id INTEGER PRIMARY KEY, 
            key TEXT, 
            value TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<void> writeOperations() async {
    for (int i = 0; i < operationCount; i++) {
      await database.insert('Test', {
        'key': 'key$i',
        'value': 'value$i',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  @override
  Future<void> readOperations() async {
    for (int i = 0; i < operationCount; i++) {
      final result = await database.query(
        'Test',
        where: 'key = ?',
        whereArgs: ['key$i'],
      );

      if (result.isEmpty) {
        throw Exception('Query failed for key: key$i');
      }
    }
  }

  @override
  Future<void> teardown() async {
    await database.close();
  }
}

class SharedPreferencesBenchmark extends BenchmarkBase {
  SharedPreferencesBenchmark() : super('SharedPreferences Benchmark');
  late SharedPreferences prefs;

  @override
  Future<void> setup() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> writeOperations() async {
    for (int i = 0; i < operationCount; i++) {
      await prefs.setString('key$i', 'value$i');
    }
  }

  @override
  Future<void> readOperations() async {
    for (int i = 0; i < operationCount; i++) {
      prefs.getString('key$i');
    }
  }

  @override
  Future<void> teardown() async {
    await prefs.clear();
  }
}

class GetXStorageBenchmark extends BenchmarkBase {
  GetXStorageBenchmark() : super('GetXStorage Benchmark');
  late GetXStorage storage;

  @override
  Future<void> setup() async {
    await GetXStorage.init();
    storage = GetXStorage();
  }

  @override
  Future<void> writeOperations() async {
    for (int i = 0; i < operationCount; i++) {
      await storage.write(key: 'key$i', value: 'value$i');
    }
  }

  @override
  Future<void> readOperations() async {
    for (int i = 0; i < operationCount; i++) {
      storage.read<String>(key: 'key$i');
    }
  }

  @override
  Future<void> teardown() async {
    await storage.clear();
  }
}

void main() {
  // Skip tests on web platform
  if (kIsWeb) {
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (
        MethodCall methodCall,
      ) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      });

  group('Storage Benchmarks', () {
    test('GetStorage Write/Read Benchmark', () async {
      await GetStorageBenchmark().report();
    });

    test('Hive Write/Read Benchmark', () async {
      await HiveBenchmark().report();
    });

    test('SQLite Write/Read Benchmark', () async {
      await SQLiteBenchmark().report();
    });

    test('SharedPreferences Write/Read Benchmark', () async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferencesBenchmark().report();
    });

    test('GetXStorage Write/Read Benchmark', () async {
      await GetXStorageBenchmark().report();
    });
  });
}
