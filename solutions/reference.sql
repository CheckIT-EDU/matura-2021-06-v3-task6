-- Reference solution for the SQL submission path (Matura czerwiec 2021 v3, termin dodatkowy,
-- zad 6.1-6.5 - task6, „Koncerty").
-- Schema: zespoly(id_zespolu, nazwa, liczba_artystow) + miasta(kod_miasta, miasto, wojewodztwo) +
-- koncerty(id, id_zespolu, kod_miasta, data).
--
-- Each block is ONE portable SELECT (the ACCESS / LIBREOFFICE upload paths store one named query =
-- one SELECT per subtask). These score 1/1 + 2/2 + 3/3 + 2/2 + 3/3 = 11/11 against the C++ checkers,
-- and carry the SAME logic as the .odb/.accdb saved queries (see make_odb.py /
-- HOW_TO_CREATE_ACCDB.md), so all three paths share one golden set.

-- task_1 BEGIN
-- 6.1 How many concerts took place in July? Answer: 122.
SELECT COUNT(*) AS liczba
FROM koncerty
WHERE MONTH(koncerty.data) = 7;
-- task_1 END


-- task_2 BEGIN
-- 6.2 City in which the largest TOTAL number of artists performed, counting a band that played in a
-- city several times only ONCE. If several cities tie, list them all. Answer: Grudziadz, Piotrkow
-- Trybunalski (71 artists each).
SELECT m.miasto
FROM (SELECT DISTINCT kod_miasta, id_zespolu FROM koncerty) d
INNER JOIN miasta m ON m.kod_miasta = d.kod_miasta
INNER JOIN zespoly z ON z.id_zespolu = d.id_zespolu
GROUP BY m.kod_miasta, m.miasto
HAVING SUM(z.liczba_artystow) = (
    SELECT MAX(t.suma) FROM (
        SELECT SUM(z2.liczba_artystow) AS suma
        FROM (SELECT DISTINCT kod_miasta, id_zespolu FROM koncerty) d2
        INNER JOIN zespoly z2 ON z2.id_zespolu = d2.id_zespolu
        GROUP BY d2.kod_miasta
    ) t
);
-- task_2 END


-- task_3 BEGIN
-- 6.3 For each voivodeship, the average number of concerts per city in that voivodeship (denominator =
-- number of cities of the voivodeship in `miasta`; every city has >= 1 concert so a plain JOIN gives
-- the same denominator). Rounded to 2 decimals, sorted descending. Answer: 16 rows.
SELECT m.wojewodztwo,
       ROUND(COUNT(k.id) / COUNT(DISTINCT m.kod_miasta), 2) AS srednia
FROM miasta m
LEFT JOIN koncerty k ON k.kod_miasta = m.kod_miasta
GROUP BY m.wojewodztwo
ORDER BY ROUND(COUNT(k.id) / COUNT(DISTINCT m.kod_miasta), 2) DESC;
-- task_3 END


-- task_4 BEGIN
-- 6.4 Names of bands that did NOT perform any concert between 20 and 25 July 2017 inclusive.
-- NOT IN over the set of bands that DID play in that window. Answer: 10 bands.
SELECT z.nazwa
FROM zespoly z
WHERE z.id_zespolu NOT IN (
    SELECT k.id_zespolu
    FROM koncerty k
    WHERE k.data BETWEEN '2017-07-20' AND '2017-07-25'
);
-- task_4 END


-- task_5 BEGIN
-- 6.5 Bands that played MORE often on weekends (Sat, Sun) than on weekdays (Mon-Fri); for each give
-- the number of weekend concerts and the number of weekday concerts. DAYOFWEEK: 1 = Sunday, 7 =
-- Saturday. Answer: 3 bands. Output column order: nazwa, weekendy, dni_powszednie.
SELECT z.nazwa,
       SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 1 ELSE 0 END) AS weekendy,
       SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 0 ELSE 1 END) AS dni_powszednie
FROM zespoly z
INNER JOIN koncerty k ON k.id_zespolu = z.id_zespolu
GROUP BY z.id_zespolu, z.nazwa
HAVING SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 1 ELSE 0 END)
     > SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 0 ELSE 1 END);
-- task_5 END


-- playground BEGIN
SELECT 1;
-- playground END
