#!/usr/bin/env python3
"""Раскладывает трейсы dikidi по фазам. Usage: analyze.py trace.json [...]"""
import json, sys, os, datetime as dt

MS = lambda v: int(v) / 1000


def phase(s, k):
    v = s["labels"].get(f"db.jooq.{k}_us")
    return MS(v) if v is not None else 0.0


def report(path):
    d = json.load(open(path))
    sp = d["spans"]
    dur = lambda s: MS(s["durationUs"])
    started = dt.datetime.fromtimestamp(int(d["startTimeUs"]) / 1e6, dt.UTC)
    envs = {s["labels"].get("deployment.environment.name") for s in sp} - {None}
    print(f"\n=== {os.path.basename(path)[:8]} {started:%Y-%m-%d %H:%M:%S} UTC "
          f"env={sorted(envs)} spans={len(sp)} services={sorted({s.get('service') for s in sp})}")

    for s in sorted(sp, key=lambda s: -dur(s))[:6]:
        extra = ""
        if "db.jooq.execute_us" in s["labels"]:
            extra = (f"  [render={phase(s,'render'):.0f} prepare={phase(s,'prepare'):.0f}"
                     f" execute={phase(s,'execute'):.0f} fetch={phase(s,'fetch'):.0f}]")
        print(f"  {dur(s):9.1f}ms {s.get('service',''):<18} {s['name'][:44]:<44}{extra}")

    db = [s for s in sp if "db.jooq.execute_us" in s["labels"]]
    if not db:
        return
    worst = lambda k: max(db, key=lambda s: phase(s, k))
    print(f"  db={len(db)}"
          f" | maxExecute={phase(worst('execute'),'execute'):.0f}ms"
          f" [{worst('execute')['labels'].get('db.sql.table','?')}]"
          f" | maxRender={phase(worst('render'),'render'):.0f}ms"
          f" | maxPrepare={phase(worst('prepare'),'prepare'):.0f}ms")
    for name, k, limit in (("ожидание пула", "prepare", 50), ("пауза JVM", "render", 20),
                           ("медленно в базе", "execute", 500)):
        hit = [s for s in db if phase(s, k) > limit]
        if hit:
            print(f"    ! {name}: {len(hit)} спанов, суммарно {sum(phase(s,k) for s in hit):.0f}ms")


for p in sys.argv[1:]:
    report(p)
