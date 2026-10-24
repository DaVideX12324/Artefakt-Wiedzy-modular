# Wersjonowanie

Zasady numerów wersji Artefaktu Wiedzy i modułów (przyjęte 2026-10-24). Numer opisuje **wydanie i jego zakres**,
etap (Alpha / Beta / RC) — **dojrzałość** tego zakresu. Numer nie jest procentem ukończenia projektu.

## Aktualne wersje

| Element | Wersja | Etap | Gdzie zapisana |
|---|---|---|---|
| Artefakt Wiedzy (host + paczka z modułami) | `0.8.0-alpha` | Alpha | `project.godot` → `application/config/version` |
| Cień Mgły (`modules/quiz_rpg`, repo CienMgly) | `0.8.0-alpha` | Alpha | `modules/quiz_rpg/module_manifest.json` → `version` |
| BitBomber (`modules/BitBomber`) | `0.9.0-beta` | Beta | `modules/BitBomber/module_manifest.json` → `version` |

Wersję pokazują: menu główne hosta (prawy dolny róg + przyciski modułów), menu Cienia Mgły i menu BitBombera — wszystkie
czytają ją z plików powyżej, więc numer zmienia się **tylko tam**. Edytor pytań, wspólne serwisy (`QuizService`,
`AudioService`, …) i `_template` nie mają osobnych numerów — należą do wersji hosta.

Dlaczego takie etapy:
- **Cień Mgły — Alpha:** systemy działają, ścieżka tutorial → jaskinia → miasto → ścieki → boss ścieków → wyjście na cmentarzysko →
  ekran końca jest spięta w kodzie, ale mapa miasta jest jeszcze w budowie (warstwa Walls, obiekty, domki).
- **BitBomber — Beta:** zakres gry meczowej jest kompletny (dwa tryby, 28 map, boty, quizy w grze, oprawa, sesja z hostem);
  zostają testy i balans. Kampania i bot kopiący bomby to rozszerzenia po 1.0.
- **Artefakt Wiedzy — Alpha:** platforma (moduły, opcje, edytor pytań, wyniki sesji) jest gotowa do testów, ale paczka
  zawiera RPG w Alphie, więc całość dziedziczy najniższy etap.

## Format

```
MAJOR.MINOR.PATCH[-etap]      np. 0.8.0-alpha, 0.8.3-alpha, 0.9.0-beta, 1.0.0-rc, 1.0.0
```

- **PATCH** — kolejny build tego samego etapu: poprawki, drobne usprawnienia, uzupełnienia (0.8.0 → 0.8.1 → 0.8.2 …).
- **MINOR** — nowy etap zakresu albo istotna nowa zawartość (0.8 → 0.9 = przejście do Bety; po 1.0: 1.1, 1.2 = aktualizacje).
- **MAJOR** — główne wydanie produktu (1.0 = zakres inżynierski, 2.0 = pełny zakres Cienia Mgły). To numeracja produktowa,
  nie ścisły SemVer: MAJOR nie oznacza zmiany API. Zmiany kompatybilności opisuje changelog (sekcja „Kompatybilność”).
- **etap** — `alpha`, `beta`, `rc`; bez sufiksu = wydanie stabilne. Do wyświetlenia: `0.8.0-alpha` → „0.8.0 Alpha”.

Etapy:
- **Alpha** — grywalne / używalne, ale zakres wydania jeszcze się buduje.
- **Beta** — zakres wydania kompletny; priorytet to testy, balans, wydajność, poprawki.
- **RC** — kandydat do wydania: brak znanych błędów blokujących, końcowe testy eksportu.
- **Stable** — wydanie gotowe w zadeklarowanym zakresie (nie znaczy: bez błędów ani koniec rozwoju).

Komponenty mają **niezależne** numery — wydanie modułu nie wymusza zmiany wersji hosta ani drugiego modułu. Paczka
(host) w changelogu zapisuje, z jakimi wersjami i commitami modułów została wydana.

## Plan głównych wydań

