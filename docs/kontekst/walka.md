# Walka: UI, pola walki, podgląd (stan na 2026-10-03)

## UI walki (styl RPG Makera, WYSIWYG)
- Scena `scenes/quiz/quiz_combat_ui.tscn`, kontroler `scripts/quiz/quiz_combat_controller.gd` tylko
  przełącza fazy i tryby dolnego pasa (`Band`: PARTY_COMMAND / ACTOR_COMMAND / STATUS_ONLY; szerokości
  i liczba linii logu jako eksporty). Wysokość dolnego pasa = `BattleWindow.offset_top` w scenie.
- Pytanie i log bitwy u góry (`TopWindow`), komunikaty po bitwie w dolnym pasie (`VictoryLog`),
  tura / seria w rogu (`CornerInfo`) — wzór: zrzuty w `fnafb/`.
- Motyw `resources/ui/quiz_theme.tres` (typy QuizWindow / QuizLog / QuizMenuItem, styl „selected”),
  czcionka Jersey 15 (`resources/ui/jersey15_pixel.res`) w całym quiz_rpg przez `QuizTheme.apply()` —
  rozmiary na siatce 27 px (`QuizTheme.snap`). Oba pliki generuje `tests/build_quiz_theme.gd`.
- Przebieg tury: Walcz / Uciekaj (lewo) → **wybór postaci** — kursor (styl „selected” pod wierszem)
  na liście drużyny w prawym oknie, mysz / strzałki, martwe pomijane → komendy tej postaci
  (`_active_actor_index`: koszty SP/TP, przedmioty) → cel. Esc cofa o krok (komendy → wybór postaci →
  Walcz). Kursory menu prowadzi kontroler — przyciski komend mają `FOCUS_NONE` (fokus Godota zjadał
  strzałki / Enter).
- Quiz (`scripts/shared/quiz/quiz_panel_controller.gd`): nawigacja odpowiedzi wg `MC_Box.columns`
  (w scenie 1 kolumna; wcześniej zakładała 2×2 i strzałka w dół skakała o 2).
- **Asset UI od usera** (tło okien) -> jedno miejsce: `quiz_theme.tres`, typ QuizWindow.
- **Wybór myszą** (aa47eaf, a7c4730): wiersz drużyny trafiany z `event.position`; `PartyVBox` ma
  `mouse_filter = IGNORE` (przepuszcza mysz do wierszy listy celów), zejście ze sprite'a wroga kasuje
  `_hovered_enemy_slot_index` — wcześniej klik na liście działał dopiero po najechaniu na sprite.
- **Kolejność rysowania wrogów** (3dce68d): wg linii stóp — tylny rząd pod przednim.
- **Szerokości okien** (44f69f4): komendy drużyny / postaci `party_command_width` / `actor_command_width`
  = 15 % ekranu (szersze, gdy treść wymaga). Tryb „na szerokość treści” (opcja `ui_combat_compact`,
  1bd9c8e): okno drużyny `compact_party_width` = 50 %, reszta pasa pusta — `_set_band_mode`.
- **Tekst 36 px** (c47d88f): `QuizTheme.COMBAT_FONT_SIZE`, ekran walki ma własną kopię motywu
  (`QuizTheme.combat_theme()`, odświeżaną w `apply_skin`), panel quizu `text_size = 36`
  (`quiz_panel_controller._ts()` — kafelki, odstępy, dopasowanie). 36 to poza siatką 27 px — ryzyko
  w `docs/znane_problemy.md` („Potencjalne problemy”).
- XP dodawane tylko na ekranie walki; po wygranej gracz rusza od razu, 5 s nietykalności
  (`player.grant_encounter_immunity`, miganie). Komunikaty zwycięstwa czekają (Enter pomija) — decyzja usera.

## Wybór tła walki
- `battle_background.gd`: klucz mapy jak folder ekranu ładowania — `get_map_key()` mapy (ProceduralLevel:
  `loading_screen_key` albo biom z typu poziomu: cave / castle / forest), `biome`/`theme`…, nazwa pliku
  sceny mapy ręcznej (`tutorial_area`), na końcu słowa w ścieżce skryptu / nazwie węzła.
