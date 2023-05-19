--1.
SELECT Nvl(d.naziv,'Nema države') "DRZAVA" , Nvl(g.naziv, 'Nema grada') "GRAD", k.naziv "KONTINENT"
FROM kontinent k
LEFT JOIN drzava d
ON k.kontinent_id = d.kontinent_id
LEFT JOIN grad g
ON d.drzava_id = g.drzava_id;

--2.
SELECT DISTINCT lice.naziv "NAZIV"
FROM pravno_lice lice
INNER JOIN  ugovor_za_pravno_lice ugovor
ON Lice.pravno_lice_id = ugovor.pravno_lice_id
WHERE ugovor.datum_potpisivanja BETWEEN To_Date('2014', 'YYYY') AND To_Date('2016', 'YYYY');

--3.
SELECT d.naziv "DRZAVA", pr.naziv "PROIZVOD", kol.kolicina_proizvoda "KOLICINA_PROIZVODA"
FROM drzava d, proizvod pr, kolicina kol, skladiste sk, lokacija lok, grad gr
WHERE kol.kolicina_proizvoda > 50 AND
      d.naziv NOT LIKE '%s%s%' AND
      kol.proizvod_id = pr.proizvod_id AND
      kol.skladiste_id = sk.skladiste_id AND
      sk.lokacija_id = lok.lokacija_id AND
      lok.grad_id = gr.grad_id AND
      gr.drzava_id = d.drzava_id;

--4.
SELECT DISTINCT pr.naziv "NAZIV", pr.broj_mjeseci_garancije "BROJ MJESECI GARANCIJE"
FROM proizvod pr, popust p, narudzba_proizvoda np
WHERE p.postotak > 0 AND Mod(pr.broj_mjeseci_garancije,3)=0 AND pr.proizvod_id = np.proizvod_id AND p.popust_id = np.popust_id;

--5.
SELECT lice.ime || ' ' || lice.prezime "ime i prezime", od.naziv "Naziv odjela", '18906' "INDEX"
FROM uposlenik up, fizicko_lice lice, odjel od, kupac kup
WHERE up.uposlenik_id = kup.kupac_id AND up.uposlenik_id<>od.sef_id AND up.uposlenik_id=lice.fizicko_lice_id AND up.odjel_id = od.odjel_id;

--6.
SELECT np.narudzba_id "NARUDZBA_ID" , pr.cijena "CIJENA", Nvl(p.postotak, 0) "POSTOTAK", Nvl(p.postotak, 0)/100 "POSTOTAKREALNI"
FROM narudzba_proizvoda np, proizvod pr, popust p
WHERE pr.cijena*Nvl(p.postotak, 0)/100 < 200 AND p.popust_id(+) = np.popust_id AND pr.proizvod_id = np.proizvod_id;

--7.
SELECT kat.naziv "Kategorija", Decode(Nvl(nadkat.nadkategorija_id,0),1 ,'Komp Oprema', 0, 'Nema Kategorije') "Nadkategorija"
FROM kategorija kat
LEFT JOIN kategorija nadkat
ON kat.kategorija_id = nadkat.kategorija_id;

--8.
SELECT ugovor.datum_potpisivanja AS "DATUM POTPISIVANJA",
       Trunc(Months_Between(To_Date('10.10.2020', 'dd.mm.YYYY'), ugovor.datum_potpisivanja) / 12 ) AS "GODINA",
       Trunc(Mod(Months_Between(To_Date('10.10.2020', 'dd.mm.YYYY'), ugovor.datum_potpisivanja), 12)) AS "MJESECI",
       Trunc(To_Date('10.10.2020', 'dd.mm.YYYY') - Add_Months(ugovor.datum_potpisivanja, Trunc(Months_Between(To_Date('10.10.2020', 'dd.mm.YYYY'), ugovor.datum_potpisivanja)))) AS "DANA"
FROM ugovor_za_pravno_lice ugovor
WHERE Trunc(Months_Between(To_Date('10.10.2020', 'dd.mm.YYYY'), ugovor.datum_potpisivanja)/12) > To_Number(SubStr(ugovor.ugovor_id,0,2));

--9.
SELECT lice.ime "IME", lice.prezime "PREZIME", Decode(od.naziv, 'Management', 'MANAGER', 'Human Resources', 'HUMAN', 'OTHER') "ODJEL", od.odjel_id "ODJEL_ID"
FROM uposlenik up, fizicko_lice lice, odjel od
WHERE up.uposlenik_id = lice.fizicko_lice_id AND up.odjel_id = od.odjel_id
ORDER BY lice.ime ASC, lice.prezime DESC;

--10.
SELECT kat.naziv "PROIZVOD", mali.naziv "NAJJEFTINIJI", veliki.naziv "NAJSKUPLJI", mali.cijena+veliki.cijena "ZCIJENA"
FROM proizvod mali, proizvod veliki, kategorija kat
WHERE kat.kategorija_id = mali.kategorija_id
      AND kat.kategorija_id = veliki.kategorija_id
      AND veliki.cijena = (SELECT Max(velika.cijena) FROM proizvod velika WHERE kat.kategorija_id = velika.kategorija_id)
      AND mali.cijena = (SELECT Min(mala.cijena) FROM proizvod mala WHERE kat.kategorija_id = mala.kategorija_id)
ORDER BY ZCijena ASC;
