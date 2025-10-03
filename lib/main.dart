import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/domain/entities/task.dart';
import 'src/presentation/screens/improved_task_list_screen.dart';
import 'src/presentation/screens/simple_add_edit_task_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ImprovedTaskListScreen(),
        '/add-edit-task': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return SimpleAddEditTaskScreen(task: args is Task ? args : null);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/add-edit-task') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) =>
                SimpleAddEditTaskScreen(task: args is Task ? args : null),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
