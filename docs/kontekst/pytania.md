# Pytania: zestawy, wybór aktywnych, edytor (stan na 2026-10-02)

- **Dane** — `scripts/core/question_bank.gd` (`QuestionBank`, statyczne):
  - wbudowane `res://resources/quizzes/<id>.json` (tylko odczyt po eksporcie gry),
  - własne `user://quizzes/<id>.json` — import, nowe, edycje wbudowanych (ten sam id przesłania oryginał;
    „Przywróć oryginał” usuwa plik z user://),
  - wybór `user://quiz_selection.json`: `enabled_sets`, `disabled_sets`, `disabled_questions{set: [id]}`;
    globalnie (wszystkie moduły i zapisy). Domyślnie aktywne: `DEFAULT_ACTIVE_SETS` (inf_podst) i własne.
  - walidacja `validate_question` (powód po polsku), import `import_file` (błędne pomijane, brakujące id
    nadawane, raport), eksport, `next_question_id`.
- **Gra** — `QuizService`: źródło `user://quizzes` dla każdego modułu (po wbudowanych), pytania mają
  `set_id`; `get_questions` losuje z puli: przypisany zestaw (quiz_id wroga / drzwi), gdy istnieje i jest
  aktywny, inaczej wszystkie aktywne zestawy (aktywne pytania). Wrogowie mają dziś `ogolne` (68, nie istnieje),
  `informatyka` (4), `matematyka` (2, nie istnieje). Menu deweloperskie (wymuszony zestaw) ma pierwszeństwo.
  `reload_all()` po każdej zmianie (sygnał `questions_changed`).
- **UI**:
  - menu główne hosta -> „Pytania” — `scenes/ui/question_editor.tscn` + `scripts/ui/question_editor.gd`
    (szkielet w scenie, formularze typów budowane w kodzie; import: okno plików albo przeciągnięcie .json),
  - Opcje -> „Pytania” — zaznaczanie zestawów używanych w grze.
- **Testy** (tests/, poza gitem): `diag_question_bank.gd` (headless, logika), `diag_question_editor.gd`
  (okno, 5 typów, zrzuty) — oba odkładają i odtwarzają pliki użytkownika.