- Grafiki z folderu mapy (`folder_battle_background.gd`): `battle_backgrounds/<klucz>/` albo
  `battle_backgrounds/pixel_crawler/<klucz>/`, losowy wariant; `KEY_ALIASES` (forest -> fairy_forest).
  Brak folderu z grafikami = tło w kodzie (`world_map`, `default`). Lista przez
  `ResourceLoader.list_directory` (działa w eksporcie). Wcześniej jaskinie generowane dostawały `default`.

## Pola walki per tło
- Plik `<grafika>_layout.tres` obok grafiki tła (`BattleBackgroundLayout`: `texture`, `fields`);
  generatory teł dają `get_layout_key()`, tło -> `get_layout()` + sygnał `layout_changed`.
- `BattleField`: `quad` (4 narożniki, sortowane: przód-lewy, przód-prawy, tył-prawy, tył-lewy;
  NaN odrzucany), `rows` 1–3, `row_capacity`, `front_scale`, `auto_depth_scale` / `back_scale`.
  Współrzędne w px obszaru bitwy przy 1920 px (`REF_AREA` = 1920×830 nad paskiem 250 px).
- **Wysokość pól** (0a7566e → 72c7b63): przedni rząd wszystkich 13 układów na y = 765 (narożniki przesunięte
  wzdłuż boków trapezu), domyślny quad w `battle_field.gd` też. Cień nad dolnym paskiem UI o połowę
  niższy: `FolderBackground.SHADOW_HEIGHT` = 35 px (`SHADOW_COLOR`). Pasek HP wroga (12 px pod stopami,
  do 16 px wysoki) kończy się na ~793 — tuż nad cieniem (795). Pola niżej = paski w cieniu.
- Rozstawienie: `assign()` losuje rzędy z wolnym miejscem (preferencje „front” / „back” z danych wroga);
  w rzędzie z n wrogami stopy k-tego w (k + 0,5) / n linii rzędu — skrajni nigdy na samym boku pola.
  Skala = `enemy_scale(liczba wrogów)` × skala rzędu.
- 13 plików układu; trapezy z ręczną skalą tyłu 0.82 (wygląd jak przed trapezami). Plik
  `tutorial_area/variant_2_training_layout.tres` edytuje user (nie commitować bez prośby).

## Podgląd / edytor pól: `scenes/tools/battle_layout_preview.tscn` (instrukcja: docs/battle_layout_preview.md)
- Każde pole = `Polygon2D` „FieldN” — przeciąganie narożników, Ctrl+D nowe pole, Delete usuwa;
  zapis pliku 0,6 s po ostatniej zmianie.
- 9b00207: blokada `_syncing` ustawiana PRZED zapisem do pól — wcześniej sygnał `changed` nadpisywał
  wielokąt w trakcie przeciągania i narożniki „eksplodowały” do NaN (user potwierdził, że działa).
- 169e294: `enemy_sprites` (lista grafik rozdawanych po kolei, klatka postoju jak w EnemyBattleDisplay;
  zastąpiło pojedyncze `enemy_frames`), `field_counts` (ilu wrogów na polu, po rzędach od przedniego;
  brak wpisu / -1 = `preview_per_row` w każdym rzędzie, 0 = puste), rysowanie od najdalszych.
  W grze rzędy są losowe — podgląd pokazuje przykładowy podział, ale miejsca i skala jak w grze.
- 9420bb6, 29739f8: podgląd rysuje cień (35 px, przerywana linia) i dolny pasek UI walki (250 px, czerwony
  obrys, „tu nie stawiaj wrogów”) — `_draw_ui_zones`, oraz paski HP pod wrogami (`HP_BAR_OFFSET` 12,
  `HP_BAR_SIZE` 96×16 — najwyższy styl pasków; zmierzone w grze).
- Niesprawdzone w edytorze przez usera: Ctrl+D / Delete, `field_counts`; w grze — klikanie wrogów
  przy wyborze celu po przeniesieniu slotów na `EnemyFieldLayer`.
- Ostrzeżenia „invalid UID” we wrogach, obiektach i kafelkach pustyni — poprawione (e37c940: UID-y
  z plików `.import`, które są już w repo).

