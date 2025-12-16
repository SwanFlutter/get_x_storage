import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_x_storage/get_x_storage.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetXStorage storage;

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
    storage = GetXStorage();
    await storage.clear();
  });

  group('writeList and readList Methods Tests', () {
    test('writeList and readList with List<String>', () async {
      final stringList = ['apple', 'banana', 'cherry', 'date', 'elderberry'];

      await storage.writeList<String>(key: 'fruits', value: stringList);
      final retrievedList = storage.readList<String>(key: 'fruits');

      expect(retrievedList, isNotNull);
      expect(retrievedList, isA<List<String>>());
      expect(retrievedList!.length, equals(5));
      expect(retrievedList, equals(stringList));
      expect(retrievedList.first, equals('apple'));
      expect(retrievedList.last, equals('elderberry'));
    });

    test('writeList and readList with List<int>', () async {
      final intList = [1, 2, 3, 4, 5, -10, 100, 0];

      await storage.writeList<int>(key: 'numbers', value: intList);
      final retrievedList = storage.readList<int>(key: 'numbers');

      expect(retrievedList, isNotNull);
      expect(retrievedList, isA<List<int>>());
      expect(retrievedList!.length, equals(8));
      expect(retrievedList, equals(intList));
      expect(retrievedList.contains(-10), isTrue);
      expect(retrievedList.contains(100), isTrue);
    });

    test('writeList and readList with List<double>', () async {
      final doubleList = [1.1, 2.2, 3.14, -4.5, 0.0, 99.99];

      await storage.writeList<double>(key: 'decimals', value: doubleList);
      final retrievedList = storage.readList<double>(key: 'decimals');

      expect(retrievedList, isNotNull);
      expect(retrievedList, isA<List<double>>());
      expect(retrievedList!.length, equals(6));
      expect(retrievedList, equals(doubleList));
      expect(retrievedList.contains(3.14), isTrue);
    });

    test('writeList and readList with List<bool>', () async {
      final boolList = [true, false, true, true, false, false];

      await storage.writeList<bool>(key: 'flags', value: boolList);
      final retrievedList = storage.readList<bool>(key: 'flags');

      expect(retrievedList, isNotNull);
      expect(retrievedList, isA<List<bool>>());
      expect(retrievedList!.length, equals(6));
      expect(retrievedList, equals(boolList));
      expect(
        retrievedList.where((b) => b).length,
        equals(3),
      ); // Count true values
    });

    test('writeList and readList with List<Map<String, dynamic>>', () async {
      final mapList = [
        {'name': 'John', 'age': 30, 'active': true, 'score': 95.5},
        {'name': 'Jane', 'age': 25, 'active': false, 'score': 87.2},
        {'name': 'Bob', 'age': 35, 'active': true, 'score': 92.8},
      ];

      await storage.writeList<Map<String, dynamic>>(
        key: 'users',
        value: mapList,
      );
      final retrievedList = storage.readList<Map<String, dynamic>>(
        key: 'users',
      );

      expect(retrievedList, isNotNull);
      expect(retrievedList, isA<List<Map<String, dynamic>>>());
      expect(retrievedList!.length, equals(3));
      expect(retrievedList, equals(mapList));

      // Test accessing nested data
      expect(retrievedList[0]['name'], equals('John'));
      expect(retrievedList[1]['age'], equals(25));
      expect(retrievedList[2]['active'], equals(true));
      expect(retrievedList[0]['score'], equals(95.5));
    });

    test('writeList and readList with List<List<dynamic>>', () async {
      final nestedList = [
        [1, 2, 3],
        ['a', 'b', 'c'],
        [true, false],
        [1.1, 2.2, 3.3],
        ['mixed', 42, true],
      ];

      await storage.writeList<List<dynamic>>(key: 'nested', value: nestedList);
      final retrievedList = storage.readList<List<dynamic>>(key: 'nested');

      expect(retrievedList, isNotNull);
      expect(retrievedList, isA<List<List<dynamic>>>());
      expect(retrievedList!.length, equals(5));
      expect(retrievedList, equals(nestedList));

      // Test accessing nested data
      expect(retrievedList[0], equals([1, 2, 3]));
      expect(retrievedList[1], equals(['a', 'b', 'c']));
      expect(retrievedList[4], equals(['mixed', 42, true]));
    });

    test('writeList and readList with empty list', () async {
      final emptyStringList = <String>[];
      final emptyIntList = <int>[];

      await storage.writeList<String>(
        key: 'emptyStrings',
        value: emptyStringList,
      );
      await storage.writeList<int>(key: 'emptyInts', value: emptyIntList);

      final retrievedStringList = storage.readList<String>(key: 'emptyStrings');
      final retrievedIntList = storage.readList<int>(key: 'emptyInts');

      expect(retrievedStringList, isNotNull);
      expect(retrievedStringList, isA<List<String>>());
      expect(retrievedStringList!.isEmpty, isTrue);

      expect(retrievedIntList, isNotNull);
      expect(retrievedIntList, isA<List<int>>());
      expect(retrievedIntList!.isEmpty, isTrue);
    });

    test('readList returns null for non-existent key', () async {
      final result = storage.readList<String>(key: 'nonExistentKey');
      expect(result, isNull);
    });

    test('readList returns null for wrong type', () async {
      // Store a non-list value
      await storage.write(key: 'notAList', value: 'just a string');

      final result = storage.readList<String>(key: 'notAList');
      expect(result, isNull);
    });

    test('writeList overwrites existing data', () async {
      final originalList = ['old1', 'old2', 'old3'];
      final newList = ['new1', 'new2', 'new3', 'new4'];

      await storage.writeList<String>(key: 'updateTest', value: originalList);
      var retrievedList = storage.readList<String>(key: 'updateTest');
      expect(retrievedList, equals(originalList));

      await storage.writeList<String>(key: 'updateTest', value: newList);
      retrievedList = storage.readList<String>(key: 'updateTest');
      expect(retrievedList, equals(newList));
      expect(retrievedList!.length, equals(4));
    });

    test('writeList and readList with large list', () async {
      final largeList = List.generate(1000, (index) => 'item_$index');

      await storage.writeList<String>(key: 'largeList', value: largeList);
      final retrievedList = storage.readList<String>(key: 'largeList');

      expect(retrievedList, isNotNull);
      expect(retrievedList!.length, equals(1000));
      expect(retrievedList.first, equals('item_0'));
      expect(retrievedList.last, equals('item_999'));
      expect(retrievedList[500], equals('item_500'));
    });

    test('writeList and readList with mixed complex types', () async {
      final complexList = [
        {
          'type': 'user',
          'data': {
            'name': 'John',
            'tags': ['admin', 'active'],
          },
        },
        {
          'type': 'product',
          'data': {'name': 'Widget', 'price': 29.99, 'inStock': true},
        },
        {
          'type': 'order',
          'data': {
            'id': 12345,
            'items': [1, 2, 3],
            'total': 99.97,
          },
        },
      ];

      await storage.writeList<Map<String, dynamic>>(
        key: 'complex',
        value: complexList,
      );
      final retrievedList = storage.readList<Map<String, dynamic>>(
        key: 'complex',
      );

      expect(retrievedList, isNotNull);
      expect(retrievedList!.length, equals(3));
      expect(retrievedList, equals(complexList));

      // Test deep nested access
      final userData = retrievedList[0]['data'] as Map<String, dynamic>;
      expect(userData['name'], equals('John'));

      final userTags = userData['tags'] as List<dynamic>;
      expect(userTags, equals(['admin', 'active']));

      final productData = retrievedList[1]['data'] as Map<String, dynamic>;
      expect(productData['price'], equals(29.99));
      expect(productData['inStock'], equals(true));
    });

    test('Type safety - readList with wrong generic type', () async {
      final stringList = ['apple', 'banana', 'cherry'];

      await storage.writeList<String>(key: 'fruits', value: stringList);

      // Try to read as int list - should return null due to type mismatch
      final wrongTypeResult = storage.readList<int>(key: 'fruits');
      expect(wrongTypeResult, isNull);

      // Reading as correct type should work
      final correctTypeResult = storage.readList<String>(key: 'fruits');
      expect(correctTypeResult, isNotNull);
      expect(correctTypeResult, equals(stringList));
    });
  });
}
