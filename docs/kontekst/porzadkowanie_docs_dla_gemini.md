# Brief dla Gemini: uporządkowanie folderu `docs/` (bez zmiany treści merytorycznej)

**Po co:** w `docs/` nakładają się role plików — zwłaszcza `docs/kontekst/otwarte.md` i `docs/znane_problemy.md` (oba zawierają „co zostało do zrobienia”, część wpisów jest nieaktualna albo
powielona, a stan tych samych rzeczy bywa różny w obu plikach). `docs/kontekst/README.md` jest spisem z 2026-10-04 z dopisanymi dziennikami sesji i nie zna nowszych plików. Cel: jedno miejsce na każdy rodzaj informacji,
aktualny indeks i oznaczone pliki historyczne — **bez gubienia informacji** i bez zmiany faktów.

Zasady wspólne (jak w `zadania_dla_antigravity.md`): czytaj pliki z dysku przed edycją (repo bywa edytowane równolegle przez Claude'a); **nie zmieniaj kodu** (`.gd`, `.tscn`, `.tres`, `.json`);
nie commituj (weryfikację i commit robi Claude); po pracy wpisz na końcu tego pliku „GOTOWE <data>” i listę zmienionych plików. Pisz po polsku, UTF-8, końce linii LF.

## 1. Twarde ograniczenia (nie łam)

1. **Hook przypomnień.** `.claude/hooks/przypomnienia.sh` czyta z `docs/znane_problemy.md` **tylko** nagłówki w dokładnym formacie `### ⚠ WAŻNE: …` i wypisuje je na starcie każdej sesji. Nie zmieniaj ścieżki ani nazwy tego pliku, nie
   zmieniaj formatu tych nagłówków, nie dodawaj `⚠ WAŻNE` do spraw załatwionych (zrobione = nagłówek bez ⚠). Nie edytuj hooka.
2. **Ścieżki, do których odwołują się inne miejsca** (pamięć Claude'a, README, kod): `docs/znane_problemy.md`, `docs/kontekst/otwarte.md`, `docs/kontekst/README.md`, `docs/game_design.md`, `docs/module_contract.md`,
   `docs/kontekst/ekwipunek_szkic.md`, `docs/kontekst/poziomy_i_xp.md`. Pliki z tej listy zostają pod tą samą nazwą i w tym samym miejscu. Inne pliki wolno przenosić do `docs/archiwum/` **tylko** po
   sprawdzeniu `grep -rn "<nazwa>" .` (md, gd, json, sh, py) i poprawieniu wszystkich odwołań; w miejscu starego pliku nie zostawiaj pustych linków.
3. **Nie kasuj treści.** Nieaktualne fragmenty przenieś do `docs/archiwum/<nazwa>_do_<data>.md` (z nagłówkiem: skąd, kiedy, dlaczego) albo oznacz jako historyczne — nie usuwaj bezpowrotnie.
4. **Nie zgaduj stanu.** Jeśli nie umiesz sprawdzić, czy coś jest zrobione (w kodzie: `grep`, `ls`; w innych dokumentach), oznacz „DO WERYFIKACJI” i wpisz to do raportu — nie zmieniaj statusu na ślepo.
5. **Nie ruszaj treści (poza dodaniem wiersza w indeksie)** świeżych dokumentów projektowych: `ekwipunek_szkic.md`, `druzyna_szkic.md`, `sloty_umiejetnosci_szkic.md`, `poziomy_i_xp.md`, `skille_i_pierwowzory.md` / `.docx`,
   `backlog_druzyna_balans.md`, `i18n_*_dla_gemini.md`, `zadania_dla_antigravity.md`. Nie ruszaj `docs/img/`, `docs/prototypy/`, `universal_interior_generator_refactor.md` (215 KB, tylko wiersz statusu na górze, patrz 3.4).

## 2. Docelowy podział ról (propozycja — wdrażaj, chyba że w raporcie uzasadnisz inaczej)

| Plik | Rola | Czego tam NIE ma |
|---|---|---|
| `docs/znane_problemy.md` | **Jedyne źródło prawdy dla todo i problemów**: priorytety `⚠ WAŻNE` (hook), sekcje „Do zrobienia”, „Do sprawdzenia w grze”, „Wydajność”, „Pułapki konfiguracji”, „Testy”, „Potencjalne problemy”, „Rozwiązane”. Każdy punkt ma linię `Stan RRRR-MM-DD: …` | dziennika sesji, szkiców projektowych |
| `docs/kontekst/otwarte.md` | **Przekazanie bieżącej sesji (handoff)**: co zrobiono w ostatniej sesji, decyzje usera, których nie ma gdzie indziej, najbliższe kroki (maks. ok. 1 strona). Zamiast powielać listy todo — odsyła do punktów w `znane_problemy.md` | pełnej listy todo, starych sesji |
| `docs/kontekst/README.md` | **Indeks** plików w `docs/kontekst/` (jedna tabela, wszystkie pliki, z jednozdaniowym opisem i statusem) | dzienników sesji, opisów todo |
| `docs/README.md` (nowy) | **Indeks całego `docs/`** pogrupowany: zasady i kontekst, projekt gry, plany, analizy, szkice projektowe (niezatwierdzone), briefy dla Gemini, archiwum | treści merytorycznej |
| `docs/archiwum/` (nowy) | stare dzienniki sesji, nieaktualne sekcje „Stan na koniec sesji”, zrealizowane plany (jeśli oznaczone jako takie) | — |

Słownik statusów (używaj tylko tych): `ZROBIONE`, `W TOKU`, `NIE ZROBIONE`, `DO SPRAWDZENIA W GRZE`, `CZEKA NA USERA`, `SZKIC (niezatwierdzone)`, `HISTORYCZNE`.

## 3. Zadania

### 3.1. `docs/kontekst/otwarte.md`
- Przeczytaj cały plik. Sekcje „Stan na koniec sesji 2026-10-11”, „… 2026-10-12 (po drugim compactie)” i górna lista „Trzy ważne todo” są w części **nieaktualne** (np. „ekran śmierci — dziś przegrana kończy się komunikatem” jest już zrobione; „Paczka Sewer v2”, „balans” itd.).
- Przenieś całość dotychczasowej treści do `docs/archiwum/otwarte_do_2026-10-12.md` (bez zmian, z nagłówkiem źródła).
- W `otwarte.md` zostaw: najnowszą sekcję „Sesja 2026-10-12 (część 3): ekwipunek, złoto, klucze” (zachowaj ją w całości), krótką sekcję „Decyzje usera, których nie ma gdzie indziej” (zbierz z archiwum tylko to, co nadal obowiązuje: sloty tierów, drużyna, blok = 100 % uniku z AGI, delegowanie prostych zadań do Gemini, koszty skilli tymczasowe, zasady ekwipunku) i „Najbliższe kroki” z odsyłaczami do punktów `znane_problemy.md` zamiast powielania opisów.
- Każdy wpis todo, którego nie ma w `znane_problemy.md`, dopisz tam (sekcja „Do zrobienia”, z `Stan RRRR-MM-DD: …`) — nie gub go.

### 3.2. `docs/znane_problemy.md`
- **Nie zmieniaj** nagłówków `### ⚠ WAŻNE: …` (hook) ani samej treści opisów problemów; możesz poprawiać tylko linie `Stan …` jeśli sprawdzisz fakty (patrz zasada 4).
- Sprawdź spójność z `otwarte.md` i `kontekst/*.md`; sprzeczności wpisz do raportu (nie rozstrzygaj sam).
- Jednolity format: każdy punkt na liście „Do zrobienia” ma linię `Stan RRRR-MM-DD: <status ze słownika> — <jedno zdanie>`; punkty bez tej linii uzupełnij (status sprawdź jak w zasadzie 4).
- Faza opcjonalna (**tylko po akceptacji planu w raporcie przez Claude'a / usera**): wydzielenie sekcji „Rozwiązane” do `docs/archiwum/rozwiazane.md` oraz „Wydajność”, „Pułapki konfiguracji”, „Testy” do osobnego pliku — wymaga poprawy odwołań typu „`znane_problemy.md` „Rozwiązane””; w raporcie wypisz wszystkie takie odwołania z numerami linii.

### 3.3. `docs/kontekst/README.md` i `docs/README.md`
- Zastąp dziennik sesji (od „Sesja 2026-10-02/03 …” w dół) indeksem: przenieś ten dziennik do `docs/archiwum/kontekst_README_sesje_do_2026-10-06.md`.
- Jedna tabela: **każdy** plik z `docs/kontekst/` (także nowe: `ekwipunek_szkic`, `druzyna_szkic`, `sloty_umiejetnosci_szkic`, `poziomy_i_xp`, `skille_i_pierwowzory`, `backlog_druzyna_balans`, `i18n_opisy_dla_gemini`, `i18n_log_wrogow_dla_gemini`, `zadania_dla_antigravity`, `porzadkowanie_docs_dla_gemini`, `balans_i_skalowanie`, `klasy_postaci_i_bronie`) z jednym zdaniem i statusem.
- Zostaw w README akapit o hooku przypomnień (jest poprawny) i odsyłacz do `znane_problemy.md`.
- Utwórz `docs/README.md` jako indeks wszystkich plików w `docs/` (grupy z sekcji 2).

### 3.4. Oznaczenie statusu planów i analiz w `docs/`
Pliki: `plan_generator_obiektow.md`, `plan_generator_sciekow.md`, `plan_przyspieszenie_generowania.md`, `analiza_ai_przeciwnikow.md`, `battle_layout_preview.md`, `migration_plan.md`, `krytyczne_zawieszenia_klatek.md`,
`universal_interior_generator_refactor.md`, `game_design.md`. Dla każdego dodaj **na górze jedną linię** `> Status (RRRR-MM-DD): <ze słownika> — <jedno zdanie, czego dotyczy stan>` (sprawdź w kodzie / innych dokumentach; gdy nie wiadomo — „DO WERYFIKACJI”). Nie zmieniaj reszty treści.
Znane fakty: ścieki (`plan_generator_sciekow.md`) zmergowane do `main` 2026-10-09 / 10; zawieszenia klatek (`krytyczne_zawieszenia_klatek.md`) rozwiązane restartem edytora 2026-10-11; generator obiektów w większości zrobiony (zostały dźwignie, leniwe sceny, nakładka podglądu).

### 3.5. Sprawdzenie linków i raport
- Sprawdź wszystkie linki względne w `docs/**/*.md` (komenda poniżej) i popraw te zepsute przez Twoje przeniesienia.
- Utwórz `docs/kontekst/raport_porzadkowania.md`: (a) lista przeniesień (skąd → dokąd), (b) sprzeczności między plikami (plik, linia, opis), (c) wpisy „DO WERYFIKACJI”, (d) odwołania do sekcji, które się zmieniły, (e) propozycje na fazę opcjonalną.

```
python - <<'EOF'
import re, pathlib
root = pathlib.Path("docs")
for f in root.rglob("*.md"):
    for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
        for m in re.finditer(r"\]\(([^)#]+\.md)(#[^)]*)?\)", line):
            if not (f.parent / m.group(1)).resolve().exists():
                print(f"{f}:{i}: brak {m.group(1)}")
EOF
```

## 4. Czego nie robić
- Nie zmieniaj liczb, decyzji i nazw w dokumentach projektowych; nie „poprawiaj” stylu; nie tłumacz.
- Nie twórz nowych dokumentów merytorycznych (poza `docs/README.md`, `docs/archiwum/*`, `raport_porzadkowania.md`).
- Nie usuwaj plików; nie zmieniaj nazw plików z listy w pkt 1.2.
- Nie dotykaj `modules/**` ani `.claude/**`.

Weryfikacja po Twojej pracy (Claude): hook (`sh .claude/hooks/przypomnienia.sh`), brak zepsutych linków, `git diff --stat` (sprawdzę, czy nic nie zniknęło), przegląd raportu.
