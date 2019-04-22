
create or replace package read_funcs2 AS

  type uczestnik_record is record (
    IMIE VARCHAR2(50),
    NAZWISKO VARCHAR2(50),
    STATUS_REZERWACJI CHAR(1)
  );
  type uczestnicy_table is table of uczestnik_record;


  type rezerwacja_record is record (
    ID_OSOBY NUMBER,
    NR_REZERWACJI NUMBER,
    ID_WYCIECZKI NUMBER,
    NAZWA VARCHAR2(100),
    KRAJ VARCHAR2(50),
    DATA DATE,
    STATUS CHAR(1)
  );
  type rezerwacje_table is table of rezerwacja_record;


  type wycieczka_record is record (
    ID_WYCIECZKI NUMBER,
    NAZWA VARCHAR2(100),
    KRAJ VARCHAR2(50),
    DATA DATE,
    OPIS VARCHAR2(200),
    LICZBA_MIEJSC INT,
    LICZBA_WOLNYCH_MIEJSC INT
  );
  type wycieczki_table is table of wycieczka_record;

  function dostepne_wycieczki2 (KRAJ_ in varchar2, DATA_OD_ in date, DATA_DO_ in date)
    return wycieczki_table pipelined;

end read_funcs2;


create or replace package body read_funcs2 as

--d) dostepne_wycieczki(kraj, data_od, data_do)
--chcemy sprawdzić wycieczki które mają jeszcz miejsca w jakimś przedziale czasowym
function dostepne_wycieczki2(KRAJ_ in VARCHAR2, DATA_OD_ in DATE, DATA_DO_ in DATE)
  return wycieczki_table pipelined
  as

  trip_exists number(1);
  cursor wycieczki is
    select * from WYCIECZKI w
    where w.KRAJ = KRAJ_ and  w.DATA >= DATA_OD_ and w.DATA < DATA_DO_;

  begin
      select case
                   when exists (select *
                                from wycieczki w
                                where w.KRAJ = KRAJ_ and  w.DATA >= DATA_OD_ and w.DATA < DATA_DO_ and w.LICZBA_WOLNYCH_MIEJSC > 0)
                     then 1
                   else 0
                 end
          into trip_exists
          from DUAL;

      if trip_exists = 0 then
          RAISE_APPLICATION_ERROR(-20001, 'Nie ma wycieczek spełniających te kryteria');
      end if;

        --wypisanie
        for wycieczka in wycieczki
        loop
          pipe row (wycieczka);
        end loop;
  end;

end read_funcs2;

select * from table (read_funcs2.dostepne_wycieczki2('Czechy', to_date('2015-04-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                                                             to_date('2019-05-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS')));