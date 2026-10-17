import xml.etree.ElementTree as ET, bisect, json, numpy as np
from PIL import Image, ImageDraw
SRC='/root/.claude/uploads/0e17de7a-cba0-50f5-80ea-f4e05142e0b7/3d5545ce-Desert_Town.tmx'
r=ET.parse(SRC).getroot()
W=int(r.attrib['width']); H=int(r.attrib['height'])
ts=[(int(c.attrib['firstgid']), c.attrib['source'].split('/')[-1]) for c in r if c.tag=='tileset']
fg=[a for a,_ in ts]
def loc(g):
    g&=0x0FFFFFFF
    i=bisect.bisect_right(fg,g)-1
    return ts[i][1], g-ts[i][0]
L={}
for c in r:
    if c.tag=='layer':
        v=np.array([int(x) for x in c.find('data').text.replace('\n','').split(',') if x.strip()],dtype=np.int64)&0x0FFFFFFF
        L[c.attrib['name']]=v.reshape(H,W)
objs=[]
for c in r:
    if c.tag=='objectgroup':
        for o in c:
            g=o.attrib.get('gid')
            if not g: continue
            ts_name, lid = loc(int(g))
            x=float(o.attrib['x']); y=float(o.attrib['y']); w=float(o.attrib['width']); h=float(o.attrib['height'])
            objs.append(dict(set=ts_name.replace('.tsx','').replace('Objects_',''), lid=lid, x0=x, y0=y-h, w=w, h=h))
np.save('layers.npy', L, allow_pickle=True)
json.dump(objs, open('objs.json','w'))
def mask(name, filler):
    return L[name]!=filler
road=mask('Road',4998); ground=mask('Ground',396); tall=mask('Tall Grass',8730); wall=mask('Wall',26924)
rs=L['RockSlopes2']-22810
auto=L['RockSlopes2_Auto']!=0; man=L['Rock slopes manual']!=0
fb=L['Fence back']!=19; ff=L['Fence Front']!=0
print('road',road.sum(),'ground',ground.sum(),'tall',tall.sum(),'wall',wall.sum(),'slopes auto',auto.sum(),'manual',man.sum(),'fence',fb.sum(),ff.sum())
print('poziomy',np.bincount(rs.ravel()))
import collections
print(collections.Counter((o['set'],o['lid']) for o in objs).most_common(12))
for o in objs:
    if o['set']=='Buildings_Desert': print(o)
# render szybki
S=8
img=Image.new('RGB',(W*S,H*S))
d=ImageDraw.Draw(img)
base=[(176,160,100),(196,180,120),(216,200,140),(236,220,170)]
for y in range(H):
    for x in range(W):
        c=base[min(int(rs[y,x]),3)]
        if ground[y,x]: c=(150,110,70)
        if road[y,x]: c=(120,120,130)
        if tall[y,x]: c=(110,150,70)
        if auto[y,x] or man[y,x]: c=(90,60,40)
        if wall[y,x]: c=(60,60,70)
        if fb[y,x] or ff[y,x]: c=(200,150,60)
        d.rectangle([x*S,y*S,x*S+S-1,y*S+S-1],fill=c)
col={'Trees_Desert':(40,120,40),'Rocks_Desert':(140,140,140),'Props_Desert':(180,80,180),'Buildings_Desert':(200,60,50)}
for o in objs:
    d.rectangle([o['x0']/16*S,o['y0']/16*S,(o['x0']+o['w'])/16*S,(o['y0']+o['h'])/16*S],outline=col.get(o['set'],(255,255,255)),width=2)
img.save('podglad_tmx.png')
