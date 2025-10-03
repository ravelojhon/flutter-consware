# Testing Guide

Este documento describe la estrategia de testing implementada en la aplicación de gestión de tareas.

## 📋 Tipos de Tests

### 1. **Unit Tests**
Tests que verifican la lógica de negocio y componentes individuales.

#### Repositorio (`test/data/repositories/`)
- **`task_repository_test.dart`** - Tests para `TaskRepositoryImpl`
- Verifica todas las operaciones CRUD
- Usa mocks para simular la base de datos
- Prueba casos de éxito y error

#### Use Cases (`test/domain/usecases/`)
- Tests para cada caso de uso individual
- Verifica validaciones y reglas de negocio
- Prueba manejo de errores

### 2. **Widget Tests**
Tests que verifican la interfaz de usuario y interacciones.

#### Pantallas (`test/presentation/screens/`)
- **`improved_task_list_screen_test.dart`** - Tests para la pantalla principal
- **`simple_add_edit_task_screen_test.dart`** - Tests para formulario de tareas

#### Widgets (`test/presentation/widgets/`)
- **`improved_task_item_test.dart`** - Tests para elementos de tarea individual

#### Providers (`test/presentation/providers/`)
- **`task_list_notifier_test.dart`** - Tests para el estado de la aplicación
- Usa `ProviderContainer` para testing aislado
- Verifica cambios de estado y efectos secundarios

### 3. **Integration Tests**
Tests que verifican flujos completos de la aplicación.

#### Archivos de Integración (`integration_test/`)
- **`app_test.dart`** - Tests de flujos completos
- Verifica navegación entre pantallas
- Prueba funcionalidades end-to-end

## 🚀 Ejecutar Tests

### Comandos Básicos

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar tests específicos
flutter test test/presentation/screens/

# Ejecutar integration tests
flutter test integration_test/
```

### Generar Mocks

```bash
# Generar mocks para testing
dart run build_runner build --delete-conflicting-outputs
```

### Coverage

```bash
# Generar reporte de coverage
./coverage_badge.sh

# Ver reporte HTML
open coverage/html/index.html
```

## 📊 Cobertura de Tests

### Objetivos de Coverage

- **Líneas de código**: > 90%
- **Funciones**: > 95%
- **Branches**: > 85%

### Métricas Actuales

```bash
# Ver coverage actual
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🧪 Estructura de Tests

### Convenciones de Naming

```
test/
├── data/
│   └── repositories/
│       └── task_repository_test.dart
├── domain/
│   └── usecases/
│       ├── add_task_test.dart
│       ├── get_tasks_test.dart
│       └── ...
├── presentation/
│   ├── providers/
│   │   └── task_list_notifier_test.dart
│   ├── screens/
│   │   ├── improved_task_list_screen_test.dart
│   │   └── simple_add_edit_task_screen_test.dart
│   └── widgets/
│       └── improved_task_item_test.dart
└── integration_test/
    └── app_test.dart
```

### Patrones de Testing

#### 1. **Arrange-Act-Assert (AAA)**
```dart
test('should return task list when successful', () async {
  // Arrange
  when(mockRepository.getAllTasks()).thenAnswer((_) async => [testTask]);
  
  // Act
  final result = await useCase.call();
  
  // Assert
  expect(result, equals([testTask]));
});
```

#### 2. **ProviderContainer para Testing**
```dart
testWidgets('should display task list', (WidgetTester tester) async {
  // Arrange
  final container = ProviderContainer(
    overrides: [
      taskRepositoryProvider.overrideWith((ref) => mockRepository),
    ],
  );
  
  // Act
  await tester.pumpWidget(
    ProviderScope(
      parent: container,
      child: MaterialApp(home: TaskListScreen()),
    ),
  );
  
  // Assert
  expect(find.text('Test Task'), findsOneWidget);
});
```

#### 3. **Mocking con Mockito**
```dart
@GenerateMocks([TaskRepository])
void main() {
  late MockTaskRepository mockRepository;
  
  setUp(() {
    mockRepository = MockTaskRepository();
  });
}
```

## 🔧 Configuración de CI/CD

### GitHub Actions

El pipeline de CI incluye:

1. **Linting y Formato**
   - `dart format --set-exit-if-changed`
   - `flutter analyze`

2. **Tests**
   - Unit tests
   - Widget tests
   - Integration tests

3. **Coverage**
   - Generación de reportes
   - Upload a Codecov

4. **Build**
   - Android APK
   - iOS build

### Workflow File

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
```

## 📝 Mejores Prácticas

### 1. **Test Isolation**
- Cada test es independiente
- Setup y teardown apropiados
- Mocks para dependencias externas

### 2. **Descriptive Test Names**
```dart
test('should return Left<ValidationFailure> when title is empty', () async {
  // Test implementation
});
```

### 3. **One Assertion Per Test**
```dart
test('should validate title length', () async {
  expect(result.isLeft(), isTrue);
});

test('should return validation error message', () async {
  expect(result.fold((l) => l.message, (r) => ''), contains('title'));
});
```

### 4. **Mock Verification**
```dart
test('should call repository method', () async {
  // Act
  await useCase.call();
  
  // Assert
  verify(mockRepository.getAllTasks()).called(1);
});
```

### 5. **Widget Testing Best Practices**
```dart
testWidgets('should handle user interaction', (WidgetTester tester) async {
  // Pump and settle for animations
  await tester.pumpAndSettle();
  
  // Use specific finders
  await tester.tap(find.byKey(Key('submit_button')));
  
  // Wait for async operations
  await tester.pumpAndSettle();
});
```

## 🐛 Debugging Tests

### Comandos Útiles

```bash
# Tests con output detallado
flutter test --verbose

# Tests específicos con debugging
flutter test test/presentation/screens/improved_task_list_screen_test.dart

# Integration tests con debugging
flutter test integration_test/app_test.dart --verbose
```

### Widget Inspector

```dart
// En tests de widgets
await tester.pumpWidget(widget);
debugDumpApp(); // Imprime el árbol de widgets
```

## 📈 Métricas y Reportes

### Coverage Reports

- **HTML**: `coverage/html/index.html`
- **LCOV**: `coverage/lcov.info`
- **JSON**: Para integración con herramientas

### Badges

```markdown
![Coverage](https://img.shields.io/badge/coverage-85%25-green)
![Tests](https://img.shields.io/badge/tests-passing-brightgreen)
```

## 🔄 Mantenimiento

### Actualización de Tests

1. **Cuando se añaden nuevas funcionalidades**
   - Crear tests para nuevos use cases
   - Añadir widget tests para nuevos componentes
   - Actualizar integration tests

2. **Cuando se modifican funcionalidades existentes**
   - Actualizar tests existentes
   - Verificar que todos los tests pasen
   - Actualizar coverage si es necesario

3. **Refactoring**
   - Mantener tests funcionando
   - Actualizar mocks si es necesario
   - Verificar que la cobertura se mantenga

### Troubleshooting

#### Tests que fallan intermitentemente
- Añadir `await tester.pumpAndSettle()`
- Usar `fake_async` para operaciones asíncronas
- Verificar timing de animaciones

#### Mocks que no funcionan
- Regenerar mocks: `dart run build_runner build --delete-conflicting-outputs`
- Verificar que los mocks estén correctamente configurados
- Usar `verify()` para confirmar llamadas

#### Coverage bajo
- Identificar código no cubierto
- Añadir tests para casos edge
- Considerar si el código no cubierto es necesario

---

## 📚 Recursos Adicionales

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
