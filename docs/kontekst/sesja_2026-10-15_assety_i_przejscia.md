# Zrzut kontekstu: assety prywatne, przejścia, drobne poprawki (sesja 2026-10-14/15)

> Handoff dla kolejnej sesji. Poprzedni zrzut: [`sesja_2026-10-13_miasto_ldtk.md`](sesja_2026-10-13_miasto_ldtk.md). Pełna lista todo:
> [`../znane_problemy.md`](../znane_problemy.md); zadania wg trudności: [`zadania_wg_trudnosci.md`](zadania_wg_trudnosci.md).

## Najważniejsze: struktura repo po przepisaniu historii (2026-10-15)

- **`assets/` hosta = prywatny submoduł** `DaVideX12324/Artefakt-Wiedzy-assets` (PRIVATE). Powód: licencje części paczek
  (Glionox, itch: „no redistribution”; kupione z Amon-Ra, np. Desert Oasis) zabraniają redystrybucji, a repo hosta i CienMgly są
  publiczne (kod ma być widoczny, publicznie tylko exe). Praca: commit + push w `assets/`, potem wskaźnik w hoście.
- **Historia hosta i CienMgly przepisana** (`git filter-repo` + force-push): z hosta zniknęło `assets/` i stare kopie assetów
  modułu (398 → 26 MB), z CienMgly `_host/assets` i stare `assets/` poza własnymi `battle_backgrounds` i `loading_screens`
  (394 → 46 MB). Gitlinki hosta na `modules/quiz_rpg` przemapowane na nowe hasze. **Wszystkie stare hasze są nieaktualne**
  (np. commit odniesienia 1a526846 → `8915c89`). Kopie zapasowe: `F:\Programy\GitHub\_kopie_zapasowe_przed_przepisaniem\`
  (host i CienMgly, lokalne + zdalne mirrory); robocze `F:\Programy\GitHub\_przepisywanie\` do usunięcia.
- **Inne klony** (laptop, Gemini/Antigravity, kolega) trzeba było sklonować od nowa albo `fetch` + `reset --hard origin/<gałąź>`
  (laptop user zrobił). Stare commity mogą być osiągalne na GitHubie przez PR-y i adresy z hashami; pełne usunięcie = GitHub
  Support.
- `modules/quiz_rpg/_host/assets` jest **generowane** przez `tools/sync_host_copies.gd` i w `.gitignore` CienMgly.
- `.gitattributes` z `* text=auto eol=lf` dodane w `assets` i BitBomber (puste „reimporty” `.import` na maszynach z
  `core.autocrlf=true` i Godotem piszącym LF); **CienMgly ma `.gitattributes`, ale nie sprawdziłem, czy z `eol=lf`** (do zrobienia).
- Lokalna gałąź hosta `ccr-744b0fc4-1vk0mk` na desktopie ma 3 niewypchnięte commity (m.in. „Fabuła: kręgi teleportacyjne…”) na
  starej historii — przenieść (cherry-pick), jeśli potrzebne.

## Assety: podział użyte / nieużywane i licencje

- Analiza odwołań (kod, sceny, `.tres`, przechodnio): z 6228 plików użyte 490. Nieużywane (poza `audio/` i free packiem Pixel
  Crawler) w `assets/_nieuzywane/<ta sama ścieżka>` (z `.import`/`.uid`, `.gdignore`); powrót = przeniesienie na starą ścieżkę.
  Skrypty analizy/przenoszenia były w scratchpadzie sesji (nie w repo): odtworzyć, gdy potrzeba.
- Decyzje usera: free pack Pixel Crawler zostaje w używanych (miasto), późniejsze mapy PC w `_nieuzywane`; `audio/` bez zmian;
  kupione assety z Amon-Ra tylko ukryte (może kiedyś użyje / kupi).
- Licencje: Pixel Crawler free = komercja OK (nie sprzedawać paczki); Kyrise = CC BY 4.0 (trzeba kredytów w grze, ich jeszcze nie
  ma); Glionox = komercja i modyfikacje OK, **zakaz redystrybucji** (`LICENSE.txt` w folderze, pełna paczka tylko w prywatnym
  repo); `pixel_art_rpg`, `assorted_16x16`, Helton Yan SFX: **brak informacji o licencji w repo** (do sprawdzenia); Raven Fantasy
  Icons free = **tylko użytek osobisty** (nie używać; kopię z `_host` usunięto).
- Ikony przedmiotów (`assets/item_icons/`, 37 PNG): 33 to przemianowane kopie z Glionox/Kyrise, 4 przerobione ręcznie
  (antidote, cloth_cap, iron_buckler, lucky_charm); `.tres` przedmiotów wskazują je po UID (`res://assets/item_icons/…`).

