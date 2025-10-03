import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/presentation/widgets/task_item.dart';

void main() {
  group('TaskItem Widget Tests', () {
    late Task testTask;

    setUp(() {
      testTask = Task.create(title: 'Test Task').copyWith(id: 1);
    });

    testWidgets('should display task title correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskItem(task: testTask)),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('should show completed state when task is completed', (
      WidgetTester tester,
    ) async {
      final completedTask = testTask.copyWith(isCompleted: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskItem(task: completedTask)),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('should show pending state when task is pending', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskItem(task: testTask)),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('should show correct status text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskItem(task: testTask)),
        ),
      );

      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('should show edit and delete buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskItem(task: testTask)),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should call onToggleCompleted when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;
      bool? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: testTask,
              onToggleCompleted: (value) {
                wasCalled = true;
                newValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(wasCalled, isTrue);
      expect(newValue, isTrue);
    });

    testWidgets('should call onEdit when edit button is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: testTask,
              onEdit: () {
                wasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('should call onDelete when delete button is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: testTask,
              onDelete: () {
                wasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // Should show confirmation dialog
      expect(find.text('Eliminar Tarea'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Eliminar'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('should dismiss delete confirmation when cancel is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: testTask,
              onDelete: () {
                wasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // Should show confirmation dialog
      expect(find.text('Eliminar Tarea'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      expect(wasCalled, isFalse);
    });

    testWidgets(
      'should show recently updated indicator when task was recently updated',
      (WidgetTester tester) async {
        final recentTask = testTask.copyWith(
          updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TaskItem(task: recentTask)),
          ),
        );

        expect(find.text('Actualizada recientemente'), findsOneWidget);
      },
    );

    testWidgets('should format date correctly', (WidgetTester tester) async {
      final taskWithDate = testTask.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskItem(task: taskWithDate)),
        ),
      );

      expect(find.text('2d'), findsOneWidget);
    });
  });

  group('EmptyTasksWidget Tests', () {
    testWidgets('should display empty state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyTasksWidget())),
      );

      expect(find.text('No hay tareas'), findsOneWidget);
      expect(
        find.text('Agrega tu primera tarea usando el campo de texto arriba'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });

    testWidgets('should call onAddTask when add button is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyTasksWidget(
              onAddTask: () {
                wasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Agregar Tarea'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });
  });

  group('TasksLoadingWidget Tests', () {
    testWidgets('should display loading state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TasksLoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando tareas...'), findsOneWidget);
    });
  });

  group('TasksErrorWidget Tests', () {
    testWidgets('should display error state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TasksErrorWidget(errorMessage: 'Test error message'),
          ),
        ),
      );

      expect(find.text('Error al cargar tareas'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is tapped', (
      WidgetTester tester,
    ) async {
      bool wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasksErrorWidget(
              errorMessage: 'Test error',
              onRetry: () {
                wasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });
  });
}
