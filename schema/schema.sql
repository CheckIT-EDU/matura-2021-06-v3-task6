CREATE TABLE zespoly (
    id_zespolu INT,
    nazwa VARCHAR(100),
    liczba_artystow INT
);

CREATE TABLE miasta (
    kod_miasta VARCHAR(10),
    miasto VARCHAR(100),
    wojewodztwo VARCHAR(50)
);

CREATE TABLE koncerty (
    id INT,
    id_zespolu INT,
    kod_miasta VARCHAR(10),
    data DATE
);
