
# GetXStorage

**GetXStorage** is a lightweight and efficient persistent storage solution for Flutter applications, designed to integrate seamlessly with the GetX state management library. It offers a simple API for storing and retrieving data with reactive capabilities.

## Features

- 🚀 **Fast and Efficient**: Quick data storage and retrieval operations.
- 💾 **Persistent Storage**: Retains data across app restarts.
- 🌐 **Cross-Platform**: Works on iOS, Android, Web, and Desktop.
- 🔄 **Reactive Updates**: Built-in support for real-time updates via GetX.
- 🔒 **Type-Safe**: Ensures safe read and write operations with generic types.
- 🧩 **Simple API**: Easy-to-use methods for common storage tasks.

## Installation

Add `get_x_storage` to your `pubspec.yaml`:

```yaml
dependencies:
  get_x_storage: ^0.0.1
```

Then run:

```bash
flutter pub get add get_x_storage
```

*Note*: Replace `^0.0.1` with the latest version available on pub.dev.

## Usage

### Initialization

Initialize `GetXStorage` in your `main()` function before running the app:

```dart
import 'package:get_x_storage/get_x_storage.dart';

void main() async {
  await GetXStorage.init();
  runApp(MyApp());
}
```

```dart
// Create a storage instance
final storage = GetXStorage();

// Initialize with optional initial data
await storage.init({'theme': 'dark', 'language': 'en'});
```

### Basic Operations

#### Writing Data

```dart
final storage = GetXStorage();
await storage.write(key: 'username', value: 'JohnDoe');
await storage.write(key: 'age', value: 30);
await storage.write(key: 'isLoggedIn', value: true);
```

*Note*: Since `write` is asynchronous, use `await` to ensure the operation completes.

#### Reading Data

```dart
String? username = storage.read<String>(key: 'username'); // 'JohnDoe'
int? age = storage.read<int>(key: 'age'); // 30
bool? isLoggedIn = storage.read<bool>(key: 'isLoggedIn'); // true
```

*Note*: Returns `null` if the key doesn’t exist.

#### Checking if Data Exists

```dart
bool hasUsername = storage.hasData(key: 'username'); // true or false
```

#### Removing Data

```dart
await storage.remove(key: 'username');
```

#### Clearing All Data

```dart
await storage.erase();
```

### Reactive Programming

#### Listening to All Changes

```dart
storage.listen(() {
  print('Storage data changed');
});
```

#### Listening to Specific Key Changes

```dart
storage.listenKey(
  key: 'username',
  callback: (value) {
    print('Username changed to: $value');
  },
);
```

### Advanced Usage

#### Read and Write Operations

```dart
// Write data
await storage.write(key: 'username', value: 'John');
await storage.write(
  key: 'settings',
  value: {'notifications': true, 'darkMode': false},
);

// Read data with type safety
String? username = storage.read<String>(key: 'username');
Map<String, dynamic>? settings = storage.read<Map<String, dynamic>>(key: 'settings');

// Synchronous value change
storage.changeValueOfKey(key: 'username', newValue: 'Jane');
```

#### Error Handling Example

```dart
Future<void> safeWrite(String key, dynamic value) async {
  try {
    await storage.write(key: key, value: value);
  } catch (e) {
    print('Failed to write to storage: $e');
  }
}
```

#### Complex Data Updates

```dart
// 1. Create storage instance
final storage = GetXStorage();

// 2. Simple value changes
storage.changeValueOfKey(key: 'username', newValue: 'John');
storage.changeValueOfKey(key: 'age', newValue: 25);
storage.changeValueOfKey(key: 'isActive', newValue: true);

// 3. Update maps and lists
void updateData() {
  // Update map
  final currentPrefs = storage.read<Map<String, dynamic>>(key: 'preferences') ?? {};
  currentPrefs['notification'] = true;
  storage.changeValueOfKey(key: 'preferences', newValue: currentPrefs);

  // Update list
  final favorites = storage.read<List<dynamic>>(key: 'favorites') ?? [];
  favorites.add('newItem');
  storage.changeValueOfKey(key: 'favorites', newValue: favorites);
}

// 4. Listen to changes
storage.listenKey(
  key: 'username',
  callback: (value) {
    print('Username changed to: $value');
  },
);

// 5. Usage in Widget
class UserProfileWidget extends StatelessWidget {
  final storage = GetXStorage();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: storage.stream,
      builder: (context, snapshot) {
        final username = storage.read<String>(key: 'username') ?? 'Guest';
        return Column(
          children: [
            Text('Username: $username'),
            ElevatedButton(
              onPressed: () => storage.changeValueOfKey(key: 'username', newValue: 'NewUser'),
              child: const Text('Update Username'),
            ),
          ],
        );
      },
    );
  }
}
```

#### Using Custom Containers

Create isolated storage instances with custom containers:

```dart
final myContainer = GetXStorage('MyCustomContainer');
await myContainer.write(key: 'customKey', value: 'customValue');
```

#### Writing Data Only if Key Doesn’t Exist

```dart
await storage.writeIfNull(key: 'firstLaunch', value: true);
```

*Note*: This writes the value only if the key is not already present.

## Best Practices

1. **Early Initialization**: Call `GetXStorage.init()` early in your app lifecycle (e.g., in `main()`).
2. **Type Safety**: Use generic types (e.g., `read<String>(key: 'key')`) to avoid runtime errors.
3. **Reactive Updates**: Leverage `listen` and `listenKey` for real-time UI updates with GetX.
4. **Data Management**: Use `remove()` or `erase()` to clear sensitive or obsolete data.

## Dependencies

GetXStorage relies on:
- `rxdart` for reactive streams.
- `flutter` SDK.

Ensure these are included in your project.

---

# Test Benchmark



![b](https://github.com/user-attachments/assets/21546e6e-c478-445f-842f-cecb3b30f631)



![b1](https://github.com/user-attachments/assets/6116c469-c511-4f63-a6da-13c62a7790ce)



![benchmark](https://github.com/user-attachments/assets/b0832a61-9355-44c7-9567-c90243b8aa23)


---

## Contributing

Contributions are welcome! Please:
1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with your changes.

## License

[MIT License](LICENSE)

