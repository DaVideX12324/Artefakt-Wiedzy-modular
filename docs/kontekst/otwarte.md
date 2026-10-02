# Otwarte sprawy

- **Tła walki 16:9** — prompty gotowe (`battle_backgrounds/*_prompts.md`, `correction_prompts.md`); gdy user
  wrzuci poprawione grafiki: tło na cały ekran w `folder_battle_background.gd` + przestawić pola walki
  (opis w [walka.md](walka.md)).
- **Sterowanie** — opcje pokazują klawisze per moduł, ale bez zmiany klawiszy (rebind z zapisem
  `SettingsService.set_module`).
- **Menu Esc** — punkty i seria (dawniej w HUD) jeszcze niepokazane.
- **Tekst walki 36 px** — obserwować, czy litery nie wychodzą nierówne (`docs/znane_problemy.md`).
- Do sprawdzenia przez usera w grze: motywy / style pasków w menu Esc, tryb „UI walki na szerokość
  treści”, muzyka menu po wyjściu z gry.

- **Edytor pytań — zrobiony** (menu główne -> Pytania, Opcje -> Pytania; `docs/kontekst/pytania.md`). Do
  sprawdzenia przez usera w grze: okna plików (import / eksport), przeciąganie pliku na okno.
- **Nisze przy ścianie 3H**: bez narożników wewnętrznych na górze (przejście) i bez sekretnego pokoju —
  opis w `docs/znane_problemy.md`.
- **Tryb walki**: losowe spotkania jak w JRPG; okna Umiejętności / Przedmioty w stylu RPG Makera — opis w
  `docs/znane_problemy.md` („Do zrobienia”).
- **Każda nisza out z losową zawartością, sekretne pokoje, klucze i wytrychy (quiz wg tieru skrzyni)** — pomysł
  usera, opis w `docs/znane_problemy.md` („Do zrobienia”).
- **Obiekty**: obejrzeć w eksploratorze map, czy duże grzyby nie są za rzadkie przy ścianach
  (ew. gęstość w `objects_caves.json`).
- **Wypustki**: gdy nie da się podnieść, są usuwane — na razie nie wystąpiło; jeśli user woli usuwanie
  zamiast podnoszenia, zmiana w `ShortLedgeRaisePass`.
- **`RigidBody2D` w `enemy.tscn`** (węzeł `Node2D`) — do decyzji usera.
- **Tutorial**: instancje wrogów z `collision_mask = 5` (bez kolizji między wrogami) — do decyzji.
- `docs/znane_problemy.md` — reszta zgłoszeń i historia rozwiązanych.
