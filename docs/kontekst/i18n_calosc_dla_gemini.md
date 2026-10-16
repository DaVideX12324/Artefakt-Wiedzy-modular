# Tłumaczenia całego Artefaktu (PL / EN) — brief dla Gemini

Cel: cały tekst widoczny dla gracza w hoście (Artefakt Wiedzy), w Cieniu Mgły (`modules/quiz_rpg`) i w BitBomberze
(`modules/BitBomber`) ma działać po polsku i angielsku. Język wybiera już opcja **Opcje → Ogólne → Język**
(`SettingsService.get_language()` / `set_language()`, lista `SettingsService.LANGUAGES`: `pl`, `en`).

Weryfikację, testy Godota, sync kopii `_host/` i commity robi Claude. Ty piszesz kod, JSON-y i raport.

## Stan dziś

- `modules/quiz_rpg/scripts/i18n/quiz_i18n.gd` (`QuizRpgI18n`): płaskie słowniki `modules/quiz_rpg/resources/i18n/pl.json`
  i `en.json` (142 klucze: `skill.<plik>.name|desc`, `status.<plik>.name|desc`, `weapon.<id>`, `class.<id>`,
  `combat.enemy_uses_skill`). Łańcuch: język → en → tekst z zasobu → klucz. Klucze skilli / statusów pochodzą z **nazwy pliku
  `.tres`** (`skill_name_key(res)` itd.), więc plików `.tres` nie wolno przemianowywać.
- Host i BitBomber nie mają tłumaczeń. W quiz_rpg nieprzetłumaczone są: sceny UI (`text =` w `.tscn`), komunikaty w kodzie
  (log walki, HUD, pauza, zapis, śmierć, dialogi), nazwy i opisy przedmiotów, wrogów, postaci, map, `scan_text`, logi skilli
  wrogów (`skill.<plik>.log` — stary brief [i18n_log_wrogow_dla_gemini.md](i18n_log_wrogow_dla_gemini.md) wchodzi w to zadanie).

## Zasady ogólne

- **Przed każdą edycją czytaj plik z dysku** (repo bywa zmieniane równolegle). Nie commituj, nie rób `git add`, `stash`,
  `checkout`, `reset`.
- **Nie ruszaj:** `assets/` (prywatny submoduł), `modules/quiz_rpg/_host/` (kopie generuje Claude skryptem sync),
  `modules/quiz_rpg/project.godot.off`, `fnafb/`, `addons/`, `tests/`, plików `.tres` (poza wyjątkiem w fazie 4 — żadnego),
  liczb i mechaniki. Nie zmieniaj istniejących tłumaczeń skilli / statusów / klas / broni (poza literówkami — wypisz je w raporcie).
- **Sceny zostają WYSIWYG:** w `.tscn` zostaje polski tekst (widać go w edytorze), **nie** wpisuj tam kluczy.
  Tłumaczenie scen robi mechanizm z fazy 0 (polski tekst z `pl.json` → tekst w wybranym języku).
- **Nie tłumaczymy:** treści pytań quizu i odpowiedzi (`resources/quizzes/*.json`, edytor pytań — tylko jego UI), nazw zapisów
  i innych tekstów wpisanych przez gracza, `print` / `push_warning` / `push_error`, komentarzy, dev menu
  (`autoloads/services/dev_menu.gd` — narzędzie dewelopera), tytułów „Artefakt Wiedzy” i „Cień Mgły”, imion bohaterów.
- Pliki: UTF-8 bez BOM, końce linii LF, JSON z wcięciem 2 spacje, płaski słownik. `pl.json` i `en.json` w jednym katalogu
  mają **identyczne zestawy kluczy**.
- Wstawki w tekście: `{nazwa}` i `String.format({...})` (jak `combat.enemy_uses_skill`: `"{enemy} używa: {skill}!"`), nigdy
  sklejanie zdań z kawałków ani `%s` (szyk zdania w PL i EN się różni). Te same `{...}` w obu językach.
