-----------------------------------------------------------------------------------------------------------------------

-- 4. READ PROCEDURES/FUNCTIONS 2

-----------------------------------------------------------------------------------------------------------------------
--DECLARATIONS
create or replace package mod_procedures2 as

--Procedure declarations
  procedure zmien_liczbe_miejsc2(ID_WYCIECZKI_ in int, LICZBA_MIEJSC_ in int);

end mod_procedures2;

create or replace package body mod_procedures2 as

--c) zmien_liczbe_miejsc(id_wycieczki, liczba_miejsc), nie wszystkie zmiany liczby miejsc są
--dozwolone, nie można zmniejszyć liczby miesc na wartość poniżej liczby zarezerwowanych
--miejsc
procedure zmien_liczbe_miejsc2(ID_WYCIECZKI_ in int, LICZBA_MIEJSC_ in int)
  as
    trip_exists number;
    can_change number;

  begin
        select case
          when exists(select * from WYCIECZKI where ID_WYCIECZKI_ = ID_WYCIECZKI)
                    then 1
                   else 0
                 end
          into trip_exists
          from dual;

          select case
            when exists(
                         select unique
                              w.ID_WYCIECZKI,
                              w.NAZWA,
                              w.LICZBA_MIEJSC,
                              w.LICZBA_WOLNYCH_MIEJSC
                        from WYCIECZKI w
                        join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
                        where w.LICZBA_WOLNYCH_MIEJSC >= 0
                        and LICZBA_MIEJSC_ >= w.LICZBA_MIEJSC - w.LICZBA_WOLNYCH_MIEJSC
                        and w.ID_WYCIECZKI = ID_WYCIECZKI_
                         )
                      then 1
                     else 0
                   end
          into can_change
          from dual;

          if (trip_exists = 0) then
            RAISE_APPLICATION_ERROR(-20001, 'Nie ma takiej wycieczki');
          end if;

          if (can_change = 0) then
            RAISE_APPLICATION_ERROR(-20001, 'Nowa wartosc jest mniejsza od ilości zarezerwowanych miejsc');
          end if;

        if (trip_exists = 1 and can_change = 1) then
          update WYCIECZKI
          set LICZBA_MIEJSC = LICZBA_MIEJSC_
          where ID_WYCIECZKI = ID_WYCIECZKI_;
          oblicz_wolne_miejsca(ID_WYCIECZKI_);
        end if;
  end;

end mod_procedures2;

call mod_procedures2.zmien_liczbe_miejsc2(2, 10);