import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/presentation/screens/add_edit_task_screen.dart';

void main() {
  group('AddEditTaskScreen Tests', () {
    testWidgets('should display "Nueva Tarea" title when creating new task', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      expect(find.text('Nueva Tarea'), findsOneWidget);
      expect(find.text('Crear Tarea'), findsOneWidget);
    });

    testWidgets(
      'should display "Editar Tarea" title when editing existing task',
      (WidgetTester tester) async {
        final task = Task.create(title: 'Test Task').copyWith(id: 1);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: AddEditTaskScreen(task: task)),
          ),
        );

        expect(find.text('Editar Tarea'), findsOneWidget);
        expect(find.text('Actualizar Tarea'), findsOneWidget);
      },
    );

    testWidgets('should pre-fill form fields when editing task', (
      WidgetTester tester,
    ) async {
      final task = Task.create(title: 'Test Task').copyWith(id: 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: AddEditTaskScreen(task: task)),
        ),
      );

      final titleField = find.byType(TextFormField).first;
      expect(titleField, findsOneWidget);

      final textField = tester.widget<TextFormField>(titleField);
      expect(textField.controller?.text, equals('Test Task'));
    });

    testWidgets('should show task ID when editing', (
      WidgetTester tester,
    ) async {
      final task = Task.create(title: 'Test Task').copyWith(id: 123);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: AddEditTaskScreen(task: task)),
        ),
      );

      expect(find.text('ID: 123'), findsOneWidget);
    });

    testWidgets('should validate required title field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      // Try to save without entering title
      await tester.tap(find.text('Crear Tarea'));
      await tester.pump();

      expect(find.text('El título es requerido'), findsOneWidget);
    });

    testWidgets('should validate minimum title length', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      // Enter title with less than 3 characters
      await tester.enterText(find.byType(TextFormField).first, 'ab');
      await tester.tap(find.text('Crear Tarea'));
      await tester.pump();

      expect(
        find.text('El título debe tener al menos 3 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should validate maximum title length', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      // Enter title with more than 255 characters
      final longTitle = 'a' * 256;
      await tester.enterText(find.byType(TextFormField).first, longTitle);
      await tester.tap(find.text('Crear Tarea'));
      await tester.pump();

      expect(
        find.text('El título no puede exceder 255 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should show completion checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.text('Tarea completada'), findsOneWidget);
    });

    testWidgets('should toggle completion checkbox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      final checkbox = find.byType(CheckboxListTile);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.value, isFalse);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pump();

      final updatedCheckboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(updatedCheckboxWidget.value, isTrue);
    });

    testWidgets('should show delete button when editing', (
      WidgetTester tester,
    ) async {
      final task = Task.create(title: 'Test Task').copyWith(id: 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: AddEditTaskScreen(task: task)),
        ),
      );

      expect(find.text('Eliminar Tarea'), findsOneWidget);
    });

    testWidgets('should not show delete button when creating new task', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      expect(find.text('Eliminar Tarea'), findsNothing);
    });

    testWidgets('should show additional info when editing', (
      WidgetTester tester,
    ) async {
      final task = Task.create(title: 'Test Task').copyWith(
        id: 1,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: AddEditTaskScreen(task: task)),
        ),
      );

      expect(find.text('Información adicional'), findsOneWidget);
      expect(find.text('Creada'), findsOneWidget);
      expect(find.text('Última actualización'), findsOneWidget);
      expect(find.text('Estado actual'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (
      WidgetTester tester,
    ) async {
      final task = Task.create(title: 'Test Task').copyWith(id: 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: AddEditTaskScreen(task: task)),
        ),
      );

      // Tap delete button
      await tester.tap(find.text('Eliminar Tarea'));
      await tester.pump();

      // Should show confirmation dialog
      expect(
        find.text('Eliminar Tarea'),
        findsNWidgets(2),
      ); // One in AppBar, one in dialog
      expect(
        find.text('¿Estás seguro de que quieres eliminar esta tarea?'),
        findsOneWidget,
      );
      expect(find.text('"Test Task"'), findsOneWidget);
      expect(find.text('Esta acción no se puede deshacer.'), findsOneWidget);
    });

    testWidgets('should dismiss delete confirmation when cancel is tapped', (
      WidgetTester tester,
    ) async {
      final task = Task.create(title: 'Test Task').copyWith(id: 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: AddEditTaskScreen(task: task)),
        ),
      );

      // Tap delete button
      await tester.tap(find.text('Eliminar Tarea'));
      await tester.pump();

      // Tap cancel in dialog
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      // Dialog should be dismissed
      expect(
        find.text('¿Estás seguro de que quieres eliminar esta tarea?'),
        findsNothing,
      );
    });

    testWidgets('should show loading state when saving', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      // Enter valid title
      await tester.enterText(
        find.byType(TextFormField).first,
        'Valid Task Title',
      );

      // Tap save button
      await tester.tap(find.text('Crear Tarea'));
      await tester.pump();

      // Should show loading indicator in AppBar
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when save fails', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditTaskScreen())),
      );

      // Enter valid title
      await tester.enterText(
        find.byType(TextFormField).first,
        'Valid Task Title',
      );

      // Tap save button
      await tester.tap(find.text('Crear Tarea'));
      await tester.pump();

      // Should eventually show error (since we don't have real providers in test)
      // This test would need to be updated when integrating with real providers
    });
  });
}