- Bez motywów FNaF w nowych tekstach.

### Przedrostki kluczy

| Gdzie | Katalog słowników | Przedrostek nowych kluczy |
|---|---|---|
| host | `res://resources/i18n/` (nowy) | `host.<ekran>.<co>` (np. `host.options.language`) |
| Cień Mgły | `res://modules/quiz_rpg/resources/i18n/` (jest) | istniejące + `ui.<ekran>.<co>`, `log.<co>`, `item.<plik>.name|desc`, `enemy.<plik>.name|scan`, `hero.<id>.name`, `npc.<id>.<co>`, `map.<scena>.name`, `skill.<plik>.log` |
| BitBomber | `res://modules/BitBomber/resources/i18n/` (nowy) | `bb.<ekran>.<co>` |

`<plik>` = nazwa pliku `.tres` bez rozszerzenia, `<scena>` = nazwa sceny poziomu z `levels/` bez rozszerzenia.

### Słownik EN (trzymaj się go wszędzie)

HP, SP, TP, ATK, DEF, MAT, MDF, AGI — bez zmian. Walcz → Fight, Uciekaj → Escape, Atak → Attack, Obrona → Guard,
Umiejętności → Skills, Przedmioty → Items, Ekwipunek → Equipment, Status → Status, Szyk → Formation, Drużyna → Party,
Zapisz → Save, Wczytaj → Load, Opcje → Options, Wyjdź → Quit, Wróć → Back, Kontynuuj → Continue, Nowa gra → New Game,
Poziom → Level (skrót Lv), Złoto → Gold, Mikstura → Potion, Strażnik → Guardian, arcymag → archmage, Skan → Scan.
Ton jak w klasycznych JRPG (krótko, rzeczowo). Angielski tekst nie może być wyraźnie dłuższy niż polski w ciasnych
kontrolkach (przyciski, nagłówki kolumn) — gdy nie da się skrócić, wpisz do raportu.

## Faza 0 — infrastruktura (po niej STOP i raport, Claude sprawdza)

1. **`autoloads/services/i18n_service.gd`** (host, `extends Node`), autoload `I18nService` w `project.godot` **zaraz po**
   `SettingsService` (dopisz tylko tę jedną linię, resztę `project.godot` zostaw dokładnie jak jest — są tam lokalne zmiany usera).
   - `const SOURCE_LANG := "pl"`, `const FALLBACK_LANG := "en"`; `signal language_changed(lang: String)`.
   - `register_dir(dir: String)` — dopisuje katalog słowników (idempotentnie), przeładowuje; w `_ready` rejestruje
     `res://resources/i18n/`. Ten sam klucz w dwóch katalogach → `push_warning`.
   - `t(key, fallback := "")` — język → en → `fallback` → klucz; `tf(key, args: Dictionary, fallback := "")` = `t().format(args)`;
     `has(key)`; `reload()`.
   - `plural(key_base, n: int, args := {})` — PL: `.one` (1), `.few` (2–4 oprócz 12–14), `.many` (reszta); EN: `.one` (1),
     `.many` (reszta); do `args` dopisuje `n`. Słowniki mają wtedy klucze `<baza>.one|few|many` (EN też ma `.few`, równe `.many`,
     żeby zestawy kluczy były identyczne).
   - **Tłumaczenie scen:** przy starcie i zmianie języka buduje jeden obiekt `Translation` dla bieżącego języka:
     dla każdego klucza `add_message(<tekst z pl.json>, <tekst w bieżącym języku>)`, dodaje go do `TranslationServer`
     (poprzedni usuwa) i woła `TranslationServer.set_locale(lang)`. Kontrolki z `auto_translate_mode` (domyślnie dziedziczony =
     włączony) przełączają się same. **Przy `pl` nie rejestruje żadnego obiektu** — Godot przy braku wpisu sięga do języka
     zapasowego (`internationalization/locale/fallback`, domyślnie `en`) i przetłumaczyłby polskie sceny na angielski.
     Ten sam polski tekst z różnymi tłumaczeniami w dwóch kluczach → `push_warning` z oboma kluczami.
   - Słucha `SettingsService.language_changed` → przebudowa + `language_changed.emit(lang)`.
