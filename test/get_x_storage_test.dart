import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_x_storage/get_x_storage.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetXStorage g;

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  void setUpMockChannels(MethodChannel channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall? methodCall) async {
          if (methodCall?.method == 'getApplicationDocumentsDirectory') {
            return '.';
          }
          return null;
        });
  }

  setUpAll(() async {
    setUpMockChannels(channel);
  });

  setUp(() async {
    await GetXStorage.init();
    g = GetXStorage();
    await g.clear();
  });

  test('write, read listen, e removeListen', () async {
    String valueListen = "";
    g.write(key: 'test', value: 'a');
    g.write(key: 'test2', value: 'a');

    final removeListen = g.listenKey(
      key: 'test',
      callback: (val) {
        valueListen = val;
      },
    );

    expect('a', g.read(key: 'test'));

    await g.write(key: 'test', value: 'b');
    expect('b', g.read<String>(key: 'test'));
    expect('b', valueListen);

    await removeListen.cancel(); // Properly cancel the listener

    await g.write(key: 'test', value: 'c');

    expect('c', g.read<String>(key: 'test'));
    expect('b', valueListen); // This should now pass
    await g.write(key: 'test', value: 'd');

    expect('d', g.read<String>(key: 'test'));
  });

  test('Write and read', () {
    var list = List<int>.generate(50, (i) {
      int count = i + 1;
      g.write(key: 'write', value: count);
      return count;
    });

    expect(list.last, g.read(key: 'write'));
  });

  test('Test backup and recover corrupted file', () async {
    await g.write(key: 'write', value: 'abc');
    expect('abc', g.read(key: 'write'));

    final file = await _fileDb();
    file.writeAsStringSync('ndj323e');
    await GetXStorage.init();

    expect('abc', g.read(key: 'write'));
  });

  test('Write and read using delegate', () {
    var list = List<int>.generate(50, (i) {
      int count = i + 1;
      g.write(key: 'write', value: count);
      return count;
    });

    final data = g.read<int>(key: 'write') ?? 0;
    expect(list.last, data);
  });

  test('Write, read, remove and exists', () {
    expect(null, g.read(key: 'write'));

    var list = List<int>.generate(50, (i) {
      int count = i + 1;
      g.write(key: 'write', value: count);
      return count;
    });
    expect(list.last, g.read(key: 'write'));
    g.remove(key: 'write');
    expect(null, g.read(key: 'write'));
  });

  test('newContainer', () async {
    final container1 = await GetXStorage.init('container1');
    await GetXStorage.init('newContainer');
    final newContainer = GetXStorage('newContainer');

    /// Attempting to start a Container that has already started must return the container already created.
    var container2 = await GetXStorage.init();
    expect(container1 == container2, true);

    newContainer.write(key: 'test', value: '1234');
    g.write(key: 'test', value: 'a');
    expect(g.read(key: 'test') == newContainer.read(key: 'test'), false);
  });

  group('get keys/values', () {
    eq(i, l) => const ListEquality().equals(i.toList(), l);

    test('should return their stored dynamic values', () {
      expect(eq(g.getKeys().toList(), []), true);
      expect(eq(g.getValues().toList(), []), true);

      g.write(key: 'key1', value: 1);
      expect(eq(g.getKeys(), ['key1']), true);
      expect(eq(g.getValues(), [1]), true);

      g.write(key: 'key2', value: 'a');
      expect(eq(g.getKeys(), ['key1', 'key2']), true);
      expect(eq(g.getValues(), [1, 'a']), true);

      g.write(key: 'key3', value: 3.0);
      expect(eq(g.getKeys(), ['key1', 'key2', 'key3']), true);
      expect(eq(g.getValues(), [1, 'a', 3.0]), true);
    });
  });
}

Future<File> _fileDb({
  bool isBackup = false,
  String fileName = 'GetXStorage',
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = dir.path;
  final file =
      isBackup ? File('$path/$fileName.bak') : File('$path/$fileName.gs');
  return file;
}
