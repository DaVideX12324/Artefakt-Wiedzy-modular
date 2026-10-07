"""Prototyp v5 układu ścieków pod miastem (jednorazowy, poza repo).
Sieć kanałów rośnie jak plątanina (skręty, odnogi od odnóg). Odcinki: tunnel (chodniki po obu stronach),
hall (kanał przez pokój / kompleks), walled (samo koryto między ścianami + korytarz za ścianą od hali do hali,
brama + dźwignia). Pokoje rzadko i daleko, łączone korytarzami A* (skręty, nie przecinają pokoi, ściana od innej
podłogi), do długich korytarzy doklejane pokoiki."""
import json, random, sys, heapq, os
from collections import deque
import numpy as np

W = int(sys.argv[1]) if len(sys.argv) > 1 else 160
H = int(sys.argv[2]) if len(sys.argv) > 2 else 160
SEED = int(sys.argv[3]) if len(sys.argv) > 3 else 119
OUT = sys.argv[4] if len(sys.argv) > 4 else 'proto5.json'
rng = random.Random(SEED)

M, CW, LANE, WALL_H, WALL_V = 3, 4, 3, 5, 2
CLEAR = 16                       # odstęp między kanałami (krawędź - krawędź)
floor = np.zeros((H, W), bool)
water = np.zeros((H, W), bool)
dry = np.zeros((H, W), bool)
lanes = np.zeros((H, W), bool)
service = np.zeros((H, W), bool)
hallm = np.zeros((H, W), bool)
roomm = np.zeros((H, W), bool)
corrm = np.zeros((H, W), bool)
bridges, gates, halls = [], [], []


def dilate(m, rx, ry):
    """Dylatacja prostokątem (2rx+1)x(2ry+1) przez sumy skumulowane."""
    if rx == 0 and ry == 0:
        return m.copy()
    a = m.astype(np.int32)
    c = np.zeros((H + 1, W + 1), np.int32)
    c[1:, 1:] = a.cumsum(0).cumsum(1)
    ys = np.arange(H); xs = np.arange(W)
    y0 = np.clip(ys - ry, 0, H); y1 = np.clip(ys + ry + 1, 0, H)
    x0 = np.clip(xs - rx, 0, W); x1 = np.clip(xs + rx + 1, 0, W)
    s = c[y1][:, x1] - c[y0][:, x1] - c[y1][:, x0] + c[y0][:, x0]
    return s > 0


def R(m, r, v=True):
    x0, y0, x1, y1 = r
    m[max(0, y0):min(H, y1 + 1), max(0, x0):min(W, x1 + 1)] = v


def any_in(m, r):
    x0, y0, x1, y1 = r
    if x0 < 0 or y0 < 0 or x1 >= W or y1 >= H:
        return True
    return bool(m[y0:y1 + 1, x0:x1 + 1].any())


def inside(r, m=M):
    return r[0] >= m and r[1] >= m and r[2] < W - m and r[3] < H - m


# ---------- 1. Sieć kanałów: wędrowcy ze skrętami + odnogi od dowolnego odcinka ----------
segs = []    # dict(rect, axis, line, idx, kind)
DIRS = [(1, 0), (-1, 0), (0, 1), (0, -1)]


def seg_rect(hx, hy, d, L):
    if d == (1, 0): return (hx, hy, hx + L + CW - 1, hy + CW - 1), (hx + L, hy)
    if d == (-1, 0): return (hx - L, hy, hx + CW - 1, hy + CW - 1), (hx - L, hy)
    if d == (0, 1): return (hx, hy, hx + CW - 1, hy + L + CW - 1), (hx, hy + L)
    return (hx, hy - L, hx + CW - 1, hy + CW - 1), (hx, hy - L)


def too_wide(r):
    # po dodaniu odcinka nigdzie w jego okolicy nie może powstać kwadrat 5x5 samej wody (kanał szerszy niż 4)
    t = water.copy(); R(t, r)
    x0, y0, x1, y1 = max(0, r[0] - 6), max(0, r[1] - 6), min(W - 1, r[2] + 6), min(H - 1, r[3] + 6)
    sub = t[y0:y1 + 1, x0:x1 + 1].astype(np.int32)
    k = CW + 1
    if sub.shape[0] < k or sub.shape[1] < k:
        return False
    c = np.zeros((sub.shape[0] + 1, sub.shape[1] + 1), np.int32)
    c[1:, 1:] = sub.cumsum(0).cumsum(1)
    box = c[k:, k:] - c[:-k, k:] - c[k:, :-k] + c[:-k, :-k]
    return bool((box == k * k).any())


