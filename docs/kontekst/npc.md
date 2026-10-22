# NPC miasta — system usług (2026-10-21)

Stan: **ZROBIONE (MVP)**, CienMgly `cbb0218a`…`698acc2e`. Kod niezależny od układu miasta: NPC to sceny-szablony
do wstawienia w dowolną mapę (edytor / LDtk).

## Jak użyć
- Wstaw scenę z `scenes/npc/`: `shopkeeper.tscn` (Zielarka — mikstury, odtrutki, wytrychy, amulet), `blacksmith.tscn`
  (Kowal — broń), `armorer.tscn` (Płatnerz — tarcze, hełmy, pancerze), `innkeeper.tscn` (Karczmarka), `skill_teacher.tscn`
  (Mistrz Fechtunku), `villager.tscn` (Mieszkanka). Sklepy podzielone wstępnie (decyzja usera 2026-10-21); sprzęt tieru 3
  u kowala i płatnerza po `boss:sewer`. Sprite'y kowala (royal Soldier) i płatnerza (Elf Base) tymczasowe — to wrogowie
  z paczki; `sprite_offset` -30 dla klatek ze stopami na dole. Wszystkie dziedziczą po `npc.tscn` (zmiany wspólne tylko w bazie).
- W Inspectorze: `npc_name` (+ klucz tłumaczenia), `sprite_frames` (animacja `idle`), `face_left`, `greeting`,
  `services` (lista usług), `farewell`. Wygląd widać w edytorze.
- Rozmowa: powitanie → menu usług + „Do widzenia” → po usłudze menu wraca. NPC z jedną rozmową mówi ją od razu.
  Przez całą rozmowę gra w stanie CUTSCENE.

## Usługi (`scripts/npc/services/`, zasoby `.tres` / sub-zasoby sceny)
| Usługa | Klasa | Dane |
|---|---|---|
| Rozmowa | `QuizRpgNpcTalk` | linie, linie przy kolejnych rozmowach, `set_flag` (flaga po rozmowie) |
| Sklep | `QuizRpgNpcShop` | `stock` (`QuizRpgShopEntry`: przedmiot, cena, `required_flag`), `can_sell` |
| Odpoczynek | `QuizRpgNpcInn` | `price` — pełne HP (też nieprzytomni), SP, bez statusów (`PlayerStats.rest_party`) |
| Nauka | `QuizRpgNpcSkillTeacher` | `lessons` (`QuizRpgSkillLesson`: skill_id, hero_id, złoto, przedmiot-żeton, min. poziom, flaga) |
| Zadanie (2026-10-22) | `QuizRpgNpcQuest` | `quest_id`, tytuł, cel (`QuizRpgQuestLog.Goal`) + `goal_count` / `goal_target` / własny `goal_text`, nagroda (`reward_gold`, `reward_xp`, `reward_items` id → sztuki), linie: propozycja, w trakcie, oddanie, po oddaniu — niżej „Zadania” |
| Ulepszanie (kowal, 2026-10-21) | `QuizRpgNpcUpgrade` | dane w przedmiotach: `upgrade_to`, `upgrade_gold`, `upgrade_flag`, `upgrade_item_id` / `_count` (etap = osobny przedmiot); okno `scenes/ui/upgrade_panel.tscn` — broń założona (zostaje założona) i z ekwipunku, powód blokady („nie pamiętam jeszcze…” bez flagi) |

Każda usługa ma `required_flag` (bez flagi nie ma jej w menu). Okna: `scenes/ui/shop_panel.tscn` (Kup / Sprzedaj,
←/→ zakładki, Enter kupuje 1 szt.), `scenes/ui/skill_teacher_panel.tscn` (wiersze „postać — umiejętność”, koszt,
powód niedostępności). Sprzedaż za połowę ceny, przedmioty bez ceny (klucze) nie do sprzedania.

## Flagi fabularne
`LevelStateManager.set_story_flag / has_story_flag / clear_story_flag` — globalne, w zapisie, osobno od paska
urządzenia. `has_story_flag` przyjmuje też id pokonanego story-bossa (tier sklepu po bossie bez dodatkowego kodu).

