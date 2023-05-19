--Zadatak 1

--1
SELECT DISTINCT naziv AS ResNaziv
FROM pravno_lice
WHERE lokacija_id = ANY(SELECT lokacija_id FROM fizicko_lice);

--2
SELECT DISTINCT To_Char(uzpl.datum_potpisivanja, 'dd.MM.yyyy') "Datum Potpisivanja",pl.naziv AS ResNaziv
FROM UGOVOR_ZA_PRAVNO_LICE uzpl, PRAVNO_LICE pl
WHERE pl.pravno_lice_id=uzpl.pravno_lice_id   AND
      uzpl.datum_potpisivanja  > ANY(SELECT f.datum_kupoprodaje
                                    FROM faktura f, proizvod p, narudzba_proizvoda np
                                    WHERE f.faktura_id = np.faktura_id AND p.proizvod_id=np.proizvod_id AND p.broj_mjeseci_garancije IS NOT NULL);

--3
SELECT naziv
FROM proizvod
WHERE kategorija_id = (SELECT p.kategorija_id
                       FROM proizvod p, kolicina k
                       WHERE p.proizvod_id=k.proizvod_id AND k.kolicina_proizvoda = (SELECT Max(kolicina_proizvoda)
                                                                                     FROM kolicina));

--4
SELECT p.naziv AS "Proizvod", pl.naziv AS "Proizvodjac"
FROM proizvod p, proizvodjac dj, pravno_lice pl
WHERE pl.pravno_lice_id = dj.proizvodjac_id AND p.proizvodjac_id = dj.proizvodjac_id AND dj.proizvodjac_id = ANY (SELECT p1.proizvodjac_id
                                                                                                                  FROM proizvodjac p1
                                                                                                                  WHERE EXISTS (SELECT *
                                                                                                                                FROM proizvod product
                                                                                                                                WHERE p1.proizvodjac_id = product.proizvodjac_id AND product.cijena > (SELECT Avg(p2.cijena) FROM proizvod p2)));

--5
SELECT fl.ime || ' ' || fl.prezime "Ime i prezime", Sum(f.iznos) "iznos"
FROM  kupac k, fizicko_lice fl, uposlenik u, faktura f
WHERE k.kupac_id = fl.fizicko_lice_id AND u.uposlenik_id = k.kupac_id AND k.kupac_id = f.kupac_id
HAVING Sum(f.iznos) > (SELECT Round(Avg(Sum(f1.iznos)),2)
                       FROM faktura f1, fizicko_lice fl1
                       WHERE f1.kupac_id = fl1.fizicko_lice_id
                       GROUP BY fl1.ime, fl1.prezime)
GROUP BY fl.ime, fl.prezime;


--6
SELECT pl.naziv "naziv"
FROM kurirska_sluzba ks, pravno_lice pl, isporuka i, faktura f, narudzba_proizvoda np, popust p
WHERE ks.kurirska_sluzba_id = pl.pravno_lice_id AND
      ks.kurirska_sluzba_id = i.kurirska_sluzba_id AND
      i.isporuka_id = f.isporuka_id AND
      f.faktura_id = np.faktura_id AND
      np.popust_id = ANY (SELECT popust_id FROM popust WHERE postotak IS NOT NULL)
HAVING Sum(np.kolicina_jednog_proizvoda) = ANY (SELECT Max(Sum(np1.kolicina_jednog_proizvoda))
                                                FROM narudzba_proizvoda np1,  kurirska_sluzba ks1, pravno_lice pl1, isporuka i1, faktura f1, popust p1
                                                WHERE ks1.kurirska_sluzba_id = pl1.pravno_lice_id AND
                                                      ks1.kurirska_sluzba_id = i1.kurirska_sluzba_id AND
                                                      i1.isporuka_id = f1.isporuka_id AND
                                                      f1.faktura_id = np1.faktura_id AND
                                                      np1.popust_id = ANY (SELECT popust_id FROM popust WHERE postotak IS NOT NULL)
                                                GROUP BY ks1.kurirska_sluzba_id)