def clear_ok(r, hx, hy):
    # kanał nie może zbliżyć się do innych kanałów na < CLEAR, poza złączem (otoczenie bloku głowy)
    near = np.zeros((H, W), bool)
    R(near, (hx - CLEAR - CW, hy - CLEAR - CW, hx + CLEAR + 2 * CW, hy + CLEAR + 2 * CW))
    zone = np.zeros((H, W), bool)
    R(zone, (r[0] - CLEAR, r[1] - CLEAR, r[2] + CLEAR, r[3] + CLEAR))
    return not (water & zone & ~near).any()


def walk(hx, hy, d, line, max_segs, turn_p):
    idx = 0
    for _ in range(max_segs):
        placed = False
        for L in (rng.randint(16, 34), rng.randint(12, 20), 10):
            r, nh = seg_rect(hx, hy, d, L)
            if inside(r, M + 1) and clear_ok(r, hx, hy) and not too_wide(r):
                segs.append({'rect': r, 'axis': 'h' if d[1] == 0 else 'v', 'line': line, 'idx': idx})
                R(water, r)
                idx += 1
                hx, hy = nh
                placed = True
                break
        if not placed:
            # spróbuj skręcić zamiast stanąć
            opts = [nd for nd in DIRS if nd[0] * d[0] + nd[1] * d[1] == 0]
            rng.shuffle(opts)
            ok = False
            for nd in opts:
                r, nh = seg_rect(hx, hy, nd, 12)
                if inside(r, M + 1) and clear_ok(r, hx, hy) and not too_wide(r):
                    d = nd; ok = True; break
            if not ok:
                return
            continue
        if rng.random() < turn_p:
            opts = [nd for nd in DIRS if nd[0] * d[0] + nd[1] * d[1] == 0]
            d = rng.choice(opts)


