import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'todo_tables.dart';

part 'todo_database.g.dart';

/// DAO (Data Access Object) para operaciones CRUD de tareas
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<TodoDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  /// Obtener todas las tareas ordenadas por fecha de creación
  Future<List<TodoTask>> getAllTasks() => select(tasks).get();

  /// Obtener todas las tareas ordenadas por fecha de actualización (más recientes primero)
  Future<List<TodoTask>> getAllTasksOrderedByUpdated() =>
      (select(tasks)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

  /// Obtener tareas completadas
  Future<List<TodoTask>> getCompletedTasks() =>
      (select(tasks)..where((t) => t.isCompleted.equals(true))).get();

  /// Obtener tareas pendientes
  Future<List<TodoTask>> getPendingTasks() =>
      (select(tasks)..where((t) => t.isCompleted.equals(false))).get();

  /// Obtener una tarea por ID
  Future<TodoTask?> getTaskById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Insertar una nueva tarea
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  /// Actualizar una tarea existente
  Future<bool> updateTask(TasksCompanion task) => update(tasks).replace(task);

  /// Marcar una tarea como completada o pendiente
  Future<bool> toggleTaskCompletion(int id) async {
    final task = await getTaskById(id);
    if (task == null) return false;

    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    return updateTask(updatedTask.toCompanion(true));
  }

  /// Actualizar el título de una tarea
  Future<bool> updateTaskTitle(int id, String newTitle) async {
    final task = await getTaskById(id);
    if (task == null) return false;

    final updatedTask = task.copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );

    return updateTask(updatedTask.toCompanion(true));
  }

  /// Eliminar una tarea por ID
  Future<bool> deleteTask(int id) async {
    final deletedRows = await (delete(
      tasks,
    )..where((t) => t.id.equals(id))).go();
    return deletedRows > 0;
  }

  /// Eliminar todas las tareas completadas
  Future<int> deleteCompletedTasks() =>
      (delete(tasks)..where((t) => t.isCompleted.equals(true))).go();

  /// Eliminar todas las tareas
  Future<int> deleteAllTasks() => delete(tasks).go();

  /// Contar el total de tareas
  Future<int> getTotalTasksCount() => selectOnly(tasks)
      .addColumns([tasks.id.count()])
      .map((row) => row.read(tasks.id.count()))
      .getSingle();

  /// Contar tareas completadas
  Future<int> getCompletedTasksCount() =>
      (selectOnly(tasks)..where(tasks.isCompleted.equals(true)))
          .addColumns([tasks.id.count()])
          .map((row) => row.read(tasks.id.count()))
          .getSingle();

  /// Contar tareas pendientes
  Future<int> getPendingTasksCount() =>
      (selectOnly(tasks)..where(tasks.isCompleted.equals(false)))
          .addColumns([tasks.id.count()])
          .map((row) => row.read(tasks.id.count()))
          .getSingle();
}

/// Base de datos principal de la aplicación usando Drift
@DriftDatabase(tables: [Tasks], daos: [TasksDao])
class TodoDatabase extends _$TodoDatabase {
  /// Constructor de la base de datos
  TodoDatabase() : super(_openConnection());

  /// Versión de la base de datos (incrementar cuando se modifiquen las tablas)
  @override
  int get schemaVersion => 1;

  /// Configuración de migraciones (para futuras versiones)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Aquí se pueden agregar migraciones cuando se actualice la versión
      if (from < 2) {
        // Ejemplo de migración para futuras versiones
      }
    },
  );
}

/// Abrir conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Obtener el directorio de documentos de la aplicación
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todo_database.db'));

    // Crear la base de datos si no existe
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    return NativeDatabase.createInBackground(file);
  });
}
