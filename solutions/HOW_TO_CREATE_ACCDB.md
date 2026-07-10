# Jak utworzyć wzorcowy plik Accessa (`Koncerty.accdb`) dla ścieżki ACCESS — instrukcja dla Windows

> **TL;DR.** Wzorcowy plik należy zbudować na Windowsie w MS Access: 3 tabele (`zespoly`, `miasta`,
> `koncerty`) wypełnione z `tables/*.tsv` oraz 5 zapisanych kwerend o nazwach z `task_definition.yml`.
> Wszystkie mają zwracać w ACE dokładnie wyniki z `tests/task_N/out/1.out`. Docelowa nazwa pliku:
> **`Koncerty.accdb`** (umieść go w `solutions/`).
>
> Uwaga: żadne narzędzie FOSS nie **tworzy** zapisanych kwerend Accessa (UCanAccess / Jackcess /
> mdbtools potrafią je tylko **czytać**) — potrzebny jest MS Access albo silnik ACE przez COM.
>
> Dopóki plik nie zostanie dodany, **e2e ścieżki ACCESS robi fallback do SQL** i maskuje ewentualne
> błędy ekstrakcji Jackcessem — po dodaniu pliku przebieg trzeba POWTÓRZYĆ.

---

## 1. Środowisko

Potrzebujesz **pełnego MS Access** (do *projektowania* kwerend), nie samego *Access Runtime*:

* prawdziwy Windows albo Windows w VM (Parallels / UTM / VMware / VirtualBox) albo chmurowy Windows;
* MS Access z **Microsoft 365** lub **Office Professional** (wystarczy 1-miesięczny trial 365).

> **Tryb zgodności SQL = ANSI-92 (zalecany).** *Plik → Opcje → Projektanci obiektów → Zgodna z SQL
> Server (ANSI-92)* — zaznacz „Ta baza danych", zamknij i otwórz bazę ponownie. W tym zadaniu nie ma
> wzorca `LIKE`, więc tryb ma znaczenie drugorzędne, ale ANSI-92 utrzymuje spójność z MySQL.

---

## 2. Pusta baza + schemat + dane

1. Utwórz nową, pustą bazę `.accdb` (nazwij ją `Koncerty.accdb`).
2. Odtwórz **3 tabele** dokładnie wg `schema/schema.sql`:

   | Tabela | Kolumny (typ Accessa) |
   |--------|------------------------|
   | `zespoly` | `id_zespolu` (Liczba/Long), `nazwa` (Tekst, 100), `liczba_artystow` (Liczba/Long) |
   | `miasta` | `kod_miasta` (Tekst, 10), `miasto` (Tekst, 100), `wojewodztwo` (Tekst, 50) |
   | `koncerty` | `id` (Liczba/Long), `id_zespolu` (Liczba/Long), `kod_miasta` (Tekst, 10), `data` (**Data/Godzina**) |

3. Wczytaj dane z `tables/*.tsv` (rozdzielone tabulacją, pierwszy wiersz to nagłówek):
   *Dane zewnętrzne → Nowe źródło danych → Z pliku → Plik tekstowy*, wskaż plik, *Rozdzielany*,
   separator **Tab**, „Pierwszy wiersz zawiera nazwy pól", dołącz do istniejącej tabeli o tej nazwie.
   Kolumna `data` musi wczytać się jako **Data/Godzina** (format `RRRR-MM-DD`).

> Zachowaj **dokładne** nazwy tabel i kolumn. Worker tłumaczy `[identyfikator]` → backtick MySQL
> automatycznie, więc gdyby Access ujął nazwę w nawiasy kwadratowe — jest to bezpieczne.

---

## 3. Pięć zapisanych kwerend (QueryDef)

Dla każdego podzadania utwórz **kwerendę** (*Utwórz → Projekt kwerendy → zamknij okno wyboru tabel →
Widok SQL*), wklej poniższy SQL i **zapisz pod DOKŁADNIE tą nazwą** z nagłówka.

Reguły dialektu (wszystkie zweryfikowane po konwersji Access→MySQL na `mysql:8` + checkery):

