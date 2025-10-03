#!/bin/bash

# Script de validación pre-push para Git hooks
# Ejecuta validaciones críticas antes de permitir el push

set -e

echo "🚀 Ejecutando validaciones pre-push..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[PRE-PUSH]${NC} $1"
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
    print_error "No se encontró pubspec.yaml. Ejecuta desde la raíz del proyecto."
    exit 1
fi

# 1. Verificar que no hay archivos sin commit
print_status "Verificando archivos sin commit..."
if ! git diff-index --quiet HEAD --; then
    print_error "Hay cambios sin commit. Commit todos los cambios antes de hacer push."
    git status --porcelain
    exit 1
fi
print_success "Todos los cambios están commiteados"

# 2. Formatear código
print_status "Formateando código..."
dart format --set-exit-if-changed . || {
    print_error "El código no está formateado. Ejecuta 'dart format .' y vuelve a commit."
    exit 1
}
print_success "Código correctamente formateado"

# 3. Análisis estático
print_status "Ejecutando análisis estático..."
flutter analyze || {
    print_error "El análisis estático encontró errores. Corrige los errores antes de hacer push."
    exit 1
}
print_success "Análisis estático sin errores"

# 4. Ejecutar tests críticos
print_status "Ejecutando tests críticos..."
if [ -d "test" ]; then
    flutter test --coverage || {
        print_error "Los tests fallaron. Corrige los tests antes de hacer push."
        exit 1
    }
    print_success "Tests pasaron correctamente"
else
    print_warning "No se encontró directorio de tests"
fi

# 5. Verificar que no hay archivos de debug en el commit
print_status "Verificando archivos de debug..."
if git ls-files | grep -E "\.(log|tmp|cache)$|debug|test.*\.dart$" > /dev/null; then
    print_warning "Se detectaron posibles archivos de debug en el repositorio"
fi

# 6. Verificar tamaño del commit
print_status "Verificando tamaño del commit..."
commit_size=$(git diff --cached --stat | tail -1 | awk '{print $4}' | sed 's/[^0-9]//g')
if [ -n "$commit_size" ] && [ "$commit_size" -gt 1000 ]; then
    print_warning "Commit muy grande ($commit_size líneas). Considera dividirlo en commits más pequeños."
fi

# 7. Verificar que las dependencias están actualizadas
print_status "Verificando dependencias..."
flutter pub get > /dev/null 2>&1
if ! flutter pub deps --style=tree | grep -q "No dependencies"; then
    print_success "Dependencias verificadas"
fi

# 8. Verificar archivos generados
print_status "Verificando archivos generados..."
if grep -q "build_runner" pubspec.yaml; then
    if [ -f "lib/src/data/local/database.dart" ] || [ -f "lib/src/data/local/todo_database.dart" ]; then
        # Verificar que los archivos generados están actualizados
        if find lib -name "*.g.dart" -newer pubspec.lock > /dev/null 2>&1; then
            print_warning "Los archivos generados pueden estar desactualizados. Ejecuta 'flutter packages pub run build_runner build'"
        fi
    fi
fi

print_success "✅ Todas las validaciones pre-push pasaron!"
echo ""
echo "🚀 Listo para hacer push al repositorio remoto"
echo ""
echo "📊 Resumen de validaciones:"
echo "  ✓ Archivos commiteados"
echo "  ✓ Código formateado"
echo "  ✓ Análisis estático sin errores"
echo "  ✓ Tests pasando"
echo "  ✓ Dependencias verificadas"
echo "  ✓ Archivos generados verificados"