2. **`SettingsService`:** `signal language_changed(lang: String)`, emitowany w `set_language`, gdy język się zmienił.
3. **`QuizRpgI18n`** zostaje (te same funkcje i klucze), ale bez własnego wczytywania: rejestruje swój katalog przez
   `I18nService.register_dir(QuizRpgPaths.path("res://modules/quiz_rpg/resources/i18n/"))` i deleguje `t` / `has` / `reload`.
   Stary `_cache` / `_dict` usuń (martwy kod). Dołóż `tf` i `plural` jako delegaty. Rejestracja: przy starcie modułu
   (`module_root.gd` i `standalone/standalone_main.gd`) + leniwie przy pierwszym `t()` jako zabezpieczenie.
   Moduł działa też samodzielnie (kopie hosta w `_host/`, ścieżki przez `QuizRpgPaths`) — nie wpisuj `res://modules/quiz_rpg/…`
   na sztywno.
4. **BitBomber:** statyczny pomocnik (np. `scripts/bb_i18n.gd`, `class_name BbI18n`) z `t` / `tf` / `plural`, który rejestruje
   `res://modules/BitBomber/resources/i18n/` (sprawdź, jak BitBomber ustala swoje ścieżki w wersji samodzielnej —
   `project.godot.off`) i gdy `I18nService` nie istnieje (`Engine.get_main_loop().root.get_node_or_null("I18nService")`),
   zwraca `fallback` (polski).
5. **Węzły z treścią gracza / quizu** (pytanie, odpowiedzi, nazwy zapisów, imiona, liczby, tekst składany w kodzie z danych)
   dostają w `.tscn` `auto_translate_mode = 2` (wyłączone), żeby przypadkiem pasujący tekst („Tak”, „Nie”) się nie podmienił.
   Ta faza: tylko w scenach quizu (panel pytania, edytor pytań — pola z treścią).
6. **`tools/check_i18n.py`** (host, nowy folder `tools/`), uruchamiany `python tools/check_i18n.py` z katalogu hosta, kod
   wyjścia ≠ 0 przy błędach:
   - błędy: każdy `*/i18n/*.json` (host, quiz_rpg, BitBomber; pomiń `_host/`) parsuje się; `pl` i `en` mają te same klucze; brak
     pustych wartości; te same `{...}` w PL i EN; brak klucza w dwóch katalogach; każdy `text` / `placeholder_text` /
     `tooltip_text` / `title` z `.tscn` (pomiń `_host/`, `addons/`, `tests/`, `assets/`, węzły z `auto_translate_mode = 2`
     i ich dzieci, teksty bez liter) występuje jako wartość w `pl.json` jakiegoś katalogu;
   - ostrzeżenia: ten sam polski tekst z różnymi tłumaczeniami; lista plików `.gd` z literałami zawierającymi polskie litery
     poza komentarzami i `print` / `push_*` (z liczbą linii) — mapa tego, co zostało w kodzie.
7. Słowniki hosta (`res://resources/i18n/pl.json`, `en.json`) — na start choćby jeden klucz (`host.options.language`), żeby
   ścieżka działała.

**Raport po fazie 0** (`docs/kontekst/i18n_calosc_raport.md`): co zmieniłeś (pliki, funkcje), wynik `check_i18n.py`
(ile tekstów scen i plików `.gd` czeka), pytania. Potem STOP.

## Faza 1 — host

