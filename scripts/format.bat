@echo off
REM Script de formateo automático para Flutter/Dart (Windows)
REM Ejecuta formateo de código, análisis estático y validaciones

setlocal enabledelayedexpansion

echo 🔧 Iniciando formateo y análisis de código...

REM Verificar que estamos en el directorio correcto
if not exist "pubspec.yaml" (
    echo [ERROR] No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto Flutter.
    exit /b 1
)

REM 1. Formatear código
echo [INFO] Formateando código con dart format...
dart format --set-exit-if-changed . 
if errorlevel 1 (
    echo [ERROR] El código no está formateado correctamente. Ejecuta 'dart format .' para corregir.
    exit /b 1
)
echo [SUCCESS] Código formateado correctamente

REM 2. Ejecutar análisis estático
echo [INFO] Ejecutando análisis estático con flutter analyze...
flutter analyze
if errorlevel 1 (
    echo [ERROR] El análisis estático encontró errores. Revisa los warnings y errores arriba.
    exit /b 1
)
echo [SUCCESS] Análisis estático completado sin errores

REM 3. Verificar que no hay imports no utilizados
echo [INFO] Verificando imports no utilizados...
dart fix --dry-run
if errorlevel 1 (
    echo [WARNING] Se encontraron imports no utilizados u otros problemas menores.
    echo [INFO] Ejecutando 'dart fix --apply' para corregir automáticamente...
    dart fix --apply
)

REM 4. Ejecutar tests (opcional, solo si se especifica --test)
if "%1"=="--test" (
    echo [INFO] Ejecutando tests...
    flutter test
    if errorlevel 1 (
        echo [ERROR] Los tests fallaron. Revisa los errores arriba.
        exit /b 1
    )
    echo [SUCCESS] Todos los tests pasaron
)

REM 5. Verificar estructura del proyecto
echo [INFO] Verificando estructura del proyecto...
if not exist "lib" (
    echo [ERROR] Directorio 'lib' no encontrado
    exit /b 1
)

if not exist "test" (
    echo [WARNING] Directorio 'test' no encontrado
)

echo [SUCCESS] Estructura del proyecto verificada

REM 6. Verificar dependencias
echo [INFO] Verificando dependencias...
flutter pub get
if errorlevel 1 (
    echo [ERROR] Error al obtener dependencias
    exit /b 1
)
echo [SUCCESS] Dependencias verificadas

REM 7. Generar archivos si es necesario
findstr /C:"build_runner" pubspec.yaml >nul
if not errorlevel 1 (
    echo [INFO] Generando archivos con build_runner...
    flutter packages pub run build_runner build --delete-conflicting-outputs
    if errorlevel 1 (
        echo [WARNING] Error al generar archivos con build_runner. Continuando...
    )
)

echo [SUCCESS] ✅ Formateo y análisis completado exitosamente!
echo.
echo 📋 Resumen:
echo   ✓ Código formateado
echo   ✓ Análisis estático sin errores
echo   ✓ Imports verificados
echo   ✓ Estructura del proyecto verificada
echo   ✓ Dependencias actualizadas
echo.
echo 🚀 El código está listo para commit!

pause
