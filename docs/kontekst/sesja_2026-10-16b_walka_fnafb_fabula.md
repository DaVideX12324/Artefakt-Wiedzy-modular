# Sesja 2026-10-16 (Opus, część 2): skala UI, walka jak w FNaFB, dołączanie w walce, fabuła finału — handoff

Kontynuacja [sesja_2026-10-16_druzyna_ui.md](sesja_2026-10-16_druzyna_ui.md). Kod: CienMgly `main`, host `main`, wszystko
wypchnięte. **Model rundy z tamtego pliku („komendy w swoim ruchu”) jest nieaktualny** — patrz niżej.
Na laptopie: `git pull` + `git submodule update`.

## Zrobione (commity CienMgly / host)

### UI
- **Wąskie okno** (`d0693325` / `8fe3c21`): `compact_min_viewport_width = 1600` — poniżej pas walki na całą szerokość.
- **UiLayerScale** (`cc598955`, `1346d5d8` / `bdc75cc`): `scripts/ui/ui_layer_scale.gd` skaluje całe CanvasLayer-y UI wg
  `UIScaleService.scale_factor` (walka, zagadki, quiz overlay, śmierć, dialog, HUD, ładowanie, menu, pauza, prompty, loot);
  stare `_ui_px` / `_ui_scale_px` usunięte. Kafelki zawijają się po słowach.
- **Kursor wiersza drużyny** szerszy o margines stylu (`1451f761` / `5b31016`).
- **Ręczna skala UI** (`d4a91771` / `d58a599`, `63ded9c4` / `17cef69`): za duże skale wyszarzone w Opcjach
  (`UIScaleService.max_mode_for_height`, tabela MIN_SCREEN_H; ×1,5 dopiero > 1080 px), zmiana rozdzielczości / trybu / monitora
  ustawia największą możliwą. Próba poluzowania progów cofnięta (user: progi chronią przed wyjściem UI poza ekran).

### Walka (`scripts/quiz/quiz_combat_controller.gd`)
- Log: „X trafia! -N HP” (`3a2ff7ef`).
- **Pole widzenia wrogów** 120° (`vision_angle_deg`), sytuacja spotkania `scripts/enemies/encounter_situation.gd`
  (NORMAL / UNSEEN / FROM_BEHIND); **przewaga** 0,75 × AGI drużyny / AGI wrogów, **zaskoczenie** 0,6 × odwrotnie, bossy bez
  (`36871b5a`).
- **Runda jak w RPG Makerze / FNaFB** (`287a9f4b`): Walcz / Uciekaj → komendy każdej postaci po kolei (Esc = poprzednia),
  wybór tylko do `_plans`, potem `_execute_round` wg prędkości = AGI + rand(0..4 + AGI/4) + speed akcji; pytanie quizu i koszt
  w ruchu postaci. Nieudana ucieczka = drużyna traci rundę.
- **Ucieczka z pytaniem** (`6d39fc32`): dobra odpowiedź 0,8, zła 0,8 − `flee_wrong_penalty` (0,3).
- **Zaskoczenie**: drużyna traci 1. rundę, jak we FNaFB (`e0a2800d`).
- **TP jak we FNaFB i prędkość umiejętności** (`e8e6d081`): start 10–20 TP; `tp_gain` za trafienie (atak / Obrona 5, serie 5,
  skille za TP 0, reszta 1); 50 × obrażenia / maks. HP trafionej postaci; `tp_charge_rate` / `tp_regen` w HeroData;
  `speed` w SkillBase (Obrona +2000, leczenie / wzmocnienia +1000, szybkie +25, wolne −25, ult −2000); wrogowie planują skill
  na początku rundy (`planned_skill`). Pola .tres muszą być **pod** `script = ExtResource` (inaczej pomijane).
- **Dołączanie w trakcie walki** (`a3fc347c` / `77fac49`): `PlayerStats.recruit` w walce (zdarzenie, zadanie, dev menu
  „Dołącz”) → sygnał `member_recruited` → `_on_member_recruited`: wiersz w oknie drużyny, TP jak na start, komendy od
  następnej rundy (jak „Change Party Member: Add” w RPG Makerze). Decyzja usera: **bez flag** w danych wroga / skilla.
  Wymóg fazy 1 finału (sojusznicy wracają w walce).
- **Nowe nazwy umiejętności pod klasy** (Gemini, przejrzane; `b3e2a9d8` / `8b1f8ce`): nazwy i opisy PL / EN, efekty bez zmian.

