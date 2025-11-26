import 'package:drift/drift.dart';
import '../../domain/entities/task.dart';
import 'todo_database.dart';

/// Mapper para convertir entre la entidad Task del dominio y el DTO TodoTask de Drift
/// Esta clase maneja la conversión entre la capa de dominio y la capa de datos
class TaskMapper {
  /// Convertir de entidad Task (dominio) a TasksCompanion (Drift)
  /// Para operaciones de inserción y actualización
  static TasksCompanion toCompanion(Task task) {
    return TasksCompanion(
      id: task.isNew ? const Value.absent() : Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
      isCompleted: Value(task.isCompleted),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
    );
  }

  /// Convertir de TodoTask (DTO de Drift) a Task (entidad del dominio)
  /// Para operaciones de lectura
  static Task toEntity(TodoTask dto) {
    return Task(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      isCompleted: dto.isCompleted,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Convertir una lista de DTOs a una lista de entidades
  static List<Task> toEntityList(List<TodoTask> dtoList) {
    return dtoList.map((dto) => toEntity(dto)).toList();
  }

  /// Crear un TasksCompanion para inserción de una nueva tarea
  /// Útil cuando se crea una tarea desde la UI
  static TasksCompanion createCompanion({
    required String title,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    return TasksCompanion(
      title: Value(title),
      isCompleted: Value(isCompleted),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  /// Crear un TasksCompanion para actualización de una tarea existente
  /// Solo incluye los campos que se van a actualizar
  static TasksCompanion updateCompanion({
    required int id,
    String? title,
    bool? isCompleted,
  }) {
    return TasksCompanion(
      id: Value(id),
      title: title != null ? Value(title) : const Value.absent(),
      isCompleted: isCompleted != null
          ? Value(isCompleted)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Crear un TasksCompanion para toggle de completado
  static TasksCompanion toggleCompletionCompanion(int id, bool currentStatus) {
    return TasksCompanion(
      id: Value(id),
      isCompleted: Value(!currentStatus),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Validar que una entidad Task tenga los datos necesarios
  static bool isValidTask(Task task) {
    return task.title.isNotEmpty &&
        task.title.length <= 255 &&
        task.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1)));
  }

  /// Crear una copia de una entidad con validación
  static Task? safeCopyWith(
    Task original, {
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newTask = original.copyWith(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    return isValidTask(newTask) ? newTask : null;
  }
}