# pień: od lewej krawędzi w prawo, skręca rzadko
walk(M + 1, rng.randint(H // 3, 2 * H // 3), (1, 0), 0, 10, 0.35)
n_branch = max(4, W * H // 2300)
line = 1
attempts = 0
while line <= n_branch and attempts < 200:
    attempts += 1
    p = rng.choice(segs)
    x0, y0, x1, y1 = p['rect']
    if p['axis'] == 'h':
        if x1 - x0 < 20: continue
        hx = rng.randint(x0 + 8, x1 - 8 - CW); hy = y0
        d = rng.choice([(0, 1), (0, -1)])
    else:
        if y1 - y0 < 20: continue
        hy = rng.randint(y0 + 8, y1 - 8 - CW); hx = x0
        d = rng.choice([(1, 0), (-1, 0)])
    before = len(segs)
    walk(hx, hy, d, line, rng.randint(2, 5), 0.6)
    if len(segs) > before:
        p['junction'] = True
        segs[before]['junction'] = True
        line += 1

# ---------- 2. Kompleksy: ciąg 2–4 odcinków jednej linii kanału -> jeden wielokąt ----------
for s_ in segs:
    s_['kind'] = 'tunnel'
lines = {}
for s_ in segs:
    lines.setdefault(s_['line'], []).append(s_)
MIN_CPLX_GAP = int(os.environ.get('CPLX_GAP', 20))
cplx_rects = []
complexes = {}


def rect_gap(a, b):
    dx = max(0, max(a[0], b[0]) - min(a[2], b[2]))
    dy = max(0, max(a[1], b[1]) - min(a[3], b[3]))
    return max(dx, dy)


def far_from_complexes(rects):
    return all(rect_gap(r, o) >= MIN_CPLX_GAP for r in rects for _, o in cplx_rects)


max_cplx = max(2, W * H // 5500)
line_ids = list(lines)
placed_any = True
while placed_any and len(complexes) < max_cplx:
    placed_any = False
    rng.shuffle(line_ids)
    for lid in line_ids:
        if len(complexes) >= max_cplx:
            break
        ln = lines[lid]
        starts = list(range(len(ln)))
        rng.shuffle(starts)
        choice = None
        for k0 in starts:
            for n in (4, 3, 2, 1):
                if k0 + n > len(ln):
                    continue
                run = ln[k0:k0 + n]
                if any(st['kind'] != 'tunnel' for st in run):
                    continue
                if n == 1 and not run[0].get('junction'):
                    continue
                if not far_from_complexes([st['rect'] for st in run]):
                    continue
                choice = run
                break
            if choice:
                break
        if not choice:
            continue
        cid = len(complexes)
        for st in choice:
            st['kind'] = 'hall'; st['cid'] = cid
        cplx_rects.extend((cid, st['rect']) for st in choice)
        complexes[cid] = {'segs': choice}
        placed_any = True

# suche koryto: cała jedna linia odnogi
if rng.random() < 0.8 and len(lines) > 1:
    dl = rng.choice([l for l in lines if l != 0])
    for s in lines[dl]:
        R(dry, s['rect'])
dry &= water

# ---------- 3. Chodniki (tunel), hale (z zapasem, bez wchodzenia na inne kanały) ----------
def bands(s):
    x0, y0, x1, y1 = s['rect']
    if s['axis'] == 'h':
        return [(x0, y0 - LANE, x1, y0 - 1), (x0, y1 + 1, x1, y1 + LANE)]
    return [(x0 - LANE, y0, x0 - 1, y1), (x1 + 1, y0, x1 + LANE, y1)]


for s in segs:
    if s['kind'] == 'tunnel':
        for b in bands(s):
            R(lanes, b)
lanes &= ~water

hall_cid_m = np.zeros((H, W), bool)
hall_cid = np.full((H, W), -9, np.int32)
EXT_MAX = 10


def seg_side_rect(st, t0, t1, k, e):
    """Pas brzegu odcinka st na odcinku osi [t0, t1], strona k (0 = góra / lewo), szerokość e od krawędzi wody."""
    x0, y0, x1, y1 = st['rect']
    if st['axis'] == 'h':
        return (t0, y0 - e, t1, y0 - 1) if k == 0 else (t0, y1 + 1, t1, y1 + e)
    return (x0 - e, t0, x0 - 1, t1) if k == 0 else (x1 + 1, t0, x1 + e, t1)


for cid, cx in complexes.items():
    run = cx['segs']
    own = np.zeros((H, W), bool)
    for st in run:
        R(own, st['rect'])
        x0, y0, x1, y1 = st['rect']
        for o in segs:                       # kanały stykające się (skręt / węzeł w sali) nie są obce
            r = o['rect']
            if not (r[2] < x0 - 1 or r[0] > x1 + 1 or r[3] < y0 - 1 or r[1] > y1 + 1):
                R(own, r)
    foreign = dilate(water & ~own, 3, 3) | dilate(hall_cid_m & (hall_cid != cid), WALL_V + 1, WALL_H + 1)

    def fit(st, t0, t1, k, want):
        e = 0
        while e < want and not any_in(foreign, seg_side_rect(st, t0, t1, k, e + 1)) and \
                inside(seg_side_rect(st, t0, t1, k, e + 1)):
            e += 1
        return e if e >= 2 else 0              # brzeg 1 kratki to za mało na przejście

    # zwężenie z korytarzem za ścianą: odcinek >= 18, środek bez brzegu po stronie k
    pinch = None
    longs = [st for st in run if max(st['rect'][2] - st['rect'][0], st['rect'][3] - st['rect'][1]) >= 18]
    if longs and rng.random() < 0.8:
        st = rng.choice(longs)
        lo, hi = (st['rect'][0], st['rect'][2]) if st['axis'] == 'h' else (st['rect'][1], st['rect'][3])
        pinch = {'seg': st, 'k': rng.randrange(2), 'p0': lo + 6, 'p1': hi - 6}
    pm = np.zeros((H, W), bool)
    ext = [rng.randint(3, 7), rng.randint(3, 7)]
    prev_ok = None
    for st in run:
        lo, hi = (st['rect'][0], st['rect'][2]) if st['axis'] == 'h' else (st['rect'][1], st['rect'][3])
        in_pinch = lambda a, b: pinch and pinch['seg'] is st and b >= pinch['p0'] and a <= pinch['p1']
        # miejsce kładki: środek odcinka (poza zwężeniem) — tam oba brzegi >= 2
        mid = (lo + hi) // 2
        if in_pinch(mid - 3, mid + 3):
            mid = lo + CW + 3 if pinch['p0'] - lo > hi - pinch['p1'] else hi - CW - 4
        st['bridge_t'] = mid
        t = lo
        while t <= hi:
            t1 = min(hi, t + rng.randint(4, 8) - 1)
            for k in (0, 1):
                ext[k] = max(0, min(EXT_MAX, ext[k] + rng.randint(-3, 3)))
            want = ext[:]
            force = [False, False]
            if pinch and pinch['seg'] is st:
                k = pinch['k']
                if in_pinch(t, t1):
                    want[k] = 0
                    want[1 - k] = max(want[1 - k], 2); force[1 - k] = True
                elif t1 >= pinch['p0'] - 8 and t <= pinch['p1'] + 8:
                    want[k] = max(want[k], (WALL_H if st['axis'] == 'h' else WALL_V) + 4)   # zatoka na wejście korytarza
                    want[1 - k] = max(want[1 - k], 2); force[1 - k] = True                 # brzeg ciągły przez zwężenie
            if t <= mid + 1 and t1 >= mid:
                want = [max(want[0], 2), max(want[1], 2)]; force = [True, True]
            got = [fit(st, t, t1, k, want[k]) for k in (0, 1)]
            # ciągłość: brzeg po stronie, która była w poprzednim kawałku
            if prev_ok is not None and not any(got[k] >= 2 for k in prev_ok):
                force[next(iter(prev_ok))] = True
            if got[0] < 2 and got[1] < 2 and not any(force):
                force[1 if want[1] >= want[0] else 0] = True
            for k in (0, 1):
                if force[k] and got[k] < 2:
                    got[k] = 2
            for k in (0, 1):
                if got[k]:
                    R(pm, seg_side_rect(st, t, t1, k, got[k]))
            prev_ok = {k for k in (0, 1) if got[k] >= 2}
            t = t1 + 1
    pm &= ~water
    # najcieńsza ściana między fragmentami wielokąta = 2 kratki (limit assetu): szczeliny 1 kratki -> podłoga
    for _ in range(2):
        f = pm | water
        gap_h = ~f[:, 1:-1] & pm[:, :-2] & pm[:, 2:]
        gap_v = ~f[1:-1, :] & pm[:-2, :] & pm[2:, :]
        pm[:, 1:-1] |= gap_h
        pm[1:-1, :] |= gap_v
    hallm |= pm
    hall_cid_m |= pm
    hall_cid[pm] = cid
    cx['mask'] = pm
    cx['pinch'] = pinch
    ys, xs = np.nonzero(pm)
    halls.append((int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())))
hallm &= ~water

floor |= water | lanes | hallm

# strefy przecięć: kanał poziomy (z chodnikami) przechodzi się tylko pionowo, pionowy tylko poziomo
cross_h = np.zeros((H, W), bool); cross_v = np.zeros((H, W), bool)
for s_ in segs:
    m = cross_h if s_['axis'] == 'h' else cross_v
    R(m, s_['rect'])
    if s_['kind'] == 'tunnel':
        for b in bands(s_):
            R(m, b)
cross_any = cross_h | cross_v
ZH = dilate(cross_h, WALL_V + 2, WALL_H + 2)
ZV = dilate(cross_v, WALL_V + 2, WALL_H + 2)
_wh = np.zeros((H, W), bool); _wv = np.zeros((H, W), bool)
for s_ in segs:
    R(_wh if s_['axis'] == 'h' else _wv, s_['rect'])
JZ_C = dilate(dilate(_wh & _wv, CW, CW) & water, 1, 1)   # środki korytarza: nie na wodzie przy zakręcie / węźle

def add_crossing_bridges(centers):
    wc = sorted({(x + dx, y + dy) for (x, y) in centers if water[y, x]
                 for dx in (-1, 0, 1) for dy in (-1, 0, 1) if water[y + dy, x + dx]})
    if not wc:
        return
    for (x, y) in wc:
        floor[y, x] = True
    vertical = bool(cross_h[wc[0][1], wc[0][0]])      # przez kanał poziomy = kładka pionowa
    bridges.append({'cells': [list(c) for c in wc], 'vertical': vertical, 'crossing': True})


def astar(start, target_mask, own_mask, bias=None, start_ok=None, zone_skip=None, extra_forb=None):
    """Środek korytarza: blok 3x3 ze ścianą od każdej obcej podłogi (także od celu). Cel = pierścień przed celem;
    na końcu prosty odcinek prostopadle do celu (drzwi przez ścianę)."""
    other = floor & ~own_mask & ~cross_any
    forb = dilate(other, WALL_V + 2, WALL_H + 2)
    ring = dilate(target_mask, WALL_V + 3, WALL_H + 3) & ~forb
    sx, sy = start
    INF = 10 ** 9
    best = {}
    pq = [(0, sx, sy, -1)]
    prev = {}
    while pq:
        g, x, y, dI = heapq.heappop(pq)
        if best.get((x, y, dI), INF) < g:
            continue
        if ring[y, x] and not own_mask[y, x]:
            path = [(x, y)]
            key = (x, y, dI)
            while key in prev:
                key = prev[key]; path.append((key[0], key[1]))
            path = path[::-1]
            bestd = None
            for dx, dy in DIRS:
                for L in range(1, WALL_H + 6):
                    nx, ny = x + dx * L, y + dy * L
                    if not (0 <= nx < W and 0 <= ny < H):
                        break
                    if target_mask[ny, nx]:
                        if bestd is None or L < bestd[0]:
                            bestd = (L, dx, dy)
                        break
                    if floor[ny, nx]:
                        break
            if bestd is None:
                continue
            L, dx, dy = bestd
            path += [(x + dx * k, y + dy * k) for k in range(1, L)]
            return path
        for ni, (dx, dy) in enumerate(DIRS):
            nx, ny = x + dx, y + dy
            if not (M + 1 <= nx < W - M - 1 and M + 1 <= ny < H - M - 1):
                continue
            if forb[ny, nx] and not own_mask[ny, nx] and not (start_ok is not None and start_ok[ny, nx]):
                continue
            if extra_forb is not None and extra_forb[ny, nx] and not own_mask[ny, nx]:
                continue
            if JZ_C[ny, nx] and not own_mask[ny, nx]:
                continue
            if not own_mask[ny, nx] and not ring[ny, nx] and not (zone_skip is not None and zone_skip[ny, nx]):
                zh, zv = ZH[ny, nx], ZV[ny, nx]
                if zh and zv:
                    continue                       # węzeł kanałów — nie przez skrzyżowanie
                if zh and dx != 0:
                    continue                       # przy kanale poziomym tylko ruch pionowy (prostopadle)
                if zv and dy != 0:
                    continue
            ng = g + 1 + (4 if dI not in (-1, ni) else 0) + (int(bias[ny, nx]) if bias is not None else 0)
            if ng < best.get((nx, ny, ni), INF):
                best[(nx, ny, ni)] = ng
                prev[(nx, ny, ni)] = (x, y, dI)
                heapq.heappush(pq, (ng, nx, ny, ni))
    return None


def rcenter(r):
    return ((r[0] + r[2]) // 2, (r[1] + r[3]) // 2)


# ---------- 3b. Korytarz za ścianą przy zwężeniu kompleksu: z części przed zwężeniem do części za nim ----------
def carve_service(cx):
    pz = cx['pinch']
    st, k = pz['seg'], pz['k']
    x0, y0, x1, y1 = st['rect']
    horiz = st['axis'] == 'h'
    coord = np.arange(W)[None, :].repeat(H, 0) if horiz else np.arange(H)[:, None].repeat(W, 1)
    sidem = np.zeros((H, W), bool)
    if horiz:
        R(sidem, (0, 0, W - 1, y0 - 1) if k == 0 else (0, y1 + 1, W - 1, H - 1))
    else:
        R(sidem, (0, 0, x0 - 1, H - 1) if k == 0 else (x1 + 1, 0, W - 1, H - 1))
    own = cx['mask'] & (coord < pz['p0'] - 1)
    tgt = cx['mask'] & (coord > pz['p1'] + 1)
    if rng.random() < 0.5:
        own, tgt = tgt, own
    canal = np.zeros((H, W), bool); R(canal, st['rect'])
    bias = np.where(dilate(canal, 16, 18), 0, 3).astype(np.int32) + np.where(sidem, 0, 50).astype(np.int32)
    ys, xs = np.nonzero(own & sidem & ~dilate(water, 1, 1))
    if len(xs) == 0 or not tgt.any():
        return False
    i = rng.randrange(len(xs))
    p = astar((int(xs[i]), int(ys[i])), tgt, own, bias,
              zone_skip=dilate(canal, WALL_V + 14, WALL_H + 14) & ~dilate(cross_any & ~canal, WALL_V + 2, WALL_H + 2),
              extra_forb=dilate(canal, WALL_V + 2, WALL_H + 2) | (cx['mask'] & ~own & ~tgt))
    if p is None:
        return False
    for (x, y) in p:
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                cx_, cy_ = x + dx, y + dy
                if not cx['mask'][cy_, cx_] and not water[cy_, cx_]:
                    floor[cy_, cx_] = True; service[cy_, cx_] = True
    add_crossing_bridges([c for c in p if not cx['mask'][c[1], c[0]]])
    out = [c for c in p if not own[c[1], c[0]]]
    if out:
        gx, gy = out[0]
        nx, ny = out[1] if len(out) > 1 else out[0]
        gates.append([(gx, gy - 1), (gx, gy), (gx, gy + 1)] if nx != gx else [(gx - 1, gy), (gx, gy), (gx + 1, gy)])
    return True


n_service = 0
for cx in complexes.values():
    if cx['pinch'] and carve_service(cx):
        n_service += 1

spine = water | lanes | hallm | service

# ---------- 4. Pokoje: rzadko, daleko od siebie i od sieci ----------
rooms_r = []
target = max(5, W * H // 2000)
for _ in range(target * 40):
    if len(rooms_r) >= target:
        break
    rw, rh = rng.randint(10, 17), rng.randint(9, 14)
    x0, y0 = rng.randint(M, W - M - rw), rng.randint(M + 2, H - M - rh)
    r = (x0, y0, x0 + rw - 1, y0 + rh - 1)
    big = dilate(floor, 9, 12)                      # >= 9 / 12 kratek od czegokolwiek (dłuższe korytarze)
    if any_in(big, r):
        continue
    far = dilate(spine, 30, 30)                     # ale nie dalej niż ~30 od sieci
    if not any_in(far, r):
        continue
    rooms_r.append(r)
    R(roomm, r); R(floor, r)


# ---------- 5. Korytarze A*: pokój -> sieć (chodnik / hala) albo inny pokój ----------
corridors = []




def carve_path(path):
    cells = set()
    for (x, y) in path:
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                cells.add((x + dx, y + dy))
    out = [c for c in cells if not water[c[1], c[0]] and not service[c[1], c[0]]]
    for (x, y) in out:
        floor[y, x] = True; corrm[y, x] = True
    add_crossing_bridges(path)
    return out


link_target = lanes | hallm
for r in rooms_r:
    own = np.zeros((H, W), bool); R(own, r)
    p = astar(rcenter(r), link_target, own)
    if p:
        corridors.append(carve_path([c for c in p if not own[c[1], c[0]]]))
# pętle: część pokoi łączy się z drugim pokojem
for r in rooms_r:
    if rng.random() < 0.35:
        own = np.zeros((H, W), bool); R(own, r)
        others = roomm & ~own
        p = astar(rcenter(r), others, own)
        if p:
            near_own = dilate(own, 9, 9)
            outside = [c for c in p if not own[c[1], c[0]]]
            wrap = sum(1 for c in outside if near_own[c[1], c[0]]) / max(1, len(outside))
            if wrap > 0.5:
                p = None                                  # obiega własną salę -> odrzuć
        if p and len(p) < 70:
            corridors.append(carve_path([c for c in p if not own[c[1], c[0]]]))

# ---------- 5a. Pętle: korytarz wychodzi z kompleksu i wraca do jego dalekiej części ----------
loops = 0
cl = list(complexes.values())
rng.shuffle(cl)
for cx in cl:
    if loops >= max(2, W * H // 7000):
        break
    pm = cx['mask']
    if pm.sum() < 150:
        continue
    ys, xs = np.nonzero(pm & ~dilate(~pm, 1, 1) | (pm & dilate(~floor, 1, 1)))
    idx = list(range(len(xs)))
    rng.shuffle(idx)
    done = False
    for i in idx[:40]:
        px, py = int(xs[i]), int(ys[i])
        for dx, dy in DIRS:
            L = (WALL_H if dy else WALL_V) + 3
            sx, sy = px + dx * L, py + dy * L
            if not (M + 2 <= sx < W - M - 2 and M + 2 <= sy < H - M - 2):
                continue
            if any(floor[py + dy * k, px + dx * k] for k in range(1, L + 1)):
                continue
            if dilate(floor, WALL_V + 1, WALL_H + 1)[sy, sx]:
                continue
            far = pm.copy()
            yy, xx = np.indices((H, W))
            far &= (np.abs(xx - px) + np.abs(yy - py)) > 26
            if not far.any():
                continue
            stz = np.zeros((H, W), bool); R(stz, (sx - 1, sy - 1, sx + 1, sy + 1))
            p1 = astar((sx, sy), far, np.zeros((H, W), bool), start_ok=dilate(stz, 2, 2))
            if p1 is None or len(p1) < 20:
                continue
            corridors.append(carve_path([(px + dx * k, py + dy * k) for k in range(1, L)] + p1))
            loops += 1
            done = True
            break
        if done:
            break

# ---------- 5b. Pokoiki doklejone do długich korytarzy ----------
for cc in corridors:
    if len(cc) < 3 * 22 or rng.random() > 0.5:
        continue
    ccm = np.zeros((H, W), bool)
    for (x, y) in cc:
        ccm[y, x] = True
    blk = dilate(floor & ~ccm, WALL_V + 1, WALL_H + 1)
    for _ in range(30):
        x, y = rng.choice(cc)
        rw, rh = rng.randint(7, 10), rng.randint(6, 9)
        side = rng.choice(DIRS)
        if side == (1, 0): r = (x + 1, y - rh // 2, x + rw, y - rh // 2 + rh - 1)
        elif side == (-1, 0): r = (x - rw, y - rh // 2, x - 1, y - rh // 2 + rh - 1)
        elif side == (0, 1): r = (x - rw // 2, y + 1, x - rw // 2 + rw - 1, y + rh)
        else: r = (x - rw // 2, y - rh, x - rw // 2 + rw - 1, y - 1)
        if not inside(r) or any_in(blk, r):
            continue
        # styk z korytarzem (otwarcie) — pokój przylega do korytarza, nie przecina go
        rr = np.zeros((H, W), bool); R(rr, r)
        if not (dilate(rr, 1, 1) & ccm).any() or (rr & ccm).any():
            continue
        R(roomm, r); R(floor, r)
        rooms_r.append(r)
        break

# ---------- 6. Kładki (tunel / hala), nie na obmurowanym ----------
bridge = np.zeros((H, W), bool)
for b in bridges:
    for (x, y) in b['cells']:
        bridge[y, x] = True
# strefa zakrętów / skrzyżowań: wspólny blok kanału poziomego i pionowego + jedna szerokość kanału wokół
wh = np.zeros((H, W), bool); wv = np.zeros((H, W), bool)
for s in segs:
    R(wh if s['axis'] == 'h' else wv, s['rect'])
jz = dilate(wh & wv, CW, CW)
# kładki przecięć korytarzy, które wypadły w strefie, też odpadają (korytarz zostaje, kładka przesunięta niżej)
bad = [b_ for b_ in bridges if any(jz[y, x] for (x, y) in b_['cells'])]
for b_ in bad:
    print('UWAGA kładka przecięcia w strefie zakrętu', b_['cells'][0])


def place_bridge(cells_of, t, lo, hi):
    for d in [0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6]:
        tt = t + d
        if tt < lo or tt + 1 > hi:
            continue
        cells = cells_of(tt)
        if any(jz[y, x] or bridge[y, x] for (x, y) in cells):
            continue
        xs_ = [c[0] for c in cells]; ys_ = [c[1] for c in cells]
        if min(xs_) == max(xs_) - 1 and len(set(ys_)) > 2:      # kładka pionowa (przez kanał poziomy)
            ends = [(x, min(ys_) - 1) for x in set(xs_)] + [(x, max(ys_) + 1) for x in set(xs_)]
        else:
            ends = [(min(xs_) - 1, y) for y in set(ys_)] + [(max(xs_) + 1, y) for y in set(ys_)]
        if not all(0 <= x < W and 0 <= y < H and floor[y, x] and not water[y, x] for (x, y) in ends):
            continue
        # min. 2 kratki odstępu od innej kładki
        if any(bridge[y + dy, x + dx] for (x, y) in cells for dx in (-2, -1, 1, 2) for dy in (-2, -1, 1, 2)
               if 0 <= x + dx < W and 0 <= y + dy < H):
            continue
        return cells
    return None


for s in segs:
    if s['kind'] == 'walled':
        continue
    x0, y0, x1, y1 = s['rect']
    if s['axis'] == 'h':
        span = x1 - x0 - 2 * CW
        if span < 6: continue
        n = max(1, span // 20)
        for i in range(n):
            bx = s['bridge_t'] if (i == 0 and 'bridge_t' in s) else x0 + CW + (i + 1) * span // (n + 1) + rng.randint(-2, 2)
            cells = place_bridge(lambda t: [(x, y) for x in (t, t + 1) for y in range(y0, y1 + 1)], bx, x0, x1)
            if cells:
                bridges.append({'cells': cells, 'vertical': True})
                for (x, y) in cells: bridge[y, x] = True
    else:
        span = y1 - y0 - 2 * CW
        if span < 6: continue
        n = max(1, span // 18)
        for i in range(n):
            by = s['bridge_t'] if (i == 0 and 'bridge_t' in s) else y0 + CW + (i + 1) * span // (n + 1) + rng.randint(-2, 2)
            cells = place_bridge(lambda t: [(x, y) for y in (t, t + 1) for x in range(x0, x1 + 1)], by, y0, y1)
            if cells:
                bridges.append({'cells': cells, 'vertical': False})
                for (x, y) in cells: bridge[y, x] = True

# ---------- 7. Spójność (bramy przechodnie), naprawa: korytarz A* z odciętej części ----------
walk_m = floor & ~(water & ~bridge)


def comp_from(start, block=None):
    m = walk_m & (~block if block is not None else True)
    seen = np.zeros((H, W), bool)
    q = deque([start]); seen[start[1], start[0]] = True
    while q:
        x, y = q.popleft()
        for dx, dy in DIRS:
            nx, ny = x + dx, y + dy
            if 0 <= nx < W and 0 <= ny < H and m[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True; q.append((nx, ny))
    return seen


ys, xs_ = np.nonzero(lanes | hallm)
center = min(zip(xs_, ys), key=lambda p: abs(p[0] - W // 2) + abs(p[1] - H // 2))
for _ in range(20):
    walk_m = floor & ~(water & ~bridge)
    main = comp_from(center)
    rest = walk_m & ~main
    if not rest.any():
        break
    yy, xx = np.nonzero(rest)
    seed_c = (int(xx[0]), int(yy[0]))
    piece = comp_from(seed_c)
    py, px = np.nonzero(piece)
    rect = (int(px.min()), int(py.min()), int(px.max()), int(py.max()))
    p = astar(rcenter(rect) if piece[rcenter(rect)[1], rcenter(rect)[0]] else seed_c, main & ~service & ~water, piece)
    if p is None:
        # ostatecznie: prosty korytarz L do najbliższej kratki głównej części (bez ograniczeń)
        my, mx = np.nonzero(main & ~water & ~service)
        cx, cy = (rect[0] + rect[2]) // 2, (rect[1] + rect[3]) // 2
        i = int(np.argmin(np.abs(mx - cx) + np.abs(my - cy)))
        tx, ty = int(mx[i]), int(my[i])
        p = [(x, cy) for x in range(min(cx, tx), max(cx, tx) + 1)] + [(tx, y) for y in range(min(cy, ty), max(cy, ty) + 1)]
        if any(JZ_C[y, x] for (x, y) in p):
            print('odcięty fragment (awaryjne L przez zakręt kanału) przy', rect)
            break
    carve_path(p)

# ---------- 8. Portale i dźwignie ----------
rooms_all = [r for r in rooms_r] + halls
def free_cells(r):
    x0, y0, x1, y1 = r
    sub = floor[y0:y1 + 1, x0:x1 + 1] & ~water[y0:y1 + 1, x0:x1 + 1] & ~lanes[y0:y1 + 1, x0:x1 + 1] & ~service[y0:y1 + 1, x0:x1 + 1]
    yy, xx = np.nonzero(sub)
    return [(int(x) + x0, int(y) + y0) for x, y in zip(xx, yy)]
cand = [(free_cells(r), r) for r in rooms_r if len(free_cells(r)) >= 60]
ctr = lambda f: (sum(p[0] for p in f) / len(f), sum(p[1] for p in f) / len(f))
cand.sort(key=lambda fr: (ctr(fr[0])[0] - W / 2) ** 2 + (ctr(fr[0])[1] - H / 2) ** 2)
ent_f = cand[0][0]; ent = ctr(ent_f)
ent_c = min(ent_f, key=lambda p: (p[0] - ent[0]) ** 2 + (p[1] - ent[1]) ** 2)
ex_f = max(cand[1:], key=lambda fr: (ctr(fr[0])[0] - ent[0]) ** 2 + (ctr(fr[0])[1] - ent[1]) ** 2)[0]
ex_c = min(ex_f, key=lambda p: (p[0] - ctr(ex_f)[0]) ** 2 + (p[1] - ctr(ex_f)[1]) ** 2)
gate_m = np.zeros((H, W), bool)
for g in gates:
    for (x, y) in g:
        gate_m[y, x] = True
walk_m = floor & ~(water & ~bridge)
reach = comp_from(ent_c, gate_m)
levers = []
for g in gates:
    gc = g[1]
    opts = [c for r in rooms_all for c in free_cells(r) if reach[c[1], c[0]]]
    if opts:
        levers.append(list(min(opts, key=lambda p: abs(abs(p[0] - gc[0]) + abs(p[1] - gc[1]) - 18))))

grid = [''.join('.' if floor[y, x] else '#' for x in range(W)) for y in range(H)]
cells = lambda m: [[int(x), int(y)] for y, x in zip(*np.nonzero(m))]
json.dump({'w': W, 'h': H, 'seed': SEED, 'grid': grid, 'water': cells(water), 'dry': cells(dry),
           'lanes': cells(lanes), 'service': cells(service), 'halls': cells(hallm), 'bridges': bridges,
           'gates': gates, 'levers': levers, 'portals': {'entrance': list(ent_c), 'exit': list(ex_c)}},
          open(OUT, 'w'))
kinds = [s['kind'] for s in segs]
print('kompleksy', len(complexes), 'odcinki w kompleksach', sorted(len(c['segs']) for c in complexes.values()),
      'kratki', sorted(int(c['mask'].sum()) for c in complexes.values()), 'zwężenia z korytarzem', n_service, 'pętle', loops)
print('ok', OUT, 'odcinki', len(segs), {k: kinds.count(k) for k in set(kinds)}, 'linie', len(lines),
      'pokoje', len(rooms_r), 'hale', len(halls), 'korytarze', len(corridors), 'bramy', len(gates),
      'wyjście za bramą' if not reach[ex_c[1], ex_c[0]] else '')
