# Sesja 2026-10-15/16 (Opus): drużyna, AGI, szyk, paski, opcje — handoff

Stan na koniec sesji. Kod: CienMgly **`main`** (merge `druzyna-balans` -> `main`, commit `9a764ec0`, polecenie usera),
host `main`. Dalej pracować na `main` CienMgly; gałąź `druzyna-balans` zostaje tylko jako historia.

## Zrobione (wszystko wypchnięte)

### Drużyna i walka
- **Towarzysze MVP:** Łotrzyk / Mag / Kapłan (Pixel Crawler), rekrutacja przez NPC z zadaniem (`scenes/npc/companion_npc.tscn`,
  `dialog_box.tscn`, trzech NPC w `town.tscn`), XP per członek (nieprzytomny 50 %), towarzysze za liderem na mapie
  (`scripts/player/party_followers.gd`), cała drużyna w walce, karta „Drużyna” w dev menu. Szczegóły: `druzyna_szkic.md`.
- **Runda wg AGI** (decyzja usera „zależne od AGI”): każdy przytomny (drużyna + wrogowie) działa raz na rundę, kolejka
  wg AGI + losowo 0..AGI/4 (`quiz_combat_controller.gd`: `_start_round` / `_roll_turn_order` / `_next_turn` /
  `_start_member_turn` / `_enemy_act`). Członek dostaje komendy w swoim ruchu (Esc -> Walcz / Uciekaj), Obrona per
  członek (`_guard`) do jego następnego ruchu. Opis: `walka.md`.
- **AGI jako statystyka:** `HeroData.base_agi` / `agi_per_level` (Bohater 15 +1, Łotrzyk 21 +1,6, Mag 13 +0,9, Kapłan
  12 +0,9), `PlayerStats.STATS` z "agi", `ItemData.agi_bonus`, `StatusData.agi_mult`, statusy `agi_up` / `agi_down`,
  `agility` wrogów (z poziomu jak bohater wzorcowy, `QuizRpgEnemyStats`), Wspólne Tempo daje AGI w górę, AGI w menu
  pauzy (Status 5 kolumn) i w Skanie.
- **Szyk** (decyzja usera: lider i kolejność wg gracza, nikogo nie da się usunąć): menu pauzy „Szyk” (dwie postacie ->
  zamiana). `party[0]` = lider (grafika na węźle gracza, cel ataków „w lidera”). Bohater na dowolnym miejscu:
  `PlayerStats.hero_index()` / `is_hero()` / `member_hp()` / `swap_members()`; pola hp / level / xp / player_name
  lustrzane do bohatera. Przedmiot w walce działa na postać, która go używa. **Do potwierdzenia przez usera:** czy szyk
  ma przejść do menu Status zamiast osobnej pozycji — nie zmieniać bez potwierdzenia.
- **Bohater** w grafice Knight z `royal_crew` (`resources/heroes/frames/bohater_frames.tres`, też w `player.tscn`, offset (1, -24)).
- **Y Sort na `PartyFollowers`** (`game.tscn` + wymuszane w `party_followers.gd`) — wcześniej ściany ucinały głowy towarzyszy.

### UI
- **Paski w walce:** napisy HP/SP/TP nad paskiem (`Line` z `z_index = 1`), odstęp kolumny `-10`.
- **Paski jednakowej grubości** we wszystkich 10 stylach jak „Pas, dwustronny”: tekstury `resources/ui/skins/bars/*`
  przerobione na 7 rzędów (obrys + 5 wypełnienia + obrys), wszystkie style `bar_scale = 2` (14 px).
- **Odstęp od tekstu liczony od środka paska:** `QuizBar` ma wysokość samego wypełnienia (stała motywu `bar_outline`,
  domyślnie 1 rząd), obrys rysowany poza węzłem — jak ramka gładkiego paska.
- **Opcje -> Motyw:** siatka kafelków z podglądem stylów pasków zamiast listy (`scenes/ui/bar_style_cell.tscn`,
  `bar_style_picker.tscn/.gd`, `module_root.create_bar_style_picker`, `QuizTheme.bar_preview_theme`, stała `bar_plain`
  dla gładkiego stylu). Okno opcji hosta wstawia siatkę, gdy moduł ją ma (kopia w `_host` zsynchronizowana).