> **Bez `Count(DISTINCT …)` w Accessie.** Silnik Jet/ACE **nie zna** `COUNT(DISTINCT)`, dlatego 6.2
> zlicza przez tabelę pochodną z `SELECT DISTINCT`, a 6.3 liczy miasta województwa przez `Count(*)`
> po tabeli pochodnej (mianownik = liczba miast) z podzapytaniem skorelowanym na liczbę koncertów.
>
> **`Weekday([data])` w 6.5.** Access numeruje `1 = niedziela … 7 = sobota`. Worker
> (`AccessDialectConverter.rewriteWeekday()`) zamienia `Weekday(x)` → `DAYOFWEEK(x)` (ta sama baza
> `1 = niedziela`), więc predykat weekendu `Weekday([data]) In (1,7)` jest row-equivalent. **Nie
> obchodź** tego wyrażeniem `DateDiff(...) Mod 7` — sensem jest użycie `Weekday`. Wariant
> dwuargumentowy `Weekday(data; pierwszy_dzien)` konwerter **odrzuca** (fail-closed).
>
> **Bez `IIf` w 6.5.** Konwerter odrzuca `IIf`/`Nz`/`Switch`/`Format` (fail-closed → `RUNTIME_ERROR`).
> Zliczaj weekendy/dni powszednie przez `Sum(Abs(warunek))`: w Accessie `warunek` (porównanie/`In`)
> daje `-1`/`0`, `Abs` → `1`/`0`; po konwersji na MySQL `SUM(ABS(...))` liczy to samo.
>
> **Literały dat `#…#` w 6.4.** Access zapisując predykat na kolumnie typu Data normalizuje literał
> do postaci `#RRRR-MM-DD#`; worker (`rewriteDateLiterals()`) zamienia `#RRRR-MM-DD#` → `'RRRR-MM-DD'`.
> Daty tego zadania (`#2017-07-20#`, `#2017-07-25#`) są jednoznaczne. **Nie usuwaj** warunku dat.
>
> **Bez aliasów z `SELECT` w `ORDER BY`/`HAVING`:** silnik ACE **nie rozwiązuje** aliasów kolumn,
> dlatego 6.3 powtarza wyrażenie `Round(...)` w `ORDER BY`, a 6.5 powtarza agregaty w `HAVING`.
>
> **Nawiasy przy złączeniu 3+ źródeł (6.2).** ACE wymaga jawnego nawiasowania łańcucha `JOIN`:
> `FROM a INNER JOIN b ON … INNER JOIN c ON …` kończy się błędem *„Błąd składniowy (brak operatora)
> w wyrażeniu kwerendy"*. Trzeba pisać `FROM (a INNER JOIN b ON …) INNER JOIN c ON …` — dokładnie tak
> generuje projektant Accessa. Nawiasy są poprawnym MySQL, więc konwerter workera je przełyka.

### Podzadanie 1 — `qryKoncertyLipiec`
```sql
SELECT Count(*) AS liczba
FROM koncerty
WHERE Month(koncerty.data) = 7;
```
Wynik: `122`.

### Podzadanie 2 — `qryMiastoNajwiecejArtystow`
```sql
SELECT miasta.miasto
FROM ((SELECT DISTINCT koncerty.kod_miasta, koncerty.id_zespolu FROM koncerty) AS d
INNER JOIN miasta ON miasta.kod_miasta = d.kod_miasta)
INNER JOIN zespoly ON zespoly.id_zespolu = d.id_zespolu
GROUP BY miasta.kod_miasta, miasta.miasto
HAVING Sum(zespoly.liczba_artystow) =
  (SELECT Max(t.suma) FROM
    (SELECT Sum(zespoly.liczba_artystow) AS suma
     FROM (SELECT DISTINCT koncerty.kod_miasta, koncerty.id_zespolu FROM koncerty) AS d2
     INNER JOIN zespoly ON zespoly.id_zespolu = d2.id_zespolu
     GROUP BY d2.kod_miasta) AS t);
```
Wynik (2): `Grudziadz`, `Piotrkow Trybunalski` (po 71 artystów).

### Podzadanie 3 — `qrySredniaKoncertowWojewodztwo`
```sql
SELECT c.wojewodztwo, Round(Sum(c.lk) / Count(*), 2) AS srednia
FROM (SELECT miasta.kod_miasta, miasta.wojewodztwo,
        (SELECT Count(*) FROM koncerty WHERE koncerty.kod_miasta = miasta.kod_miasta) AS lk
      FROM miasta) AS c
GROUP BY c.wojewodztwo
ORDER BY Round(Sum(c.lk) / Count(*), 2) DESC;
```
Wynik (16 województw): `swietokrzyskie 8,00` … `pomorskie 2,67` (średnia po **wszystkich** miastach
województwa; wszystkie 49 miast mają ≥1 koncert).

