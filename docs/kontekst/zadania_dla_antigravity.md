# Zadania dla Antigravity (Gemini) — teksty i dane, bez projektowania

Zasady wspólne: czytaj pliki z dysku przed edycją (repo bywa edytowane równolegle); nie zmieniaj kodu `.gd` ani liczb w `.tres`
(poza polami wskazanymi niżej); bez motywów FNaF; polski + angielski tam, gdzie wskazano; po pracy napisz, co zmieniłeś.
Weryfikację i commit robi Claude (testy `check_i18n`).

## Zadanie A — `scan_text` wrogów (po polsku)

Pole `scan_text` w danych wroga (`modules/quiz_rpg/resources/enemies/pixel_crawler/data/*.tres` oraz `resources/enemies/enemy_*.tres`)
to opis, który gracz widzi w logu walki po użyciu umiejętności Skan (`scripts/quiz/quiz_combat_controller.gd`, `_scan_enemy`; gdy pole jest puste,
Skan pokazuje statystyki i listę umiejętności). **Dziś żaden wróg go nie ma.**

- Dopisz w sekcji `[resource]` linię `scan_text = "…"` (jedna linia, 1–2 zdania, do ok. 160 znaków, bez cudzysłowów i znaków `\` w treści).
- Treść: krótka wskazówka dla gracza (czym jest wróg, czego unika / na co jest wrażliwy, jakiej sztuczki używa), ton jak opis w grach JRPG
  („Wilgotny grzyb zarażający zarodnikami. Podatny na ogień.”). Opieraj się na nazwie, statystykach i skillach z tabeli; nie wymyślaj mechanik,
  których wróg nie ma (statusy tylko z jego `battle_skills`, sprawdź `resources/enemies/skills/*.tres` i
  `docs/kontekst/skille_i_pierwowzory.md`, kolumna „Obecnie”).
- Wzór (tylko styl): FNaFB CC ma ~38 opisów wrogów — styl krótki, jedna wskazówka.
- Tylko polski (angielski przy okazji wdrożenia tłumaczeń).

| Plik (bez `.tres`) | Nazwa | Tier | HP | ATK | DEF | Ma skille | Ma scan_text |
|---|---|---|---|---|---|---|---|
| `bandit_fighter` | Bandyta Wojownik | 3 | 900 | 90 | 90 | tak | tak |
| `bandit_scout` | Bandyta Zwiadowca | 1 | 100 | 26 | 30 | — | tak |
| `bandit_sorcerer` | Bandyta Czarownik | 2 | 400 | 60 | 61 | tak | tak |
| `bandit_tracker` | Bandyta Tropiciel | 2 | 400 | 60 | 61 | tak | tak |
| `bat_fur` | Włochaty Nietoperz | 1 | 100 | 26 | 30 | — | tak |
| `bat_small` | Mały Nietoperz | 1 | 100 | 26 | 30 | — | tak |
| `elf_base` | Elf | 1 | 100 | 26 | 30 | — | tak |
| `elf_druid` | Elf Druid | 2 | 400 | 60 | 61 | tak | tak |
| `elf_hunter` | Elf Łowca | 2 | 400 | 60 | 61 | tak | tak |
| `elf_ranger` | Elf Tropiciel | 3 | 900 | 90 | 90 | tak | tak |
| `fungus_heavy` | Ciężki Grzyb | 3 | 900 | 90 | 90 | tak | tak |
| `fungus_immature` | Młody Grzyb | 1 | 100 | 26 | 30 | — | tak |
| `fungus_long` | Wysoki Grzyb | 2 | 400 | 60 | 61 | tak | tak |
| `fungus_old` | Stary Grzyb | 4 | 2500 | 155 | 140 | tak | tak |
| `mummy_base` | Mumia | 1 | 100 | 26 | 30 | — | tak |
| `mummy_mage` | Mumia Mag | 2 | 400 | 60 | 61 | tak | tak |
| `mummy_rogue` | Mumia Łotrzyk | 2 | 400 | 60 | 61 | tak | tak |
| `mummy_warrior` | Mumia Wojownik | 3 | 900 | 90 | 90 | tak | tak |
| `orc_base` | Ork | 1 | 100 | 26 | 30 | — | tak |
| `orc_rogue` | Ork Łotrzyk | 2 | 400 | 60 | 61 | tak | tak |
| `orc_shaman` | Ork Szaman | 2 | 400 | 60 | 61 | tak | tak |
| `orc_warrior` | Ork Wojownik | 3 | 900 | 90 | 90 | tak | tak |
| `rat_base` | Szczur | 1 | 100 | 26 | 30 | — | tak |
| `rat_mage` | Szczur Mag | 2 | 400 | 60 | 61 | tak | tak |
| `rat_rogue` | Szczur Łotrzyk | 2 | 400 | 60 | 61 | tak | tak |
| `rat_warrior` | Szczur Wojownik | 3 | 900 | 90 | 90 | tak | tak |
| `royal_archer` | Łucznik | 2 | 400 | 60 | 61 | tak | tak |
| `royal_knight` | Rycerz | 3 | 900 | 90 | 90 | tak | tak |
| `royal_priest` | Kapłan | 2 | 400 | 60 | 61 | tak | tak |
| `royal_soldier` | Żołnierz | 1 | 100 | 26 | 30 | — | tak |
| `scholar_cataloguer` | Katalogista | 1 | 100 | 26 | 30 | — | tak |
| `scholar_censor` | Cenzor | 2 | 400 | 60 | 61 | tak | tak |
| `scholar_director` | Dyrektor | 3 | 900 | 90 | 90 | tak | tak |
| `scholar_researcher` | Badacz | 1 | 100 | 26 | 30 | — | tak |
| `skeleton_base` | Szkielet | 1 | 100 | 26 | 30 | — | tak |
| `skeleton_mage` | Szkielet Mag | 2 | 400 | 60 | 61 | tak | tak |
| `skeleton_rogue` | Szkielet Łotrzyk | 2 | 400 | 60 | 61 | tak | tak |
| `skeleton_warrior` | Szkielet Wojownik | 3 | 900 | 90 | 90 | tak | tak |
| `statue_feminine` | Posąg Kobiety | 1 | 100 | 26 | 30 | — | tak |
| `statue_masculine` | Posąg Mężczyzny | 1 | 100 | 26 | 30 | — | tak |
| `statue_medusa` | Meduza | 3 | 900 | 90 | 90 | tak | tak |
| `statue_old` | Posąg Starca | 2 | 400 | 60 | 61 | tak | tak |
| `stone_base` | Kamieniak | 1 | 100 | 26 | 30 | — | tak |
| `stone_broken` | Rozbity Kamieniak | 1 | 100 | 26 | 30 | — | tak |
| `stone_golem` | Kamienny Golem | 3 | 900 | 90 | 90 | tak | tak |
| `stone_lava` | Lawowy Kamieniak | 3 | 900 | 90 | 90 | tak | tak |
| `zombie_banshee` | Banshee | 2 | 400 | 60 | 61 | tak | tak |
| `zombie_base` | Zombie | 1 | 100 | 26 | 30 | — | tak |
| `zombie_muscle` | Zombie Osiłek | 3 | 900 | 90 | 90 | tak | tak |
| `zombie_overweight` | Zombie Grubas | 2 | 400 | 60 | 61 | tak | tak |

## Zadanie B — opisy skilli wrogów (pl.json i en.json)

W `modules/quiz_rpg/resources/i18n/pl.json` i `en.json` opisy wrogich skilli (`skill.<plik>.desc` dla: `dual_attack`, `triple_attack`, `phantom_volt`,
`decay_breath`, `poison_vine`, `spook_howl`, `blinding_smoke`, `dizzying_gaze`, `toxic_gaze`, `battering_dash`, `whirling_slash`, `dark_regen`,
`relentless_assault`, `heavy_strike`, `knockdown`, `sonic_blast`, `timed_charge`, `burst_swarm`, `crushing_blow`, `frenzy_charge`, `venom_screech`)
mówią o „sojuszniku”, bo były pisane z perspektywy wroga. Gracz czyta je w Skanie, więc:

- PL: „sojusznika / sojuszników” → „bohatera” (cel pojedynczy) albo „drużynę” (cel wszyscy), czasownik w 3. os. („Wróg wyprowadza dwa uderzenia w bohatera.”).
- EN: „ally / allies” → „hero” albo „party”.
- Nie zmieniaj liczb ani kluczy; oba pliki muszą mieć identyczne zestawy kluczy i parsować się jako JSON (UTF-8, wcięcie 2 spacje).

## Zadanie C — statusy: nazwy i opisy do tłumaczeń (tylko dane JSON)

Statusy w `modules/quiz_rpg/resources/statuses/*.tres` (pola `display_name`, `description`). Do `pl.json` i `en.json` dopisz klucze:
`status.<plik>.name` i `status.<plik>.desc` (plik = nazwa `.tres` bez rozszerzenia, np. `status.poison.name`), PL = obecny tekst z `.tres`
(popraw tylko literówki), EN = tłumaczenie. Jeśli opis w `.tres` jest pusty, napisz 1 zdanie zgodne z mechaniką (sprawdź pola efektu w `.tres`).
Podpięcie kluczy do kodu zrobi Claude po oddaniu (osobny krok).
