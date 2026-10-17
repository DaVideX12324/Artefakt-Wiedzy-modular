import json, random

ANY = 1000001


def load(path):
    return json.load(open(path, encoding='utf-8'))


def layer_def(d, name):
    return [x for x in d['defs']['layers'] if x['identifier'] == name][0]


def eval_rules(ldef, csv, w, h, tile_cols, grid=16, seed=1):
    """Zastosuj reguły autolayera LDtk do siatki IntGrid. Zwraca listę autoLayerTiles."""
    rules = [r for g in ldef['autoRuleGroups'] if g['active'] for r in g['rules'] if r['active']]
    rnd = random.Random(seed)
    out = []
    def val(x, y, oob):
        if 0 <= x < w and 0 <= y < h:
            return csv[y * w + x]
        return oob
    for cy in range(h):
        for cx in range(w):
            for r in rules:
                n = r['size']
                half = n // 2
                ok = True
                for j in range(n):
                    for i in range(n):
                        p = r['pattern'][j * n + i]
                        if p == 0:
                            continue
                        v = val(cx + i - half, cy + j - half, r['outOfBoundsValue'])
                        if p == ANY:
                            m = v != 0
                        elif p == -ANY:
                            m = v == 0
                        elif p > 0:
                            m = v == p
                        else:
                            m = v != -p
                        if not m:
                            ok = False
                            break
                    if not ok:
                        break
                if not ok:
                    continue
                if r['chance'] < 1 and rnd.random() > r['chance']:
                    continue
                ids = r['tileRectsIds'][rnd.randrange(len(r['tileRectsIds']))] if len(r['tileRectsIds']) > 1 else r['tileRectsIds'][0]
                for t in ids[:1] if r['tileMode'] == 'Single' else ids:
                    out.append({'px': [cx * grid, cy * grid], 'src': [(t % tile_cols) * grid, (t // tile_cols) * grid], 'f': 0, 't': t,
                                'd': [r['uid'], cy * w + cx], 'a': r['alpha']})
                if r['breakOnMatch']:
                    break
    return out
