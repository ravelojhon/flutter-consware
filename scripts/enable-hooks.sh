#!/bin/bash
# scripts/enable-hooks.sh

echo "🔗 Re-habilitando hooks de Git..."

# Re-habilitar pre-commit hook
if [ -f ".git/hooks/pre-commit.disabled" ]; then
    mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "✅ Hook pre-commit re-habilitado."
else
    echo "⚠️ Hook pre-commit.disabled no encontrado."
fi

# Re-habilitar pre-push hook
if [ -f ".git/hooks/pre-push.disabled" ]; then
    mv .git/hooks/pre-push.disabled .git/hooks/pre-push
    chmod +x .git/hooks/pre-push
    echo "✅ Hook pre-push re-habilitado."
else
    echo "⚠️ Hook pre-push.disabled no encontrado."
fi

echo "🎉 Hooks re-habilitados exitosamente."
echo "Los hooks se ejecutarán automáticamente en cada 'git commit' y 'git push'."
