# Brief dla Gemini: uproszczenie dużych dokumentów w `docs/`

Zasady: czytaj pliki z dysku przed edycją; nie zmieniaj kodu ani zasobów gry; nie usuwaj informacji bez śladu — to, co
wycinasz, przenieś do `docs/archiwum/` (nowy plik z datą w nazwie); po polsku, krótko, bez lania wody. Na koniec
napisz, co zmieniłeś (lista plików + liczba linii przed / po).

## 1. `docs/znane_problemy.md` (~500 linii)
- Sekcję „Rozwiązane” i wpisy oznaczone ZROBIONE / ✅ przenieś do `docs/archiwum/znane_problemy_rozwiazane_2026-10-29.md`.
- W pliku zostaw tylko otwarte sprawy: nagłówki `### ⚠ WAŻNE:` (czyta je hook — nie zmieniaj ich formatu), „Do zrobienia”,
  „Do sprawdzenia w grze”, „Pułapki konfiguracji”. Długie wpisy z historią „Aktualizacja …” skróć do bieżącego stanu
  (1–3 linie) — historię do archiwum.
- Cel: ≤ 200 linii.

## 2. `docs/universal_interior_generator_refactor.md` (~4350 linii)
- Porównaj z kodem (`modules/quiz_rpg/scripts/generation/`) i z `docs/plan_generator_sciekow.md`: co zrobione, co nie.
- Zostaw w pliku krótkie podsumowanie (≤ 150 linii): architektura etapów, stan faz (zrobione / zostało), odnośniki.
  Całą resztę przenieś do `docs/archiwum/universal_interior_generator_refactor_pelny.md`.

## 3. `docs/kontekst/zadania_wg_trudnosci.md`
- Usuń punkty ✅ i ✖ (przenieś do archiwum jako `zadania_zrobione_2026-10-29.md`); zostaw otwarte z numeracją bez zmian.

## 4. Indeksy
- Zaktualizuj `docs/README.md` i `docs/kontekst/README.md` (nowe pliki archiwum, statusy, linie opisów krótsze).
- Sprawdź, że żaden link `](….md)` w `docs/` (poza `archiwum/`) nie jest zepsuty.

Nie commituj — commit zrobi Claude po sprawdzeniu.
