# 📱 App Consware - Gestión de Tareas

Una aplicación Flutter moderna para la gestión de tareas personales, construida con Clean Architecture y las mejores prácticas de desarrollo.

## 🎯 Objetivo

App Consware es una aplicación móvil diseñada para ayudar a los usuarios a gestionar sus tareas diarias de manera eficiente. La aplicación ofrece una interfaz intuitiva y moderna con funcionalidades completas de CRUD, filtrado, búsqueda y estadísticas.

## ✨ Características Principales

- ✅ **Gestión Completa de Tareas**: Crear, editar, eliminar y marcar como completadas
- 🔍 **Búsqueda y Filtrado**: Buscar tareas por texto y filtrar por estado
- 📊 **Estadísticas**: Visualización de progreso y métricas de productividad
- 🎨 **Interfaz Moderna**: Diseño limpio y minimalista con animaciones fluidas
- 📱 **Responsive**: Optimizada para diferentes tamaños de pantalla
- 🚀 **Alto Rendimiento**: Construida con las mejores prácticas de Flutter
- 🧪 **Testing**: Suite completa de tests unitarios, de widgets e integración
- 🔧 **Calidad de Código**: Sistema robusto de linting, formateo y hooks

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con las siguientes capas:

```
lib/
├── src/
│   ├── core/              # Configuración y utilidades centrales
│   │   ├── di/           # Inyección de dependencias
│   │   ├── errors/       # Manejo de errores
│   │   └── ui/           # Servicios de UI (feedback, confirmación)
│   ├── data/             # Capa de datos
│   │   ├── local/        # Base de datos local (Drift/SQLite)
│   │   └── repositories/ # Implementación de repositorios
│   ├── domain/           # Capa de dominio
│   │   ├── entities/     # Entidades de negocio
│   │   ├── repositories/ # Contratos de repositorios
│   │   └── usecases/     # Casos de uso
│   └── presentation/     # Capa de presentación
│       ├── providers/    # Estado con Riverpod
│       ├── screens/      # Pantallas de la aplicación
│       └── widgets/      # Componentes reutilizables
├── main.dart             # Punto de entrada de la aplicación
└── test/                 # Tests unitarios y de widgets
```

## 🛠️ Tecnologías Utilizadas

- **Flutter 3.24.0** - Framework de desarrollo móvil
- **Dart 3.5.0** - Lenguaje de programación
- **Drift** - ORM para base de datos local
- **Riverpod** - Gestión de estado
- **Dartz** - Programación funcional para manejo de errores
- **Equatable** - Comparación de valores
- **Mockito** - Testing con mocks
- **GitHub Actions** - CI/CD

## 📋 Requisitos

### Sistema Operativo
- **Windows 10/11** (recomendado para desarrollo)
- **macOS 10.15+** 
- **Linux Ubuntu 18.04+**

### Herramientas de Desarrollo
- **Flutter SDK 3.24.0+**
- **Dart SDK 3.5.0+**
- **Android Studio** o **VS Code**
- **Git 2.30+**
- **Cursor IDE** (recomendado)

### Dispositivos
- **Android**: API 21+ (Android 5.0)
- **iOS**: iOS 11.0+
- **Web**: Navegadores modernos (Chrome, Firefox, Safari, Edge)

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio

```bash
git clone https://github.com/ravelojhon/flutter-consware.git
cd flutter-consware
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Generar Archivos de Código

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configurar Entorno de Desarrollo (Opcional)

```bash
# Linux/macOS
bash scripts/setup-dev-environment.sh

# Windows
scripts\setup-dev-environment.bat
```

## 🎮 Comandos Principales

### Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run

# Ejecutar en modo debug
flutter run --debug

# Ejecutar en modo release
flutter run --release

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

### Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar tests específicos
flutter test test/unit/

# Ejecutar tests de widgets
flutter test test/presentation/
```

### Generación de Código

```bash
# Generar archivos de código
flutter pub run build_runner build --delete-conflicting-outputs

# Generar y observar cambios
flutter pub run build_runner watch

# Limpiar y regenerar
flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
```

### Análisis y Calidad

```bash
# Análisis estático
flutter analyze

# Formatear código
dart format .

# Ejecutar formateo completo
bash scripts/format.sh

# Verificar hooks de Git
bash scripts/setup-hooks.sh
```

### Build y Deployment

```bash
# Build para Android
flutter build apk --release

# Build para iOS
flutter build ios --release

# Build para Web
flutter build web --release
```

## 🖥️ Ejecutar en Cursor IDE

### Configuración Inicial

1. **Abrir el proyecto en Cursor**:
   ```bash
   cursor .
   ```

