#!/usr/bin/env python3
"""
tools/check_i18n.py - Internationalization validator and status checker.

Verifies:
- All i18n JSON files parse properly
- pl.json and en.json key symmetry
- No empty values in JSON files
- Placeholder consistency ({...}) between PL and EN
- No duplicate keys across different i18n catalogs
- Scene text coverage in pl.json (per phase or strict)
- Warnings for identical PL text with differing EN translations
- Map of remaining GDScript files with Polish string literals
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

POLISH_CHARS_RE = re.compile(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]")
LETTERS_RE = re.compile(r"[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ]")
PLACEHOLDER_RE = re.compile(r"\{([^{}]+)\}")
STRING_LITERAL_RE = re.compile(r'("""[\s\S]*?"""|\'\'\'[\s\S]*?\'\'\'|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')')
NODE_RE = re.compile(r'^\[node\s+name="([^"]+)"(?:\s+type="([^"]+)")?(?:\s+parent="([^"]+)")?')
ATTR_RE = re.compile(r'^(text|placeholder_text|tooltip_text|title)\s*=\s*("(?:\\.|[^"\\])*"|"""[\s\S]*?""")')
PRINT_OR_PUSH_RE = re.compile(r"\b(print|print_rich|push_warning|push_error)\s*\(")

SKIP_PATH_PARTS = ("_host/", "addons/", "tests/", "assets/", ".godot/", "_template/")


def is_skipped(path_str: str) -> bool:
    norm = path_str.replace("\\", "/")
    return any(part in norm for part in SKIP_PATH_PARTS)


def find_i18n_dirs(root: Path):
    dirs = []
    for path in root.rglob("i18n"):
        if path.is_dir() and not is_skipped(path.as_posix()):
            # check if directory has json files
            if list(path.glob("*.json")):
                dirs.append(path)
    return sorted(dirs)


def validate_json_catalogs(i18n_dirs):
    errors = []
    warnings = []
    all_keys = {}  # key -> dir_path
    catalogs = {}  # dir_path -> {"pl": dict, "en": dict}
    pl_to_en = {}  # pl_text -> {en_text: [(catalog, key)]}

    for d in i18n_dirs:
        rel_d = d.as_posix()
        pl_path = d / "pl.json"
        en_path = d / "en.json"

        if not pl_path.exists():
            errors.append(f"[{rel_d}] Brakuje pliku pl.json")
            continue
        if not en_path.exists():
            errors.append(f"[{rel_d}] Brakuje pliku en.json")
            continue

        try:
            pl_data = json.loads(pl_path.read_text(encoding="utf-8"))
        except Exception as e:
            errors.append(f"[{rel_d}/pl.json] Błąd parsowania JSON: {e}")
            continue

        try:
            en_data = json.loads(en_path.read_text(encoding="utf-8"))
        except Exception as e:
            errors.append(f"[{rel_d}/en.json] Błąd parsowania JSON: {e}")
            continue

        if not isinstance(pl_data, dict):
            errors.append(f"[{rel_d}/pl.json] Główna struktura nie jest słownikiem")
            continue
        if not isinstance(en_data, dict):
            errors.append(f"[{rel_d}/en.json] Główna struktura nie jest słownikiem")
            continue

        catalogs[rel_d] = {"pl": pl_data, "en": en_data}

        # Key symmetry
        pl_keys = set(pl_data.keys())
        en_keys = set(en_data.keys())

        missing_in_en = pl_keys - en_keys
        missing_in_pl = en_keys - pl_keys

        if missing_in_en:
            errors.append(f"[{rel_d}] Klucze w pl.json, brakujące w en.json: {sorted(missing_in_en)}")
        if missing_in_pl:
            errors.append(f"[{rel_d}] Klucze w en.json, brakujące w pl.json: {sorted(missing_in_pl)}")

        # Empty values & Placeholder checks
        common_keys = pl_keys & en_keys
        for k in common_keys:
            pl_val = str(pl_data[k])
            en_val = str(en_data[k])

            if not pl_val.strip():
                errors.append(f"[{rel_d}/pl.json] Pusta wartość dla klucza '{k}'")
            if not en_val.strip():
                errors.append(f"[{rel_d}/en.json] Pusta wartość dla klucza '{k}'")

            pl_ph = set(PLACEHOLDER_RE.findall(pl_val))
            en_ph = set(PLACEHOLDER_RE.findall(en_val))
            if pl_ph != en_ph:
                errors.append(f"[{rel_d}] Niezgodne zmienne formatowania {{{k}}}: PL={pl_ph}, EN={en_ph}")

            # Cross-catalog identical PL with differing EN
            if pl_val.strip() and en_val.strip():
                if pl_val not in pl_to_en:
                    pl_to_en[pl_val] = {}
                if en_val not in pl_to_en[pl_val]:
                    pl_to_en[pl_val][en_val] = []
                pl_to_en[pl_val][en_val].append((rel_d, k))

        # Check duplicate keys across different catalogs
        for k in pl_keys:
            if k in all_keys:
                errors.append(f"Zduplikowany klucz '{k}' w katalogu '{rel_d}' (wcześniej w '{all_keys[k]}')")
            else:
                all_keys[k] = rel_d

    # Warnings for identical PL text with different EN translations
    for pl_text, en_dict in pl_to_en.items():
        if len(en_dict) > 1:
            diffs = []
            for en_text, sources in en_dict.items():
                src_str = ", ".join(f"{k} ({src})" for src, k in sources)
                diffs.append(f"'{en_text}' -> {src_str}")
            warnings.append(
                f"Polski tekst \"{pl_text}\" ma różne tłumaczenia angielskie:\n  " + "\n  ".join(diffs)
            )

    return catalogs, errors, warnings


def extract_scene_texts(root: Path):
    """
    Extracts text/placeholder_text/tooltip_text/title from .tscn files.
    Nodes with auto_translate_mode = 2 and their children are excluded.
    Texts with no letters are excluded.
    """
    scene_items = []  # dict: {file, path, attr, text, category}

    for p in sorted(root.rglob("*.tscn")):
        rel = p.as_posix()
        if is_skipped(rel):
            continue

        try:
            content = p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

        lines = content.splitlines()
        root_name = ""
        nodes_mode = {}  # full_path -> effective_mode
        current_node_path = None

        i = 0
        while i < len(lines):
            line = lines[i]
            node_match = NODE_RE.match(line)
            if node_match:
                name = node_match.group(1)
                parent = node_match.group(3)

                if parent is None:
                    root_name = name
                    path = name
                    eff_mode = 0
                elif parent == ".":
                    path = f"{root_name}/{name}"
                    eff_mode = nodes_mode.get(root_name, 0)
                else:
                    full_parent = f"{root_name}/{parent}"
                    path = f"{full_parent}/{name}"
                    eff_mode = nodes_mode.get(full_parent, 0)
                    for np, m in nodes_mode.items():
                        if (full_parent == np or full_parent.startswith(np + "/")) and m == 2:
                            eff_mode = 2
                            break

                nodes_mode[path] = eff_mode
                current_node_path = path
                i += 1
                continue

            if line.startswith("["):
                current_node_path = None
                i += 1
                continue

            if current_node_path:
                atm_match = re.match(r"^auto_translate_mode\s*=\s*(\d+)", line)
                if atm_match:
                    nodes_mode[current_node_path] = int(atm_match.group(1))

                attr_match = ATTR_RE.match(line)
                if attr_match:
                    val_raw = attr_match.group(2)
                    if val_raw.startswith('"""'):
                        val = val_raw[3:-3]
                    else:
                        val = val_raw[1:-1]
                    val = val.replace('\\"', '"').replace("\\n", "\n")

                    # Check if disabled
                    is_disabled = False
                    for np, m in nodes_mode.items():
                        if (current_node_path == np or current_node_path.startswith(np + "/")) and m == 2:
                            is_disabled = True
                            break

                    if not is_disabled and LETTERS_RE.search(val):
                        # Determine category
                        if rel.startswith("modules/quiz_rpg/"):
                            category = "quiz_rpg"
                        elif rel.startswith("modules/BitBomber/"):
                            category = "BitBomber"
                        else:
                            category = "host"

                        scene_items.append({
                            "file": rel,
                            "node": current_node_path,
                            "attr": attr_match.group(1),
                            "text": val,
                            "category": category,
                        })
            i += 1

    return scene_items


