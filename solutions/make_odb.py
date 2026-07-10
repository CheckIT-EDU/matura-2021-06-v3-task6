#!/usr/bin/env python3
"""Generate the reference LibreOffice Base .odb for the LIBREOFFICE submission path (zad 6.1–6.5).

A LibreOffice Base .odb is an OPEN format — a ZIP whose content.xml stores each saved query as
<db:query db:name="…" db:command="…"/> with the SQL in plain text. So we build the exact file a
student would upload, fully reproducibly on any OS (no LibreOffice install required).

The five saved queries carry the SAME names as the Access reference (so one per-subtask query name
serves both upload paths), written in ANSI quoting (double-quoted identifiers, single-quoted string
literals). The worker's LibreOfficeSqlNormalizer rewrites the double-quoted identifiers to MySQL
backticks and leaves string literals + functions untouched, so each normalized query is logically
identical to the matching `-- task_N BEGIN/END` block in solutions/reference.sql, and all three
paths (SQL / ACCESS / LIBREOFFICE) share one golden set (1/1 + 2/2 + 3/3 + 2/2 + 3/3 = 11/11).

The .odb path is MySQL-shaped, so it carries CASE WHEN aggregates, DAYOFWEEK, ROUND and plain string
date literals ('2017-07-20') directly (unlike the Access path, which uses Abs(bool) tallies,
Weekday(), Sum(Abs(...)) and relies on the worker's converter).

Run:  python3 make_odb.py   ->   writes Koncerty.odb next to this script.
"""

import os
import zipfile
from xml.sax.saxutils import quoteattr

# saved query name (== accessQueryName in task_definition.yml) -> ANSI SQL command.
QUERIES = {
    # 6.1 — number of concerts in July.
    "qryKoncertyLipiec": (
        'SELECT COUNT(*) AS "liczba" FROM "koncerty" '
        'WHERE MONTH("koncerty"."data") = 7'
    ),
    # 6.2 — city (or cities) with the largest total number of artists (each band counted once per city).
    "qryMiastoNajwiecejArtystow": (
        'SELECT "m"."miasto" '
        'FROM (SELECT DISTINCT "kod_miasta", "id_zespolu" FROM "koncerty") "d" '
        'INNER JOIN "miasta" "m" ON "m"."kod_miasta" = "d"."kod_miasta" '
        'INNER JOIN "zespoly" "z" ON "z"."id_zespolu" = "d"."id_zespolu" '
        'GROUP BY "m"."kod_miasta", "m"."miasto" '
        'HAVING SUM("z"."liczba_artystow") = ('
        'SELECT MAX("t"."suma") FROM ('
        'SELECT SUM("z2"."liczba_artystow") AS "suma" '
        'FROM (SELECT DISTINCT "kod_miasta", "id_zespolu" FROM "koncerty") "d2" '
        'INNER JOIN "zespoly" "z2" ON "z2"."id_zespolu" = "d2"."id_zespolu" '
        'GROUP BY "d2"."kod_miasta") "t")'
    ),
    # 6.3 — for each voivodeship, average concerts per city, rounded to 2 decimals, sorted descending.
    "qrySredniaKoncertowWojewodztwo": (
        'SELECT "m"."wojewodztwo", '
        'ROUND(COUNT("k"."id") / COUNT(DISTINCT "m"."kod_miasta"), 2) AS "srednia" '
        'FROM "miasta" "m" '
        'LEFT JOIN "koncerty" "k" ON "k"."kod_miasta" = "m"."kod_miasta" '
        'GROUP BY "m"."wojewodztwo" '
        'ORDER BY ROUND(COUNT("k"."id") / COUNT(DISTINCT "m"."kod_miasta"), 2) DESC'
    ),
    # 6.4 — bands that did NOT play any concert between 20 and 25 July 2017 inclusive.
    "qryZespolyBezKoncertow": (
        'SELECT "z"."nazwa" FROM "zespoly" "z" '
        'WHERE "z"."id_zespolu" NOT IN ('
        'SELECT "k"."id_zespolu" FROM "koncerty" "k" '
        'WHERE "k"."data" BETWEEN \'2017-07-20\' AND \'2017-07-25\')'
    ),
    # 6.5 — bands playing more often on weekends than weekdays; name, weekend count, weekday count.
    "qryZespolyWeekendy": (
        'SELECT "z"."nazwa", '
        'SUM(CASE WHEN DAYOFWEEK("k"."data") IN (1, 7) THEN 1 ELSE 0 END) AS "weekendy", '
        'SUM(CASE WHEN DAYOFWEEK("k"."data") IN (1, 7) THEN 0 ELSE 1 END) AS "dni_powszednie" '
        'FROM "zespoly" "z" INNER JOIN "koncerty" "k" ON "k"."id_zespolu" = "z"."id_zespolu" '
        'GROUP BY "z"."id_zespolu", "z"."nazwa" '
        'HAVING SUM(CASE WHEN DAYOFWEEK("k"."data") IN (1, 7) THEN 1 ELSE 0 END) '
        '> SUM(CASE WHEN DAYOFWEEK("k"."data") IN (1, 7) THEN 0 ELSE 1 END)'
    ),
}

DB_NS = "urn:oasis:names:tc:opendocument:xmlns:database:1.0"
OFFICE_NS = "urn:oasis:names:tc:opendocument:xmlns:office:1.0"
MANIFEST_NS = "urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
MIMETYPE = "application/vnd.oasis.opendocument.base"


def content_xml() -> str:
    parts = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<office:document-content xmlns:office="{OFFICE_NS}" xmlns:db="{DB_NS}">',
        "<office:body><office:database><db:queries>",
    ]
    for name, command in QUERIES.items():
        parts.append(
            f"<db:query db:name={quoteattr(name)} "
            f"db:command={quoteattr(command)} db:escape-processing=\"true\"/>"
        )
    parts.append("</db:queries></office:database></office:body></office:document-content>")
    return "".join(parts)


def manifest_xml() -> str:
    return (
        '<?xml version="1.0" encoding="UTF-8"?>'
        f'<manifest:manifest xmlns:manifest="{MANIFEST_NS}" manifest:version="1.2">'
        f'<manifest:file-entry manifest:full-path="/" manifest:media-type="{MIMETYPE}"/>'
        '<manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>'
        "</manifest:manifest>"
    )


def build(path: str) -> None:
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(zipfile.ZipInfo("mimetype"), MIMETYPE, compress_type=zipfile.ZIP_STORED)
        zf.writestr("content.xml", content_xml())
        zf.writestr("META-INF/manifest.xml", manifest_xml())


if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Koncerty.odb")
    build(out)
    print(f"wrote {out}")