## Motywy UI (1c368e2; menu Esc 3230daa — [menu_i_opcje.md](menu_i_opcje.md))
- Opcje hosta -> zakładka „Motyw”: lista z `get_ui_skins()` aktywnego modułu (module_root -> `QuizTheme.SKINS`),
  suwak jasności 50–150 %. Zapis: `SettingsService.set_module("quiz_rpg", "ui_skin" / "ui_brightness")`,
  zmiana na żywo przez sygnał `module_setting_changed`.
- `QuizTheme.apply_skin(id, jasność)`: `resources/ui/skins/<id>.tres` nadpisuje style typów QuizWindow /
  QuizLog / QuizMenuItem / QuizBar* w motywie modułu (w pamięci; „klasyczny” = sam quiz_theme.tres).
  Jasność mnoży kolor okien i zaznaczenia (paski bez zmian).
  Zmiana jasności (suwak) idzie przez `QuizTheme.set_brightness`: kopie stylów zmieniane w miejscu z
  zablokowanym sygnałem `changed` + `queue_redraw` kontrolek — bez przebudowy motywu (ta cięła grę; 2026-10-04).
  Suwak zapisuje plik po 0,4 s spokoju. Test: `diag_brightness` (piksele tekstu / pasków bez zmian, koszt).
  Menu Esc przygasza wiersze tylko podczas wybierania (bez wyboru — pełne kolory).
- Paski walki mają warianty motywu QuizBarLP / SP / TP / Timer / Enemy (dawniej nadpisania w scenie).
- Motywy st_* (granatowy / jasny × zaokrąglony / kwadratowy × płaski / z głębią) buduje
  `tests/build_ui_skins.gd` z wycinków w `resources/ui/skins/st/` (źródło: assets/UI/UI Assets pack_v.1_st,
  paski: Pixel UI pack 3). Nowy motyw: plik `.tres` + wpis w `QuizTheme.SKINS`.
- Uwaga: `tests/build_quiz_theme.gd` (stary generator quiz_theme.tres) nie zna typów QuizBar* — po jego
  użyciu trzeba ponownie puścić build_ui_skins.gd (bez SKIP_BARS nie zadziała, bo scena nie ma już nadpisań —
  wtedy style pasków brać z historii gita).
- Licencje paczek `_st` i Pixel UI pack 3 — do sprawdzenia (napisy końcowe).

## Style pasków (5e0c9bb)
- Opcje -> Motyw -> „Styl paskow” (klucz ui_bar_style, `QuizTheme.BAR_STYLES`), niezależnie od motywu okien;
  warstwy: styl pasków > motyw okien > quiz_theme.tres. Motywy st_* nie mają już własnych pasków.
- `QuizBar` (scripts/ui/quiz_bar.gd, ProgressBar ze skryptem na 23 paskach walki): ikony motywu
  `bar_under` / `bar_progress` -> shader (środek rozciągany albo powtarzany przy `bar_tile`, końcówki stałe,
  płynne przycinanie wiersz po wierszu); bez ikon — zwykłe style (klasyczne gradienty).
- Tekstury: resources/ui/skins/bars/<styl>_<kolor>_full|empty.png z assets/UI/Pixel UI pack 3/Full.png
  (+ 05.png); style budowane przez tests/build_ui_skins.gd (BAR_STYLES = kolory, BAR_TILED = modułowe).
- Licencja Pixel UI pack 3 (bdragon1727): niekomercyjnie za darmo, komercyjnie — wpłata dowolnej kwoty.
- 099fd2a: „pas” jednostronny i dwustronny (`pas2` — cały pasek z paczki; od d76eacf ubywa od prawej do lewej jak inne, wcześniej od środka
  w obie strony), cienkie paski ×3 (wyższe klasyczne), klasyczne paski w motywach pikselowych dostają ramkę.
- Pułapki `QuizBar`: w shaderze `COLOR` zawiera już teksturę — kolor wierzchołka przez `varying`; natywny
  ProgressBar ignoruje `_get_minimum_size` skryptu — wysokość przez marginesy `StyleBoxEmpty`; blokada
  `_switching` przed rekurencją THEME_CHANGED; `_refresh_mode` liczy wysokość przy każdej zmianie stylu.
- `assets/UI/` (surowe paczki) nie idzie do repo — licencja Pixel UI pack 3 zabrania redystrybucji;
  w repo tylko wycinki w `resources/ui/skins/`. `tests/build_ui_skins.gd`: `SKIP_BARS=1` = bez pasków.

