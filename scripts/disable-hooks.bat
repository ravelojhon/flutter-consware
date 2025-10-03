@echo off
REM scripts/disable-hooks.bat

echo 🚫 Deshabilitando hooks de Git...

REM Deshabilitar pre-commit hook
if exist .git\hooks\pre-commit (
    move .git\hooks\pre-commit .git\hooks\pre-commit.disabled > nul
    echo ✅ Hook pre-commit deshabilitado.
) else (
    echo ⚠️ Hook pre-commit no encontrado.
)

REM Deshabilitar pre-push hook
if exist .git\hooks\pre-push (
    move .git\hooks\pre-push .git\hooks\pre-push.disabled > nul
    echo ✅ Hook pre-push deshabilitado.
) else (
    echo ⚠️ Hook pre-push no encontrado.
)

echo.
echo 🎉 Hooks deshabilitados exitosamente.
echo Los hooks NO se ejecutarán en 'git commit' y 'git push'.
echo Para re-habilitarlos, ejecuta: scripts\enable-hooks.bat