GROUP BY pl.naziv;


--7
SELECT fl.ime || ' ' || fl.prezime "Kupac", Sum(np.kolicina_jednog_proizvoda * p.cijena * po.postotak/100) "Usteda"
FROM kupac k, fizicko_lice fl, narudzba_proizvoda np, proizvod p, popust po, faktura f
WHERE k.kupac_id = fl.fizicko_lice_id AND
      k.kupac_id = f.kupac_id AND
      f.faktura_id = np.faktura_id AND
      np.popust_id = po.popust_id AND
      np.proizvod_id = p.proizvod_id
GROUP BY fl.ime || ' ' || fl.prezime;


--8
SELECT DISTINCT i.isporuka_id idisporuke, i.kurirska_sluzba_id idkurirske
FROM isporuka i, faktura f, narudzba_proizvoda np
WHERE i.isporuka_id = f.isporuka_id AND
      f.faktura_id = np.faktura_id AND
      np.popust_id = ANY (SELECT popust_id FROM popust WHERE popust_id IS NOT NULL) AND
      np.proizvod_id = ANY (SELECT proizvod_id FROM proizvod WHERE broj_mjeseci_garancije > 0);

--9
SELECT naziv, cijena
FROM proizvod
WHERE cijena > (SELECT Round(Avg(Max(cijena)),2)
                FROM proizvod
                GROUP BY kategorija_id);


--10
SELECT pr.naziv, pr.cijena
FROM proizvod pr
WHERE pr.cijena < ALL(SELECT Avg(p.cijena)
                FROM proizvod p
                WHERE p.kategorija_id = ANY (SELECT k.kategorija_id FROM kategorija k WHERE pr.kategorija_id <> k.nadkategorija_id)
                GROUP BY p.kategorija_id);


--Zadatak 2
CREATE TABLE TabelaA(id NUMBER(15),
                     naziv VARCHAR2(25),
                     datum DATE,
                     cijelibroj NUMBER(20),
                     realnibroj NUMBER(20,2),
                     CONSTRAINT TabelaA_id_pk PRIMARY KEY (id),
                     CONSTRAINT cbA_check CHECK (cijelibroj NOT BETWEEN 5 AND 15),
                     CONSTRAINT rbA_check CHECK (realnibroj > 5));


CREATE TABLE TabelaB(id NUMBER(15),
                     naziv VARCHAR2(25),
                     datum DATE,
                     cijelibroj NUMBER(20),
                     realnibroj NUMBER(20,2),
                     FKTabelaA NUMBER(15) NOT NULL,
                     CONSTRAINT TabelaB_id_pk PRIMARY KEY (id),
                     CONSTRAINT TabelaB_a_fk FOREIGN KEY (FKTabelaA) REFERENCES TabelaA(id),
                     CONSTRAINT cbB_u UNIQUE (cijelibroj) );


CREATE TABLE TabelaC(id NUMBER(15),
                     naziv VARCHAR2(25) NOT NULL,
                     datum DATE,
                     cijelibroj NUMBER(20) NOT NULL,
                     realnibroj NUMBER(20,2),
                     FKTabelaB NUMBER(15),
                     CONSTRAINT TabelaC_id_pk PRIMARY KEY (id),
                     CONSTRAINT FkCnst FOREIGN KEY (FKTabelaB) REFERENCES TabelaB(id));


INSERT INTO TabelaA values (1, 'tekst', NULL, NULL, 6.2);
INSERT INTO TabelaA values (2, NULL, NULL, 3, 5.26);
INSERT INTO TabelaA values (3, 'tekst', NULL, 1, NULL);
INSERT INTO TabelaA values (4, NULL, NULL, NULL, NULL);
INSERT INTO TabelaA values (5, 'tekst', NULL, 16, 6.78);


