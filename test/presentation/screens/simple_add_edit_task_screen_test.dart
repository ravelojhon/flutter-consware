import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_consware/src/core/errors/failures.dart';
import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/domain/usecases/add_task.dart';
import 'package:app_consware/src/domain/usecases/update_task.dart';
import 'package:app_consware/src/presentation/providers/task_list_notifier.dart';
import 'package:app_consware/src/presentation/screens/simple_add_edit_task_screen.dart';
import 'package:app_consware/src/core/di/dependency_injection.dart';

import 'simple_add_edit_task_screen_test.mocks.dart';

@GenerateMocks([AddTask, UpdateTask])
void main() {
  late MockAddTask mockAddTask;
  late MockUpdateTask mockUpdateTask;
  late ProviderContainer container;

  setUp(() {
    mockAddTask = MockAddTask();
    mockUpdateTask = MockUpdateTask();

    container = ProviderContainer(
      overrides: [
        addTaskProvider.overrideWith((ref) => mockAddTask),
        updateTaskProvider.overrideWith((ref) => mockUpdateTask),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createWidgetUnderTest({Task? task}) {
    return ProviderScope(
      overrides: container.overrides,
      child: MaterialApp(home: SimpleAddEditTaskScreen(task: task)),
    );
  }

  group('SimpleAddEditTaskScreen', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    group('Add Task Mode', () {
      testWidgets('should display correct title for add mode', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Nueva Tarea'), findsOneWidget);
      });

      testWidgets('should display empty form fields', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Ingresa el título de la tarea...'), findsOneWidget);
        expect(
          find.text('Agrega una descripción detallada de la tarea...'),
          findsOneWidget,
        );
      });

      testWidgets('should show create button', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Crear Tarea'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should validate required title field', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Crear Tarea'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('El título no puede estar vacío'), findsOneWidget);
      });
    });

    group('Edit Task Mode', () {
      testWidgets('should display correct title for edit mode', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: testTask));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Editar Tarea'), findsOneWidget);
      });

      testWidgets('should populate form fields with existing task data', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: testTask));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Task'), findsOneWidget);
        expect(find.text('Test Description'), findsOneWidget);
      });

      testWidgets('should show update button', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: testTask));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Actualizar Tarea'), findsOneWidget);
        expect(find.byIcon(Icons.update), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should show character count for title field', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, 'Test');

        // Assert
        expect(find.text('4/255 caracteres'), findsOneWidget);
      });

      testWidgets('should show character count for description field', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).last,
          'Test Description',
        );

        // Assert
        expect(find.text('15/500 caracteres'), findsOneWidget);
      });

      testWidgets('should validate title length limit', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).first,
          'A' * 256, // Exceeds 255 character limit
        );
        await tester.tap(find.text('Crear Tarea'));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('El título es demasiado largo (máximo 255 caracteres)'),
          findsOneWidget,
        );
      });
    });

    group('Completion Toggle', () {
      testWidgets('should show completion switch', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Switch), findsOneWidget);
        expect(find.text('Esta tarea está pendiente'), findsOneWidget);
      });

      testWidgets('should toggle completion switch', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Esta tarea está completada'), findsOneWidget);
      });

      testWidgets('should show correct completion status for existing task', (
        WidgetTester tester,
      ) async {
        // Arrange
        final completedTask = testTask.copyWith(isCompleted: true);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: completedTask));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Esta tarea está completada'), findsOneWidget);
      });
    });
  });
}
