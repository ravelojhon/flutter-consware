import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../../domain/entities/task.dart';
import '../../core/errors/failures.dart';
import 'todo_tables.dart';
import 'task_mapper.dart';

part 'todo_database.g.dart';

/// DAO (Data Access Object) para operaciones CRUD de tareas
/// Ahora trabaja con entidades del dominio en lugar de DTOs directamente
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<TodoDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  /// Obtener todas las tareas ordenadas por fecha de creación
  Future<List<Task>> getAllTasks() async {
    final dtoList = await select(tasks).get();
    return TaskMapper.toEntityList(dtoList);
  }

  /// Obtener todas las tareas ordenadas por fecha de actualización (más recientes primero)
  Future<List<Task>> getAllTasksOrderedByUpdated() async {
    final dtoList = await (select(
      tasks,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return TaskMapper.toEntityList(dtoList);
  }

  /// Obtener tareas completadas
  Future<List<Task>> getCompletedTasks() async {
    final dtoList = await (select(
      tasks,
    )..where((t) => t.isCompleted.equals(true))).get();
    return TaskMapper.toEntityList(dtoList);
  }

  /// Obtener tareas pendientes
  Future<List<Task>> getPendingTasks() async {
    final dtoList = await (select(
      tasks,
    )..where((t) => t.isCompleted.equals(false))).get();
    return TaskMapper.toEntityList(dtoList);
  }

  /// Obtener una tarea por ID
  Future<Task?> getTaskById(int id) async {
    final dto = await (select(
      tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return dto != null ? TaskMapper.toEntity(dto) : null;
  }

  /// Insertar una nueva tarea desde entidad del dominio
  Future<int> insertTask(Task task) async {
    final companion = TaskMapper.toCompanion(task);
    return await into(tasks).insert(companion);
  }

  /// Insertar una nueva tarea con título
  Future<int> insertTaskFromTitle(String title) async {
    final companion = TaskMapper.createCompanion(title: title);
    return await into(tasks).insert(companion);
  }

  /// Actualizar una tarea existente
  Future<bool> updateTask(Task task) async {
    final companion = TaskMapper.toCompanion(task);
    await update(tasks).replace(companion);
    return true;
  }

  /// Marcar una tarea como completada o pendiente
  Future<bool> toggleTaskCompletion(int id) async {
    final task = await getTaskById(id);
    if (task == null) return false;

    final updatedTask = task.toggleCompletion();
    return await updateTask(updatedTask);
  }

  /// Actualizar el título de una tarea
  Future<bool> updateTaskTitle(int id, String newTitle) async {
    final task = await getTaskById(id);
    if (task == null) return false;

    final updatedTask = task.updateTitle(newTitle);
    return await updateTask(updatedTask);
  }

  /// Eliminar una tarea por ID
  Future<bool> deleteTask(int id) async {
    final deletedRows = await (delete(
      tasks,
    )..where((t) => t.id.equals(id))).go();
    return deletedRows > 0;
  }

  /// Eliminar todas las tareas completadas
  Future<int> deleteCompletedTasks() async {
    final deletedRows = await (delete(
      tasks,
    )..where((t) => t.isCompleted.equals(true))).go();
    return deletedRows;
  }

  /// Eliminar todas las tareas
  Future<int> deleteAllTasks() async {
    final deletedRows = await delete(tasks).go();
    return deletedRows;
  }

  /// Contar el total de tareas
  Future<int> getTotalTasksCount() async {
    final allTasks = await getAllTasks();
    return allTasks.length;
  }

  /// Contar tareas completadas
  Future<int> getCompletedTasksCount() async {
    final completedTasks = await getCompletedTasks();
    return completedTasks.length;
  }

  /// Contar tareas pendientes
  Future<int> getPendingTasksCount() async {
    final pendingTasks = await getPendingTasks();
    return pendingTasks.length;
  }
}

/// Base de datos principal de la aplicación usando Drift
@DriftDatabase(tables: [Tasks], daos: [TasksDao])
class TodoDatabase extends _$TodoDatabase {
  /// Constructor de la base de datos
  TodoDatabase() : super(_openConnection());

  /// Versión de la base de datos (incrementar cuando se modifiquen las tablas)
  @override
  int get schemaVersion => 2;

  /// Configuración de migraciones (para futuras versiones)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Para esta versión, simplemente recrear las tablas
      if (from < 2) {
        await m.drop(tasks);
        await m.createTable(tasks);
      }
    },
  );
}

/// Abrir conexión a la base de datos con manejo de errores
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      // Asegurar que las bibliotecas SQLite estén disponibles
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Obtener el directorio de documentos de la aplicación
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'todo_database.db'));

      // Verificar permisos de escritura
      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }

      // Crear la base de datos si no existe
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Crear la conexión
      final database = NativeDatabase.createInBackground(file);

      return database;
    } catch (e) {
      // Si falla la conexión, intentar recrear la base de datos
      try {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'todo_database.db'));

        // Eliminar archivo corrupto si existe
        if (await file.exists()) {
          await file.delete();
        }

        // Crear nueva base de datos
        return NativeDatabase.createInBackground(file);
      } catch (recreateError) {
        // Si todo falla, lanzar un error descriptivo
        throw DatabaseFailure(
          message:
              'No se pudo inicializar la base de datos: ${recreateError.toString()}',
        );
      }
    }
  });
}
