#!/usr/bin/env sh
# SessionStart: przypomina o ważnych todo — nagłówkach "### ⚠ WAŻNE: …" w docs/znane_problemy.md.
# Załatwione = usunięty nagłówek albo znacznik; wtedy przypomnienie znika samo.
# Wyjście: JSON z additionalContext (dla Claude'a) i systemMessage (widoczne w UI).
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null || exit 0
f=docs/znane_problemy.md
[ -f "$f" ] || exit 0
items=$(grep '^### ⚠ WAŻNE:' "$f" | sed 's/^### ⚠ WAŻNE: *//' | tr -d '\r')
[ -n "$items" ] || exit 0
list=$(printf '%s\n' "$items" | sed 's/^/- /' | awk 'BEGIN{ORS="\\n"} {print}')
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | sed 's/\\\\n/\\n/g'; }
msg="Ważne todo (docs/znane_problemy.md):\\n$list"
printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s Na początku pierwszej odpowiedzi w tej sesji krótko przypomnij o tych punktach userowi (po polsku), zanim zajmiesz się jego prośbą."}}\n' "$(esc "$msg")" "$(esc "$msg")"
exit 0
