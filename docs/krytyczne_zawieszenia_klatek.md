# KRYTYCZNE: wielosekundowe zawieszenia klatek przy ruchu kursora (zgłoszone 2026-10-11)

## WYNIK KOŃCOWY (2026-10-11, ~17:00): lag zniknął po RESTARCIE EDYTORA — rozwiązane, mechanizm niepotwierdzony
- Lag ustąpił dopiero po zamknięciu edytora Godota działającego od 14:21 (ponad 2,5 h) i uruchomieniu nowego.
- Potem testy kontrolne na świeżym edytorze, wszystkie czyste: Forward+ (Vulkan) z gry uruchamianej z edytora; Windhawk
  włączony i potwierdzony jako wstrzyknięty (windhawk.dll + mody dark-menus/fix-darkmode-listviews w procesie edytora);
  LittleBigMouse włączony. **Winni NIE są:** Vulkan/D3D12, Windhawk, LittleBigMouse, warstwy OBS/RTSS, AccessKit, VSync,
  audio, mysz (G502 X, 1 kHz), kod `quiz_rpg`/hosta.
- Wcześniejszy wniosek „renderer Vulkan” był błędny: czysty bieg na OpenGL przypadł już po zmianach w tle; zmiana renderera
  NIE jest potrzebna.
- Fakty pasujące do „stary proces edytora”: lag dotykał też procesów niezwiązanych z edytorem (gra i pusty projekt
  uruchamiane z terminala) — czyli działał na poziomie systemowego wejścia; tylko z fokusem na oknie Godota; tylko przy
  prawdziwej myszy (programowy `SetCursorPos`, który omija globalne haki myszy, nie wywoływał lagu); Windows chwilowo
  zgłaszał okno starego edytora jako zawieszone (`IsHungAppWindow`); efekt kuli śnieżnej (klatki 70→2000+ ms).
- **Hipoteza (niepotwierdzona):** stary edytor trzymał globalny hak myszy (np. po popupie/menu) i obsługiwał go z opóźnieniem
  (edytor w tle śpi do ~100 ms na obieg) — każde zdarzenie myszy w systemie czekało na edytor.

### Jeśli wróci — NIE restartować od razu, najpierw zebrać dowody (narzędzia: `modules/quiz_rpg/tools/diag_input/`)
1. `Get-Process Godot*` — które procesy Godota działają i od kiedy (stary edytor?).
2. Próbnik stosów starego edytora: `python stack_sampler.py <pid_edytora> 10 ed.json`, potem
   `DBGHELP="F:/Windows Kits/10/Debuggers/x64/dbghelp.dll" python symbolize.py ed.json --ms` (uruchamiać w katalogu
   Debuggers/x64, żeby załapał symsrv.dll). Szukać hooka myszy (`CallNextHookEx`, `MouseProc`, `LowLevelMouseProc`) i tego,
   czy wątek główny śpi (`NtDelayExecution`) lub wisi.
3. Ten sam próbnik na grze w trakcie lagu (porównać z profilem z tej sesji: 99,9% w `PeekMessageW`).
4. Sprawdzić, czy zamknięcie popupów/menu w edytorze (Esc, klik w puste miejsce) albo samo kliknięcie w edytor usuwa lag.
5. `python win32_loop_test.py 30 busy` (okno bez Godota, kliknąć i ruszać myszą) — czy dławi się też nie-Godot.
6. Dopiero potem restart edytora; zapisać w tym dokumencie, co pokazały kroki 1–5.

### Historia dochodzenia (poniżej) — wnioski pośrednie z tej sekcji bywały błędne, aktualny jest WYNIK KOŃCOWY wyżej.


Status: rozwiązane restartem edytora (patrz WYNIK KOŃCOWY na górze). Zawieszenie obejmuje cały proces Godota (user: nawet przesuwanie okna gry i
edytora jest opóźnione, a hovery „stoją w kolejce” — po zatrzymaniu myszy przyciski dalej się podświetlają).

## NAJWAŻNIEJSZE USTALENIE (2026-10-11, późniejsze testy)
**Zawieszenia występują w PUSTYM projekcie Godota** (`scratchpad/mini_mouse`: jedna scena z siatką 64 `Button`, bez
autoloadów, bez modułu), gdy user rusza **prawdziwą myszą chaotycznie**: 17 zacięć >50 ms, razem 21 s, najgorsze 7,6 s
(Vulkan Forward+, okno zmaksymalizowane, ustawienia okna z hosta). Także w oknie 1280×720 (18 zacięć, 10,5 s) i na D3D12
(12 zacięć, 11,2 s). Zacięcia występują też w menu głównym hosta (`scenes/main.tscn`) bez modułu. Czyli **to nie jest kod
`quiz_rpg` ani hosta** — to Godot 4.7.2 (Windows, wejście/prezentacja) + sprzęt/sterownik/mysz usera.
- Programowy ruch kursora (`SetCursorPos`, ~250–500 zdarzeń/s, sinusoida) **nie** wywołuje zacięć w pustym projekcie
  (9 stref po 5 s: 0 zacięć) — natomiast zdarzenia z prawdziwej myszy tak. User: im bardziej chaotyczny ruch, tym więcej
  zacięć; „hover działa na środku ekranu” i „za wolno, przy szybkim ruchu myszą”.
