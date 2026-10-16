#!/usr/bin/env bash
# Arranca ListGenerator en local con todo actualizado.
#
# Uso (desde la raiz del proyecto):
#   ./start.sh              instala dependencias si faltan, regenera el catalogo y arranca el frontend
#   ./start.sh --data-only  solo regenera el catalogo (JSON de unidades), sin arrancar nada
#
# Si da "permission denied": chmod +x start.sh   (o ejecutalo con: bash start.sh)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Instala dependencias solo si no estan o si package-lock.json es mas nuevo que node_modules.
install_if_needed() {
  local dir="$1"
  if [ ! -d "$dir/node_modules" ] || [ "$dir/package-lock.json" -nt "$dir/node_modules" ]; then
    echo "==> Instalando dependencias en $(basename "$dir")..."
    (cd "$dir" && npm install)
    touch "$dir/node_modules"
  fi
}

install_if_needed "$ROOT/backend"
install_if_needed "$ROOT/frontend"

echo "==> Regenerando el catalogo (datos de unidades, comandantes y opciones)..."
(cd "$ROOT/backend" && npm run build:static)

if [ "${1:-}" = "--data-only" ]; then
  echo "==> Catalogo actualizado."
  exit 0
fi

echo "==> Arrancando el frontend (http://localhost:4200). Recarga el navegador con Cmd+Shift+R."
cd "$ROOT/frontend"
exec npm start
