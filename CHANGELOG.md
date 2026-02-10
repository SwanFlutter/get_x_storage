## 0.1.0

* **BREAKING CHANGE**: Migrated from deprecated `dart:html` to modern `package:web` for web platform support
* Fixed web storage persistence issues - data now saves correctly using `package:web` API
* Improved web storage implementation with proper `localStorage.setItem()` and `getItem()` methods
* Removed all debug print statements for cleaner production code
* Enhanced web storage reliability and compatibility with latest Flutter SDK
* Fixed theme persistence in web applications
* All tests passing with new web implementation

## 0.0.9

* **BREAKING CHANGE**: Removed `path_provider` dependency to fix Android NDK Clang build errors
* Replaced `encrypt` package with lightweight `crypto`-based encryption for better compatibility
* Fixed Android build issues with Flutter 3.38+ that required NDK installation
* Improved cross-platform compatibility by removing native dependencies
* Updated encryption implementation to use XOR cipher with SHA-256 key derivation
* All tests passing with new implementation

* Update Last SDK version

## 0.0.8

* Update Lsat SDK

## 0.0.7

* add delete method erese 
* add new method remove 

## 0.0.6

* add new two method

## 0.0.5

* Fix pub point.

## 0.0.4

* Fix bug platform support.

## 0.0.3

* Fix bug platform support.

## 0.0.2

* Fix bug platform support.

## 0.0.1

* initial release. 
