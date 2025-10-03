@echo off
REM scripts/enable-hooks.bat

echo 🔗 Re-habilitando hooks de Git...

REM Re-habilitar pre-commit hook
if exist .git\hooks\pre-commit.disabled (
    move .git\hooks\pre-commit.disabled .git\hooks\pre-commit > nul
    echo ✅ Hook pre-commit re-habilitado.
) else (
    echo ⚠️ Hook pre-commit.disabled no encontrado.
)

REM Re-habilitar pre-push hook
if exist .git\hooks\pre-push.disabled (
    move .git\hooks\pre-push.disabled .git\hooks\pre-push > nul
    echo ✅ Hook pre-push re-habilitado.
) else (
    echo ⚠️ Hook pre-push.disabled no encontrado.
)

echo.
echo 🎉 Hooks re-habilitados exitosamente.
echo Los hooks se ejecutarán automáticamente en cada 'git commit' y 'git push'.
