#!/usr/bin/env bash
# Valida sintaxis JavaScript de todos los dossier_*.html del repo.
# Uso: bash scripts/validate.sh
#
# Requiere Node.js instalado.

set -e

cd "$(dirname "$0")/.."

errors=0
total=0

for f in dossier_*.html; do
  if [ ! -f "$f" ]; then
    echo "No se encontraron archivos dossier_*.html en la raíz del repo."
    exit 0
  fi

  total=$((total + 1))
  echo ""
  echo "=== $f ==="

  result=$(node -e "
    const fs = require('fs');
    const html = fs.readFileSync('$f', 'utf8');
    const scripts = [...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)].map(m => m[1]);
    let ok = true;
    scripts.forEach((s, i) => {
      try {
        new Function(s);
        console.log('Script ' + (i+1) + ': OK (' + s.length + ' chars)');
      } catch(e) {
        console.log('Script ' + (i+1) + ' ERROR: ' + e.message);
        ok = false;
      }
    });
    process.exit(ok ? 0 : 1);
  " 2>&1) || {
    echo "$result"
    errors=$((errors + 1))
    continue
  }
  echo "$result"
done

echo ""
echo "=========================================="
if [ $errors -eq 0 ]; then
  echo "✓ $total archivo(s) validado(s) sin errores"
else
  echo "✗ $errors de $total archivo(s) con errores de sintaxis"
  exit 1
fi
