#!/bin/bash
# scripts/disable-hooks.sh

echo "🚫 Deshabilitando hooks de Git..."

# Deshabilitar pre-commit hook
if [ -f ".git/hooks/pre-commit" ]; then
    mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
    echo "✅ Hook pre-commit deshabilitado."
else
    echo "⚠️ Hook pre-commit no encontrado."
fi

# Deshabilitar pre-push hook
if [ -f ".git/hooks/pre-push" ]; then
    mv .git/hooks/pre-push .git/hooks/pre-push.disabled
    echo "✅ Hook pre-push deshabilitado."
else
    echo "⚠️ Hook pre-push no encontrado."
fi

echo "🎉 Hooks deshabilitados exitosamente."
echo "Los hooks NO se ejecutarán en 'git commit' y 'git push'."
echo "Para re-habilitarlos, ejecuta: bash scripts/enable-hooks.sh"