- Hipoteza do sprawdzenia w pierwszej kolejności: **mysz o wysokiej częstotliwości próbkowania** (2–8 kHz) lub sterownik
  myszy/Windows 11 Insider (build 26300) + obsługa `WM_MOUSEMOVE` / raw input w Godocie na Windows (znane problemy
  Godota z gęstym wejściem myszy). Sprawdzić: model i częstotliwość myszy usera; obniżenie do 1000 Hz w oprogramowaniu myszy;
  mysz zapasowa/inny port USB; Godot w innej wersji (4.4/4.5/4.6) na tym samym pustym projekcie; `Input.use_accumulated_input`.
- Test rendererów na pustym projekcie wyszedł **niejednoznaczny**: `opengl3` 0 zacięć, Vulkan/D3D12 zacinają się, ale
  powtórka (opengl3 2×, mobile, vulkan) dała 0 — user prawdopodobnie nie ruszał wtedy myszą jak w pierwszych biegach.
  Powtórzyć z jawnym potwierdzeniem, że user rusza myszą przez całe 25 s, w kolejności: vulkan, opengl3, vulkan, opengl3.
- Odtwarzanie w pustym projekcie: `scratchpad/mini_mouse` (Godot `--path`, `MINI_LOG` = plik logu; log klatek >50 ms).
  Projekt NIE jest w repo — jeśli potrzebny, odtworzyć: `Control` + `GridContainer` z 64 `Button`, `_process` mierzący
  `Time.get_ticks_usec()` i logujący delta > 50 ms; `project.godot` z `[display] window/size/mode=2`, `stretch/mode="canvas_items"`.

## Objawy
- Przy jeżdżeniu kursorem po oknie gry klatki trwają **od 0,4 do ponad 8 s** (zmierzone 8641 ms, średnio 0 FPS w oknie 12 s).
- Występuje **także w menu głównym** (nie tylko w walce), więc to nie jest UI walki.
- Bez ruchu kursora gra trzyma pełne 170 FPS (VSync) / ~1200 FPS (bez VSync).
- Zgłoszone pierwotnie jako: po wejściu w Atak → wyjściu → Umiejętności → wyjściu w walce wszystko się wiesza.

## Odtwarzanie (deterministyczne, bez udziału człowieka)
Windows, 3 monitory, RX 9070 XT, Godot 4.7.2, Windows 11 Insider (build 26300).
```
# terminal 1 (okno gry na 100,100 1280x720):
Godot_v4.7.2-stable_win64_console.exe --path . --position 100,100 --resolution 1280x720 -s res://modules/quiz_rpg/tools/repro_mouse_stall.gd
# terminal 2 równolegle (nie ruszać myszą):
powershell -NoProfile -ExecutionPolicy Bypass -File modules/quiz_rpg/tools/mouse_sweep.ps1
# wynik: %APPDATA%\Godot\app_userdata\Artefakt Wiedzy Modular\perf_log.txt (wpisy PUŁS co 5 s, ZACIĘCIE, ZAWIESZENIE)
```
Fazy skryptu: 8 s bez ruchu (PUŁS: 170 FPS, zacięć 0), potem 12 s ruchu (PUŁS: np. „śr. 19 FPS, najgorsza klatka 4004 ms”).

## Monitor wydajności (już w grze, tylko build debug)
`scripts/tools/perf_monitor.gd`, dodawany w `module_root._ready`. F3 = nakładka, F4 = przełącznik VSync.
Wpis `ZACIĘCIE` (>60 ms) rozbija klatkę na: „przed rysowaniem” (skrypty + submit renderu), „po rysowaniu”
(od `frame_post_draw` do następnego `_process`: prezentacja / system / dostarczanie wejścia), render CPU/GPU,
metryki silnika, liczbę zdarzeń wejścia w klatce i ich opóźnienie, kontekst gry. `ZAWIESZENIE` zapisuje wątek strażnika,
gdy główny wątek stoi >1,5 s. `PUŁS` co 5 s: średnie FPS, najgorsza klatka, metryki, kontekst.