### Podzadanie 4 — `qryZespolyBezKoncertow`
```sql
SELECT zespoly.nazwa
FROM zespoly
WHERE zespoly.id_zespolu NOT IN
  (SELECT koncerty.id_zespolu
   FROM koncerty
   WHERE koncerty.data Between #2017-07-20# And #2017-07-25#);
```
Wynik (10): Male nutki, Stare mandoliny, Wiosenne bebny, Powolne fortepiany, Ciche organy,
Fajne trojkaty, Rozstrojone pianina, Metalowe klarnety, Zlote saksofony, Piszczace trabki.

### Podzadanie 5 — `qryZespolyWeekendy`
```sql
SELECT zespoly.nazwa,
       Sum(Abs(Weekday(koncerty.data) In (1,7))) AS weekendy,
       Sum(Abs(Weekday(koncerty.data) Not In (1,7))) AS dni_powszednie
FROM zespoly INNER JOIN koncerty ON koncerty.id_zespolu = zespoly.id_zespolu
GROUP BY zespoly.id_zespolu, zespoly.nazwa
HAVING Sum(Abs(Weekday(koncerty.data) In (1,7)))
     > Sum(Abs(Weekday(koncerty.data) Not In (1,7)));
```
Wynik (3): Powolne fortepiany 5/4, Wiosenne bebny 4/3, Niebieskie kontrabasy 4/1 (weekendy/powszednie).

---

## 4. Zapis i przekazanie

1. Zapisz bazę. Sprawdź w panelu nawigacji, że widać **5 kwerend** o nazwach dokładnie jak wyżej.
2. Prześlij plik do repozytorium jako `solutions/Koncerty.accdb`.

> **Status:** `solutions/Koncerty.accdb` **istnieje** — zbudowany na Windowsie przez DAO
> (`DAO.DBEngine.120`, format 128 = Access 2007+): 3 tabele z kompletem danych z `tables/*.tsv`
> (23 + 49 + 240 wierszy) i 5 zapisanych kwerend o nazwach z `task_definition.yml`. Każda kwerenda
> została **wykonana** w ACE (`OpenRecordset`), nie tylko zapisana; wyniki zgadzają się z
> `tests/task_N/out/1.out` (6.1=122, 6.2=Grudziadz + Piotrkow Trybunalski, 6.3=16 województw,
> 6.4=10 zespołów, 6.5=3 zespoły). Wcześniej te same kwerendy zweryfikowano w postaci **po konwersji**
> Access→MySQL na `mysql:8` przez checkery C++; 6.5 dowodzi reguły `Weekday(x)` → `DAYOFWEEK(x)`.
>
> Uwaga: w 6.2 SQL podany wcześniej w tej instrukcji **nie kompilował się** w ACE (JOIN 3 źródeł bez
> nawiasów → „brak operatora"). Poprawione powyżej; sam alias nie wystarczy, wymagane są nawiasy.
> Kolejność wierszy przy remisach w 6.3 (`lodzkie`/`opolskie` itd.) jest dowolna — `checker3`
> sprawdza jedynie nierosnący porządek wartości.

---

## 5. Domknięcie ścieżki ACCESS (po dostarczeniu pliku)

1. **Weryfikacja ekstrakcji (lokalnie, Java 25):** odczytaj kwerendy Jackcessem
   (`AccessQueryExtractor.assembleQuerySql(accdbFile, taskDefinition)`) i sprawdź, że znormalizowany
   `query.sql` daje te same wyniki co `solutions/reference.sql` (na `mysql:8` + checkery C++).
2. **E2e na stagingu:** ustaw aktywną ścieżkę przez upload `POST .../file?language=ACCESS`, oddaj
   cały test (`POST /tests/{testId}/process`), poll → pełne 11/11 punktów.

> **Fallback SQL maskuje błędy ścieżki Access.** Dopóki nie ma `.accdb`, e2e ścieżki ACCESS robi
> fallback do SQL i zawsze daje 11/11 — więc PO dostarczeniu pliku PRZEBIEG e2e trzeba POWTÓRZYĆ.
