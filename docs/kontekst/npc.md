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

## Otwarte (do decyzji usera)
- Waluta nauczyciela: złoto (teraz) / żeton „Skill Slip” z lv 5 / 10 / 15 jak FNaFB / sama flaga — zmiana w danych.
- Flagi asortymentu i lekcji to placeholdery (`shop_tier3`, `teacher_desert` / `_forge` / `_forest`) — podpiąć pod
  realne zdarzenia fabularne.
- Imiona i teksty NPC (robocze), Hideout jako wnętrze, kowal (ulepszenia broni — osobna usługa), zadania NPC.
