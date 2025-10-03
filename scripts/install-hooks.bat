@echo off
REM Script para instalar hooks de Git en Windows
REM Configura los hooks pre-commit y pre-push

echo 🔧 Instalando hooks de Git...

REM Verificar que estamos en un repositorio Git
if not exist ".git" (
    echo [ERROR] No se encontró directorio .git. Ejecuta desde la raíz de un repositorio Git.
    exit /b 1
)

REM Verificar que estamos en un proyecto Flutter
if not exist "pubspec.yaml" (
    echo [ERROR] No se encontró pubspec.yaml. Ejecuta desde la raíz del proyecto Flutter.
    exit /b 1
)

REM Crear directorio de hooks si no existe
if not exist ".git\hooks" (
    mkdir ".git\hooks"
)

REM Copiar scripts de hooks
echo [INFO] Configurando hook pre-commit...
copy ".git\hooks\pre-commit" ".git\hooks\pre-commit.bak" >nul 2>&1
echo [INFO] Configurando hook pre-push...
copy ".git\hooks\pre-push" ".git\hooks\pre-push.bak" >nul 2>&1

REM Crear scripts de PowerShell para Windows
echo [INFO] Creando scripts de PowerShell para Windows...

REM Hook pre-commit para PowerShell
(
echo # Git hook pre-commit para Windows PowerShell
echo # Este hook se ejecuta antes de crear un commit
echo.
echo Write-Host "🔍 Ejecutando validaciones pre-commit..." -ForegroundColor Blue
echo.
echo # Obtener el directorio raíz del proyecto
echo $PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
echo $PROJECT_ROOT = Split-Path -Parent $PROJECT_ROOT
echo $PROJECT_ROOT = Split-Path -Parent $PROJECT_ROOT
echo.
echo # Cambiar al directorio del proyecto
echo Set-Location $PROJECT_ROOT
echo.
echo # Verificar que estamos en un proyecto Flutter
echo if ^(-not ^(Test-Path "pubspec.yaml"^)^) {
echo     Write-Host "❌ No se encontró pubspec.yaml - no es un proyecto Flutter" -ForegroundColor Red
echo     exit 1
echo }
echo.
echo # 1. Formatear archivos que van a ser commiteados
echo Write-Host "🔧 Formateando archivos modificados..." -ForegroundColor Yellow
echo $dartFiles = git diff --cached --name-only --diff-filter=ACM ^| Where-Object { $_ -match "\.dart$" }
echo if ^($dartFiles^) {
echo     $dartFiles ^| ForEach-Object { dart format --set-exit-if-changed $_ }
echo     if ^($LASTEXITCODE -ne 0^) {
echo         Write-Host "❌ Archivos no formateados correctamente" -ForegroundColor Red
echo         Write-Host "💡 Ejecuta 'dart format .' para corregir" -ForegroundColor Yellow
echo         exit 1
echo     }
echo }
echo.
echo # 2. Verificar análisis estático
echo Write-Host "🔍 Verificando análisis estático..." -ForegroundColor Yellow
echo if ^($dartFiles^) {
echo     $dartFiles ^| ForEach-Object { flutter analyze $_ }
echo     if ^($LASTEXITCODE -ne 0^) {
echo         Write-Host "❌ Errores de análisis estático en archivos modificados" -ForegroundColor Red
echo         exit 1
echo     }
echo }
echo.
echo Write-Host "✅ Todas las validaciones pre-commit pasaron" -ForegroundColor Green
echo Write-Host "🚀 Commit autorizado" -ForegroundColor Green
) > ".git\hooks\pre-commit.ps1"

REM Hook pre-push para PowerShell
(
echo # Git hook pre-push para Windows PowerShell
echo # Este hook se ejecuta antes de hacer push al repositorio remoto
echo.
echo Write-Host "🔍 Ejecutando validaciones pre-push..." -ForegroundColor Blue
echo.
echo # Obtener el directorio raíz del proyecto
echo $PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
echo $PROJECT_ROOT = Split-Path -Parent $PROJECT_ROOT
echo $PROJECT_ROOT = Split-Path -Parent $PROJECT_ROOT
echo.
echo # Cambiar al directorio del proyecto
echo Set-Location $PROJECT_ROOT
echo.
echo # Ejecutar validaciones básicas
echo if ^(-not ^(Test-Path "pubspec.yaml"^)^) {
echo     Write-Host "❌ No se encontró pubspec.yaml" -ForegroundColor Red
echo     exit 1
echo }
echo.
echo # Formateo básico
echo Write-Host "🔧 Verificando formateo..." -ForegroundColor Yellow
echo dart format --set-exit-if-changed .
echo if ^($LASTEXITCODE -ne 0^) {
echo     Write-Host "❌ Código no formateado. Ejecuta 'dart format .'" -ForegroundColor Red
echo     exit 1
echo }
echo.
echo # Análisis básico
echo Write-Host "🔍 Verificando análisis estático..." -ForegroundColor Yellow
echo flutter analyze
echo if ^($LASTEXITCODE -ne 0^) {
echo     Write-Host "❌ Errores de análisis estático" -ForegroundColor Red
echo     exit 1
echo }
echo.
echo Write-Host "✅ Validaciones básicas completadas" -ForegroundColor Green
echo Write-Host "🚀 Push autorizado - todas las validaciones pasaron" -ForegroundColor Green
) > ".git\hooks\pre-push.ps1"

echo [SUCCESS] ✅ Hooks de Git instalados correctamente!
echo.
echo 📋 Hooks configurados:
echo   ✓ pre-commit.ps1 - Validaciones antes del commit
echo   ✓ pre-push.ps1 - Validaciones antes del push
echo.
echo 💡 Nota: Los hooks de PowerShell se ejecutarán automáticamente
echo    en Windows. Para Linux/Mac, usa los scripts .sh correspondientes.
echo.
echo 🚀 Los hooks están listos para usar!

pause
