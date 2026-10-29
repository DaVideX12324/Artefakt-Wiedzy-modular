# Zadania od najłatwiejszych / najszybszych

> Widok pomocniczy, **nie** źródło prawdy — szczegóły i statusy: [`docs/znane_problemy.md`](../znane_problemy.md). Stan na 2026-10-29.  
> Wpisy ✅ i ✖ → [`archiwum/zadania_zrobione_2026-10-29.md`](../archiwum/zadania_zrobione_2026-10-29.md).  
> Skróty: **U** = user (gra/grafika), **S** = Sonnet, **O** = Opus. ➜ = rozszerzony scope.

---

## 1. Minuty

1. **U** — sprawdzić w grze: ekran śmierci i trucizna, skrzynie / klucze / beczki / złoto, koszt walki, zakładkę „Ogólne", scroll drużyny w pauzie, wczytywanie map z dysku, grę po angielsku w oknie.
2. **U** — skomitować `Floor_Full.xcf` (submoduł, potem wskaźnik w hoście).

---

## 2. Godziny

9. **U** — (brak numeru, luka po ✅ 5–8) — brak otwartych wpisów w tej sekcji.

---

## 3. Pół dnia

16. **S** — warianty skrzyń z innych paczek i więcej mikstur w jaskiniach.
29. **S** — ujednolicić skrzynie w jednym stylu Pixel Crawlera (2026-10-29): `closed_chest_tutorial.tscn` + generator używają `legacy_amonra/RPG Chests.png`, ścieki — `sewer/Assets/Props.png`. Kandydaci: kryjówka (`_nieuzywane/hideout`), kuźnia / Desert / biblioteka — jeden zestaw na tiery.

---

## 4. Dni

25. **O** — logika miasta: konkretne wnętrza, zadania NPC, prawdziwe flagi etapów. Szkielet zrobiony 2026-10-22 (`kontekst/miasto.md`).
26. ➜ **rozszerzony scope** — finał: boss z fazami, cutscenka, ścieżki zakończeń, umiejętność 10. poziomu, limit SP w finale. Szkic: `fabula_krag_i_zakonczenia_szkic.md` sekcje 5–6.
28. ➜ **rozszerzony scope v2.0** — walki z widokiem z boku jak Desire Fantasy (sprite'y drużyny, animacje z szablonu LumenLorePixels, decyzja 2026-10-28).
29. ➜ **niski priorytet** — revamp UI pod telefony (Android): większe elementy, układ pod dotyk, walka i menu klikalne palcem. APK release działa od 2026-10-29, sterowanie dotykowe na mapie jest (`touch_controls.tscn`).

Odłożone poza inżynierkę: tilesety kolejnych map, dalszy refaktor generatora (etapy 8–12), finał (pkt 26), walki z boku (pkt 28).

---

## Z znanych problemów (otwarte, od najłatwiejszych)

**Minuty / godziny**
- **U** — sprawdzić w grze: mysz w walce (klik wroga, listy, znacznik celu, klik po fokusie), pytania bossów, skróty dev w eksporcie, kafle wielokratkowe na `Props`, grzyby nad ścianą; sloty (Q/E), trasa map (jaskinia po tutorialu od południa), skille klasowe.
- **S/O** — `PlateauPass._solve` ~750 ms na 250² — zysk ≤ 0,5 s przy ryzyku regresji 42/42; raczej odpuścić.

**Pół dnia**
- **S** — propozycja korzenia modułu z położenia skryptu (`module_root()`), po zatwierdzeniu przez usera.
- **S** — ścieki: uskoki lica przy dostawionych pokojach (`diag_sewer_thin_walls.gd`).
- ➜ **opcjonalne** — częstsze nisze-przejścia (celowe wycięcie ściany do głębokości 3).
- **O** — pancerz na późnych poziomach: wzór `ATK×4 × 100/(100+DEF·k)` albo mocniejszy DEF (po zmierzeniu drabiny).
- **O** — NPC: kwestie przy nowym tierze (`required_flag`), flagi kowala i sklepów, skrzynia przeklęta, akcesoria z bonusem slotów.

**Dni**
- ➜ **opcjonalne** — ukryte przejścia między pokojami (tunel pod voidem, shader + kolizje) — projekt najpierw.

**User / poza inżynierką**
- Miasto (ręcznie), wariant kafli RIM nisz-przejść, tilesety kolejnych map, mapy otwarte (las).
