# Wrogowie

- **Zasięg wykrywania** (028bafc): kształt `DetectionArea` w `enemy.tscn` jest `resource_local_to_scene`,
  setter `detection_radius` od razu zmienia promień (widać przy Visible Collision Shapes, także
  ze zdalnego inspektora). Wcześniej kształt był wspólny dla wszystkich instancji.
- `enemy_data` (jeśli przypisane) nadpisuje `detection_radius` i inne staty z inspektora
  (np. Enemy5 w `tutorial_area.tscn` — pusty `enemy_data` → zasięg 150).
- **Dziedziczenie**: wszystkie sceny wrogów dziedziczą po `enemy.tscn` — nie zmieniać; zmiany wspólne
  w bazie. Kod `@tool` w bazie nie działa w edytorze dla pochodnych bez `@tool`.
- **Nie zbijają się w punkt**, bo kolidują fizycznie (maska 39 = Player + Enemies + Ground + Objects,
  `move_and_slide`); RVO wyłączone. W `tutorial_area.tscn` instancje mają `collision_mask = 5` (bez Enemies).
- **Podejrzany węzeł**: `Node2D` w `enemy.tscn` to `RigidBody2D` (warstwa/maska 1 = Player) z grawitacją —
  spada ~488 px/s spod wroga. Z commitu usera f5ef8d0; do decyzji usera, czy usunąć.
- Wróg poza navmeshem wraca do nav area — zamierzone.
