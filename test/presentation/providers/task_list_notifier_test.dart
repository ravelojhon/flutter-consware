import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_consware/src/core/errors/failures.dart';
import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/domain/usecases/add_task.dart';
import 'package:app_consware/src/domain/usecases/delete_task.dart';
import 'package:app_consware/src/domain/usecases/get_tasks.dart';
import 'package:app_consware/src/domain/usecases/update_task.dart';
import 'package:app_consware/src/presentation/providers/task_list_notifier.dart';
import 'package:app_consware/src/core/di/dependency_injection.dart';

import 'task_list_notifier_test.mocks.dart';

@GenerateMocks([GetTasks, AddTask, UpdateTask, DeleteTask])
void main() {
  late MockGetTasks mockGetTasks;
  late MockAddTask mockAddTask;
  late MockUpdateTask mockUpdateTask;
  late MockDeleteTask mockDeleteTask;
  late ProviderContainer container;

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockAddTask = MockAddTask();
    mockUpdateTask = MockUpdateTask();
    mockDeleteTask = MockDeleteTask();

    container = ProviderContainer(
      overrides: [
        getTasksProvider.overrideWith((ref) => mockGetTasks),
        addTaskProvider.overrideWith((ref) => mockAddTask),
        updateTaskProvider.overrideWith((ref) => mockUpdateTask),
        deleteTaskProvider.overrideWith((ref) => mockDeleteTask),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TaskListNotifier', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    group('build', () {
      test('should return loading state initially', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));

        // Act
        final notifier = container.read(taskListProvider.notifier);
        final state = await notifier.future;

        // Assert
        expect(state, equals([testTask]));
        verify(mockGetTasks.call()).called(1);
      });

      test('should return error state when getTasks fails', () async {
        // Arrange
        when(mockGetTasks.call()).thenAnswer(
          (_) async => dartz.Left(DatabaseFailure(message: 'Database error')),
        );

        // Act & Assert
        expect(
          () => container.read(taskListProvider.future),
          throwsA(isA<Exception>()),
        );
        verify(mockGetTasks.call()).called(1);
      });
    });

    group('refresh', () {
      test('should reload tasks successfully', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        final notifier = container.read(taskListProvider.notifier);

        // Act
        await notifier.refresh();

        // Assert
        verify(
          mockGetTasks.call(),
        ).called(2); // Once for build, once for refresh
      });

      test('should handle error during refresh', () async {
        // Arrange
        when(mockGetTasks.call())
            .thenAnswer((_) async => dartz.Right<List<Task>, Failure>([testTask]))
            .thenAnswer(
              (_) async =>
                  dartz.Left<List<Task>, Failure>(DatabaseFailure(message: 'Database error')),
            );
        final notifier = container.read(taskListProvider.notifier);

        // Act & Assert
        expect(() => notifier.refresh(), throwsA(isA<Exception>()));
        verify(mockGetTasks.call()).called(2);
      });
    });

    group('addTask', () {
      test('should add task successfully', () async {
        // Arrange
        when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));
        when(
          mockAddTask.call(
            title: anyNamed('title'),
            description: anyNamed('description'),
            isCompleted: anyNamed('isCompleted'),
          ),
        ).thenAnswer((_) async => dartz.Right(testTask));
        final notifier = container.read(taskListProvider.notifier);

        // Act
        await notifier.addTask(
          title: 'New Task',
          description: 'New Description',
          isCompleted: false,
        );

        // Assert
        verify(
          mockAddTask.call(
            title: 'New Task',
            description: 'New Description',
            isCompleted: false,
          ),
        ).called(1);
        verify(mockGetTasks.call()).called(1); // For refresh
      });

      test('should handle error when adding task', () async {
        // Arrange
        when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));
        when(
          mockAddTask.call(
            title: anyNamed('title'),
            description: anyNamed('description'),
            isCompleted: anyNamed('isCompleted'),
          ),
        ).thenAnswer(
          (_) async =>
              dartz.Left(ValidationFailure(message: 'Validation error')),
        );
        final notifier = container.read(taskListProvider.notifier);

        // Act & Assert
        expect(
          () => notifier.addTask(
            title: 'New Task',
            description: 'New Description',
            isCompleted: false,
          ),
          throwsA(isA<Exception>()),
        );
        verify(
          mockAddTask.call(
            title: 'New Task',
            description: 'New Description',
            isCompleted: false,
          ),
        ).called(1);
      });
    });

    group('updateTask', () {
      test('should update task successfully', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        when(
          mockUpdateTask.call(any),
        ).thenAnswer((_) async => dartz.Right(testTask));
        final notifier = container.read(taskListProvider.notifier);

        // Act
        await notifier.updateTask(testTask);

        // Assert
        verify(mockUpdateTask.call(testTask)).called(1);
        verify(mockGetTasks.call()).called(1); // For refresh
      });

      test('should handle error when updating task', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        when(mockUpdateTask.call(any)).thenAnswer(
          (_) async => dartz.Left(DatabaseFailure(message: 'Database error')),
        );
        final notifier = container.read(taskListProvider.notifier);

        // Act & Assert
        expect(() => notifier.updateTask(testTask), throwsA(isA<Exception>()));
        verify(mockUpdateTask.call(testTask)).called(1);
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        when(mockDeleteTask.call(1)).thenAnswer((_) async => dartz.Right(true));
        final notifier = container.read(taskListProvider.notifier);

        // Act
        await notifier.deleteTask(1);

        // Assert
        verify(mockDeleteTask.call(1)).called(1);
      });

      test('should handle error when deleting task', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        when(mockDeleteTask.call(1)).thenAnswer(
          (_) async => dartz.Left(DatabaseFailure(message: 'Database error')),
        );
        final notifier = container.read(taskListProvider.notifier);

        // Act & Assert
        expect(() => notifier.deleteTask(1), throwsA(isA<Exception>()));
        verify(mockDeleteTask.call(1)).called(1);
      });
    });

    group('toggleTaskCompletion', () {
      test('should toggle task completion successfully', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        when(
          mockUpdateTask.call(any),
        ).thenAnswer((_) async => dartz.Right(testTask));
        final notifier = container.read(taskListProvider.notifier);

        // Act
        await notifier.toggleTaskCompletion(1);

        // Assert
        verify(mockUpdateTask.call(any)).called(1);
      });

      test('should handle error when toggling task completion', () async {
        // Arrange
        when(
          mockGetTasks.call(),
        ).thenAnswer((_) async => dartz.Right([testTask]));
        when(mockUpdateTask.call(any)).thenAnswer(
          (_) async => dartz.Left(DatabaseFailure(message: 'Database error')),
        );
        final notifier = container.read(taskListProvider.notifier);

        // Act & Assert
        expect(
          () => notifier.toggleTaskCompletion(1),
          throwsA(isA<Exception>()),
        );
        verify(mockUpdateTask.call(any)).called(1);
      });
    });
  });

  group('TaskStats', () {
    test('should calculate stats correctly', () {
      // Arrange
      final tasks = [
        Task(
          id: 1,
          title: 'Task 1',
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: 2,
          title: 'Task 2',
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: 3,
          title: 'Task 3',
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Act
      final stats = TaskStats.fromTasks(tasks);

      // Assert
      expect(stats.total, equals(3));
      expect(stats.completed, equals(2));
      expect(stats.pending, equals(1));
      expect(stats.completionPercentage, equals(66.67));
    });

    test('should handle empty task list', () {
      // Arrange
      final tasks = <Task>[];

      // Act
      final stats = TaskStats.fromTasks(tasks);

      // Assert
      expect(stats.total, equals(0));
      expect(stats.completed, equals(0));
      expect(stats.pending, equals(0));
      expect(stats.completionPercentage, equals(0.0));
    });
  });
}
