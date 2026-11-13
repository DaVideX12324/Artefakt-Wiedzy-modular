# Dokumentacja projektu „Artefakt Wiedzy” / „Cień Mgły”

Główny indeks dokumentacji projektowej, architektonicznej i roboczej w katalogu `docs/`.

> **Zasady organizacji dokumentacji:**
> - **Pojedyncze źródło prawdy dla błędów i zadań:** [`docs/znane_problemy.md`](znane_problemy.md) — zawiera priorytety `⚠ WAŻNE:` (odczytywane przez hook startowy Claude Code), sekcje „Do zrobienia”, „Do sprawdzenia w grze”, „Pułapki konfiguracji” i „Rozwiązane”.
> - **Materiały robocze** (handoffy sesji, notatki kontekstowe, plany, szkice, briefy, ewaluacja, archiwum) są w prywatnym repozytorium notatek — nie ma ich w tym repo.
> - **Submoduły:** kod gier leży w repo modułów (`modules/BitBomber`, `modules/quiz_rpg` = Cień Mgły), a dokumentacja Cienia Mgły — w tym katalogu hosta. README modułów są w ich repo (zmiana = commit w repo modułu + nowy wskaźnik submodułu w hoście).

---

## 1. Zasady i stan prac

| Plik | Opis zawartości | Status |
|---|---|---|
| [znane_problemy.md](znane_problemy.md) | Jedyne źródło prawdy dla todo i problemów: priorytety `⚠ WAŻNE:` (hook), Do zrobienia, Do sprawdzenia w grze, Pułapki konfiguracji. Wpisy ZROBIONE → archiwum (notatki prywatne). | `W TOKU` |
| [wersjonowanie.md](wersjonowanie.md) | Numery wersji i etapy (Alpha / Beta / RC) hosta i modułów, gdzie są zapisane, plan wydań 0.9 / 1.0 / 2.0, changelogi, kroki wydania. Aktualnie: Artefakt Wiedzy i Cień Mgły `0.8.0-alpha`, BitBomber `0.9.0-beta`. | `ZROBIONE` |
| [module_contract.md](module_contract.md) | Kontrakt modułowy gry, izolacja modułów, konwencje ścieżek (`QuizRpgPaths`) i synchronizacja zasobów hosta. | `ZROBIONE` |

---

## 2. Projekt gry i mechaniki (dokumenty systemowe)

| Plik | Opis zawartości | Status |
|---|---|---|
| [game_design.md](game_design.md) | Główny dokument projektowy gry Cień Mgły (fabuła i zakończenia, kolejność 12 stref — docelowo ok. 15 map, mechaniki, progresja, pętla rozgrywki). | `W TOKU` |