INSERT INTO TabelaB values (1, NULL, NULL, 1, NULL,1);
INSERT INTO TabelaB values (2, NULL, NULL, 3, NULL, 1);
INSERT INTO TabelaB values (3, NULL, NULL, 6, NULL, 2);
INSERT INTO TabelaB values (4, NULL, NULL, 11, NULL, 2);
INSERT INTO TabelaB values (5, NULL, NULL, 22, NULL, 3);

INSERT INTO TabelaC values (1, 'YES', NULL, 33, NULL, 4);
INSERT INTO TabelaC values (2, 'NO', NULL, 33, NULL, 2);
INSERT INTO TabelaC values (3, 'NO', NULL, 55, NULL, 1);


--Moze se izvrsiti:
INSERT INTO TabelaA (id,naziv,datum,cijeliBroj,realniBroj) VALUES (6,'tekst',null,null,6.20);


--Ne moze se izvrsiti jer cijeliBroj mora biti unique, a vec imamo unesenu vrijednost 1
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,1,null,1);


--Moze se izvrsiti
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,123,null,6);


--Moze se izvrsiti
INSERT INTO TabelaC (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaB) VALUES (4,'NO',null,55,null,null);


--Moze se izvrsiti
Update TabelaA set naziv = 'tekst' Where naziv is null and cijeliBroj is not null;


--Ne moze se izvrsiti jer je primary key iz TabelaA zapravo foreign key za TabelaC
Drop table tabelaB;


--Ne moze se izvrsiti jer jer je primaary key iz TabelaA zapravo foreign key za TabelaB
Delete from TabelaA where realniBroj is null;


--Moze se izvrsiti
Delete from TabelaA where id = 5;


--Moze se izvrsiti
Update TabelaB set fktabelaA = 4 where fktabelaA = 2;


--Moze se izvrsiti
Alter Table tabelaA add Constraint cst Check (naziv like 'tekst');

Select Sum(id) From TabelaA --Rezultat 16
Select Sum(id) From TabelaB --Rezultat 22
Select Sum(id) From TabelaC --Rezultat 10



--Zadatak 3
DROP TABLE TabelaC;
DROP TABLE TabelaB;
DROP TABLE TabelaA;


CREATE TABLE TabelaA(id NUMBER(15),
                     naziv VARCHAR2(25),
                     datum DATE,
                     cijelibroj NUMBER(20),
                     realnibroj NUMBER(20,2),
                     CONSTRAINT TabelaA_id_pk PRIMARY KEY (id),
                     CONSTRAINT cbA_check CHECK (cijelibroj NOT BETWEEN 5 AND 15),
                     CONSTRAINT rbA_check CHECK (realnibroj > 5));


CREATE TABLE TabelaB(id NUMBER(15),
                     naziv VARCHAR2(25),
                     datum DATE,
                     cijelibroj NUMBER(20),
                     realnibroj NUMBER(20,2),
                     FKTabelaA NUMBER(15) NOT NULL,
                     CONSTRAINT TabelaB_id_pk PRIMARY KEY (id),
                     CONSTRAINT TabelaB_a_fk FOREIGN KEY (FKTabelaA) REFERENCES TabelaA(id),
                     CONSTRAINT cbB_u UNIQUE (cijelibroj) );


CREATE TABLE TabelaC(id NUMBER(15),
                     naziv VARCHAR2(25) NOT NULL,
                     datum DATE,
                     cijelibroj NUMBER(20) NOT NULL,
                     realnibroj NUMBER(20,2),
                     FKTabelaB NUMBER(15),
                     CONSTRAINT TabelaC_id_pk PRIMARY KEY (id),
                     CONSTRAINT FkCnst FOREIGN KEY (FKTabelaB) REFERENCES TabelaB(id));


INSERT INTO TabelaA values (1, 'tekst', NULL, NULL, 6.2);
INSERT INTO TabelaA values (2, NULL, NULL, 3, 5.26);
INSERT INTO TabelaA values (3, 'tekst', NULL, 1, NULL);
INSERT INTO TabelaA values (4, NULL, NULL, NULL, NULL);
INSERT INTO TabelaA values (5, 'tekst', NULL, 16, 6.78);


