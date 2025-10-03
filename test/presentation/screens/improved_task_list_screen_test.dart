import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
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
import 'package:app_consware/src/presentation/screens/improved_task_list_screen.dart';
import 'package:app_consware/src/core/di/dependency_injection.dart';

import 'improved_task_list_screen_test.mocks.dart';

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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: container.overrides,
      child: MaterialApp(home: const ImprovedTaskListScreen()),
    );
  }

  group('ImprovedTaskListScreen', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display task list when data is loaded', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockGetTasks.call(),
      ).thenAnswer((_) async => dartz.Right([testTask]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('should display empty state when no tasks', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No hay tareas'), findsOneWidget);
      expect(find.text('Agrega tu primera tarea'), findsOneWidget);
    });

    testWidgets('should display error state when data loading fails', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer(
        (_) async => dartz.Left(DatabaseFailure(message: 'Database error')),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error al cargar las tareas'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('should show floating action button', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Nueva Tarea'), findsOneWidget);
    });

    testWidgets('should navigate to add task screen when FAB is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nueva Tarea'), findsWidgets);
    });

    testWidgets('should display statistics section', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockGetTasks.call(),
      ).thenAnswer((_) async => dartz.Right([testTask]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Completadas'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);
    });

    testWidgets('should display search and filter section', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should filter tasks by search query', (
      WidgetTester tester,
    ) async {
      // Arrange
      final tasks = [
        testTask,
        Task(
          id: 2,
          title: 'Another Task',
          isCompleted: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right(tasks));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Another Task'), findsNothing);
    });

    testWidgets('should filter tasks by status', (WidgetTester tester) async {
      // Arrange
      final tasks = [
        testTask,
        Task(
          id: 2,
          title: 'Completed Task',
          isCompleted: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right(tasks));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select completed filter
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completadas'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('Test Task'), findsNothing);
    });

    testWidgets('should show menu with clear completed option', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockGetTasks.call(),
      ).thenAnswer((_) async => dartz.Right([testTask]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Limpiar Completadas'), findsOneWidget);
      expect(find.text('Limpiar Filtros'), findsOneWidget);
    });

    testWidgets('should refresh when pull to refresh is triggered', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockGetTasks.call(),
      ).thenAnswer((_) async => dartz.Right([testTask]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();

      // Assert
      verify(mockGetTasks.call()).called(greaterThan(1));
    });

    testWidgets('should show header with title and actions', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tareas'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });
  });
}
