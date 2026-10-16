# Szkic fabuły — dopiski z 2026-10-16, konflikty i otwarte sprawy

Do przeglądu przed przeniesieniem szkicu [fabula_krag_i_zakonczenia_szkic.md](fabula_krag_i_zakonczenia_szkic.md) (PR #12)
do [game_design.md](../game_design.md). Stan: **lokalnie, bez commita**, czeka na potwierdzenie usera.

## 1. Sprawdzenie PR #12

- Gałąź chmurowego Claude `ccr-744b0fc4-1vk0mk`: jeden commit (`7892203`), trzy pliki, wszystkie w `main` (`4a92f92`).
  Szkic i `docs/README.md` identyczne z gałęzią; `docs/kontekst/README.md` różni się tylko wpisem o sesji 2026-10-16, którego
  gałąź (z 2026-10-12) nie miała — scalenie go zachowało.
- Odwołania szkicu do kodu zgadzają się z dzisiejszym stanem: `LEVEL_CAP = 20`, `MAX_LEVEL = 100`, SP 1739 na lv 100,
  `PARTY_TP_MAX = 100`, cooldown tylko w `scripts/enemies/enemy_skill.gd`, `SAVE_DIR` / `SLOT_CONFIG_PATH` zdublowane
  w `save_manager.gd` i `game_manager.gd`, leczenie `PERCENT` / `heal_percent`.
- Nie da się sprawdzić, czy chmurowy Claude miał cały kontekst rozmowy z 2026-10-13 — do przejrzenia przez usera punkty **[U]**
  (rzekome decyzje usera).

## 2. Dopiski w szkicu (decyzje usera 2026-10-16)

1. **6.1 Faza 2 (True):** zamiast nieśmiertelności **absurdalna pula HP** (np. 9 999 999); zwykłe ataki ledwo ją ruszają,
   **pierwsze użycie 10. poziomu zadaje absurdalne obrażenia** (jak The Bite of 87), zbija pasek → Faza 3.
2. **6.1 Good:** bez 10. poziomu **inna Faza 2** i inna interakcja z uzurpatorem w finale (przebieg do ustalenia).
3. **4 i 6.1:** w **True prawdziwy Strażnik przeżywa** walkę w zamku, potem walka z uzurpatorem; w **Good umiera**.
4. **6.2:** **7 użyć 10. poziomu, optimum na 4.** Użycie 1 kończy Fazę 2, 2–7 w Fazie 3, 7. (ostatnie przed ścianą kosztu)
   kończy walkę. Krzywa spłaszczona: 1. użycie 35%, optimum (4.) 25%, 7. 96%, 8. 150% (niemożliwe); deficyt ≈ 3747 SP z własnych mikstur.
8. **6.6 cooldown — odrzucony** (w zamian spłaszczona krzywa).
5. **6.3 safelock:** jednorazowy, tylko HP, **na otwarcie Fazy 3** — zmutowany uzurpator naparza skillami, drużyna pada,
   „but it refused” (własne sformułowanie), potem bez taryfy ulgowej.
6. **6.4 pomoc Strażnika — usunięta.** Bez kółek ratunkowych: kto przepali SP, ginie i wraca do zapisu.
7. **6.5 zapas przed walką — usunięty.** Zostaje „brak gwarantowanego leczenia” z `game_design.md`; mikstury gracz przynosi sam.

## 3. Wzór z FNaFB2 (sprawdzone w danych gry)

Build: `E:/Dawid/Desktop/Gry/Five Nights at Fuckboy's 2 (Gamejolt Version)` (starszy, sprzed ostatniej aktualizacji).

- **Faza 1** (grupa walki 83): start samym Toy Freddym; Toy Bonnie dołącza w turze 5, Toy Chica w 10, Mangle w 15
  („Change Party Member: Add” w trakcie walki, tylko zwerbowani; bez TP — +15 TP i tury 3 / 7 / 11 dodał remaster CC).
  BB: 150 000 HP. Nie trzeba czekać na całą drużynę, ale bez boostów pokonanie przed 15. turą jest mało realne.
- **Faza 2** (grupa 85, B.B. Giygas): przed walką dołączają Withered. BB ma odporność na stan śmierci, więc przy 0 HP walczy
  dalej (trik VX Ace: `state_addable?` odrzuca „Death”). 100 HP w starym buildzie, 999 999 po aktualizacji — tylko dla paska HP.
  W 5. turze Mangle dostaje pełne HP i uczy się The Bite of 87 (100 TP), która kończy walkę.
- Kod gry: dołączanie postaci w trakcie walki już jest (commit `a3fc347c` w CienMgly — `PlayerStats.recruit` w walce
  dodaje postać, działa od następnej rundy). Nadaje się i pod powrót za TP, i pod powrót po turach.

## 4. Konflikty do rozstrzygnięcia

### 4.1. Szkic sam ze sobą

- Rozwiązane decyzjami z 2026-10-16: krzywa kosztów (6.2) vs koniec Fazy 2, safelock (6.3), pomoc Strażnika (6.4, usunięta),
  zapas vs „bez gwarantowanego leczenia” (6.5, usunięty).
- Zostaje [P]: czy w Fazie 3 umiejętność 10. poziomu zadaje zwykłe (duże) obrażenia, a absurdalne tylko przy przełamaniu Fazy 2;
  czy atak otwarcia Fazy 3 jest oskryptowany (zawsze zabija), czy safelock łapie dowolną śmierć na jej starcie.
- Mikstury procentowe (pkt 7): w finale nie mogą w pełni uzupełniać SP, inaczej psują krzywą kosztów [P] — przy braku zapasu
  to jedyne źródło SP, więc limit trzeba dobrać tak, żeby ~3750 SP deficytu dało się pokryć.

### 4.2. Szkic vs `game_design.md`

- **Los arcymaga/Strażnika w True:** `game_design.md` (linie ~154, 166, 205): arcymag w true endingu **ginie**, chroniąc drużynę.
  Szkic po dopisku: w True prawdziwy Strażnik (w ciele arcymaga) **przeżywa**. Do zamiany przy przenoszeniu.
- **Wzmocnienie tarczy** (`game_design.md` ~187, 214): „moc, którą arcymag odblokował bohaterowi **przed śmiercią**”. W True
  Strażnik nie umiera — uzasadnienie do przepisania (np. „zestrojenie” przed walką).
- **Faza 1 — umiejętności 9. poziomu** (`game_design.md` ~183, 186, 211, 214): przepadają na start Fazy 1 i wracają z ostatnim
  sojusznikiem. Szkic: w True gracz ma też **10. poziom** — czy 10. poziom też przepada w Fazie 1 i wraca z drużyną? W Good są
  tylko formuły 9. poziomu.
- **Skąd 9. poziom:** `game_design.md` — czary 9. poziomu tylko od arcymaga w true endingu (4 klasy: Uberheal, manipulacja
  wspomnieniami, ofensywna, klątwa). Szkic — 9. poziom dostaje gracz w Good (od Strażnika), nauczyciele 9. poziomu w Hideout od
  lv 90, a 4 klasy przechodzą na 10. poziom. Do przepisania (szkic, pkt 10).
- **Powrót sojuszników w Fazie 1:** `game_design.md` — tylko za 100 TP (tury bez znaczenia). FNaFB2 — po turach. Szkic zostawia
  regułę z `game_design.md`. Decyzja: zostaje TP?
- **Koniec Fazy 1:** `game_design.md` — „z pełną drużyną gracz pokonuje Strażnika po raz pierwszy, potem Faza 2”. Szkic: Faza 2 to
  „pełne starcie drużynowe”. Czy Faza 1 kończy się pokonaniem (pula HP), czy samym powrotem całej drużyny?
- **Dwa zakończenia → trzy:** `game_design.md` ma bad / true; szkic bad / good / true. „Mała maszyna” → „zapasowy krąg”.

## 5. Propozycje Gemini (2026-10-16) — przyjęte przez usera

Wpisane do szkicu jako pkt 11 („Ustalenia 2026-10-16”): Faza 1 za TP i koniec przez pulę HP, wzmocnienie tarczy (Good / True),
10. poziom przepada w Fazie 1, jedna umiejętność 10. poziomu + 4 klasy na 9. poziomie, zamiana ciał nieodwrócona, 4 relikwie
(bronie klas), Good Faza 2 jako zwykła walka. **Wyjątek:** zapasowy krąg **nie** w Bibliotece — gdzie indziej, decyzja po
zbudowaniu miasta w pełnej skali.

## 6. Otwarte

- Gdzie stoi zapasowy krąg (po zbudowaniu miasta).
- Złoto w NG+ (ekonomia sklepów).
- Ile mikstur zjada Faza 1 (testy).
- Limit mikstur procentowych SP w finale (pkt 4.1).
