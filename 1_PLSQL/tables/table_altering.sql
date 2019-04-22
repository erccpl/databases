------------------------------------------------------------------------------------------------------------------------------------------------

-- 7. CHNAGE IN TABLE

----------------------------------------------------------------------------------------------------------------------------------------------

--Zmieniamy strukturę tabeli WYCIECZKI:
ALTER TABLE WYCIECZKI
ADD LICZBA_WOLNYCH_MIEJSC INT;


--Procedura obliczająca ile jest wolnych miejsc dla istniejących danych
create or replace procedure oblicz_wolne_miejsca(ID_WYCIECZKI_ in int)
  as
  wolne_miejsca number;
  begin

          select unique
          w.LICZBA_MIEJSC - (select count(ID_WYCIECZKI) from REZERWACJE r where r.ID_WYCIECZKI = w.ID_WYCIECZKI and r.STATUS not in ('A'))
          into wolne_miejsca
          from WYCIECZKI w
          join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
          where w.ID_WYCIECZKI = ID_WYCIECZKI_;

      update WYCIECZKI
      set LICZBA_WOLNYCH_MIEJSC = wolne_miejsca
      where ID_WYCIECZKI = ID_WYCIECZKI_;
  end;

--Test
select * from wycieczki;
call oblicz_wolne_miejsca(1);