INSERT INTO TabelaB values (1, NULL, NULL, 1, NULL,1);
INSERT INTO TabelaB values (2, NULL, NULL, 3, NULL, 1);
INSERT INTO TabelaB values (3, NULL, NULL, 6, NULL, 2);
INSERT INTO TabelaB values (4, NULL, NULL, 11, NULL, 2);
INSERT INTO TabelaB values (5, NULL, NULL, 22, NULL, 3);

INSERT INTO TabelaC values (1, 'YES', NULL, 33, NULL, 4);
INSERT INTO TabelaC values (2, 'NO', NULL, 33, NULL, 2);
INSERT INTO TabelaC values (3, 'NO', NULL, 55, NULL, 1);

CREATE SEQUENCE seq1
INCREMENT BY 1
START WITH 1;

CREATE SEQUENCE seq2
INCREMENT BY 1
START WITH 0
MINVALUE 0;

CREATE TABLE TabelaABekap(id NUMBER(15),
                     naziv VARCHAR2(25),
                     datum DATE,
                     cijelibroj NUMBER(20),
                     realnibroj NUMBER(20,2),
                     cijeliBrojB INTEGER,
                     sekvenca INTEGER,
                     CONSTRAINT TabelaAB_id_pk PRIMARY KEY (id),
                     CONSTRAINT cbAB_check CHECK (cijelibroj NOT BETWEEN 5 AND 15),
                     CONSTRAINT rbAB_check CHECK (realnibroj > 5));


CREATE OR REPLACE TRIGGER trigger1
AFTER INSERT ON TabelaB
FOR EACH ROW
DECLARE
    uslov INTEGER;
    idd NUMBER(20);
    name VARCHAR2(45);
    datumcic DATE;
    cb NUMBER(20);
    rb NUMBER(20,2);
BEGIN
    SELECT t.id, t.naziv, t.datum, t.cijelibroj, t.realnibroj
       INTO idd, name, datumcic, cb, rb
       FROM TabelaA t
       WHERE t.id = :new.FKTabelaA;
    SELECT Count(*)
    INTO uslov
    FROM TabelaABekap bekap
    WHERE bekap.id = idd;
    IF uslov = 0 THEN
       INSERT INTO TabelaABekap
       VALUES(idd, name, datumcic, cb, rb, :new.cijelibroj, seq1.nextval);
    ELSE
       UPDATE TabelaABekap
       SET cijeliBrojB = cijeliBrojB + :new.cijelibroj
       WHERE id = :new.FKTabelaA;
    END IF;
END;

DROP TABLE TabelaBCheck;

CREATE TABLE TabelaBCheck(sekvenca INTEGER PRIMARY KEY);

CREATE OR REPLACE TRIGGER trigger2
AFTER DELETE ON TabelaB
BEGIN
    INSERT INTO TabelaBCheck(sekvenca)
    VALUES (seq2.nextval);
END;

CREATE PROCEDURE procedure1 (broj NUMBER)
AS
   idd NUMBER(20);
   suma NUMBER(20);
BEGIN
   SELECT Count(*)+1 INTO idd FROM TabelaC;
   SELECT Sum(cijelibroj) INTO suma FROM TabelaA;
   FOR i IN 1..suma LOOP
      INSERT INTO TabelaC (id,naziv,cijelibroj) VALUES (idd, 'no.', broj);
      idd := idd + 1;
   END LOOP;
END;

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,2,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,4,null,2);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (8,null,null,8,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (9,null,null,5,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (10,null,null,7,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (11,null,null,9,null,5);
Delete From TabelaB where id not in (select FkTabelaB from TabelaC);
Alter TABLE tabelaC drop constraint FkCnst;
Delete from TabelaB where 1=1;
call procedure1(1);


