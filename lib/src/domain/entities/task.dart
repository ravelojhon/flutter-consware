/// Entidad de dominio para representar una tarea
/// Esta entidad es independiente de cualquier implementación de base de datos
/// y contiene únicamente la lógica de negocio
class Task {
  /// Identificador único de la tarea
  final int id;

  /// Título de la tarea
  final String title;

  /// Descripción de la tarea
  final String? description;

  /// Estado de completado de la tarea
  final bool isCompleted;

  /// Fecha y hora de creación de la tarea
  final DateTime createdAt;

  /// Fecha y hora de última actualización de la tarea
  final DateTime updatedAt;

  /// Constructor de la entidad Task
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Constructor para crear una nueva tarea (sin ID)
  /// Útil cuando se crea una tarea por primera vez
  factory Task.create({
    required String title,
    String? description,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    return Task(
      id: 0, // Se asignará cuando se guarde en la base de datos
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Constructor para copiar una tarea existente con modificaciones
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Marcar la tarea como completada
  Task markAsCompleted() {
    return copyWith(isCompleted: true, updatedAt: DateTime.now());
  }

  /// Marcar la tarea como pendiente
  Task markAsPending() {
    return copyWith(isCompleted: false, updatedAt: DateTime.now());
  }

  /// Alternar el estado de completado de la tarea
  Task toggleCompletion() {
    return copyWith(isCompleted: !isCompleted, updatedAt: DateTime.now());
  }

  /// Actualizar el título de la tarea
  Task updateTitle(String newTitle) {
    return copyWith(title: newTitle, updatedAt: DateTime.now());
  }

  /// Verificar si la tarea está completada
  bool get isPending => !isCompleted;

  /// Verificar si la tarea es nueva (sin ID)
  bool get isNew => id == 0;

  /// Obtener el estado de la tarea como texto
  String get statusText => isCompleted ? 'Completada' : 'Pendiente';

  /// Obtener la duración desde la creación
  Duration get durationSinceCreation => DateTime.now().difference(createdAt);

  /// Obtener la duración desde la última actualización
  Duration get durationSinceUpdate => DateTime.now().difference(updatedAt);

  /// Verificar si la tarea fue actualizada recientemente (últimos 5 minutos)
  bool get wasRecentlyUpdated => durationSinceUpdate.inMinutes < 5;

  /// Verificar si la tarea es antigua (más de 7 días)
  bool get isOld => durationSinceCreation.inDays > 7;

  /// Obtener una representación en texto de la tarea
  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, isCompleted: $isCompleted, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// Comparar dos tareas por igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Obtener el hash code de la tarea
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      isCompleted,
      createdAt,
      updatedAt,
    );
  }

  /// Convertir la entidad a un mapa para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crear una entidad Task desde un mapa
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
