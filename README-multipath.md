# matura-2021-06-v3-task6 — DATABASE „Koncerty" (multipath: SQL / Access / LibreOffice)

Wielościeżkowa (single-repo) edycja **podzadań 6.1–6.5** arkusza Matura czerwiec 2021 (termin
dodatkowy), zadanie 6 (1 + 2 + 3 + 2 + 3 = **11 pkt**). Uczeń wybiera per zgłoszenie: pisze MySQL,
albo wgrywa plik **Accessa (`.accdb`)** albo **LibreOffice Base (`.odb`)**. Worker wyciąga zapisane
kwerendy **deterministycznie (bez LLM)** i ocenia tym samym potokiem `mysql:8` + checkery C++.

## Układ repo
```
task_definition.yml          # languages: [SQL, ACCESS, LIBREOFFICE] + access/libreOfficeQueryName (6.1–6.5)
schema/ tables/              # schemat (zespoly, miasta, koncerty) + dane (23 + 49 + 240 wierszy)
scripts/init.sh              # ładowanie schematu/danych (tables/*.tsv, IGNORE 1 ROWS, TAB)
scripts/run_subtask.sh       # wykonanie kwerendy → result.csv (gałąź RUN_DISPLAY = nazwy kolumn na „Uruchom")
checkers/                    # checkery C++ per podzadanie (checker1..checker5, testlib.h)
src/query.sql                # stub ucznia (ścieżka SQL)
solutions/reference.sql      # wzorzec SQL (5 zapytań, 11/11)
solutions/partial.sql        # wzorzec częściowy (5/11) do e2e partial-credit
solutions/Koncerty.odb + make_odb.py   # wzorzec LIBREOFFICE (format otwarty, odtwarzalny; 5 kwerend)
solutions/HOW_TO_CREATE_ACCDB.md       # przepis na wzorzec ACCESS (Windows-only)
```
> Mapowanie kwerenda→podzadanie: `accessQueryName` / `libreOfficeQueryName` (identyczne, jedna nazwa
> obsługuje oba uploady). Ekstrakcja: Access via Jackcess, `.odb` via zip+XML (XXE-hardened).

## Uwagi o danych

- Dane źródłowe (`cke/zalaczniki/DANE/{zespoly,miasta,koncerty}.txt`) mają średniki i wiersz
  nagłówkowy; `tables/*.tsv` są **przycięte (TRIM)** przy generowaniu.
- **23 zespoły** (id 101–123), 49 miast, 240 koncertów (wyłącznie lipiec/sierpień 2017). Wszystkie 49
  miast mają ≥1 koncert, więc mianownik 6.3 (liczba miast województwa) nie wymaga `LEFT JOIN` na
  ścieżce liczenia koncertów.

## Ograniczenie multipath (kształtuje SQL)

Ścieżka ACCESS/LIBREOFFICE = JEDNA nazwana kwerenda = JEDEN `SELECT`. Każde podzadanie to jeden
przenośny `SELECT`. Punkty styczne dialektu:

* **6.2/6.3** — bez `COUNT(DISTINCT)` na ścieżce Access (Jet/ACE go nie zna): 6.2 zlicza przez tabelę
  pochodną `SELECT DISTINCT`, 6.3 liczy miasta przez `Count(*)` po tabeli pochodnej + podzapytanie
  skorelowane na liczbę koncertów.
* **6.4** — `NOT IN` po zbiorze zespołów grających w oknie `2017-07-20..2017-07-25`. Ścieżki
  MySQL/`.odb` niosą literały łańcuchowe `'2017-07-20'`; ścieżka ACCESS literały dat `#2017-07-20#`
  (worker `rewriteDateLiterals()` → `'2017-07-20'`).
* **6.5** — weekend vs dzień powszedni: MySQL/`.odb` = `DAYOFWEEK(data) IN (1,7)` z `SUM(CASE WHEN …)`;
  ACCESS = `Weekday([data]) In (1,7)` z `Sum(Abs(...))` (konwerter tłumaczy `Weekday`→`DAYOFWEEK`,
  odrzuca `IIf`). `ORDER BY`/`HAVING` nie odwołują się do aliasów `SELECT` (ACE ich nie rozwiązuje).

## Weryfikacja (lokalna, `mysql:8` + checkery)

Ścieżka SQL, znormalizowana ścieżka `.odb` i **skonwertowana ścieżka ACCESS** zweryfikowane lokalnie
na `mysql:8` przez checkery C++ (ścieżka grade: `--batch --raw --skip-column-names`):

| Podzadanie | maxPoints | SQL | .odb (norm.) | ACCESS (konw.) | Wynik |
|------------|-----------|-----|--------------|----------------|-------|
| 6.1 | 1 | 1/1 | 1/1 | 1/1 | `122` |
| 6.2 | 2 | 2/2 | 2/2 | 2/2 | Grudziadz, Piotrkow Trybunalski |
| 6.3 | 3 | 3/3 | 3/3 | 3/3 | 16 województw, malejąco |
| 6.4 | 2 | 2/2 | 2/2 | 2/2 | 10 zespołów |
| 6.5 | 3 | 3/3 | 3/3 | 3/3 | 3 zespoły |

Częściowa odpowiedź (`solutions/partial.sql`) → **5/11** (1 + 1 + 1 + 1 + 1). Plik `Koncerty.accdb`
(Windows-only, patrz `solutions/HOW_TO_CREATE_ACCDB.md`) trzeba jeszcze utworzyć ręcznie — do tego
czasu run ACCESS na stagingu robi fallback do SQL; kwerendy wzorcowe są gotowe i zweryfikowane w
postaci po konwersji na MySQL.

## Rubryki checkerów (naprawione względem starego portu `matura-2021-06-task6`)

Stare `checker{1..5}` dawały maksa na wzorcu, ale ich **tiery częściowe były fabrykowane /
nieosiągalne / zbyt hojne**. Przepisane tak, by realizowały rubrykę CKE i były w PEŁNI osiągalne:

- `checker3` (6.3) — **nowy tier 1 pkt „obliczenie tylko liczby koncertów w województwie" (bez
  dzielenia)** — realnie rozpoznawany po zaszytej tabeli liczb koncertów; osiągalne wyniki `{0,1,2,3}`.
  **Zaostrzona kontrola zaokrąglenia**: wartość z >2 miejscami po przecinku (np. `5.5333` zamiast
  `5.53`) traci punkt „za zaokrąglenie", choć jest liczbowo bliska (stary checker akceptował ją przez
  tolerancję `< 0.02`).
- `checker4` (6.4) — 2 pkt = dokładnie 10 zespołów; **1 pkt WYŁĄCZNIE za zbiór „bez dni granicznych"
  (21–24 lipca) = 15 zespołów** (zaszyty). Stary `found > 0` dawał 1 pkt za jeden trafiony zespół.
- `checker2` (6.2) — 2 pkt oba miasta, 1 pkt co najmniej jedna poprawna nazwa.
- `checker5` (6.5) — addytywnie: 1 pkt nazwy + 1 pkt weekendy + 1 pkt dni powszednie.
- `scripts/run_subtask.sh` — z gałęzią `RUN_DISPLAY` (nazwy kolumn + zebra na ścieżce „Uruchom";
  ścieżka grade bajt-identyczna).
