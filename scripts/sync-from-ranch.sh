#!/usr/bin/env bash
set -euo pipefail

RANCH_PATH="${1:-}"
if [ -z "$RANCH_PATH" ]; then
  echo "Usage: scripts/sync-from-ranch.sh <ranch-checkout-path>" >&2
  echo "Or: make sync-from-ranch RANCH_PATH=<ranch-checkout-path>" >&2
  exit 1
fi

if [ ! -d "$RANCH_PATH/api/src/slices/reins" ]; then
  echo "Error: $RANCH_PATH does not look like a ranch checkout (missing api/src/slices/reins)" >&2
  exit 1
fi

REINS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Syncing reins state:"
echo "  source: $RANCH_PATH"
echo "  target: $REINS_ROOT"

NESTJS_DIRS=(knowledge source lightrag config)
echo
echo "==> NestJS slice"
for d in "${NESTJS_DIRS[@]}"; do
  echo "  copy $d/"
  rm -rf "$REINS_ROOT/nestjs/$d"
  cp -r "$RANCH_PATH/api/src/slices/reins/$d" "$REINS_ROOT/nestjs/"
done

echo
echo "==> Nuxt layer"
NUXT_DIRS=(pages components stores plugins i18n)
for d in "${NUXT_DIRS[@]}"; do
  if [ -d "$RANCH_PATH/admin/slices/reins/$d" ]; then
    echo "  copy admin/slices/reins/$d/"
    rm -rf "$REINS_ROOT/nuxt/$d"
    cp -r "$RANCH_PATH/admin/slices/reins/$d" "$REINS_ROOT/nuxt/"
  fi
done

# Top-level files in ranch's reins admin slice (e.g. pages.ts route name constants).
# Skip nuxt.config.ts (reins ships its own) and pages.ts is the only known top-level file.
if [ -f "$RANCH_PATH/admin/slices/reins/pages.ts" ]; then
  echo "  copy admin/slices/reins/pages.ts"
  cp "$RANCH_PATH/admin/slices/reins/pages.ts" "$REINS_ROOT/nuxt/pages.ts"
fi

# Remove empty leftover locales/ dir (i18n content lives in i18n/locales/).
rm -rf "$REINS_ROOT/nuxt/locales"

# Settings page lives in ranch's setting slice; cherry-pick it.
echo "  copy admin/slices/setting/pages/settings/knowledge.vue"
mkdir -p "$REINS_ROOT/nuxt/pages/settings"
cp "$RANCH_PATH/admin/slices/setting/pages/settings/knowledge.vue" "$REINS_ROOT/nuxt/pages/settings/knowledge.vue"

echo
echo "==> Diff summary"
cd "$REINS_ROOT"
git status --short nestjs/ nuxt/ || true

echo
echo "Sync done. Review the diff with: git diff -- nestjs/ nuxt/"
echo "If it looks right, commit and push."
