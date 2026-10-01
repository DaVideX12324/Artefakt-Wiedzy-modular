#!/usr/bin/env sh
# SessionStart: przypomnienia dla usera, dopóki sprawa nie jest załatwiona (każde sprawdza stan repo
# i znika samo). Wyjście: JSON z additionalContext (dla Claude'a) i systemMessage (widoczne w UI).
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null || exit 0

# 1. Pliki .import (UID-y assetów) poza repo — patrz docs/znane_problemy.md, wpis o modularności.
tracked=$(git ls-files '*.import' 2>/dev/null | wc -l | tr -d ' ')
if grep -qxF '*.import' .gitignore 2>/dev/null || [ "${tracked:-0}" -lt 50 ]; then
	msg="PRZYPOMNIENIE: pliki .import nie są w repo (\`*.import\` w .gitignore, śledzonych: ${tracked}). Trzymają UID-y assetów — bez nich każdy klon ma inne UID-y i odwołania uid:// do obrazków/fontów/dźwięków nie działają. Do zrobienia przez autora na jego komputerze: usunąć \`*.import\` z .gitignore i zacommitować pliki .import (nie z sesji w chmurze — tam UID-y są świeże i losowe). Szczegóły: docs/znane_problemy.md, wpis o modularności assetów."
	printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s Na początku pierwszej odpowiedzi w tej sesji krótko przypomnij o tym userowi (po polsku), zanim zajmiesz się jego prośbą."}}\n' \
		"$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')" "$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')"
fi
exit 0
