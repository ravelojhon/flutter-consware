# 🚀 Guía de Desarrollo - App Consware

Esta guía te ayudará a configurar tu entorno de desarrollo y entender las herramientas de calidad de código implementadas.

## 📋 Tabla de Contenidos

- [Configuración Inicial](#-configuración-inicial)
- [Herramientas de Calidad](#-herramientas-de-calidad)
- [Hooks de Git](#-hooks-de-git)
- [Scripts Disponibles](#-scripts-disponibles)
- [CI/CD](#-cicd)
- [Troubleshooting](#-troubleshooting)

## 🛠️ Configuración Inicial

### Requisitos Previos

- **Flutter 3.24.0+** - [Instalar Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** - Incluido con Flutter
- **Git** - [Instalar Git](https://git-scm.com/downloads)
- **Python 3.7+** (opcional) - Para pre-commit hooks

### Configuración del Proyecto

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd app_consware
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar entorno de desarrollo**
   ```bash
   # Linux/macOS
   bash scripts/setup-dev-environment.sh
   
   # Windows
   scripts\setup-dev-environment.bat
   ```

4. **Configurar hooks de Git**
   ```bash
   # Linux/macOS
   bash scripts/setup-hooks.sh
   
   # Windows
   scripts\install-hooks.bat
   ```

## 🔍 Herramientas de Calidad

### Análisis Estático

El proyecto utiliza reglas estrictas de análisis estático configuradas en `analysis_options.yaml`:

- **Reglas de estilo**: Formateo consistente, uso de const, etc.
- **Reglas de Flutter**: Mejores prácticas específicas de Flutter
- **Reglas de análisis**: Detección de problemas potenciales
- **Reglas de documentación**: Verificación de documentación

### Formateo de Código

```bash
# Formatear todo el código
dart format .

# Verificar formateo sin cambiar archivos
dart format --set-exit-if-changed .

# Corregir imports no utilizados
dart fix --apply
```

### Análisis de Dependencias

```bash
# Verificar dependencias
flutter pub deps

# Verificar vulnerabilidades
flutter pub deps --style=tree
```

## 🔗 Hooks de Git

### Pre-commit Hook

Se ejecuta antes de cada commit y valida:

- ✅ Formateo de archivos modificados
- ✅ Análisis estático en archivos modificados
- ✅ Verificación de imports no utilizados
- ✅ Ejecución de tests relacionados
- ✅ Verificación de archivos sensibles

### Pre-push Hook

Se ejecuta antes de cada push y valida:

- ✅ Todos los cambios están commiteados
- ✅ Código formateado correctamente
- ✅ Análisis estático sin errores
- ✅ Tests pasando
- ✅ Dependencias actualizadas
- ✅ Archivos generados verificados

### Pre-commit Framework (Opcional)

Si tienes Python instalado, puedes usar el framework oficial de pre-commit:

```bash
# Instalar pre-commit
pip install pre-commit

# Instalar hooks
pre-commit install

# Ejecutar en todos los archivos
pre-commit run --all-files
```

## 📜 Scripts Disponibles

### Scripts de Formateo

```bash
# Formateo completo con validaciones
bash scripts/format.sh

# Formateo completo con tests
bash scripts/format.sh --test

# Windows
scripts\format.bat
scripts\format.bat --test
```

### Scripts de Validación

```bash
# Validación pre-push
bash scripts/pre-push-validation.sh

# Configuración de hooks
bash scripts/setup-hooks.sh

# Configuración completa del entorno
bash scripts/setup-dev-environment.sh
```

### Comandos Útiles

```bash
# Análisis estático
flutter analyze

# Tests con coverage
flutter test --coverage

# Generar archivos
dart run build_runner build --delete-conflicting-outputs

# Limpiar proyecto
flutter clean && flutter pub get
```

## 🚀 CI/CD

### GitHub Actions

El proyecto incluye múltiples workflows de CI/CD:

#### 1. **CI/CD Principal** (`.github/workflows/ci.yml`)
- ✅ Tests unitarios y de widgets
- ✅ Build para Android e iOS
- ✅ Análisis de seguridad con Trivy
- ✅ Quality gate
- ✅ Reportes de coverage

#### 2. **Análisis de Calidad** (`.github/workflows/code-quality.yml`)
- ✅ Verificación de formateo
- ✅ Análisis estático estricto
- ✅ Verificación de imports no utilizados
- ✅ Análisis de complejidad
- ✅ Verificación de seguridad
- ✅ Reportes de calidad en PRs

### Validaciones Automáticas

Cada push y PR ejecuta:

1. **Formateo de código**
2. **Análisis estático con reglas estrictas**
3. **Verificación de imports no utilizados**
4. **Tests unitarios y de widgets**
5. **Build multiplataforma**
6. **Análisis de seguridad**
7. **Quality gate**

## 🐛 Troubleshooting

### Problemas Comunes

#### 1. **Hook pre-commit falla**
```bash
# Verificar que el hook es ejecutable
chmod +x .git/hooks/pre-commit

# Ejecutar manualmente para debug
.git/hooks/pre-commit
```

#### 2. **Análisis estático falla**
```bash
# Verificar reglas específicas
flutter analyze --verbose

# Corregir automáticamente
dart fix --apply
```

#### 3. **Tests fallan**
```bash
# Ejecutar tests específicos
flutter test test/unit/

# Ejecutar con verbose
flutter test --verbose
```

#### 4. **Formateo falla**
```bash
# Formatear archivos específicos
dart format lib/

# Verificar diferencias
dart format --set-exit-if-changed .
```

### Comandos de Debug

```bash
# Ver estado de Git
git status

# Ver hooks instalados
ls -la .git/hooks/

# Ver configuración de análisis
cat analysis_options.yaml

# Ver dependencias
flutter pub deps --style=tree
```

## 📚 Recursos Adicionales

- [Flutter Style Guide](https://flutter.dev/docs/development/ui/widgets-intro)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Pre-commit Documentation](https://pre-commit.com/)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

## 🤝 Contribución

1. **Fork el repositorio**
2. **Crear una rama feature**: `git checkout -b feature/nueva-funcionalidad`
3. **Hacer cambios** siguiendo las reglas de calidad
4. **Commit con mensaje descriptivo**: `git commit -m "feat: añadir nueva funcionalidad"`
5. **Push a la rama**: `git push origin feature/nueva-funcionalidad`
6. **Crear Pull Request**

### Estándares de Commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Formateo, espacios, etc.
- `refactor:` Refactorización de código
- `test:` Añadir o modificar tests
- `chore:` Cambios en build, dependencias, etc.

## 📞 Soporte

Si tienes problemas con la configuración:

1. Revisa esta documentación
2. Verifica los logs de error
3. Ejecuta los scripts de configuración
4. Crea un issue en el repositorio

---

**¡Happy Coding! 🎉**
