#!/usr/bin/env bash
# Publikacja paczki aktualizacji: wydanie z .pck w DaVideX12324/ArtefaktWiedzy-updates + manifest w gist.
# Użycie (po eksporcie łatki w Godocie):  bash tools/publish_patch.sh [ścieżka.pck]
#   domyślnie build/windows/patches/patch_001.pck; wersja i build z resources/build.json (podbija je ExportCheck).
# Paczki są skumulowane względem bazy, więc manifest wskazuje tylko najnowszą. Link do pełnego exe (url) zostaje z gista.
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="DaVideX12324/ArtefaktWiedzy-updates"
GIST="cc2274c3de25a1ee9a122ad9419097a8"
PCK="${1:-build/windows/patches/patch_001.pck}"

[ -f "$PCK" ] || { echo "Brak paczki: $PCK"; exit 1; }
read -r VERSION BUILD < <(python -c "import json; d=json.load(open('resources/build.json')); print(d['version'], d['build'])")
ASSET="patch_${BUILD}.pck"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp "$PCK" "$TMP/$ASSET"

echo "Wydanie $VERSION (build $BUILD): $PCK"
gh release create "$VERSION" "$TMP/$ASSET" -R "$REPO" -t "$VERSION" -n "Paczka $VERSION (build $BUILD)"
URL="https://github.com/$REPO/releases/download/$VERSION/$ASSET"

gh api "gists/$GIST" --jq '.files["version.json"].content' > "$TMP/old.json"
python - "$TMP/old.json" "$VERSION" "$BUILD" "$URL" > "$TMP/body.json" <<'EOF'
import json, sys
old_path, version, build, url = sys.argv[1:]
try:
    full = json.load(open(old_path, encoding="utf-8")).get("url", "")
except Exception:
    full = ""
manifest = {"version": version, "build": int(build), "url": full, "patches": [{"build": int(build), "url": url}]}
print(json.dumps({"files": {"version.json": {"content": json.dumps(manifest, ensure_ascii=False, indent=1)}}}))
EOF
gh api -X PATCH "gists/$GIST" --input "$TMP/body.json" > /dev/null
echo "Gist zaktualizowany: $VERSION, build $BUILD"
echo "$URL"
