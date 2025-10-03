#!/bin/bash

# Script de formateo automático para Flutter/Dart
# Ejecuta formateo de código, análisis estático y validaciones

set -e  # Salir si cualquier comando falla

echo "🔧 Iniciando formateo y análisis de código..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto Flutter."
    exit 1
fi

# 1. Formatear código
print_status "Formateando código con dart format..."
dart format --set-exit-if-changed . || {
    print_error "El código no está formateado correctamente. Ejecuta 'dart format .' para corregir."
    exit 1
}
print_success "Código formateado correctamente"

# 2. Ejecutar análisis estático
print_status "Ejecutando análisis estático con flutter analyze..."
flutter analyze || {
    print_error "El análisis estático encontró errores. Revisa los warnings y errores arriba."
    exit 1
}
print_success "Análisis estático completado sin errores"

# 3. Verificar que no hay imports no utilizados
print_status "Verificando imports no utilizados..."
dart fix --dry-run || {
    print_warning "Se encontraron imports no utilizados u otros problemas menores."
    print_status "Ejecutando 'dart fix --apply' para corregir automáticamente..."
    dart fix --apply
}

# 4. Ejecutar tests (opcional, solo si se especifica --test)
if [ "$1" = "--test" ]; then
    print_status "Ejecutando tests..."
    flutter test || {
        print_error "Los tests fallaron. Revisa los errores arriba."
        exit 1
    }
    print_success "Todos los tests pasaron"
fi

# 5. Verificar estructura del proyecto
print_status "Verificando estructura del proyecto..."
if [ ! -d "lib" ]; then
    print_error "Directorio 'lib' no encontrado"
    exit 1
fi

if [ ! -d "test" ]; then
    print_warning "Directorio 'test' no encontrado"
fi

print_success "Estructura del proyecto verificada"

# 6. Verificar dependencias
print_status "Verificando dependencias..."
flutter pub get || {
    print_error "Error al obtener dependencias"
    exit 1
}
print_success "Dependencias verificadas"

# 7. Generar archivos si es necesario
if grep -q "build_runner" pubspec.yaml; then
    print_status "Generando archivos con build_runner..."
    flutter packages pub run build_runner build --delete-conflicting-outputs || {
        print_warning "Error al generar archivos con build_runner. Continuando..."
    }
fi

print_success "✅ Formateo y análisis completado exitosamente!"
echo ""
echo "📋 Resumen:"
echo "  ✓ Código formateado"
echo "  ✓ Análisis estático sin errores"
echo "  ✓ Imports verificados"
echo "  ✓ Estructura del proyecto verificada"
echo "  ✓ Dependencias actualizadas"
echo ""
echo "🚀 El código está listo para commit!"
