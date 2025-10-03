import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/presentation/widgets/improved_task_item.dart';

void main() {
  group('ImprovedTaskItem', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    Widget createWidgetUnderTest({
      Task? task,
      VoidCallback? onTap,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
      ValueChanged<bool>? onToggleCompleted,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ImprovedTaskItem(
              task: task ?? testTask,
              onTap: onTap,
              onEdit: onEdit,
              onDelete: onDelete,
              onToggleCompleted: onToggleCompleted,
            ),
          ),
        ),
      );
    }

    testWidgets('should display task title and description', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should display pending status for incomplete task', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.pending), findsOneWidget);
    });

    testWidgets('should display completed status for completed task', (
      WidgetTester tester,
    ) async {
      // Arrange
      final completedTask = testTask.copyWith(isCompleted: true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: completedTask));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Completada'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Deshacer'), findsOneWidget);
    });

    testWidgets('should display strikethrough text for completed task', (
      WidgetTester tester,
    ) async {
      // Arrange
      final completedTask = testTask.copyWith(isCompleted: true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: completedTask));
      await tester.pumpAndSettle();

      // Assert
      final titleWidget = tester.widget<Text>(find.text('Test Task'));
      expect(titleWidget.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('should show edit and delete buttons', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should call onEdit when edit button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool editCalled = false;
      void onEdit() {
        editCalled = true;
      }

      // Act
      await tester.pumpWidget(createWidgetUnderTest(onEdit: onEdit));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Assert
      expect(editCalled, isTrue);
    });

    testWidgets('should call onDelete when delete button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool deleteCalled = false;
      void onDelete() {
        deleteCalled = true;
      }

      // Act
      await tester.pumpWidget(createWidgetUnderTest(onDelete: onDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCalled, isTrue);
    });

    testWidgets(
      'should show confirmation dialog when delete button is tapped',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Eliminar Tarea'), findsOneWidget);
        expect(
          find.text('¿Estás seguro de que quieres eliminar esta tarea?'),
          findsOneWidget,
        );
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Eliminar'), findsOneWidget);
      },
    );

    testWidgets('should show confirmation dialog when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Completar Tarea'), findsOneWidget);
      expect(
        find.text(
          '¿Estás seguro de que quieres marcar esta tarea como completada?',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Completar'), findsOneWidget);
    });

    testWidgets(
      'should call onToggleCompleted when checkbox confirmation is accepted',
      (WidgetTester tester) async {
        // Arrange
        bool? toggleValue;
        void onToggleCompleted(bool value) {
          toggleValue = value;
        }

        // Act
        await tester.pumpWidget(
          createWidgetUnderTest(onToggleCompleted: onToggleCompleted),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Completar'));
        await tester.pumpAndSettle();

        // Assert
        expect(toggleValue, isTrue);
      },
    );

    testWidgets('should show undo button for completed task', (
      WidgetTester tester,
    ) async {
      // Arrange
      final completedTask = testTask.copyWith(isCompleted: true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: completedTask));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Deshacer'), findsOneWidget);
      expect(find.byIcon(Icons.undo), findsOneWidget);
    });

    testWidgets('should display formatted date', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      // The date should be displayed in a relative format
      expect(find.textContaining('d atrás'), findsOneWidget);
    });

    testWidgets('should handle task without description', (
      WidgetTester tester,
    ) async {
      // Arrange
      final taskWithoutDescription = testTask.copyWith(description: null);

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(task: taskWithoutDescription),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsNothing);
    });

    testWidgets('should handle empty description', (WidgetTester tester) async {
      // Arrange
      final taskWithEmptyDescription = testTask.copyWith(description: '');

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(task: taskWithEmptyDescription),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsNothing);
    });

    testWidgets('should display task in card with proper styling', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets(
      'should show different colors for completed and pending tasks',
      (WidgetTester tester) async {
        // Test pending task
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final pendingCard = tester.widget<Card>(find.byType(Card));
        expect(pendingCard.shape, isA<RoundedRectangleBorder>());

        // Test completed task
        final completedTask = testTask.copyWith(isCompleted: true);
        await tester.pumpWidget(createWidgetUnderTest(task: completedTask));
        await tester.pumpAndSettle();

        final completedCard = tester.widget<Card>(find.byType(Card));
        expect(completedCard.shape, isA<RoundedRectangleBorder>());
      },
    );
  });
}