`scenes/ui/*.tscn` (menu główne, opcje, edytor pytań, przejście modułu), `scripts/ui/*.gd`, `scripts/core/*`, `scripts/shared/*`,
widoczne dla gracza teksty w `autoloads/services/*` (poza dev menu) i `autoloads/compat/*`.
- Teksty scen: polski zostaje w `.tscn`, dopisz klucze `host.*` do `pl.json` (dokładnie ten tekst) i `en.json`.
- Teksty z kodu: `I18nService.t("host.…")` / `tf` / `plural`. Kontrolki, które kod wypełnia, a które są widoczne w chwili zmiany
  języka (Opcje, menu główne), odświeżają się na `I18nService.language_changed` (albo `NOTIFICATION_TRANSLATION_CHANGED`).
- Nazwy w `SettingsService.LANGUAGES` („Polski”, „English”) zostają bez tłumaczenia.
- Edytor pytań: tłumaczysz etykiety, przyciski, komunikaty; treść pytań nie.

## Faza 2 — Cień Mgły: sceny

`modules/quiz_rpg/scenes/**/*.tscn` (poza `_host/`): klucze `ui.<ekran>.<co>` dla każdego tekstu, `auto_translate_mode = 2`
na węzłach z danymi. Sceny poziomów i obiektów (`levels/`, obiekty) zwykle nie mają tekstu — pomiń, jeśli `check_i18n.py`
nic tam nie zgłasza.

## Faza 3 — Cień Mgły: teksty w kodzie

`modules/quiz_rpg/scripts/**`, `autoloads/**` (poza `tests/`, `tools/`): log walki (`scripts/quiz/quiz_combat_controller.gd` i
pokrewne — klucze `log.*` z `{actor}`, `{target}`, `{amount}` itd.), HUD, pauza / Status / Ekwipunek, zapis i wczytywanie,
ekran śmierci, dialogi, podpowiedzi przycisków, loot, sklep. Używaj `QuizRpgI18n.t` / `tf` / `plural`. Liczebniki
(„3 mikstury / 5 mikstur”) przez `plural`. Nie zmieniaj logiki — tylko źródło tekstu.

## Faza 4 — Cień Mgły: dane z zasobów

Klucze z nazwy pliku, **bez edycji `.tres`**: w klasach danych dopisz metody w stylu istniejącego `localized_log_text()`
(np. `localized_name()` / `localized_description()` w `item_data.gd`, danych wroga, `hero_data.gd`), które zwracają
`QuizRpgI18n.t(<klucz>, <pole z zasobu>)`, i podmień odczyty pól w UI na te metody.
- Przedmioty: `item.<plik>.name|desc`. Wrogowie: `enemy.<plik>.name`, `enemy.<plik>.scan` (`scan_text`).
  Bohaterowie: `hero.<id>.name` (imiona bez tłumaczenia — EN = PL, ale klucz jest). Mapy: `map.<scena>.name`.
  NPC / dialogi: `npc.<id>.<co>`. Logi skilli wrogów: `skill.<plik>.log` wg [i18n_log_wrogow_dla_gemini.md](i18n_log_wrogow_dla_gemini.md).
- PL = obecny tekst z `.tres` (popraw tylko literówki, wypisz je), EN = tłumaczenie.

## Faza 5 — BitBomber

`modules/BitBomber/scenes/**`, `scripts/**`, `autoloads/**`: tak samo jak faza 1, przez `BbI18n`, klucze `bb.*`.

## Koniec każdej fazy

1. `python tools/check_i18n.py` — zero błędów dla plików tej fazy (ostrzeżenia z kodu kolejnych faz mogą zostać).
2. Każdy zmieniony `.gd` przejrzyj pod kątem składni (Godot 4.7; typowanie jak w otoczeniu, wcięcia tabami).
3. Dopisz do `docs/kontekst/i18n_calosc_raport.md`: faza, zmienione pliki, ile kluczy doszło, kolizje, teksty za długie po
   angielsku, literówki poprawione w PL, pytania. Gier i testów Godota nie uruchamiaj (zmieniają plik ustawień usera) — testy
   robi Claude.