### Spawny
- Wrogowie dopiero za pierwszym pokojem (`380f5b50` / `d646300`): `SpawnPlanner._entrance_area`. Wąski pasek navmesh
  („grzyb chodzi tylko góra–dół”) **nie** naprawiony.

### Testy (lokalne, `tests/` poza gitem CienMgly)
`check_initiative`, `check_party_combat`, `check_flee_quiz`, `check_tp_speed` (naprawiony: typowane `Array[Dictionary]` przy
`ui.set("_plans", ...)`), `check_join_in_battle` (nowy) — 0 FAIL. Stare: `check_combat_lists` 1 FAIL („opis drugiej pozycji”),
`check_start_safety` 4, `check_pause_lists` 3. Testy nie mogą zapisywać `artefakt_wiedzy_settings.cfg` — kopia przed, cmp po.

## FNaFB — dane referencyjne

- **FNaFB2** (VX Ace): `E:/Dawid/Desktop/Gry/Five Nights at Fuckboy's 2 (Gamejolt Version)/Data` (starszy build). Czytnik
  Marshal w Pythonie (obiekty → dict) był w scratchpadzie sesji (`fn/marshal_rv.py`, `troops_rv.py`, `maps_battle.py`).
- BB faza 1 = grupa 83: start samym Toy Freddym, Toye dołączają w turach 5 / 10 / 15 (tylko zwerbowani, bez TP; CC: 3 / 7 / 11
  i +15 TP). BB 150 000 HP. Faza 2 = grupa 85 (B.B. Giygas): odporność na śmierć (nie ginie przy 0 HP), 100 HP w starym buildzie,
  999 999 po aktualizacji tylko dla paska; w 5. turze Mangle uczy się Bite of 87 (100 TP) — kończy walkę.
- Remaster CC: `F:/Games/FNaFb-CC/www/data` (JSON); FNaFB1: `H:/Pobrane/fnafb1/Data`.

## Fabuła finału (szkic, nie w `game_design.md`)

- [fabula_krag_i_zakonczenia_szkic.md](fabula_krag_i_zakonczenia_szkic.md) — szkic z PR #12 (chmurowy Claude, gałąź
  `ccr-744b0fc4-1vk0mk`, sprawdzone: zgodna z `main`) + decyzje usera z 2026-10-16 (pkt 6, 11, 12).
- [fabula_szkic_dopiski_i_konflikty.md](fabula_szkic_dopiski_i_konflikty.md) — co dopisano, konflikty szkicu z `game_design.md`
  (do rozwiązania przy przenoszeniu), propozycje Gemini (przyjęte).
- Najważniejsze decyzje 2026-10-16: Faza 2 (True) — absurdalna pula HP, pierwsze użycie 10. poziomu jak Bite of 87 → Faza 3;
  7 użyć 10. poziomu, krzywa 35% → optimum 25% (4.) → 96% (7., finał) → 150% (8., niemożliwe); safelock HP jednorazowo na
  otwarcie Fazy 3 („but it refused”); bez pomocy Strażnika, bez zapasu przed walką, bez cooldownu; w True prawdziwy Strażnik
  przeżywa, w Good umiera; 10. poziom = jedna umiejętność bohatera, 4 klasy czarów na 9. poziomie; 4 relikwie = bronie klas;
  zapasowy krąg **nie** w Bibliotece (decyzja po zbudowaniu miasta w pełnej skali).
- `docs/prototypy/` usunięte przez usera (ścieki gotowe), odwołania oznaczone.

## Otwarte

- Fabuła: przebieg Good (Faza 2 jako zwykła walka — szczegóły), miejsce zapasowego kręgu, złoto w NG+, ile mikstur zjada
  Faza 1, limit mikstur procentowych SP w finale (~3750 SP deficytu z krzywej), przeniesienie szkicu do `game_design.md`.
- Finał w kodzie: zabranie towarzyszy na start fazy 1, umiejętność „Wzmocnienie tarczy” (100 TP → `recruit` kolejnego),
  fazy bossa, umiejętność 10. poziomu z krzywą kosztów.
- Decyzja usera: wysokie okno pytania zasłania potwory (podjazd pola tylko gdy trzeba vs zostawić).
- Wcześniejsze: zapis map na dysk (`docs/plan_zapis_map.md`), `distance_to` w korytarzach ścieków, zacięcie pierwszej klatki
  po generowaniu, scroll drużyny > 4 w pauzie, szyk w Status (bez zmian bez potwierdzenia), sprite'y, osada / sklep / NPC,
  tła 16:9, generator obiektów.
