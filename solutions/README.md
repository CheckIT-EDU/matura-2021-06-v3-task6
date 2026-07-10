# Rozwiązania wzorcowe — „Koncerty" (task6, podzadania 6.1–6.5)

Pliki wzorcowe dla trzech ścieżek zgłoszenia. Ścieżki SQL i `.odb` (znormalizowana) zweryfikowane
lokalnie na `mysql:8` checkerami C++ (ścieżka grade: `--batch --raw --skip-column-names`). Ścieżka
ACCESS zweryfikowana w postaci **po konwersji** Access→MySQL (wszystkie 5 kwerend zwraca wyniki z
`tests/task_N/out/1.out`), a plik `Koncerty.accdb` zbudowany i wykonany w silniku ACE — patrz
`HOW_TO_CREATE_ACCDB.md`.

| Plik | Ścieżka | Rola |
|------|---------|------|
| `reference.sql` | SQL | Wzorzec pełny — 1 + 2 + 3 + 2 + 3 = **11/11**. |
| `partial.sql` | SQL | Wzorzec częściowy — 1 + 1 + 1 + 1 + 1 = **5/11** (do e2e partial-credit). |
| `make_odb.py` | LibreOffice | Generator `Koncerty.odb` (ODF zip, 5 zapisanych kwerend w ANSI SQL). `python3 make_odb.py`. |
| `Koncerty.odb` | LibreOffice | Wygenerowany wzorzec `.odb` (nazwy kwerend = `accessQueryName`). Zweryfikowany: normalizacja `"ident"`→backtick → 11/11. |
| `HOW_TO_CREATE_ACCDB.md` | Access | Przepis na `Koncerty.accdb` (Windows-only). |
| `Koncerty.accdb` | Access | Wzorzec `.accdb` (3 tabele + 5 zapisanych kwerend = `accessQueryName`). Wykonany w ACE → wyniki jak w `tests/`. |

## Mapowanie kwerend (ścieżki upload)

| Podzadanie | Nazwa kwerendy | maxPoints |
|------------|----------------|-----------|
| 6.1 | `qryKoncertyLipiec` | 1 |
| 6.2 | `qryMiastoNajwiecejArtystow` | 2 |
| 6.3 | `qrySredniaKoncertowWojewodztwo` | 3 |
| 6.4 | `qryZespolyBezKoncertow` | 2 |
| 6.5 | `qryZespolyWeekendy` | 3 |

## Wyniki wzorcowe (na dostarczonych danych)

- **6.1** — `122` koncerty w lipcu.
- **6.2** — 2 miasta: `Grudziadz`, `Piotrkow Trybunalski` (po 71 artystów, zespół w mieście liczony raz).
- **6.3** — 16 województw (średnia koncertów na miasto, zaokrąglona do 2 miejsc, malejąco):
  swietokrzyskie 8,00; lodzkie 7,00; opolskie 7,00; lubuskie 6,50; slaskie 5,53; malopolskie 5,33;
  lubelskie 5,00; podkarpackie 5,00; dolnoslaskie 4,75; kujawsko-pomorskie 4,25; wielkopolskie 4,25;
  podlaskie 4,00; warminsko-mazurskie 4,00; zachodniopomorskie 4,00; mazowieckie 2,67; pomorskie 2,67.
- **6.4** — 10 zespołów: Male nutki, Stare mandoliny, Wiosenne bebny, Powolne fortepiany, Ciche organy,
  Fajne trojkaty, Rozstrojone pianina, Metalowe klarnety, Zlote saksofony, Piszczace trabki.
- **6.5** — 3 zespoły (nazwa, weekendy, dni powszednie): Powolne fortepiany 5/4, Wiosenne bebny 4/3,
  Niebieskie kontrabasy 4/1.

## Częściowe (`partial.sql`) — tier per podzadanie

- **6.1** — poprawna liczba (122) → 1/1.
- **6.2** — tylko jedno z dwóch remisujących miast → 1/2.
- **6.3** — sama liczba koncertów w województwie (bez dzielenia) → 1/3.
- **6.4** — zbiór bez dni granicznych (21–24 lipca) = 15 zespołów → 1/2.
- **6.5** — poprawne nazwy zespołów, ale zamienione liczby weekendów/dni powszednich → 1/3.

## Arytmetyka i dialekt na ścieżce ACCESS

- **`Weekday` (6.5):** `Weekday([data])` → worker `rewriteWeekday()` → `DAYOFWEEK([data])` (baza
  `1 = niedziela`, row-equivalent). Wariant `Weekday(data; pierwszy_dzien)` fail-closed.
- **Zliczanie (6.5):** `Sum(Abs(warunek))` zamiast `IIf` (konwerter odrzuca `IIf`).
- **Daty (6.4):** `#2017-07-20#` / `#2017-07-25#` → `rewriteDateLiterals()` → `'2017-07-20'` / `'2017-07-25'`.
- **Bez `Count(DISTINCT)`:** 6.2/6.3 używają tabel pochodnych z `SELECT DISTINCT` / podzapytań
  skorelowanych (Jet/ACE nie ma `COUNT(DISTINCT)`).
- **Aliasy:** `ORDER BY`/`HAVING` powtarzają wyrażenie zamiast odwoływać się do aliasu `SELECT`.
- **Nawiasy w JOIN (6.2):** ACE wymaga `FROM (a JOIN b ON …) JOIN c ON …` przy 3 źródłach; bez
  nawiasów kwerenda się nie zapisze („brak operatora"). W MySQL nawiasy są neutralne.

## Weryfikacja lokalna (skrót)

Uruchom `mysql:8`, załaduj `schema/schema.sql` + `tables/*.tsv` (jak `scripts/init.sh`, `IGNORE 1
ROWS`, TAB), wykonaj każdą sekcję `-- task_N BEGIN/END` z `reference.sql` w trybie
`--batch --raw --skip-column-names` → `result.csv`, skompiluj `checkers/checkerN.cpp`
(`g++ -O2 -std=c++17`) i uruchom `checkerN <wejście> result.csv tests/task_N/out/1.out
checker_output.txt` (wejście = `/dev/null`). Pierwszy token `checker_output.txt` = `16 + punkty`.