| Wersja | Cień Mgły | Artefakt Wiedzy |
|---|---|---|
| `0.8.x-alpha` | teraz: systemy + spięta ścieżka, miasto w budowie | teraz |
| `0.9.0-beta` | miasto skończone i przechodzalne, ścieżka do ekranu końca bez komend deweloperskich; zapis / wczytanie / śmierć drużyny nie blokują postępu | gdy oba moduły są w Becie |
| `1.0.0-rc` → `1.0.0` | stabilne wydanie zakresu inżynierskiego (tutorial → jaskinia → miasto → ścieki → boss → zakończenie) — „pierwszy rozdział”, nie cała kampania | zamrożony kontrakt host ↔ moduł, sprawdzone wejścia/wyjścia z obu gier, eksport |
| `1.x` | poprawki i stopniowa rozbudowa (nowe obszary, zadania, przeciwnicy) | |
| `2.0.0` (przez `2.0.0-alpha` / `-beta`) | pełny zakres z [`game_design.md`](game_design.md) (kampania, ~15 map, finał z rozszerzonego scope) | nie musi rosnąć razem z grą |

## Wersje danych (osobno od numeru produktu)

Numer produktu nie zastępuje wersji formatów. Zmianę formatu podbija się w kodzie i opisuje w changelogu:

| Format | Stała | Plik |
|---|---|---|
| Zapis gry Cienia Mgły | `SAVE_VERSION` (teraz 2) + migracja przy wczytaniu | `modules/quiz_rpg/autoloads/save_manager.gd` |
| Zapisane mapy (cache na dysku) | `MAP_CACHE_VERSION` — inna wersja = mapa generowana od nowa | `modules/quiz_rpg/scripts/maps/map_disk_cache.gd` |
| Kontrakt modułu | pola manifestu, `embedded_start` / `request_exit`, wynik sesji | [`module_contract.md`](module_contract.md) |

## Changelog

Każde repo ma `CHANGELOG.md` (host, CienMgly, BitBomber):
- na górze sekcja **`[Unreleased]`** — zmiany już w `main`, jeszcze niewydane (dopisywać przy commitach widocznych dla gracza);
- przy wydaniu sekcja zmienia nazwę na `[wersja] — RRRR-MM-DD`, pod nią pusta nowa `[Unreleased]`;
- podsekcje: Dodano / Zmieniono / Naprawiono / Kompatybilność / Znane ograniczenia (puste pomijać);
- opisuje skutki dla gracza, nie każdy commit (historia jest w git); planów nie wpisuje się jako wydanych — plany są w
  roadmapie / [`zakres_inzynierka.md`](zakres_inzynierka.md);
- changelog hosta przy aktualizacji modułu: „Cień Mgły: 0.8.0-alpha → 0.8.1-alpha, commit `abc1234`, najważniejsze zmiany”.

## Wydanie — kroki

1. Podbić `version` (manifest modułu i/lub `project.godot`).
2. W `CHANGELOG.md` zamienić `[Unreleased]` na `[wersja] — data`, dodać nowe puste `[Unreleased]`.
3. Commit „Wydanie X.Y.Z-etap”, tag `vX.Y.Z-etap` (annotated) w repo komponentu, push z tagami.
   Gdy zmienił się generator map — podbić `MAP_CACHE_VERSION` (zapisane mapy graczy generują się od nowa).
4. W hoście: wskaźnik submodułu + wpis w changelogu hosta (wersja i commit modułu); przy wydaniu paczki — tag hosta.
5. Build: preset „Windows Desktop” w `export_presets.cfg` (host, w repo; wynik w `build/`, poza gitem):
   `Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release "Windows Desktop" build/windows/ArtefaktWiedzy.exe`.
   Wymaga wzorców eksportu 4.7.2. Przy podbiciu wersji zmienić też `application/file_version` / `product_version`
   w presecie (Windows przyjmuje tylko liczby: `0.8.0-alpha` → `0.8.0.0`). Poza paczką: `scratch/`, `podglady_ui/`, `fnafb/`, testy, narzędzia, `addons/`,
   `_template`, `standalone/` modułów i foldery z `.gdignore` (`assets/_nieuzywane`, `docs`, `_host`).
6. Do zgłoszeń błędów dołączać wersję i krótki hash commita.