## Zadania (2026-10-22)
- Przebieg: propozycja → „Przyjmujesz zadanie?” (Przyjmuję / Nie teraz) → wpis w dzienniku → rozmowa w trakcie
  (`{left}`) → oddanie: przedmiot celu zabrany, nagroda, flaga **`quest:<quest_id>`**, toast „Zadanie wykonane”.
  Po oddaniu pozycja zostaje w menu tylko z `after_lines` (puste = znika).
- Cele: `ANSWER_CORRECT` (poprawne odpowiedzi od przyjęcia), `DEFEAT_ENEMIES` (id pliku danych wroga, np. `rat_base`,
  prefiks `rat_*` albo pusty = dowolni; liczą się zabici od przyjęcia), `BRING_ITEM` (`item_id`, zabierany),
  `STORY_FLAG` (np. `boss:sewer`; dać `goal_text`), `PAY_GOLD` (`goal_count` D, pobierane przy oddaniu).
- Linie: `{count}`, `{left}`, `{target}`, `{reward}`; klucze tłumaczeń `<klucz>_1`, `_2`… jak w rozmowie.
- Stan w zapisie: `PlayerStats.quests` (wpis z tytułem, celem i licznikiem startowym — dziennik nie potrzebuje sceny
  NPC) i `PlayerStats.enemy_kills` (`record_kill` z `enemy_base` po wygranej, każdy wróg grupy; `kill_count(target)`).
- Dziennik: menu pauzy → „Zadania” (`scenes/ui/quest_panel.tscn`, wiersz-wzór `QuestRow0`): najpierw gotowe do
  oddania (zielone „Gotowe — wróć do: …”), potem w toku z postępem, na końcu ukończone (przygaszone).
- Świat po zadaniu: `QuizRpgFlagGate` / `required_flag` usług i drzwi z flagą `quest:<id>`.
- Przykład: Lina (`villager.tscn`) — „Szczury w kanałach”: 5 × `rat_*`, 150 D + 2 mikstury (teksty robocze, do Gemini).
- Etykieta w menu: „Zadanie: <tytuł>” (pusta `label`). Łańcuch zadań: następne z `required_flag = "quest:<poprzednie>"`,
  poprzednie bez `after_lines` (znika z menu po oddaniu).
- **Zadania o materiały (decyzja usera 2026-10-22: pośrednie na zadanie, główne na bossa; zadanie = rzemieślnik
  potrzebuje lepszych surowców):** Brann „Lepsza ruda” (ruda żelaza) → „Węgiel i stal” (300 D), Kastor „Surowe skóry” →
  „Żelazne łuski” (ruda) — tabela w `ekwipunek_szkic.md` sekcja 12. Cel `PAY_GOLD`: dukaty pobierane przy oddaniu.

## Ceny (`QuizRpgItemData.price`)
Broń 2,5 × ATK, pancerz / tarcza / hełm 3 × DEF; mikstura 8, eter 10, tonik 15, odtrutka 6, wytrych 20, amulet 60.
Odniesienie: wróg mapy 1 daje ok. 15–25 D (`QuizRpgEnemyGold`), tier 2 sprzętu ≈ 2 zabicia (FNaFB). Nocleg 20 D,
lekcje 60–300 D. Wszystko do strojenia w danych.

## Punkt narzuconego zapisu (`scenes/objects/save_point.tscn`)
Decyzja usera: zapis dostępny prawie zawsze z menu pauzy, karczma nie zapisuje; narzucony zapis tylko w punktach
(np. przed point of no return). Strefa: ostrzeżenie → menu pauzy na zakładce zapisu; dziecko `Barrier` przepuszcza
po zapisie. Flaga `save_point:<point_id>` jest ustawiana przed zapisem (trafia do pliku) i cofana, gdy gracz zamknie
okno bez zapisu. Opcja `once`.

## Testy
`tests/check_npc_services.gd` (headless, 22 sprawdzenia: sklep, karczma, nauczyciel, flagi w zapisie),
`tests/shot_npc_ui.gd` (zrzuty z oknem), `tests/check_quests.gd` (33 sprawdzenia zadań i dziennika),
`tests/shot_quest_log.gd` (zrzut dziennika). **Nie przechodzone w grze:** pełna rozmowa z klawiatury w mieście, punkt
zapisu (bariera po zapisie).

