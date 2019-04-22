

-- 4. READ PROCEDURES/FUNCTIONS

--DECLARATIONS
create or replace package read_funcs as

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


--Function declarations
  function uczestnicy_wycieczki (ID_WYCIECZKI_ in int)
    return uczestnicy_table pipelined;

  function rezerwacje_osoby (ID_OSOBY_ in int)
    return rezerwacje_table pipelined;

  function przyszle_rezerwacje_osoby (ID_OSOBY_ in int)
    return rezerwacje_table pipelined;

  function dostepne_wycieczki (KRAJ_ in varchar2, DATA_OD_ in date, DATA_DO_ in date)
    return wycieczki_table pipelined;

end read_funcs;


--Function DEFINITIONS--------------------------------------------
create or replace package body read_funcs as

--a) uczestnicy_wycieczki (id_wycieczki), procedura ma zwracać podobny zestaw danych jak widok wycieczki_osoby
function uczestnicy_wycieczki (ID_WYCIECZKI_ in int)
   return uczestnicy_table pipelined

  as
    id_exists number;
    cursor uczestnicy is
      select unique
             wo.IMIE,
             wo.NAZWISKO,
             wo.STATUS
           from wycieczki_osoby wo
           where wo.ID_WYCIECZKI = ID_WYCIECZKI_ and wo.STATUS not in ('A');

  begin
      --sprawdzenie
      select case
               when exists (select *
                            from WYCIECZKI w
                            where w.ID_WYCIECZKI = ID_WYCIECZKI_)
                 then 1
               else 0
             end
      into id_exists
      from dual;

      if id_exists = 0 then
        RAISE_APPLICATION_ERROR(-20001, 'Wycieczka nie istnieje');
      end if;

      --wypisanie
      for uczestnik in uczestnicy
      loop
        pipe row (uczestnik);
      end loop;

  end;


--b) rezerwacje_osoby(id_osoby), procedura ma zwracać podobny zestaw danych jak widok wycieczki_osoby
function rezerwacje_osoby(ID_OSOBY_ in int)
  return rezerwacje_table pipelined

  as
  id_exists number(1);
  cursor rezerwacje is
    select
          o.ID_OSOBY,
          r.NR_REZERWACJI,
          w.ID_WYCIECZKI,
          w.NAZWA,
          w.KRAJ,
          w.DATA,
          r.STATUS
      from wycieczki w
      join rezerwacje r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
      join osoby o on o.ID_OSOBY = r.ID_OSOBY
      where o.ID_OSOBY = ID_OSOBY_;

    begin
        select case
                 when exists (select *
                              from rezerwacje r
                              where r.ID_OSOBY = ID_OSOBY_)
                   then 1
                 else 0
               end
        into id_exists
        from DUAL;

        if id_exists = 0
        then
          RAISE_APPLICATION_ERROR(-20001, 'Taka osoba nie istnieje');
        end if;

        --wypisanie
        for rezerwacja in rezerwacje
        loop
          pipe row (rezerwacja);
        end loop;
 end;


--c) przyszle_rezerwacje_osoby(id_osoby) - zakładam że to takie że data jest w przyszłości
function przyszle_rezerwacje_osoby(ID_OSOBY_ in int)
  return rezerwacje_table pipelined

  as
  id_exists number(1);
  cursor rezerwacje is
    select
          o.ID_OSOBY,
          r.NR_REZERWACJI,
          w.ID_WYCIECZKI,
          w.NAZWA,
          w.KRAJ,
          w.DATA,
          r.STATUS
      from wycieczki w
      join rezerwacje r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
      join osoby o on o.ID_OSOBY = r.ID_OSOBY
      where o.ID_OSOBY = 1 and w.DATA > sysdate;

    begin
       select case
                 when exists (select *
                              from rezerwacje r
                              where r.ID_OSOBY = ID_OSOBY_)
                   then 1
                 else 0
               end
        into id_exists
        from DUAL;

        if id_exists = 0
        then
          RAISE_APPLICATION_ERROR(-20001, 'Taka osoba nie istnieje');
        end if;

        --wypisanie
        for rezerwacja in rezerwacje
        loop
          pipe row (rezerwacja);
        end loop;

end;

--d) dostepne_wycieczki(kraj, data_od, data_do)
--chcemy sprawdzić wycieczki które mają jeszcze miejsca w jakimś przedziale czasowym
function dostepne_wycieczki(KRAJ_ in VARCHAR2, DATA_OD_ in DATE, DATA_DO_ in DATE)
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
                                where w.KRAJ = KRAJ_ and  w.DATA >= DATA_OD_ and w.DATA < DATA_DO_)
                     then 1
                   else 0
                 end
          into trip_exists
          from DUAL;

      if trip_exists = 0 then
          RAISE_APPLICATION_ERROR(-20001, 'Nie ma wycieczek spełniających te kryterium');
      end if;

        --wypisanie
        for wycieczka in wycieczki
        loop
          pipe row (wycieczka);
        end loop;
  end;


end read_funcs;
