# Otwarte sprawy

- **⚠ WAŻNE — tilesety kolejnych map** (autor): Cemetery, Fairy Forest, Desert, Forge, Dense Forest / zima,
  Library, Garden, Castle — `docs/znane_problemy.md`.
- **Feature — ukryte przejścia między pokojami** (tunel pod voidem) — `docs/znane_problemy.md`.

- **Tła walki 16:9** — prompty gotowe (`battle_backgrounds/*_prompts.md`, `correction_prompts.md`); gdy user
  wrzuci poprawione grafiki: tło na cały ekran w `folder_battle_background.gd` + przestawić pola walki
  (opis w [walka.md](walka.md)).
- **Tekst walki 36 px** — obserwować, czy litery nie wychodzą nierówne (`docs/znane_problemy.md`).
- Do sprawdzenia przez usera w grze: motywy / style pasków w menu Esc, tryb „UI walki na szerokość
  treści”, muzyka menu po wyjściu z gry.

- **Edytor pytań — zrobiony** (menu główne -> Pytania, Opcje -> Pytania; `docs/kontekst/pytania.md`). Do
  sprawdzenia przez usera w grze: okna plików (import / eksport), przeciąganie pliku na okno.
- **Nisze-przejścia** (ściana o głębokości 3 nad niszą): generator gotowy, kafle OUT z szerszym otworem
  (alternatywa 1) są — **user robi wariant kafli RIM z innymi kolizjami jako alternatywę 1** (te same id
  kafli co zwykły szczyt); bez niego szczyt nad przejściem blokuje. Opis w [sciany_i_kafle.md](sciany_i_kafle.md).
  Przejść jest mało (geometria: na 6 mapach 2 miejsca) — user chce częściej; do ustalenia, jak (np. ścianka
  o głębokości 3 za niszą wycinana celowo).
- **Tryb walki**: losowe spotkania jak w JRPG; okna Umiejętności / Przedmioty w stylu RPG Makera — opis w
  `docs/znane_problemy.md` („Do zrobienia”).
- **Każda nisza out z losową zawartością, sekretne pokoje, klucze i wytrychy (quiz wg tieru skrzyni)** — pomysł
  usera, opis w `docs/znane_problemy.md` („Do zrobienia”).
- **Obiekty**: obejrzeć w eksploratorze map, czy duże grzyby nie są za rzadkie przy ścianach
  (ew. gęstość w `objects_caves.json`).
- **Wypustki**: gdy nie da się podnieść, są usuwane — na razie nie wystąpiło; jeśli user woli usuwanie
  zamiast podnoszenia, zmiana w `ShortLedgeRaisePass`.
- `docs/znane_problemy.md` — reszta zgłoszeń i historia rozwiązanych.
