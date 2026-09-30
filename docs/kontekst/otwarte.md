# Otwarte sprawy

- **Nisze przy ścianie 3H**: bez narożników wewnętrznych na górze (przejście) i bez sekretnego pokoju —
  opis w `docs/znane_problemy.md`.
- **Tryb walki**: interfejs, wrogowie za nisko (kontroler nadpisuje ustawienia sceny wartościami z tła),
  marginesy pola walki per tło jako `.tres`, freeze po pokonaniu potwora, losowe spotkania jak w JRPG —
  opis w `docs/znane_problemy.md` („Do zrobienia”).
- **Każda nisza out z losową zawartością, sekretne pokoje, klucze i wytrychy (quiz wg tieru skrzyni)** — pomysł
  usera, opis w `docs/znane_problemy.md` („Do zrobienia”).
- **Obiekty**: obejrzeć w eksploratorze map, czy duże grzyby nie są za rzadkie przy ścianach
  (ew. gęstość w `objects_caves.json`).
- **Ekran ładowania pod mapy ręczne**: `level_manager.load_level_direct` → `load_threaded_request` +
  `track_resource_load`, klucz tła = nazwa sceny.
- **Wypustki**: gdy nie da się podnieść, są usuwane — na razie nie wystąpiło; jeśli user woli usuwanie
  zamiast podnoszenia, zmiana w `ShortLedgeRaisePass`.
- **`RigidBody2D` w `enemy.tscn`** (węzeł `Node2D`) — do decyzji usera.
- **Tutorial**: instancje wrogów z `collision_mask = 5` (bez kolizji między wrogami) — do decyzji.
- `docs/znane_problemy.md` — reszta zgłoszeń i historia rozwiązanych.
