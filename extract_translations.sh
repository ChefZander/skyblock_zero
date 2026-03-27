#!/usr/bin/env bash
set -e

# Get submodule mod names from .gitmodules
SUBMODULES=$(grep 'path = mods/' .gitmodules 2>/dev/null | sed 's|.*mods/||')

for mod in mods/*; do
  [ -d "$mod" ] || continue

  modname="$(basename "$mod")"

  # Skip if this mod is a git submodule
  if echo "$SUBMODULES" | grep -qx "$modname"; then
    echo "Skipping git submodule: $modname"
    continue
  fi

  # Skip mods that don’t use translations
  if ! grep -qr "get_translator" "$mod"; then
    echo "Skipping (no translations): $modname"
    continue
  fi

  outdir="$mod/locale"
  outfile="$outdir/$modname.pot"

  echo "Processing $modname..."

  mkdir -p "$outdir"

  find "$mod" -type f -name "*.lua" \
    -not -path "*/.git/*" \
    -not -path "*/vendor/*" \
    -not -path "*/deps/*" \
    -not -path "*/third_party/*" \
    | xgettext \
        --from-code=UTF-8 \
        -L lua \
        -kS -kPS:1,2 \
        -kcore.translate:1c,2 \
        -kcore.translate_n:1c,2,3 \
        -d "$modname" \
        -o "$outfile" \
        -f -

  # Fix charset
  if [ -f "$outfile" ]; then
    sed -i 's/charset=CHARSET/charset=UTF-8/' "$outfile"
  else
    echo "No translatable strings found in $modname"
  fi

done

echo "Done."