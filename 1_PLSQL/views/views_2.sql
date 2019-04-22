

--VIEWS 2 

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