## Tła walki: kadr 16:9 (zrealizowane 2026-10-06, commit `deb8866`)
- **Pełnoekranowe tło 1920×1080**: Węzeł `Background` w `quiz_combat_ui.tscn` przeniesiony bezpośrednio do `Root`
  (za `DimOverlay`, przed `Battlefield` i `BattleWindow`), rozciągnięty na całe okno (`anchors_preset = 15`).
  Grafika 16:9 nie jest już obcinana z góry i dołu o 125 px, lecz pokrywa w 100% cały ekran 1920×1080.
- **Przejrzysty pas dolny w trybie kompaktowym**: Styl panelu `BattleWindow` zmieniony na `StyleBoxEmpty`.
  W trybie „na szerokość treści” (`ui_combat_compact`) po bokach wyśrodkowanych okien widoczna jest posadzka
  z tła zamiast czarnej pustki.
- **Cień nad UI w grze i w edytorze**: `folder_battle_background.gd` rysuje cień na `y = 795` (35 px nad dolnym
  paskiem UI 250 px, `y = 830`), identycznie jak w edytorze podglądu `battle_layout_preview.gd`.
- **Podgląd / edytor pól (`battle_layout_preview.gd`)**: Rysuje pełny kadr 1920×1080 (bez ucinania), a dolny pasek
  250 px jest półprzezroczysty z czerwoną ramką informacyjną, pozwalając na precyzyjne ustawianie pól walki na widocznej posadzce.
- Prompty w `battle_backgrounds/pixel_crawler_prompts.md` i `tutorial_area_prompts.md` przepisane na
  cały ekran 16:9: górne ~10 % spokojne, horyzont ~40–45 %, wrogowie 50–70 %, dolne ~25 % pod UI
  z gładką podłogą. `correction_prompts.md` — prompty korekcyjne dla 12 istniejących grafik.

## Model Umiejętności i Obrażeń (FNaFB / RPG Maker)
Wprowadzony i zintegrowany model umiejętności bazuje na strukturze z FNaFB / RPG Makera:
- Klasy bazowe: `QuizRpgSkillBase` (`scripts/skills/skill_base.gd`), dziedziczone przez:
  - `QuizRpgSkillData` (`scripts/skills/skill_data.gd`) – umiejętności drużyny (koszty SP/TP, poziom nauki `learn_level`, okazje `occasion`, combo).
  - `QuizRpgEnemySkill` (`scripts/skills/enemy_skill.gd`) – umiejętności wrogów (cooldown, warunki użycia, szanse).
- **Formuła obrażeń** (wyliczana przez `QuizRpgSkillMath`):
  `Obrażenia = (base_damage + ATK × atk_coeff + MAT × mat_coeff − DEF × def_coeff − MDF × mdf_coeff) × damage_multiplier`
  - Tryby obrażeń (`DamageMode`):
    - `FORMULA` (0): powyższy wzór, redukowany przez pancerz celu (`DEF` i `MDF`).
    - `FIXED` (1): stałe obrażenia `fixed_damage` ignorujące pancerz.
    - `NONE` (2): brak bezpośrednich obrażeń (leczenie, nakładanie statusów, buffy).
  - `variance`: losowy rozrzut obrażeń (np. `0.2` = ±20%).
  - `hits` i `hit_interval`: serie wielokrotnych trafień z odstępem czasowym.
  - `success_rate`: bazowa szansa trafienia (u gracza modyfikowana poprawnością odpowiedzi w quizie).
  - `bonus_vs_status` oraz `bonus_multiplier`: zwielokrotnienie obrażeń, jeśli cel ma określony status (np. `piercing_shriek` zadaje ×2,1 obrażeń na zatrutym wrogu).
- **Cele umiejętności (`Target`)**:
  - `ONE_OPPONENT` (0): pojedynczy wróg.
  - `ALL_OPPONENTS` (1): wszyscy wrogowie.
  - `RANDOM_OPPONENTS` (2): losowi wrogowie (ilość losowań zdefiniowana przez `random_count`).
  - `SELF` (3): rzucający.
  - `ONE_ALLY` (4): pojedynczy żywy sojusznik.
  - `ALL_ALLIES` (5): wszyscy żywi sojusznicy.
  - `DEAD_ALLY` (6): poległy sojusznik (wskrzeszanie).
