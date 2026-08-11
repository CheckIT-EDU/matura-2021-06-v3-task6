-- PARTIAL-credit reference solution for the SQL submission path (Matura czerwiec 2021 v3, termin
-- dodatkowy, zad 6.1-6.5 - task6, „Koncerty"). Companion to solutions/reference.sql (11/11).
--
-- Each block yields an EXACT, known partial score against the repo's C++ checkers, so an e2e runner
-- can prove partial scoring works end-to-end. Validated on a real mysql:8 container graded exactly as
-- scripts/run_subtask.sh does (--batch --raw --skip-column-names):
--
--   task_1 (6.1, checker1): correct count (122 July concerts)                              -> 1/1
--   task_2 (6.2, checker2): only ONE of the two correct cities                             -> 1/2
--   task_3 (6.3, checker3): only the concert COUNT per voivodeship (no division)           -> 1/3
--   task_4 (6.4, checker4): the "without boundary days" set (21-24 July only) = 15 bands   -> 1/2
--   task_5 (6.5, checker5): the correct band names but the two counts swapped              -> 1/3
--
-- Total partial = 1 + 1 + 1 + 1 + 1 = 5 / 11.
--
-- NOTE: every "unsorted / one-of / swapped" tier is forced with an EXPLICIT clause (LIMIT 1, ORDER BY
-- ... DESC, column swap), NOT by relying on scan order.

-- Miejsce na zapytania pomocnicze — NIE jest oceniane.
-- playground BEGIN

-- playground END


-- task_1 BEGIN
-- 6.1 CORRECT: number of July concerts (122) -> 1/1.
SELECT COUNT(*) AS liczba
FROM koncerty
WHERE MONTH(koncerty.data) = 7;
-- task_1 END


-- task_2 BEGIN
-- 6.2 PARTIAL: found the maximum but listed only ONE of the two tied cities -> 1/2.
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
)
ORDER BY m.miasto
LIMIT 1;
-- task_2 END


-- task_3 BEGIN
-- 6.3 PARTIAL: only the number of concerts per voivodeship, WITHOUT dividing by the number of cities
-- (the "obliczenie tylko liczby koncertow" tier) -> 1/3.
SELECT m.wojewodztwo, COUNT(k.id) AS liczba
FROM miasta m
LEFT JOIN koncerty k ON k.kod_miasta = m.kod_miasta
GROUP BY m.wojewodztwo
ORDER BY COUNT(k.id) DESC;
-- task_3 END


-- task_4 BEGIN
-- 6.4 PARTIAL: dropped the boundary days (21-24 July instead of 20-25 July inclusive) -> 15 bands,
-- the named "bez dni granicznych" tier -> 1/2.
SELECT z.nazwa
FROM zespoly z
WHERE z.id_zespolu NOT IN (
    SELECT k.id_zespolu
    FROM koncerty k
    WHERE k.data BETWEEN '2017-07-21' AND '2017-07-24'
);
-- task_4 END


-- task_5 BEGIN
-- 6.5 PARTIAL: the correct band names, but the weekend and weekday counts SWAPPED between the two
-- columns -> names right, both numbers wrong -> 1/3.
SELECT z.nazwa,
       SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 0 ELSE 1 END) AS weekendy,
       SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 1 ELSE 0 END) AS dni_powszednie
FROM zespoly z
INNER JOIN koncerty k ON k.id_zespolu = z.id_zespolu
GROUP BY z.id_zespolu, z.nazwa
HAVING SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 1 ELSE 0 END)
     > SUM(CASE WHEN DAYOFWEEK(k.data) IN (1, 7) THEN 0 ELSE 1 END);
-- task_5 END
