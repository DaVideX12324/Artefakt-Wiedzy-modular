# Brief dla Antigravity: poprawa i rozbudowa quizów

Godot 4.7, host „Artefakt Wiedzy”. Zestawy pytań: `resources/quizzes/*.json` (źródło). Kopie dla Cienia Mgły
(`modules/quiz_rpg/resources/quizzes/`) i BitBombera (`modules/BitBomber/resources/quizzes/`) — po zmianach w hoście
skopiuj zmienione pliki 1:1 do obu modułów (oba to osobne submoduły git: commit + push w nich, potem wskaźnik w hoście).

## Zadanie
1. **Poprawa treści** we wszystkich zestawach: błędy merytoryczne, literówki, dwuznaczne pytania, odpowiedzi, z których
   więcej niż jedna jest poprawna, zła wartość `correct_index`. Nie zmieniaj `id` istniejących pytań.
2. **Nowe pytania**: każdy zestaw do min. 40 pytań (informatyka ma już 70 — tylko poprawa). Rozkład trudności 1–5
   mniej więcej równy (1–2 szkoła podstawowa, 3–5 liceum, jak w `description`). Mieszaj typy:
   `multiple_choice`, `true_false`, `fill_text`, `fill_tiles`, `matching` — pola dokładnie jak w istniejących pytaniach
   tego typu (wzór też w `resources/data/question_set_template.json`, opis w `scripts/core/question_bank.gd`).
3. Nowe `id`: kolejne numery z prefiksem typu (np. `mc_017`, `tf_005`) — unikalne w pliku.

## Zasady
- Tylko pliki JSON quizów — żadnych zmian w kodzie.
- Po polsku (poza `jezyk_angielski`), poprawna polszczyzna, bez emoji.
- Kodowanie UTF-8, końce linii LF, wcięcia 2 spacje jak teraz; każdy plik musi się parsować (`python -m json.tool`).
- Odpowiedzi w `multiple_choice`: 4, podobnej długości, poprawna na losowej pozycji.
- Test: w grze Opcje → Pytania → zestaw się wczytuje, licznik pytań się zgadza.
- Commit osobno per zestaw, opis po polsku.