## Decyzje usera (2026-10-21)
- **Waluta: dukaty, symbol „D” w każdym języku** (nazwa Dukaty / Ducats; niepowiązana z prawdziwą walutą; w kodzie
  nadal `gold`). **Nauczyciel bierze dukaty.** Opcjonalnie później dodatkowo przedmiot z dropu potworów albo z zadania pobocznego
  (pole `item_id` / `item_count` lekcji — bez zmian w kodzie).
- **Flagi = pokonani bossowie.** Pokonany boss zawsze ustawia flagę `boss:<id>` (`EnemyBase._persist_boss_defeat`;
  id = `boss_story_id` albo nazwa sceny mapy, np. `boss:cave`, `boss:sewer` — nowe mapy nazywać jak strefy:
  `cemetery`, `fairy_forest`…). Szablony: sprzęt tieru 3 w sklepie po `boss:sewer` (tier 2 od razu — miasto jest po
  jaskini), umiejętności z blokad biomów (`onslaught`, `reckless_blow`, `leap_series`) po `boss:fairy_forest` (hub
  przed trzema bramami). Do korekty w Inspectorze, gdy ustali się kolejność.
- **Pamięć rzemieślników (fabuła tierów sklepów):** mieszkańcy pod Mgłą **pamiętają swoje imiona, ale słabo swoje
  rzemiosło**. Z biegiem gry przypominają sobie umiejętności — **stąd przedmioty kolejnych tierów** w sklepach, u kowala
  (ulepszenia: „nie pamiętam jeszcze…”) i u nauczyciela. Mechanicznie to flagi pokonanych bossów (`required_flag`,
  `upgrade_flag`) — pasuje do fabuły: bossowie przechowują wspomnienia wyssane przez Mgłę (`fabula_krag_i_zakonczenia_szkic.md`
  1.2), pokonany boss je uwalnia. Teksty NPC piszą się w tym duchu (np. kowal po odblokowaniu tieru: „Przypomniałem sobie,
  jak hartować stal…”). Pomysł do zrobienia: kwestia NPC przy pierwszej rozmowie po nowym tierze (rozmowa z `required_flag`).
- **Imiona i teksty NPC zrobione przez Gemini** (2026-10-21: wdrożono imiona Fenna, Brann, Kastor, Greta, Corvus, Lina oraz kwestie powitań i dialogów w pl.json, en.json i scenach .tscn).

## Brief dla Gemini: imiona i teksty NPC
- Pliki: `modules/quiz_rpg/resources/i18n/pl.json` i `en.json` (UTF-8, **LF**, wcięcie 2 spacje, klucze w kolejności
  alfabetycznej), sceny `modules/quiz_rpg/scenes/npc/{shopkeeper,blacksmith,armorer,innkeeper,skill_teacher,villager}.tscn`.
- Klucze: `npc.<rola>.name`, `npc.<rola>.greeting_<n>`, `npc.innkeeper.talk_<n>`, `npc.villager.talk_<n>`
  (role: `shopkeeper`, `blacksmith`, `armorer`, `innkeeper`, `teacher`, `villager`). W scenie zmienić też `npc_name` / `greeting` / `lines`
  (zapasowe teksty) na te same polskie wersje; liczba linii w scenie = liczba kluczy `_<n>`.
- Ton: osada odcięta mgłą, ludzie tracą wspomnienia (`docs/game_design.md`, „Zarys fabuły — co gracz wie na
  początku”); nauczyciel w Hideout — dialog „formuły przekażę, osobistej techniki nie”
  (`kontekst/fabula_krag_i_zakonczenia_szkic.md`, „Kropka 1”). Bez zdradzania twistu fabuły.
- Nie ruszać kluczy `shop.*`, `teacher.*`, `npc.inn.*`, `npc.service.*`, `npc.bye`, `npc.menu_question`.

## Otwarte
- Hideout jako wnętrze. Zadania: mechanizm jest (wyżej) — teksty robocze do poprawy przez Gemini. Kowal ma już ulepszanie (wyżej); flagi
  etapów: tier 2 od razu, tier 3 `boss:sewer`, dalej zastępcze `boss:forge` / `boss:library` — do ustawienia, gdy będzie kolejność map.