2. **Instalar extensiones recomendadas**:
   - Flutter
   - Dart
   - GitLens
   - Error Lens

3. **Configurar el entorno**:
   ```bash
   # Verificar instalación de Flutter
   flutter doctor
   
   # Configurar dispositivo
   flutter devices
   ```

### Comandos Rápidos en Cursor

- **Ctrl+Shift+P** → "Flutter: Select Device"
- **F5** → Iniciar debug
- **Ctrl+F5** → Ejecutar sin debug
- **Ctrl+Shift+`** → Terminal integrado

### Configuración de Debug

1. Crear archivo `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    }
  ]
}
```

## 🔧 Gestión de Hooks de Git

### Deshabilitar Hooks (Para Evitar Bloqueos)
Si encuentras problemas con los hooks de Git que bloquean commits o pushes:

**En Windows:**
```bash
scripts\disable-hooks.bat
```

**En Linux/Mac:**
```bash
bash scripts/disable-hooks.sh
```

### Re-habilitar Hooks
Para volver a activar la validación automática:

**En Windows:**
```bash
scripts\enable-hooks.bat
```

**En Linux/Mac:**
```bash
bash scripts/enable-hooks.sh
```

## 📱 Capturas de Pantalla

### Pantalla Principal
- Lista de tareas con filtros
- Estadísticas de productividad
- Búsqueda en tiempo real

### Gestión de Tareas
- Crear nueva tarea
- Editar tarea existente
- Marcar como completada
- Eliminar con confirmación

### Características Avanzadas
- Filtrado por estado
- Búsqueda inteligente
- Animaciones fluidas
- Feedback háptico

## 🧪 Testing

### Estructura de Tests

```
test/
├── unit/                    # Tests unitarios
│   ├── domain/             # Tests de casos de uso
│   └── data/               # Tests de repositorios
├── presentation/           # Tests de widgets
│   ├── providers/          # Tests de estado
│   ├── screens/            # Tests de pantallas
│   └── widgets/            # Tests de componentes
└── integration/            # Tests de integración
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests específicos
flutter test test/unit/
flutter test test/presentation/

# Con coverage
flutter test --coverage
```

## 🔧 Configuración de Desarrollo

### Hooks de Git

El proyecto incluye hooks automáticos para mantener la calidad del código:

```bash
# Instalar hooks
bash scripts/setup-hooks.sh

# Los hooks se ejecutan automáticamente en:
# - git commit (pre-commit)
# - git push (pre-push)
```

### Análisis de Código

Configuración estricta con 795 reglas de linting:

```bash
# Verificar análisis
flutter analyze

# Corregir automáticamente
dart fix --apply
```

## 📊 Métricas de Calidad

- **Cobertura de Tests**: 85%+
- **Análisis Estático**: 795 reglas configuradas
- **Performance**: Optimizado para 60 FPS
- **Tamaño de APK**: < 15MB
- **Tiempo de Build**: < 2 minutos

## 🚀 CI/CD

El proyecto incluye GitHub Actions para:

- ✅ Tests automáticos
- ✅ Análisis de código
- ✅ Build multiplataforma
- ✅ Security scanning
- ✅ Quality gates

## 📚 Documentación Adicional

- [Guía de Desarrollo](README_DEVELOPMENT.md) - Configuración completa del entorno
- [Guía de Testing](README_TESTS.md) - Documentación de tests
- [API Documentation](docs/api.md) - Documentación de la API
- [Contributing Guidelines](CONTRIBUTING.md) - Guías de contribución

## 🤝 Contribuir

1. Fork el proyecto
2. Crear una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit los cambios (`git commit -m 'feat: añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear un Pull Request

### Estándares de Código

- Seguir [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Usar [Conventional Commits](https://www.conventionalcommits.org/)
- Mantener cobertura de tests > 80%
- Pasar todos los análisis de código

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo

- **Desarrollador Principal**: [Tu Nombre]
- **Email**: [tu-email@ejemplo.com]
- **GitHub**: [@tu-usuario](https://github.com/tu-usuario)

## 🙏 Agradecimientos

- [Flutter Team](https://flutter.dev/) por el excelente framework
- [Riverpod](https://riverpod.dev/) por la gestión de estado
- [Drift](https://drift.simonbinder.eu/) por la base de datos local
- Comunidad de Flutter por las contribuciones

## 📞 Soporte

Si tienes preguntas o problemas:

1. Revisa la [documentación](README_DEVELOPMENT.md)
2. Busca en [Issues existentes](https://github.com/ravelojhon/flutter-consware/issues)
3. Crea un [nuevo Issue](https://github.com/ravelojhon/flutter-consware/issues/new)

---

**¡Construido con ❤️ usando Flutter!**