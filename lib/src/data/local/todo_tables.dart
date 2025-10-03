import 'package:drift/drift.dart';

/// Tabla para almacenar tareas con persistencia local
@DataClassName('TodoTask')
class Tasks extends Table {
  /// Identificador único de la tarea
  IntColumn get id => integer().autoIncrement()();

  /// Título de la tarea
  TextColumn get title => text().withLength(min: 1, max: 255)();

  /// Descripción de la tarea (opcional)
  TextColumn get description => text().nullable()();

  /// Estado de completado de la tarea
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// Fecha y hora de creación de la tarea
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Fecha y hora de última actualización de la tarea
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// La columna id ya es la clave primaria por ser autoIncrement()
}