## Ustalenia (dowody)
1. Cały czas ginie w sekcji **„po rysowaniu”** (np. 2410, 3527, 3947 ms); „przed rysowaniem” 2 ms, render CPU 0,3 ms,
   GPU 0,1 ms, `TIME_PROCESS` 2–6 ms, fizyka ~0, 59–74 draw calle. Skrypty `_process`, render i GPU są zdrowe.
2. W każdej długiej klatce silnik dostaje **dokładnie 1 zdarzenie wejścia** (ruch myszy), dostarczone dopiero po przerwie
   („pierwsze 3631 ms po rysowaniu”). To nie jest powódź zdarzeń. Uwaga: czas mierzy dotarcie do węzła monitora, więc
   mógł zostać „zjedzony” wcześniej przez inny węzeł w kolejności `_input`.
3. **Nie zależy od VSync:** zacięcia występują przy włączonym, Mailbox i Adaptive (log 15:49–15:50).
4. **Nie zależy od audio:** menu główne z domyślnym sterownikiem audio i z `--audio-driver Dummy` zacina się tak samo
   (testy 16:00 w tej sesji; Dummy: „śr. 0 FPS, najgorsza klatka 7162 ms”).
5. **Nie jest wyciekiem:** liczba węzłów i obiektów stała w pętli wejść/wyjść z zakładek (test z 6 rundami).
6. **~~Coś w projekcie~~ — UNIEWAŻNIONE:** minimalny projekt przy ruchu *programowym* się nie zacinał, ale przy ruchu prawdziwą
   myszą usera zacina się tak samo jak gra (patrz „NAJWAŻNIEJSZE USTALENIE”). Różnica to rodzaj zdarzeń (sprzętowa mysz vs
   `SetCursorPos`), nie zawartość projektu.
7. Wejścia/wyjścia z zakładek pauzy i menu walki (Atak/Umiejętności), nawet z 3 wrogami, bez ruchu myszy: klatki 6–12 ms.

## Co już naprawiono po drodze (osobne, mniejsze sprawy)
- Hover w walce: `QuizTheme.set_menu_item_selected` przepisywał style 7 przycisków przy każdym najechaniu (~1 ms + ~0,5 ms w
  następnej klatce) → teraz nic nie robi bez zmiany stanu (`force` tylko przy zmianie motywu). To tłumaczyło utratę
  ~400 klatek na hover (1200 → 800 FPS), **nie** zawieszenia na sekundy.
- Delta statystyk w ekwipunku liczona względem złego slotu (osobny commit, naprawione).

## Podejrzani / następne kroki (nic z tego jeszcze niesprawdzone; punkty o kodzie gry są teraz mało prawdopodobne)
- NAJPIERW: częstotliwość próbkowania myszy, inna mysz/port, inna wersja Godota na pustym projekcie, sterownik AMD.
- Bisekcja po różnicy względem minimalnego projektu: uruchamiać `repro_mouse_stall.gd` z coraz mniejszą zawartością —
  bez `QuizTheme.apply()`, bez motywu/czcionki (Jersey 15), bez autoloadów hosta (`dev_menu.gd`, `cheat_service.gd`,
  `loot_manager.gd`, `AudioService`, `SettingsService`), sam `main_menu.tscn` bez `module_root`.
- Wszystkie `_input`/`_unhandled_input` w autoloadach (`dev_menu`, `cheat_service`, `loot_manager`) — zmierzyć czas każdego
  handlera na zdarzenie myszy (zawijać w mierniki).
- Kontrolki z `mouse_filter = STOP` i obsługa `mouse_entered/exited` (tooltipy, `gui_find_control` po dużym drzewie).
- `QuizCombatController._find_pause_menu_node` robi `find_child` po całym drzewie na KAŻDE zdarzenie wejścia i KAŻDĄ klatkę,
  gdy węzła `PauseMenu` nie ma (realna nieefektywność; nie zbadano, czy ma wpływ w menu głównym — tam kontrolera walki nie ma).
- Profil procesu zewnętrznym narzędziem (np. Windows Performance Recorder / Process Explorer: stos wątku głównego w trakcie
  zawieszenia), bo silnik raportuje, że czas ginie poza skryptami.
- Sprawdzić, czy to samo dzieje się w buildzie eksportowanym (release) i bez debuggera/edytora.
- Rozważyć wersję Godota (4.7.2) — porównać z inną wersją na minimalnym projekcie z tą samą zawartością.

## Pliki
`scripts/tools/perf_monitor.gd` (monitor), `tools/repro_mouse_stall.gd` + `tools/mouse_sweep.ps1` (odtwarzanie),
`tests/check_equip_hover.gd`. Niezacommitowane zmiany usera w `scenes/quiz/quiz_combat_ui.tscn` i `resources/ui/quiz_theme.tres`
(m.in. `StatusLabel` min. szerokość 230 → 64) — nie wykluczone jako czynnik, nie testowane osobno.