- **Leczenie (`HealMode`)**:
  - `NONE` (0): brak leczenia.
  - `FIXED` (1): leczenie o stałą wartość `heal_amount` HP.
  - `PERCENT` (2): leczenie o procent maksymalnego HP celu (`heal_percent`).

## Statystyki Magiczne: MAT i MDF
Wprowadzone dla wsparcia ataków magicznych, leczenia i obrony przed magią:
- `MAT` (Magic Attack): siła zaklęć i umiejętności magicznych. Bohater: bazowo 20, +2.0 per poziom.
- `MDF` (Magic Defense): redukcja obrażeń magicznych. Bohater: bazowo 12, +1.1 per poziom.
- Sprzęt może modyfikować `mat_bonus` i `mdf_bonus` (np. nakrycia głowy maga, różdżki, szaty).

## System Statusów (`QuizRpgStatusData`, `QuizRpgStatusCatalog`)
Statusy ładowane automatycznie z katalogu `resources/statuses/*.tres`:
- **Ograniczenia (`Restriction`)**:
  - `NONE` (0): pełna swoboda akcji.
  - `SKIP_TURN` (1): pominięcie tury (ogłuszenie `stun`, paraliż `paralysis`, sen `sleep`).
  - `CONFUSED` (2): chaos/zamroczenie (`confusion`, `charm`, `lunatic`) – losowy cel ataku, czasem sojusznik.
  - `SILENCED` (3): zablokowane używanie umiejętności (`silence`).
- **Modyfikatory statystyk**: `atk_mult`, `def_mult`, `mat_mult`, `mdf_mult`, `hit_mult` (np. oślepienie `blind` redukuje trafienie do 40%).
- **Efekty co turę**: `turn_hp_percent` (np. trucizna `poison` -5% HP na turę, regeneracja `regen` +5% HP).
- **Czas trwania**: `min_turns` i `max_turns` (lub 0/0 dla trwałej trucizny do wyleczenia).
- **Zdejmowanie**: `remove_on_damage_chance` (np. sen zdejmuje się w 100% po otrzymaniu ciosu, zamroczenie w 50%).
- **Dostępne statusy**:
  - Negatywne: `poison` (Zatrucie), `sleep` (Sen), `stun` (Ogłuszenie), `paralysis` (Paraliż), `blind` (Oślepienie), `confusion` (Zamroczenie), `silence` (Cisza), `lunatic` (Obłęd), `charm` (Urok), `provoke` (Prowokacja), `spooked` (Przestrach), `bleed` (Krwawienie), `curse` (Klątwa).
  - Pozytywne / Modyfikujące: `atk_up` (Zwiększenie Ataku), `atk_down` (Obniżenie Ataku), `def_up` (Zwiększenie Obrony), `def_down` (Obniżenie Obrony), `regen` (Regeneracja).

## Tabela Umiejętności Bohatera (`hero_bohater.tres`)
Pula umiejętności bohatera liczy dokładnie 12 pozycji (2 startowe, 3 z poziomów CC, 7 odblokowywanych fabularnie / przez NPC):

