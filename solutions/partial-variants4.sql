-- Warianty progow CZESCIOWYCH z klucza CKE - Matura czerwiec 2021, zad. 6 (task6), plik 4.
--   task_3 - 1 pkt "za obliczenie tylko liczby koncertow w kazdym wojewodztwie" (bez dzielenia)
--   task_5 - KONTROLA SMIECIA: odpowiedz bez zwiazku z zadaniem musi dostac 0

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
-- Sama liczba koncertow w wojewodztwie, bez dzielenia przez liczbe miast.
SELECT m.wojewodztwo, COUNT(k.id) AS srednia
FROM miasta m
LEFT JOIN koncerty k ON k.kod_miasta = m.kod_miasta
GROUP BY m.wojewodztwo
ORDER BY COUNT(k.id) DESC;
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
SELECT 1;
-- task_5 END

