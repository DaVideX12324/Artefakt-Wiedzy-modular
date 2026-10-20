# NPC miasta — system usług (2026-10-21)

Stan: **ZROBIONE (MVP)**, CienMgly `cbb0218a`…`698acc2e`. Kod niezależny od układu miasta: NPC to sceny-szablony
do wstawienia w dowolną mapę (edytor / LDtk).

## Jak użyć
- Wstaw scenę z `scenes/npc/`: `shopkeeper.tscn` (Sklepikarka), `innkeeper.tscn` (Karczmarka), `skill_teacher.tscn`
  (Mistrz Fechtunku), `villager.tscn` (Mieszkanka). Wszystkie dziedziczą po `npc.tscn` (zmiany wspólne tylko w bazie).
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

Każda usługa ma `required_flag` (bez flagi nie ma jej w menu). Okna: `scenes/ui/shop_panel.tscn` (Kup / Sprzedaj,
←/→ zakładki, Enter kupuje 1 szt.), `scenes/ui/skill_teacher_panel.tscn` (wiersze „postać — umiejętność”, koszt,
powód niedostępności). Sprzedaż za połowę ceny, przedmioty bez ceny (klucze) nie do sprzedania.

## Flagi fabularne
`LevelStateManager.set_story_flag / has_story_flag / clear_story_flag` — globalne, w zapisie, osobno od paska
urządzenia. `has_story_flag` przyjmuje też id pokonanego story-bossa (tier sklepu po bossie bez dodatkowego kodu).

## Ceny (`QuizRpgItemData.price`)
Broń 2,5 × ATK, pancerz / tarcza / hełm 3 × DEF; mikstura 8, eter 10, tonik 15, odtrutka 6, wytrych 20, amulet 60.
Odniesienie: wróg mapy 1 daje ok. 15–25 zł (`QuizRpgEnemyGold`), tier 2 sprzętu ≈ 2 zabicia (FNaFB). Nocleg 20 zł,
lekcje 60–300 zł. Wszystko do strojenia w danych.

## Punkt narzuconego zapisu (`scenes/objects/save_point.tscn`)
Decyzja usera: zapis dostępny prawie zawsze z menu pauzy, karczma nie zapisuje; narzucony zapis tylko w punktach
(np. przed point of no return). Strefa: ostrzeżenie → menu pauzy na zakładce zapisu; dziecko `Barrier` przepuszcza
po zapisie. Flaga `save_point:<point_id>` jest ustawiana przed zapisem (trafia do pliku) i cofana, gdy gracz zamknie
okno bez zapisu. Opcja `once`.

## Testy
`tests/check_npc_services.gd` (headless, 22 sprawdzenia: sklep, karczma, nauczyciel, flagi w zapisie),
`tests/shot_npc_ui.gd` (zrzuty z oknem). **Nie przechodzone w grze:** pełna rozmowa z klawiatury w mieście, punkt
zapisu (bariera po zapisie).

## Decyzje usera (2026-10-21)
- **Waluta nauczyciela: złoto.** Opcjonalnie później dodatkowo przedmiot z dropu potworów albo z zadania pobocznego
  (pole `item_id` / `item_count` lekcji — bez zmian w kodzie).
- **Flagi = pokonani bossowie.** Pokonany boss zawsze ustawia flagę `boss:<id>` (`EnemyBase._persist_boss_defeat`;
  id = `boss_story_id` albo nazwa sceny mapy, np. `boss:cave`, `boss:sewer` — nowe mapy nazywać jak strefy:
  `cemetery`, `fairy_forest`…). Szablony: sprzęt tieru 3 w sklepie po `boss:sewer` (tier 2 od razu — miasto jest po
  jaskini), umiejętności z blokad biomów (`onslaught`, `reckless_blow`, `leap_series`) po `boss:fairy_forest` (hub
  przed trzema bramami). Do korekty w Inspectorze, gdy ustali się kolejność.
- **Imiona i teksty NPC robi Gemini** (brief niżej).

## Brief dla Gemini: imiona i teksty NPC
- Pliki: `modules/quiz_rpg/resources/i18n/pl.json` i `en.json` (UTF-8, **LF**, wcięcie 2 spacje, klucze w kolejności
  alfabetycznej), sceny `modules/quiz_rpg/scenes/npc/{shopkeeper,innkeeper,skill_teacher,villager}.tscn`.
- Klucze: `npc.<rola>.name`, `npc.<rola>.greeting_<n>`, `npc.innkeeper.talk_<n>`, `npc.villager.talk_<n>`
  (role: `shopkeeper`, `innkeeper`, `teacher`, `villager`). W scenie zmienić też `npc_name` / `greeting` / `lines`
  (zapasowe teksty) na te same polskie wersje; liczba linii w scenie = liczba kluczy `_<n>`.
- Ton: osada odcięta mgłą, ludzie tracą wspomnienia (`docs/game_design.md`, „Zarys fabuły — co gracz wie na
  początku”); nauczyciel w Hideout — dialog „formuły przekażę, osobistej techniki nie”
  (`kontekst/fabula_krag_i_zakonczenia_szkic.md`, „Kropka 1”). Bez zdradzania twistu fabuły.
- Nie ruszać kluczy `shop.*`, `teacher.*`, `npc.inn.*`, `npc.service.*`, `npc.bye`, `npc.menu_question`.

## Otwarte
- Hideout jako wnętrze, kowal (ulepszenia broni — osobna usługa), zadania NPC.
