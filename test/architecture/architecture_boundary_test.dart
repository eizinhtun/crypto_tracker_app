import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('architecture boundaries', () {
    test('presentation layer does not import API, persistence, or data layer',
        () {
      _expectNoForbiddenImports(
        path: 'lib/features/crypto/presentation',
        forbiddenImports: {
          'data layer': RegExp(r'features/crypto/data/'),
          'relative data layer': RegExp(r'''['"](?:\.\./)+data/'''),
          'network core': RegExp(r'core/network/'),
          'database core': RegExp(r'core/database/'),
          'service locator': RegExp(r'core/di/|package:get_it/'),
          'Dio': RegExp(r'package:dio/'),
          'Hive': RegExp(r'package:hive/'),
          'HTTP client': RegExp(r'package:http/'),
        },
      );
    });

    test('domain layer does not depend on Flutter, data, or infrastructure',
        () {
      _expectNoForbiddenImports(
        path: 'lib/features/crypto/domain',
        forbiddenImports: {
          'presentation layer': RegExp(r'features/crypto/presentation/'),
          'data layer': RegExp(r'features/crypto/data/'),
          'relative data layer': RegExp(r'''['"](?:\.\./)+data/'''),
          'Flutter': RegExp(r'package:flutter'),
          'BLoC': RegExp(r'package:flutter_bloc/|package:bloc/'),
          'Dio': RegExp(r'package:dio/'),
          'Hive': RegExp(r'package:hive/'),
          'database core': RegExp(r'core/database/'),
          'network core': RegExp(r'core/network/'),
        },
      );
    });
  });
}

void _expectNoForbiddenImports({
  required String path,
  required Map<String, RegExp> forbiddenImports,
}) {
  final violations = <String>[];

  for (final file in _dartFiles(path)) {
    final importLines = file
        .readAsLinesSync()
        .where((line) => line.trimLeft().startsWith('import '));

    for (final importLine in importLines) {
      for (final entry in forbiddenImports.entries) {
        if (entry.value.hasMatch(importLine)) {
          violations.add('${file.path}: ${entry.key}: $importLine');
        }
      }
    }
  }

  expect(
    violations,
    isEmpty,
    reason: 'Architecture boundary violations:\n${violations.join('\n')}',
  );
}

Iterable<File> _dartFiles(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