## Zrobione w kodzie (CienMgly + host)

- **Menu deweloperskie:** karta „Statusy bohaterów” (nałóż / zdejmij / zdejmij wszystkie), `PlayerStats.get_status_catalog()`.
- **Zatrucie:** fioletowy kolor zamiast zielonego (status, log, liczby), w świecie co 3 s tyle HP co w rundzie walki (nadal
  najwyżej do 1 HP poza walką), **winieta zatrucia** (`scenes/ui/poison_vignette.tscn`, słaby poziom bazowy + błysk przy ubytku).
- **Gradient schodów portali:** kolizja ostatnich pikseli kafla we wszystkich wariantach (E/W/S/N; alternatywy kafla mają własne
  dane, silnik nie odbija polygonu) w `caves.tres`; obszar przejścia wchodzi 4 px w ostatni stopień (`PORTAL_AREA_OVERLAP`).
- **Ekran śmierci:** „Wczytaj zapis” otwiera okno wyboru zapisu; powrót do menu głównego przykryty ekranem ładowania
  (`menu_transition.gd`); `level_manager` zna nazwy cave/sewer/town od pierwszej klatki.
- **Ekran przejścia host ↔ moduł** (`scripts/core/module_transition.gd`, `scenes/ui/module_transition.tscn`): powstaje i jest
  rysowany przed wczytaniem modułu (scena wejściowa w tle), przy wyjściu zasłania przed wyłączeniem (`module_exiting`).
- **QuizTheme:** zmiany motywu w paczce (`set_block_signals`): `apply()` 835 → 43 ms, `_ready` modułu ~1000 → ~200 ms
  (to była ścinka na środku ekranu przejścia). Przełączenie skórki ~18 ms, jasność ~1 ms.
- **Start mapy:** bez nietykalności gracza (brak nawigacji wrogów w pokoju wejścia/wyjścia i pierwszym za wejściem); azyl
  (`QuizRpgSafeZone`) zostaje.
- **Komunikaty po bitwie:** stała wysokość okna, strony po zapełnieniu (czekają na Enter), migający trójkąt `MoreMarker` w prawym
  dolnym rogu okna.
- **TileSet free packa** (`modules/quiz_rpg/resources/maps/pixel_crawler_free.tres`): 25 atlasów (w tym `Floors_Full`, legacy
  `Forest_Tiles`, `Tiles`).

## Otwarte / do podjęcia

1. **Ikony statusów zamiast tekstu:** propozycje z Raven (free, tylko użytek osobisty) są tylko na planszy w
   `F:\Programy\GitHub\podglady_ui\propozycje_ikon_statusow.png` — **nie używać w grze**. User rozważa pakiet
   `finalbossblues.itch.io/icons` (6 USD, 32×32 i 24×24, kategoria „status and effects”, komercja OK, bez kredytów, bez
   redystrybucji; **nie potwierdzono, że są wszystkie 18 statusów** — sprawdzić zrzuty / zapytać autora). Po wyborze: wyciąć
   ikony, dodać pole ikony w `status_data`, wstawić w log walki, panel drużyny, pasek jednostek (ikony jak ikony przedmiotów:
   przemianowane w `assets/`, UID w `.tres`).
2. **Priorytet #1 (z Opusem):** przyspieszenie generowania map — gałęzie `optymalizacja-generowania` w hoście i CienMgly (z `main` i
   `druzyna-balans`), punkt odniesienia host `8915c89`; plan: [`../plan_przyspieszenie_generowania.md`](../plan_przyspieszenie_generowania.md).
3. Miasto: sprawdzić `town.ldtk` w LDtk, konwerter LDtk → TileMapLayer (zadanie 14 w `zadania_wg_trudnosci.md`).
4. Kredyty Kyrise w grze (CC BY), sprawdzenie licencji pozostałych paczek.
5. GitHub Support (opcjonalnie): usunięcie starych commitów z cache; przeniesienie 3 lokalnych commitów z `ccr-…`.

## Przydatne (Windows)

- PowerShell 5.1 nie zna `&&` (używać `;`); komendy `git` z `!` w promptcie Claude Code idą w Git Bash.
- Auto-tryb Claude Code blokuje force-push (wykonał go user); `reset --mixed`, `branch -f` i zwykłe pushe przechodzą.
