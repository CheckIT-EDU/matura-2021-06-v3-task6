-- Warianty progow CZESCIOWYCH z klucza CKE - Matura czerwiec 2021, zad. 6 (task6), plik 3.
--   task_3 - 1 pkt "za sortowanie" (wyniki + sortowanie malejace, bez zaokraglenia)
--   task_5 - 1 pkt "za poprawne liczby koncertow poszczegolnych zespolow w dni powszednie"

-- playground BEGIN

-- playground END

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
-- Poprawne srednie i sortowanie malejace, ale bez zaokraglenia do dwoch miejsc.
SELECT m.wojewodztwo, COUNT(k.id) / COUNT(DISTINCT m.kod_miasta) AS srednia
FROM miasta m
LEFT JOIN koncerty k ON k.kod_miasta = m.kod_miasta
GROUP BY m.wojewodztwo
ORDER BY COUNT(k.id) / COUNT(DISTINCT m.kod_miasta) DESC;
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
-- Poprawne liczby dni powszednich, liczby weekendowe zawyzone o 1.
SELECT z.nazwa,
       SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 1 ELSE 0 END) + 1 AS weekendy,
       SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 0 ELSE 1 END) AS dni_powszednie
FROM zespoly z
INNER JOIN koncerty k ON k.id_zespolu = z.id_zespolu
GROUP BY z.id_zespolu, z.nazwa
HAVING SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 1 ELSE 0 END)
     > SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 0 ELSE 1 END);
-- task_5 END

