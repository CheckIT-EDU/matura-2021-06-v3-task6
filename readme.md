Pewna rozgłośnia radiowa postanowiła podsumować wakacje 2017 roku pod względem liczby koncertów
w lipcu i sierpniu. Dane zostały zgromadzone w plikach: `zespoly.txt`, `miasta.txt`, `koncerty.txt`.
Pierwszy wiersz każdego z plików jest wierszem nagłówkowym, a dane w wierszach są rozdzielone
znakami tabulacji.

Plik o nazwie `zespoly.txt` zawiera informacje o zespołach, które koncertowały w wakacje. W każdym
wierszu pliku znajdują się następujące dane:

- `id_zespolu` – identyfikator zespołu;
- `nazwa` – nazwa zespołu;
- `liczba_artystow` – liczba wykonawców wchodzących w skład zespołu.

**Przykład:**

```text
id_zespolu	nazwa	liczba_artystow
101	Male nutki	10
102	Szalone gitary	8
```

Plik o nazwie `miasta.txt` zawiera informacje o miastach, w których odbywały się koncerty. W każdym
wierszu pliku znajdują się następujące informacje:

- `kod_miasta` – kod miasta;
- `miasto` – nazwa miasta;
- `wojewodztwo` – województwo, w którym miasto jest położone.

**Przykład:**

```text
kod_miasta	miasto	wojewodztwo
99-540	Myslowice	slaskie
99-515	Nowy Sacz	malopolskie
```

Plik o nazwie `koncerty.txt` zawiera informacje o koncertach, które miały miejsce w wakacje.
W każdym wierszu pliku znajdują się następujące informacje:

- `id` – identyfikator koncertu;
- `id_zespolu` – identyfikator zespołu;
- `kod_miasta` – kod miasta;
- `data` – data koncertu (w formacie rrrr-mm-dd).

**Przykład:**

```text
id	id_zespolu	kod_miasta	data
1	109	99-508	2017-07-25
2	111	99-540	2017-07-19
```

Korzystając z dostępnych narzędzi informatycznych, podaj odpowiedzi do poniższych zadań.

### Jak oddać odpowiedzi w tym systemie

Trzy pliki z danymi są do pobrania w sekcji **Materiały** pod treścią zadania — pobierz je, jeśli
chcesz pracować w programie Microsoft Access albo LibreOffice Base.

Odpowiedź do każdego podzadania to **jedno zapytanie**:

- w edytorze (MySQL) — wpisane między znaczniki `-- task_N BEGIN` i `-- task_N END`; te same dane są
  tam już wczytane do tabel `zespoly`, `miasta` i `koncerty`, o kolumnach z opisu powyżej;
- albo w przesyłanym pliku Microsoft Access / LibreOffice Base — jako zapisana kwerenda o nazwie
  wskazanej w opisie danego podzadania.

## Podzadanie 1. (0–1)

Ile koncertów odbyło się w lipcu?

Nazwa kwerendy w przesyłanym pliku: `qryKoncertyLipiec`.

## Podzadanie 2. (0–2)

Podaj nazwę miasta, w którym wystąpiło łącznie najwięcej artystów (wykonawców). Jeżeli miast,
w których wystąpiła największa liczba artystów jest więcej niż jedno, **podaj nazwy ich wszystkich**.

**Uwaga:** artystę, który w danym mieście wystąpił ze swoim zespołem kilkakrotnie, liczymy tylko raz.

Nazwa kwerendy w przesyłanym pliku: `qryMiastoNajwiecejArtystow`.

## Podzadanie 3. (0–3)

Wykonaj zestawienie, w którym dla każdego województwa podasz średnią liczbę koncertów w przeliczeniu
na jedno miasto w tym województwie. Wyniki podaj w zaokrągleniu do dwóch miejsc po przecinku
i posortuj od najwyższej do najniższej średniej.

Kolejność kolumn w wyniku: **nazwa województwa, średnia liczba koncertów**. Przykład poprawnie
sformatowanej (ale **błędnej**) odpowiedzi:

```text
podlaskie	3.50
```

Nazwa kwerendy w przesyłanym pliku: `qrySredniaKoncertowWojewodztwo`.

## Podzadanie 4. (0–2)

Podaj nazwy zespołów, które nie koncertowały w okresie od 20 lipca do 25 lipca włącznie.

Nazwa kwerendy w przesyłanym pliku: `qryZespolyBezKoncertow`.

## Podzadanie 5. (0–3)

Podaj nazwy zespołów, które częściej koncertowały w weekendy (sobota, niedziela) niż w dni
powszednie (od poniedziałku do piątku). Dla każdego z tych zespołów podaj liczbę koncertów
w weekendy oraz liczbę koncertów w dni powszednie.

Kolejność kolumn w wyniku: **nazwa zespołu, liczba koncertów w weekendy, liczba koncertów w dni
powszednie**. Przykład poprawnie sformatowanej (ale **błędnej**) odpowiedzi:

```text
Cicha perkusja	6	2
```

Nazwa kwerendy w przesyłanym pliku: `qryZespolyWeekendy`.
