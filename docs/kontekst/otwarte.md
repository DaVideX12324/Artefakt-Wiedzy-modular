# Otwarte sprawy

- **Obiekty**: obejrzeć w eksploratorze map, czy duże grzyby nie są za rzadkie przy ścianach
  (ew. gęstość w `objects_caves.json`).
- **Ekran ładowania pod mapy ręczne**: `level_manager.load_level_direct` → `load_threaded_request` +
  `track_resource_load`, klucz tła = nazwa sceny.
- **Spłaszczanie wybrzuszeń**: user woli bez — ewentualnie `enable_bulge_flatten: false` w `caves.json`
  (nie zmienione; decyzja usera).
- **Ostatni stopień skosu przed płaskim końcem** zostaje narożnikiem 3H (`step_placer`, warunek
  kontynuacji skosu) — przy ścianach innych niż małe filary.
- **Wypustki**: gdy nie da się podnieść, są usuwane — na razie nie wystąpiło; jeśli user woli usuwanie
  zamiast podnoszenia, zmiana w `ShortLedgeRaisePass`.
- **`RigidBody2D` w `enemy.tscn`** (węzeł `Node2D`) — do decyzji usera.
- **Tutorial**: instancje wrogów z `collision_mask = 5` (bez kolizji między wrogami) — do decyzji.
- `docs/znane_problemy.md` — reszta zgłoszeń i historia rozwiązanych.
