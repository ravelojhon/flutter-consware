import 'package:dartz/dartz.dart' as dartz;

import '../entities/task.dart';
import '../../core/errors/failures.dart';

/// Interfaz del repositorio de tareas
/// Define el contrato que debe implementar la capa de datos
/// Usa Either<Failure, T> para manejo de errores sin excepciones
abstract class ITaskRepository {
  /// Obtener todas las tareas
  /// Retorna Either<Failure, List<Task>>
  Future<dartz.Either<Failure, List<Task>>> getAllTasks();

  /// Obtener todas las tareas ordenadas por fecha de actualización
  /// Retorna Either<Failure, List<Task>>
  Future<dartz.Either<Failure, List<Task>>> getAllTasksOrderedByUpdated();

  /// Obtener tareas completadas
  /// Retorna Either<Failure, List<Task>>
  Future<dartz.Either<Failure, List<Task>>> getCompletedTasks();

  /// Obtener tareas pendientes
  /// Retorna Either<Failure, List<Task>>
  Future<dartz.Either<Failure, List<Task>>> getPendingTasks();

  /// Obtener una tarea por ID
  /// Retorna Either<Failure, Task?> donde null indica que no se encontró
  Future<dartz.Either<Failure, Task?>> getTaskById(int id);

  /// Crear una nueva tarea
  /// Retorna Either<Failure, Task> con la tarea creada
  Future<dartz.Either<Failure, Task>> createTask(Task task);

  /// Crear una nueva tarea con solo el título
  /// Retorna Either<Failure, Task> con la tarea creada
  Future<dartz.Either<Failure, Task>> createTaskWithTitle(String title);

  /// Actualizar una tarea existente
  /// Retorna Either<Failure, Task> con la tarea actualizada
  Future<dartz.Either<Failure, Task>> updateTask(Task task);

  /// Marcar una tarea como completada o pendiente
  /// Retorna Either<Failure, Task> con la tarea actualizada
  Future<dartz.Either<Failure, Task>> toggleTaskCompletion(int id);

  /// Actualizar el título de una tarea
  /// Retorna Either<Failure, Task> con la tarea actualizada
  Future<dartz.Either<Failure, Task>> updateTaskTitle(int id, String newTitle);

  /// Eliminar una tarea por ID
  /// Retorna Either<Failure, bool> indicando si se eliminó correctamente
  Future<dartz.Either<Failure, bool>> deleteTask(int id);

  /// Eliminar todas las tareas completadas
  /// Retorna Either<Failure, int> con el número de tareas eliminadas
  Future<dartz.Either<Failure, int>> deleteCompletedTasks();

  /// Eliminar todas las tareas
  /// Retorna Either<Failure, int> con el número de tareas eliminadas
  Future<dartz.Either<Failure, int>> deleteAllTasks();

  /// Contar el total de tareas
  /// Retorna Either<Failure, int> con el total de tareas
  Future<dartz.Either<Failure, int>> getTotalTasksCount();

  /// Contar tareas completadas
  /// Retorna Either<Failure, int> con el número de tareas completadas
  Future<dartz.Either<Failure, int>> getCompletedTasksCount();

  /// Contar tareas pendientes
  /// Retorna Either<Failure, int> con el número de tareas pendientes
  Future<dartz.Either<Failure, int>> getPendingTasksCount();

  /// Verificar si una tarea existe por ID
  /// Retorna Either<Failure, bool> indicando si existe
  Future<dartz.Either<Failure, bool>> taskExists(int id);

  /// Buscar tareas por título (búsqueda parcial)
  /// Retorna Either<Failure, List<Task>> con las tareas encontradas
  Future<dartz.Either<Failure, List<Task>>> searchTasksByTitle(String query);
}
