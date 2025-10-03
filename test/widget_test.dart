// This is a basic Flutter widget test for the Task Manager app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_consware/main.dart';

void main() {
  testWidgets('Task Manager app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads with the task list screen
    expect(find.text('Lista de Tareas'), findsOneWidget);
    expect(find.text('Nueva tarea...'), findsOneWidget);
    expect(find.text('Agregar'), findsOneWidget);

    // Verify that the stats widget is present
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);
  });
}
