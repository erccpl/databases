-------------------------------------------------------------------------------

--3. VIEWS 1

-------------------------------------------------------------------------------

--a) wycieczki osoby
CREATE OR REPLACE VIEW wycieczki_osoby
  AS
    SELECT
      w.ID_WYCIECZKI,
      w.NAZWA,
      w.KRAJ,
      w.DATA,
      o.IMIE,
      o.NAZWISKO,
      r.STATUS
FROM WYCIECZKI w
  JOIN REZERWACJE r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
  JOIN OSOBY o ON r.ID_OSOBY = o.ID_OSOBY;

select * from osoby;
select * from wycieczki_osoby
    order by ID_WYCIECZKI;

--b) wycieczki_osoby_potwierdzone (kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
create or replace view wycieczki_osoby_potwierdzone
  as
    select
      w.ID_WYCIECZKI,
      w.NAZWA,
      w.KRAJ,
      w.DATA,
      o.IMIE,
      o.NAZWISKO,
      r.STATUS
    from wycieczki w
    join rezerwacje r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
    join osoby o ON r.ID_OSOBY = o.ID_OSOBY
    where r.STATUS = 'P';

  select * from wycieczki_osoby;
  select * from wycieczki_osoby_potwierdzone order by id_wycieczki;


--c) wycieczki_przyszle (kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
create or replace view wycieczki_przyszle
  as
    select
      w.ID_WYCIECZKI,
      w.NAZWA,
      w.KRAJ,
      w.DATA,
      o.IMIE,
      o.NAZWISKO,
      r.STATUS
    from wycieczki w
    join rezerwacje r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
    join osoby o ON r.ID_OSOBY = o.ID_OSOBY
    where w.DATA > sysdate;

--d) wycieczki_miejsca(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
create or replace view wycieczki_miejsca
  as
      select unique
            w.ID_WYCIECZKI,
            w.NAZWA,
            w.LICZBA_MIEJSC,
            w.LICZBA_MIEJSC - (select count(ID_WYCIECZKI)
                               from REZERWACJE r where w.ID_WYCIECZKI = r.ID_WYCIECZKI
                               and r.STATUS not in ('A')) Wolne
      from WYCIECZKI w
      join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
      order by w.ID_WYCIECZKI;


--e) dostępne_wyciezki(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
create or replace view dostepne_wycieczki
  as
      select unique
            w.ID_WYCIECZKI,
            w.NAZWA,
            w.LICZBA_MIEJSC,
            w.LICZBA_MIEJSC - (select count(ID_WYCIECZKI) from REZERWACJE r
                               where w.ID_WYCIECZKI = r.ID_WYCIECZKI
                               and r.STATUS not in ('A')) wolne
      from WYCIECZKI w
      join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
      where w.LICZBA_MIEJSC - (select count(ID_WYCIECZKI) from REZERWACJE r where w.ID_WYCIECZKI = r.ID_WYCIECZKI
                              and r.STATUS not in ('A')) > 0
      and w.DATA > sysdate
      order by w.ID_WYCIECZKI;

--f) rezerwacje_do_ anulowania
-- – lista niepotwierdzonych rezerwacji które powinne zostać anulowane,
-- rezerwacje przygotowywane są do anulowania na tydzień przed wyjazdem)
create or replace view rezerwacje_do_anulowania
  as
      select
            w.ID_WYCIECZKI,
            w.NAZWA,
            w.DATA,
            r.NR_REZERWACJI,
            r.STATUS

      from WYCIECZKI w
      join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
       where r.STATUS = 'N' and round(to_number(w.DATA - sysdate) / 7) <= 1
      and round(to_number(w.DATA - sysdate) / 7) > 0
      order by w.ID_WYCIECZKI;


-------------------------------------------------------------------------------

--VIEWS 2 (after altering tables and adding a log table)

-------------------------------------------------------------------------------

--d) wycieczki_miejsca(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
create or replace view wycieczki_miejsca2
  as
      select unique
            w.ID_WYCIECZKI,
            w.NAZWA,
            w.LICZBA_MIEJSC,
            w.LICZBA_WOLNYCH_MIEJSC
      from WYCIECZKI w
      join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
      order by w.ID_WYCIECZKI;

select * from wycieczki_miejsca;
select * from wycieczki_miejsca2;

--e) dostępne_wyciezki(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
create or replace view dostepne_wycieczki2
  as
      select unique
            w.ID_WYCIECZKI,
            w.NAZWA,
            w.LICZBA_MIEJSC,
            w.LICZBA_WOLNYCH_MIEJSC
      from WYCIECZKI w
      join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
      where LICZBA_WOLNYCH_MIEJSC > 0
      order by w.ID_WYCIECZKI;


select * from dostepne_wycieczki;
select * from dostepne_wycieczki2;