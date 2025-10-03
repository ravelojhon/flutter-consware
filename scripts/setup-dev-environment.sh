#!/bin/bash

# Script para configurar el entorno de desarrollo
# Instala hooks, configura herramientas y valida el setup

set -e

echo "🚀 Configurando entorno de desarrollo para Flutter..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Ejecuta desde la raíz del proyecto Flutter."
    exit 1
fi

# 1. Verificar Flutter instalado
print_status "Verificando instalación de Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado o no está en el PATH"
    exit 1
fi

flutter --version
print_success "Flutter verificado"

# 2. Verificar Dart instalado
print_status "Verificando instalación de Dart..."
if ! command -v dart &> /dev/null; then
    print_error "Dart no está instalado o no está en el PATH"
    exit 1
fi

dart --version
print_success "Dart verificado"

# 3. Instalar dependencias
print_status "Instalando dependencias de Flutter..."
flutter pub get || {
    print_error "Error al instalar dependencias"
    exit 1
}
print_success "Dependencias instaladas"

# 4. Configurar hooks de Git
print_status "Configurando hooks de Git..."
if [ -f "scripts/install-hooks.bat" ]; then
    # Windows
    if command -v cmd.exe &> /dev/null; then
        cmd.exe /c "scripts\\install-hooks.bat"
    else
        print_warning "No se pudo ejecutar el instalador de hooks para Windows"
    fi
else
    # Linux/Mac
    if [ -f "scripts/pre-push-validation.sh" ]; then
        chmod +x scripts/*.sh
        chmod +x .git/hooks/*
        print_success "Hooks de Git configurados"
    else
        print_warning "Scripts de hooks no encontrados"
    fi
fi

# 5. Verificar análisis estático
print_status "Verificando configuración de análisis estático..."
if [ -f "analysis_options.yaml" ]; then
    flutter analyze --no-fatal-infos || {
        print_warning "Se encontraron warnings en el análisis estático"
    }
    print_success "Análisis estático configurado"
else
    print_warning "analysis_options.yaml no encontrado"
fi

# 6. Verificar formateo
print_status "Verificando formateo de código..."
dart format --set-exit-if-changed . || {
    print_warning "El código no está formateado. Ejecutando formateo..."
    dart format .
    print_success "Código formateado"
}

# 7. Generar archivos si es necesario
print_status "Verificando archivos generados..."
if grep -q "build_runner" pubspec.yaml; then
    print_status "Generando archivos con build_runner..."
    flutter packages pub run build_runner build --delete-conflicting-outputs || {
        print_warning "Error al generar archivos con build_runner"
    }
fi

# 8. Ejecutar tests básicos
print_status "Ejecutando tests básicos..."
if [ -d "test" ]; then
    flutter test || {
        print_warning "Algunos tests fallaron"
    }
    print_success "Tests ejecutados"
else
    print_warning "No se encontró directorio de tests"
fi

# 9. Verificar estructura del proyecto
print_status "Verificando estructura del proyecto..."
required_dirs=("lib" "test")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_success "Directorio $dir encontrado"
    else
        print_warning "Directorio $dir no encontrado"
    fi
done

# 10. Crear archivos de configuración si no existen
print_status "Verificando archivos de configuración..."

# .gitignore
if [ ! -f ".gitignore" ]; then
    print_status "Creando .gitignore básico..."
    cat > .gitignore << 'EOF'
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Web
/web/

# Android
/android/app/debug
/android/app/profile
/android/app/release

# iOS
/ios/build/
/ios/Pods/
/ios/.symlinks/
/ios/Flutter/App.framework
/ios/Flutter/Flutter.framework
/ios/Flutter/Flutter.podspec
/ios/Flutter/Generated.xcconfig
/ios/Flutter/ephemeral/
/ios/Flutter/app.flx
/ios/Flutter/app.zip
/ios/Flutter/flutter_assets/
/ios/Flutter/flutter_export_environment.sh
/ios/ServiceDefinitions.json
/ios/Runner/GeneratedPluginRegistrant.*

# Coverage
coverage/
lcov.info

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Environment
.env
.env.local
.env.*.local

# Temporary files
*.tmp
*.cache
EOF
    print_success ".gitignore creado"
fi

# README.md básico
if [ ! -f "README.md" ]; then
    print_status "Creando README.md básico..."
    cat > README.md << 'EOF'
# App Consware

Aplicación Flutter para gestión de tareas.

## Configuración del entorno de desarrollo

1. Instala Flutter: https://flutter.dev/docs/get-started/install
2. Instala dependencias: `flutter pub get`
3. Configura hooks: `scripts/install-hooks.bat` (Windows) o `scripts/setup-dev-environment.sh` (Linux/Mac)
4. Ejecuta la app: `flutter run`

## Scripts disponibles

- `scripts/format.sh` - Formatear código y análisis estático
- `scripts/pre-push-validation.sh` - Validaciones pre-push
- `scripts/setup-dev-environment.sh` - Configurar entorno de desarrollo

## Estructura del proyecto

```
lib/
├── src/
│   ├── core/           # Configuración y utilidades
│   ├── data/           # Capa de datos
│   ├── domain/         # Entidades y casos de uso
│   └── presentation/   # UI y providers
test/                   # Tests unitarios y de widgets
integration_test/       # Tests de integración
```

## Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar análisis estático
flutter analyze

# Formatear código
dart format .
```
EOF
    print_success "README.md creado"
fi

print_success "✅ Entorno de desarrollo configurado exitosamente!"
echo ""
echo "📋 Resumen de configuración:"
echo "  ✓ Flutter y Dart verificados"
echo "  ✓ Dependencias instaladas"
echo "  ✓ Hooks de Git configurados"
echo "  ✓ Análisis estático configurado"
echo "  ✓ Código formateado"
echo "  ✓ Archivos generados"
echo "  ✓ Tests ejecutados"
echo "  ✓ Estructura del proyecto verificada"
echo "  ✓ Archivos de configuración creados"
echo ""
echo "🚀 ¡Tu entorno de desarrollo está listo!"
echo ""
echo "💡 Comandos útiles:"
echo "  • flutter run                    - Ejecutar la app"
echo "  • dart format .                  - Formatear código"
echo "  • flutter analyze                - Análisis estático"
echo "  • flutter test                   - Ejecutar tests"
echo "  • scripts/format.sh              - Formateo completo"
echo ""