| ID Umiejętności | Nazwa | Typ / Źródło | Koszt | Cel | Trafienia / Wzór / Efekt |
|---|---|---|---|---|---|
| `leczenie` | Leczenie | Poziom 1 | 20 SP | Pojedynczy sojusznik | Leczy 30% maks. HP celu. Działa także w menu (`ALWAYS`). |
| `mocny_atak` | Mocny Atak | Poziom 1 | 25 TP | 1 wróg | Cios z mnożnikiem obrażeń ×1,5. |
| `double_throw` | Podwójny Rzut | Poziom 5 | 24 SP | 1 wróg | 2 trafienia. Wzór: `(100 + ATK×3.4 - DEF×2) × 1.35`. |
| `piercing_shriek` | Przeszywający Krzyk | Poziom 10 | 29 SP | 1 wróg | Wzór: `(105 + ATK×3.5 - DEF×1.6) × 2.0`. Szansa 15% na zatrucie. Zadaje ×2,1 obrażeń celom z trucizną. |
| `lullaby` | Usypiająca Melodia | Poziom 15 | 25 TP | 1 wróg | 9 trafień po 0,15 obrażeń. Szansa 70% na uśpienie celu przy każdym ciosie. |
| `leap_series` | Seria Skoków | NPC / Zdarzenie | 10 SP | 1 wróg | 5 trafień po `(20 + ATK×1.6 - DEF×0.8)`. 4% szansy na ogłuszenie per hit. |
| `reckless_blow` | Ryzykowny Cios | NPC / Zdarzenie | 50 SP | 1 wróg | Stałe 25 000 obrażeń. Niska szansa trafienia (8% sukcesu). |
| `aerial_strike` | Atak z Powietrza | NPC / Zdarzenie | 30 SP | 1 wróg | Atak magiczno-fizyczny: `(400 + MAT×2.0 - MDF×2.0)`. |
| `shove` | Zepchnięcie | NPC / Zdarzenie | 50 SP | 1 wróg | `(100 + ATK×1.6 - DEF×0.8)`. 50% szansy na nałożenie paraliżu. |
| `onslaught` | Natarcie | NPC / Zdarzenie | 80 SP | 1 wróg | 6 uderzeń pazurami: `(200 + ATK×1.6 - DEF×0.8)`. |
| `hearty_meal` | Pożywny Posiłek | NPC / Zdarzenie | 50 SP | Pojedynczy sojusznik | Stałe leczenie 1000 HP. Działa także w menu (`ALWAYS`). |
| `revive_tonic`| Tonik Ożywienia | NPC / Zdarzenie | 100 SP | Poległy sojusznik | Wskrzeszenie poległego sojusznika i uleczenie 250 HP. Działa w menu. |

## Umiejętności Towarzyszy w `resources/skills/`
Umiejętności przygotowane dla pozostałych członków drużyny:
- **Bonnie**: `sound_wave` (Fala Dźwięku, lv 10, zatrucie), `rousing_tune` (Porywająca Melodia, lv 20, buff atk_up).
- **Chica**: `nurturing_care` (Matka Ptaków, lv 20, leczenie obszarowe 40% HP dla wszystkich sojuszników).
- **Foxy**: `share_tempo` (Podział Szybkości, lv 15, podbicie TP drużyny), `sea_chant` (Szanta Żeglarska, lv 20, uciszenie i debuff wroga).
- **Balloon Boy (BB)**:
  - `coin_barrage` (Grad Monet, lv 5, 3 losowe cele, 3 trafienia).
  - `dive_attack` (Atak Nurkujący, lv 10, silne uderzenie śmigłem, mnożnik 1.5).
  - `smoke_cloud` (Chmura Dymu, lv 15, 50% szansy na oślepienie).
  - `death_enrage` (Szał Zniszczenia, lv 20, combo: 9 trafień obszarowych po wszystkich wrogach za 50 SP i 50 TP).



## Obrona i statusy w wierszu drużyny
- **Obrona** (`_resolve_defend`, stałe w `quiz_combat_controller.gd`): przepuszcza `GUARD_DAMAGE_FACTOR_CORRECT` = 1/4 obrażeń po dobrej
  odpowiedzi na quiz i `GUARD_DAMAGE_FACTOR_WRONG` = 1/2 po złej (wzór: Guard w FNaFB — tam połowa, bez quizu). Dotyczy zwykłego ataku wroga
  i umiejętności z `can_be_blocked` (domyślnie tak). Zawsze przechodzi co najmniej 1 punkt obrażeń.
- **Statusy a obrona:** broniąca się postać ma szansę na status od umiejętności wroga razy `GUARD_STATUS_CHANCE_FACTOR` = 0,5
  (`_guarded_status_chance`); status wchodzi więc nadal, tylko rzadziej (obrażenia zawsze przechodzą w części, nie ma pełnego bloku).
- **Statusy w wierszu drużyny:** `StatusLabel` (RichTextLabel) w każdym `PartyRow0..3` ekranu walki (`quiz_combat_ui.tscn`) pokazuje
  nazwy statusów postaci w kolorach z `QuizRpgStatusData.color` (`_set_party_row_statuses`, odświeżane w `_refresh_stats_panel`).
