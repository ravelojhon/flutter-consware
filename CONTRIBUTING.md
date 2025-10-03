# 🤝 Guía de Contribución - App Consware

¡Gracias por tu interés en contribuir a App Consware! Este documento te guiará a través del proceso de contribución.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Cómo Contribuir](#cómo-contribuir)
- [Configuración del Entorno](#configuración-del-entorno)
- [Estándares de Código](#estándares-de-código)
- [Proceso de Pull Request](#proceso-de-pull-request)
- [Reportar Issues](#reportar-issues)

## 🤝 Código de Conducta

Este proyecto se adhiere a un código de conducta que esperamos que todos los contribuidores sigan:

- **Sé respetuoso** y inclusivo en todas las comunicaciones
- **Mantén un ambiente colaborativo** y constructivo
- **Enfócate en lo que es mejor** para la comunidad y el proyecto
- **Muestra empatía** hacia otros miembros de la comunidad

## 🚀 Cómo Contribuir

### Tipos de Contribuciones

- 🐛 **Bug fixes** - Corrección de errores
- ✨ **Nuevas funcionalidades** - Añadir características
- 📚 **Documentación** - Mejorar documentación
- 🧪 **Tests** - Añadir o mejorar tests
- 🎨 **UI/UX** - Mejoras de interfaz
- ⚡ **Performance** - Optimizaciones

### Proceso de Contribución

1. **Fork** el repositorio
2. **Clona** tu fork localmente
3. **Crea** una rama para tu feature
4. **Desarrolla** tu contribución
5. **Prueba** tus cambios
6. **Commit** con mensajes descriptivos
7. **Push** a tu fork
8. **Crea** un Pull Request

## 🛠️ Configuración del Entorno

### Requisitos Previos

- Flutter 3.24.0+
- Dart 3.5.0+
- Git 2.30+
- Cursor IDE o VS Code

### Configuración Inicial

```bash
# 1. Fork y clonar
git clone https://github.com/TU-USUARIO/flutter-consware.git
cd flutter-consware

# 2. Añadir upstream
git remote add upstream https://github.com/ravelojhon/flutter-consware.git

# 3. Instalar dependencias
flutter pub get

# 4. Generar archivos
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Configurar entorno
bash scripts/setup-dev-environment.sh
```

### Configuración de Hooks

```bash
# Instalar hooks de Git
bash scripts/setup-hooks.sh

# Esto configurará:
# - Pre-commit hooks (formateo y análisis)
# - Pre-push hooks (tests y validaciones)
```

## 📝 Estándares de Código

### Convenciones de Naming

```dart
// Clases: PascalCase
class TaskRepository {}

// Variables y métodos: camelCase
String taskTitle;
void updateTask() {}

// Constantes: SCREAMING_SNAKE_CASE
const String API_BASE_URL = 'https://api.example.com';

// Archivos: snake_case
task_repository.dart
```

### Estructura de Archivos

```
lib/src/
├── core/
│   ├── di/           # Dependency Injection
│   ├── errors/       # Error handling
│   └── ui/           # UI services
├── data/
│   ├── local/        # Local data sources
│   └── repositories/ # Repository implementations
├── domain/
│   ├── entities/     # Business entities
│   ├── repositories/ # Repository contracts
│   └── usecases/     # Use cases
└── presentation/
    ├── providers/    # State management
    ├── screens/      # App screens
    └── widgets/      # Reusable widgets
```

### Estándares de Código

#### 1. Imports

```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:riverpod/riverpod.dart';

// 4. Relative imports
import '../domain/entities/task.dart';
```

#### 2. Documentación

```dart
/// Una tarea representa una actividad que el usuario necesita completar.
/// 
/// Las tareas pueden tener un título, descripción y estado de completado.
/// También incluyen timestamps de creación y actualización.
class Task {
  /// Identificador único de la tarea
  final int id;
  
  /// Título descriptivo de la tarea
  final String title;
  
  /// Descripción opcional con más detalles
  final String? description;
  
  /// Indica si la tarea está completada
  final bool isCompleted;
}
```

#### 3. Error Handling

```dart
// Usar Either para manejo de errores
Future<Either<Failure, Task>> createTask(CreateTaskParams params) async {
  try {
    final task = await _repository.createTask(params);
    return Right(task);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

#### 4. Testing

```dart
// Tests unitarios
group('TaskRepository', () {
  late MockTaskRepository mockRepository;
  late TaskRepositoryImpl repository;
  
  setUp(() {
    mockRepository = MockTaskRepository();
    repository = TaskRepositoryImpl(mockRepository);
  });
  
  test('should return task when createTask is successful', () async {
    // Arrange
    const params = CreateTaskParams(title: 'Test Task');
    const expectedTask = Task(id: 1, title: 'Test Task');
    
    when(() => mockRepository.createTask(params))
        .thenAnswer((_) async => expectedTask);
    
    // Act
    final result = await repository.createTask(params);
    
    // Assert
    expect(result, equals(Right(expectedTask)));
  });
});
```

## 🔄 Proceso de Pull Request

### 1. Crear una Rama

```bash
# Crear y cambiar a nueva rama
git checkout -b feature/nueva-funcionalidad

# O para bug fixes
git checkout -b fix/corregir-bug-xyz
```

### 2. Desarrollar tu Feature

```bash
# Hacer cambios en el código
# Añadir tests
# Actualizar documentación

# Commit con mensajes descriptivos
git add .
git commit -m "feat: añadir funcionalidad de filtrado avanzado

- Implementar filtros por fecha y prioridad
- Añadir tests unitarios para nuevos filtros
- Actualizar documentación de la API"
```

### 3. Sincronizar con Upstream

```bash
# Obtener cambios más recientes
git fetch upstream
git checkout main
git merge upstream/main

# Rebase tu rama
git checkout feature/nueva-funcionalidad
git rebase main
```

### 4. Push y Crear PR

```bash
# Push a tu fork
git push origin feature/nueva-funcionalidad

# Crear Pull Request en GitHub
```

### Template de Pull Request

```markdown
## 📝 Descripción
Breve descripción de los cambios realizados.

## 🔗 Tipo de Cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Breaking change
- [ ] Documentación

## 🧪 Testing
- [ ] Tests unitarios añadidos/actualizados
- [ ] Tests de widgets añadidos/actualizados
- [ ] Tests de integración añadidos/actualizados
- [ ] Todos los tests pasan localmente

## 📸 Screenshots (si aplica)
Añadir capturas de pantalla de los cambios visuales.

## ✅ Checklist
- [ ] Código sigue las convenciones del proyecto
- [ ] Self-review completado
- [ ] Documentación actualizada
- [ ] Tests añadidos/actualizados
- [ ] No hay warnings de linting
```

## 🐛 Reportar Issues

### Antes de Crear un Issue

1. **Busca** en issues existentes
2. **Verifica** que no esté duplicado
3. **Asegúrate** de que sea un bug real

### Template de Bug Report

```markdown
## 🐛 Descripción del Bug
Descripción clara y concisa del problema.

## 🔄 Pasos para Reproducir
1. Ir a '...'
2. Hacer clic en '...'
3. Scroll hacia '...'
4. Ver error

## 📱 Comportamiento Esperado
Descripción de lo que debería pasar.

## 📸 Screenshots
Añadir capturas si aplica.

## 📱 Información del Dispositivo
- OS: [e.g. Android 12, iOS 15]
- Flutter: [e.g. 3.24.0]
- Device: [e.g. Pixel 6, iPhone 13]

## 📋 Información Adicional
Cualquier contexto adicional sobre el problema.
```

## 🏷️ Conventional Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/) para mensajes de commit:

```bash
# Estructura
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Tipos de Commit

- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formateo, espacios, etc.
- `refactor`: Refactorización de código
- `test`: Añadir o modificar tests
- `chore`: Cambios en build, dependencias, etc.

### Ejemplos

```bash
feat: añadir filtro por fecha de vencimiento
fix: corregir crash al eliminar tarea
docs: actualizar README con nuevas instrucciones
test: añadir tests para TaskRepository
chore: actualizar dependencias de Flutter
```

## 📊 Métricas de Calidad

### Cobertura de Tests

- **Mínimo**: 80% de cobertura
- **Objetivo**: 90% de cobertura
- **Comando**: `flutter test --coverage`

### Análisis de Código

- **Flutter Analyze**: Sin errores
- **Linting**: 795 reglas configuradas
- **Comando**: `flutter analyze`

### Performance

- **Build Time**: < 2 minutos
- **APK Size**: < 15MB
- **Startup Time**: < 3 segundos

## 🎯 Roadmap

### v1.1.0
- [ ] Sincronización en la nube
- [ ] Categorías de tareas
- [ ] Notificaciones push

### v1.2.0
- [ ] Modo oscuro
- [ ] Temas personalizables
- [ ] Widgets para pantalla de inicio

### v2.0.0
- [ ] Colaboración en equipo
- [ ] API REST
- [ ] Aplicación web

## 📞 Contacto

- **Email**: [tu-email@ejemplo.com]
- **GitHub**: [@tu-usuario](https://github.com/tu-usuario)
- **Discord**: [Servidor del proyecto]

## 🙏 Reconocimientos

Gracias a todos los contribuidores que han hecho posible este proyecto:

- [Lista de contribuidores]

---

**¡Gracias por contribuir a App Consware! 🚀**
