import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_consware/src/presentation/providers/task_providers.dart';

void main() {
  group('Task Providers Simple Tests', () {
    test('taskListProvider should be defined', () {
      // Arrange & Act
      final provider = taskListProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('completedTasksProvider should be defined', () {
      // Arrange & Act
      final provider = completedTasksProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('pendingTasksProvider should be defined', () {
      // Arrange & Act
      final provider = pendingTasksProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('taskStatsProvider should be defined', () {
      // Arrange & Act
      final provider = taskStatsProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('isLoadingProvider should be defined', () {
      // Arrange & Act
      final provider = isLoadingProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('hasErrorProvider should be defined', () {
      // Arrange & Act
      final provider = hasErrorProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('hasTasksProvider should be defined', () {
      // Arrange & Act
      final provider = hasTasksProvider;

      // Assert
      expect(provider, isNotNull);
    });

    test('TaskStatus enum should have correct values', () {
      // Assert
      expect(TaskStatus.values.length, equals(3));
      expect(TaskStatus.all.toString(), contains('all'));
      expect(TaskStatus.completed.toString(), contains('completed'));
      expect(TaskStatus.pending.toString(), contains('pending'));
    });

    test('TaskStatus displayName should return correct text', () {
      // Assert
      expect(TaskStatus.all.displayName, equals('Todas'));
      expect(TaskStatus.completed.displayName, equals('Completadas'));
      expect(TaskStatus.pending.displayName, equals('Pendientes'));
    });
  });
}
