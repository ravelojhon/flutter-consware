import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app_consware/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete task flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if app loaded successfully
      expect(find.text('Tareas'), findsOneWidget);

      // Tap on floating action button to add new task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in task details
      await tester.enterText(
        find.byType(TextFormField).first,
        'Integration Test Task',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'This is a test task created during integration testing',
      );

      // Submit the form
      await tester.tap(find.text('Crear Tarea'));
      await tester.pumpAndSettle();

      // Verify task was created
      expect(find.text('Integration Test Task'), findsOneWidget);
      expect(
        find.text('This is a test task created during integration testing'),
        findsOneWidget,
      );

      // Mark task as completed
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Confirm completion
      await tester.tap(find.text('Completar'));
      await tester.pumpAndSettle();

      // Verify task is marked as completed
      expect(find.text('Completada'), findsOneWidget);

      // Delete the task
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Verify task was deleted
      expect(find.text('Integration Test Task'), findsNothing);
    });

    testWidgets('Search and filter functionality', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Create multiple tasks for testing
      await _createTestTasks(tester);

      // Test search functionality
      await tester.enterText(find.byType(TextField), 'Search');
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.text('Search Task'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Test filter functionality
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completadas'));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('Pending Task'), findsNothing);

      // Clean up test tasks
      await _cleanupTestTasks(tester);
    });

    testWidgets('Statistics display', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Create test tasks
      await _createTestTasks(tester);

      // Verify statistics are displayed
      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Completadas'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);

      // Clean up test tasks
      await _cleanupTestTasks(tester);
    });

    testWidgets('Error handling', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to create task with empty title
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear Tarea'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('El título no puede estar vacío'), findsOneWidget);

      // Cancel and go back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    });
  });
}

Future<void> _createTestTasks(WidgetTester tester) async {
  // Create completed task
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).first, 'Completed Task');
  await tester.enterText(
    find.byType(TextFormField).last,
    'This task will be completed',
  );
  await tester.tap(find.byType(Switch)); // Mark as completed
  await tester.tap(find.text('Crear Tarea'));
  await tester.pumpAndSettle();

  // Create pending task
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).first, 'Pending Task');
  await tester.enterText(
    find.byType(TextFormField).last,
    'This task will remain pending',
  );
  await tester.tap(find.text('Crear Tarea'));
  await tester.pumpAndSettle();

  // Create search task
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).first, 'Search Task');
  await tester.enterText(
    find.byType(TextFormField).last,
    'This task is for search testing',
  );
  await tester.tap(find.text('Crear Tarea'));
  await tester.pumpAndSettle();
}

Future<void> _cleanupTestTasks(WidgetTester tester) async {
  // Delete all test tasks
  final deleteButtons = find.byIcon(Icons.delete);
  final deleteButtonCount = deleteButtons.evaluate().length;

  for (int i = 0; i < deleteButtonCount; i++) {
    await tester.tap(deleteButtons.at(i));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
  }
}
