Pewna rozgłośnia radiowa postanowiła podsumować wakacje 2017 roku pod względem liczby koncertów w lipcu i sierpniu. Dane zgromadzono w trzech tabelach.

Tabela **`zespoly`** zawiera informacje o zespołach, które koncertowały w wakacje:

- `id_zespolu` — identyfikator zespołu,
- `nazwa` — nazwa zespołu,
- `liczba_artystow` — liczba wykonawców wchodzących w skład zespołu.

| id_zespolu | nazwa | liczba_artystow |
|------------|-------|-----------------|
| 101 | Male nutki | 10 |
| 102 | Szalone gitary | 8 |
| 103 | Niebieskie kontrabasy | 12 |

Tabela **`miasta`** zawiera informacje o miastach, w których odbywały się koncerty:

- `kod_miasta` — kod miasta,
- `miasto` — nazwa miasta,
- `wojewodztwo` — województwo, w którym miasto jest położone.

| kod_miasta | miasto | wojewodztwo |
|------------|--------|-------------|
| 99-522 | Bialystok | podlaskie |
| 99-531 | Bielsko-Biala | slaskie |
| 99-504 | Bydgoszcz | kujawsko-pomorskie |

Tabela **`koncerty`** zawiera informacje o koncertach, które miały miejsce w wakacje:

- `id` — identyfikator koncertu,
- `id_zespolu` — identyfikator zespołu,
- `kod_miasta` — kod miasta,
- `data` — data koncertu (w formacie `rrrr-mm-dd`).

| id | id_zespolu | kod_miasta | data |
|----|------------|------------|------|
| 1 | 109 | 99-508 | 2017-07-25 |
| 2 | 111 | 99-540 | 2017-07-19 |
| 3 | 104 | 99-510 | 2017-07-27 |

Wynik każdego podzadania uzyskaj jednym zapytaniem — w edytorze (MySQL) albo, przesyłając plik, w programie Microsoft Access lub LibreOffice Base.

## Podzadanie 1 (0–1)

Ile koncertów odbyło się w lipcu?

## Podzadanie 2 (0–2)

Podaj nazwę miasta, w którym wystąpiło łącznie najwięcej artystów (wykonawców). Jeżeli miast, w których wystąpiła największa liczba artystów, jest więcej niż jedno, podaj nazwy ich wszystkich. Uwaga: artystę, który w danym mieście wystąpił ze swoim zespołem kilkakrotnie, liczymy tylko raz.

## Podzadanie 3 (0–3)

Wykonaj zestawienie, w którym dla każdego województwa podasz średnią liczbę koncertów w przeliczeniu na jedno miasto w tym województwie. Wyniki podaj w zaokrągleniu do dwóch miejsc po przecinku i posortuj od najwyższej do najniższej średniej.

## Podzadanie 4 (0–2)

Podaj nazwy zespołów, które nie koncertowały w okresie od 20 lipca do 25 lipca 2017 roku włącznie.

## Podzadanie 5 (0–3)

Podaj nazwy zespołów, które częściej koncertowały w weekendy (sobota, niedziela) niż w dni powszednie (od poniedziałku do piątku). Dla każdego z tych zespołów podaj liczbę koncertów w weekendy oraz liczbę koncertów w dni powszednie.