- **Opcje -> Ekran:** V-Sync (przełącznik) + limit FPS przy wyłączonym V-Sync: suwak 0–360 co 10 (0 = bez limitu) i pole
  wpisu do 1000 (1–9 -> 10). `WindowService.vsync_enabled` / `max_fps` / `apply_frame_pacing` / `clamp_fps`, zapis
  `[display] vsync, max_fps`. Host + kopia `_host`.

### Inne
- Optymalizacja generowania (sesja wcześniej): `archiwum/plan_przyspieszenie_generowania.md` „Sesja 2026-10-16”.
- Point and click zapisany jako dodatkowy feature, niski priorytet (`game_design.md`, Otwarte zadania -> Mechaniczne).

## Ważne pułapki
- **Plik ustawień usera** `%APPDATA%/Godot/app_userdata/Artefakt Wiedzy Modular/artefakt_wiedzy_settings.cfg` jest
  wspólny dla gry i testów. 2026-10-16 skrypt z `SettingsService.set_module` w `_initialize` (przed `_ready` autoloadów)
  nadpisał go pustym configiem — odtworzono motyw / opcje walki / okno, **stracone: głośności, klawisze, język,
  skalowanie UI** (user ustawi ponownie). Testy zmieniające ustawienia: kopia pliku przed i przywrócenie po
  (`tests/check_vsync_options.gd`, `tests/shot_options_bars.gd` tak robią).
- Testy z kolejką AGI: wróg może ruszyć pierwszy i działać w tle — w testach ustawiać wrogowi `agility = 1`
  (np. `check_enemy_skills.gd`, `shot_bar_styles.gd`).
- Okno opcji to scena hosta: zmiany w `scripts/ui/options_menu.gd`, `scenes/ui/options_menu.tscn`,
  `autoloads/services/*.gd` robić też w kopii `modules/quiz_rpg/_host/...` (scena różni się tylko ścieżką skryptu).

## Grafika postaci (otwarte)
- Pixel Crawler: postacie royal crew / NPC **nie mają rąk**; `Weapons/Hands/Hands.png` to same lewitujące dłonie
  (bez przedramion), `Weapons/Wood|Bone` — ikony broni; `Body_A` — gołe ciało z rękami (warstwy Corpo / Braços / Cabeça),
  ubrania tylko w płatnej wersji. Wniosek usera: **szuka innych sprite'ów postaci.** Wymagania podane userowi: klatki
  ~64×64 (postać ~30 px), widok 3/4, min. idle / chód / trafienie / śmierć (+ atak), gruby ciemny obrys jak PC, PNG z równymi
  klatkami albo .aseprite, licencja do gry. Po dostarczeniu: pocięcie na SpriteFrames i podpięcie (bohater / towarzysze).

## Otwarte do decyzji usera
1. Imiona i charakter towarzyszy; skille klasowe (dziś pożyczone z puli bohatera).
2. Szyk w menu Status zamiast osobnej pozycji (czeka na potwierdzenie).
3. Kolizja ścian dopasowana do dawnego niskiego Soldiera — przy dolnej ścianie bohater wchodzi prawie kafel za krawędź.

## Następne kroki (propozycja, kolejność)
1. Osada w grze: wejścia / wyjścia w `level_manager` (jaskinia -> osada -> ścieki), kolizje klifów, nawigacja —
   bez tego NPC rekrutacji są poza normalną grą.
2. Usługi w osadzie: sklep, kowal (ulepszanie broni), NPC umiejętności (żetony lv 5/10/15).
3. Tła walki 16:9 na cały ekran; generator obiektów F5; skalowanie walki (HP wrogów / obrażenia, krzywe do lv 100).
4. AGI: unik / ucieczka z AGI, umiejętności „zawsze ostatnie” (Marsz, Usypiająca Melodia).
5. Testy z błędami sprzed zmian: `check_start_safety` (4), `check_pause_lists` (3, nieaktualna lista skilli),
   `check_combat_lists` (1).

## Testy lokalne (tests/, poza gitem) dodane w tej sesji
`check_party_formation` (okno), `check_party_combat` (AGI + kolejka), `check_vsync_options` (okno, kopia ustawień),
`shot_bar_styles` (render 10 stylów), `shot_options_bars` (siatka w opcjach, kopia ustawień), `shot_hero_ysort`.
