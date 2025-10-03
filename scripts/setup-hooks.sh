#!/bin/bash

# Script para instalar y configurar hooks de Git y pre-commit
# Compatible con Linux, macOS y Windows (con Git Bash)

set -e

echo "🔧 Configurando hooks de Git y herramientas de desarrollo..."

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

# Verificar que estamos en un repositorio Git
if [ ! -d ".git" ]; then
    print_error "No se encontró directorio .git. Ejecuta desde la raíz de un repositorio Git."
    exit 1
fi

# Verificar que estamos en un proyecto Flutter
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Ejecuta desde la raíz del proyecto Flutter."
    exit 1
fi

# 1. Configurar hooks básicos de Git
print_status "Configurando hooks básicos de Git..."

# Crear directorio de hooks si no existe
mkdir -p .git/hooks

# Copiar hooks si existen
if [ -f "scripts/pre-commit" ]; then
    cp scripts/pre-commit .git/hooks/
    chmod +x .git/hooks/pre-commit
    print_success "Hook pre-commit configurado"
fi

if [ -f "scripts/pre-push" ]; then
    cp scripts/pre-push .git/hooks/
    chmod +x .git/hooks/pre-push
    print_success "Hook pre-push configurado"
fi

# 2. Instalar pre-commit si está disponible
print_status "Verificando pre-commit..."

if command -v pre-commit &> /dev/null; then
    print_success "pre-commit ya está instalado"
    
    if [ -f ".pre-commit-config.yaml" ]; then
        print_status "Instalando hooks de pre-commit..."
        pre-commit install
        pre-commit install --hook-type pre-push
        print_success "Hooks de pre-commit instalados"
        
        print_status "Ejecutando pre-commit en archivos existentes..."
        pre-commit run --all-files || {
            print_warning "Algunos hooks de pre-commit fallaron. Revisa los errores arriba."
        }
    else
        print_warning "No se encontró .pre-commit-config.yaml"
    fi
else
    print_warning "pre-commit no está instalado"
    print_status "Para instalar pre-commit:"
    echo "  • Linux/macOS: pip install pre-commit"
    echo "  • Windows: pip install pre-commit"
    echo "  • Después ejecuta: pre-commit install"
fi

# 3. Configurar scripts ejecutables
print_status "Configurando scripts ejecutables..."
chmod +x scripts/*.sh 2>/dev/null || true
print_success "Scripts configurados como ejecutables"

# 4. Verificar herramientas necesarias
print_status "Verificando herramientas de desarrollo..."

# Flutter
if command -v flutter &> /dev/null; then
    print_success "Flutter encontrado: $(flutter --version | head -n 1)"
else
    print_error "Flutter no está instalado o no está en el PATH"
fi

# Dart
if command -v dart &> /dev/null; then
    print_success "Dart encontrado: $(dart --version | head -n 1)"
else
    print_error "Dart no está instalado o no está en el PATH"
fi

# Git
if command -v git &> /dev/null; then
    print_success "Git encontrado: $(git --version)"
else
    print_error "Git no está instalado o no está en el PATH"
fi

# 5. Configurar .gitignore si no existe
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

# Coverage
coverage/
lcov.info

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Environment
.env
.env.local

# Temporary files
*.tmp
*.cache
EOF
    print_success ".gitignore creado"
fi

# 6. Configurar archivo de secretos si no existe
if [ ! -f ".secrets.baseline" ]; then
    print_status "Creando baseline de secretos..."
    if command -v detect-secrets &> /dev/null; then
        detect-secrets scan --baseline .secrets.baseline
        print_success "Baseline de secretos creado"
    else
        print_warning "detect-secrets no está instalado. Instala con: pip install detect-secrets"
    fi
fi

# 7. Ejecutar validación inicial
print_status "Ejecutando validación inicial..."

# Formatear código
if command -v dart &> /dev/null; then
    print_status "Formateando código..."
    dart format . || {
        print_warning "Error al formatear código"
    }
fi

# Análisis estático
if command -v flutter &> /dev/null; then
    print_status "Ejecutando análisis estático..."
    flutter analyze || {
        print_warning "El análisis estático encontró problemas"
    }
fi

print_success "✅ Configuración de hooks completada!"
echo ""
echo "📋 Resumen de configuración:"
echo "  ✓ Hooks de Git configurados"
echo "  ✓ Scripts ejecutables configurados"
echo "  ✓ Herramientas verificadas"
echo "  ✓ Archivos de configuración creados"
echo "  ✓ Validación inicial ejecutada"
echo ""
echo "🚀 ¡Tu entorno está listo para desarrollo!"
echo ""
echo "💡 Comandos útiles:"
echo "  • git commit                    - Usar hooks automáticos"
echo "  • git push                      - Validaciones pre-push"
echo "  • scripts/format.sh             - Formateo completo"
echo "  • pre-commit run --all-files    - Ejecutar todos los hooks"
echo ""