def scan_gdscript_files(root: Path):
    """
    Finds .gd files with string literals containing Polish characters
    outside comments and print/push_* calls.
    """
    gd_results = {}  # file -> list of (line_num, line_str, literals)

    for p in sorted(root.rglob("*.gd")):
        rel = p.as_posix()
        if is_skipped(rel):
            continue

        try:
            content = p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

        lines = content.splitlines()
        matching_lines = []

        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith("#"):
                continue

            # Remove trailing comments outside string literals
            # Simple approximation: if '#' exists, find comments
            code_part = line
            # Check print/push_* calls
            if PRINT_OR_PUSH_RE.search(code_part):
                continue

            # Find all string literals
            literals = STRING_LITERAL_RE.findall(code_part)
            polish_literals = []
            for lit in literals:
                # unquote
                if lit.startswith('"""') or lit.startswith("'''"):
                    val = lit[3:-3]
                else:
                    val = lit[1:-1]
                if POLISH_CHARS_RE.search(val):
                    polish_literals.append(val)

            if polish_literals:
                matching_lines.append((idx, line.strip(), polish_literals))

        if matching_lines:
            gd_results[rel] = matching_lines

    return gd_results


def main():
    parser = argparse.ArgumentParser(description="Sprawdzarka kompletności i poprawności tłumaczeń i18n.")
    parser.add_argument(
        "--phase",
        type=str,
        default="0",
        help="Aktualna faza wdrożenia (0, 1, 2, 3, 4, 5 lub 'all'). Domyślnie 0.",
    )
    parser.add_argument(
        "--strict-scenes",
        action="store_true",
        help="Wymuszaj obecność WSZYSTKICH tekstów scen w pl.json niezależnie od fazy.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Wypisz szczegółowe listy brakujących tekstów i plików .gd.",
    )
    args = parser.parse_args()

    root = Path(".")
    print("=" * 70)
    print("  WALIDATOR I18N — Artefakt Wiedzy")
    print(f"  Faza: {args.phase}")
    print("=" * 70)

    # 1. Discover and validate JSON catalogs
    i18n_dirs = find_i18n_dirs(root)
    print(f"\n[1/4] Znalezione katalogi i18n ({len(i18n_dirs)}):")
    for d in i18n_dirs:
        print(f"  - {d.as_posix()}")

    catalogs, json_errors, json_warnings = validate_json_catalogs(i18n_dirs)

    # Build union of all Polish texts in pl.json files
    all_pl_values = set()
    for cat_data in catalogs.values():
        for val in cat_data["pl"].values():
            all_pl_values.add(str(val))

    # 2. Extract scene texts
    scene_items = extract_scene_texts(root)
    unique_scene_texts = set(item["text"] for item in scene_items)

    by_cat = {"host": [], "quiz_rpg": [], "BitBomber": []}
    for item in scene_items:
        by_cat[item["category"]].append(item)

    missing_scenes_by_cat = {"host": [], "quiz_rpg": [], "BitBomber": []}
    for item in scene_items:
        if item["text"] not in all_pl_values:
            missing_scenes_by_cat[item["category"]].append(item)

    total_missing_scenes = sum(len(items) for items in missing_scenes_by_cat.values())
    unique_missing_scene_texts = set(
        item["text"] for items in missing_scenes_by_cat.values() for item in items
    )

    print(f"\n[2/4] Teksty w scenach (.tscn):")
    print(f"  Łącznie wystąpień tekstu w scenach: {len(scene_items)} (unikalnych: {len(unique_scene_texts)})")
    for cat_name, items in by_cat.items():
        missing_count = len(missing_scenes_by_cat[cat_name])
        uniq_missing = len(set(x["text"] for x in missing_scenes_by_cat[cat_name]))
        print(f"  - {cat_name:10}: {len(items):3} wystąpień | przetłumaczonych: {len(items)-missing_count:3} | oczekujących: {missing_count:3} (unikalnych: {uniq_missing})")

    # 3. Scan GDScript files
    gd_results = scan_gdscript_files(root)
    total_gd_lines = sum(len(lines) for lines in gd_results.values())

    print(f"\n[3/4] Literały z polskimi znakami w kodzie GDScript (.gd):")
    print(f"  Plików .gd wymagających i18n: {len(gd_results)}")
    print(f"  Łącznie linii z literałami PL: {total_gd_lines}")

    # Determine which phase strictness applies
    phase_str = str(args.phase).lower()
    scene_errors = []

    if args.strict_scenes or phase_str in ("all", "5"):
        # All scenes must be translated
        for item in scene_items:
            if item["text"] not in all_pl_values:
                scene_errors.append(f"[{item['file']}] Węzeł '{item['node']}' ({item['attr']}): brak tekstu \"{item['text']}\" w pl.json")
    elif phase_str == "1":
        # Host scenes must be translated
        for item in missing_scenes_by_cat["host"]:
            scene_errors.append(f"[{item['file']}] Host węzeł '{item['node']}' ({item['attr']}): brak tekstu \"{item['text']}\" w pl.json")
    elif phase_str in ("2", "3", "4"):
        # Host + quiz_rpg scenes must be translated
        for item in missing_scenes_by_cat["host"] + missing_scenes_by_cat["quiz_rpg"]:
            scene_errors.append(f"[{item['file']}] Węzeł '{item['node']}' ({item['attr']}): brak tekstu \"{item['text']}\" w pl.json")

    # 4. Report errors & warnings
    print("\n" + "=" * 70)
    print("  WYNIKI WERYFIKACJI")
    print("=" * 70)

    if json_warnings:
        print(f"\nOSTRZEŻENIA ({len(json_warnings)}):")
        for w in json_warnings:
            print(f"  [WARN] {w}")

    all_errors = json_errors + scene_errors

    if all_errors:
        print(f"\nBŁĘDY ({len(all_errors)}):")
        for err in all_errors:
            print(f"  [BŁĄD] {err}")
    else:
        print("\nBrak krytycznych błędów dla aktualnej fazy!")

    if args.verbose or phase_str == "0":
        print("\n--- MAPA PLIKÓW .GD Z POLSKIMI LITERAŁAMI ---")
        for f, lines in sorted(gd_results.items(), key=lambda x: -len(x[1])):
            print(f"  {f:60} : {len(lines):2} linii")

    print("\n" + "-" * 70)
    print(f"Podsumowanie Fazy {args.phase}:")
    print(f"  - Błędy JSON:               {len(json_errors)}")
    print(f"  - Błędy scen dla tej fazy:  {len(scene_errors)}")
    print(f"  - Oczekujące teksty scen:   {total_missing_scenes} (unikalnych: {len(unique_missing_scene_texts)})")
    print(f"  - Oczekujące pliki .gd:     {len(gd_results)} ({total_gd_lines} linii)")
    print("-" * 70)

    if all_errors:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
