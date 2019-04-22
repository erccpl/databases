

-- 5. MODIFYING PROCEDURES/FUNCTIONS 2

--DECLARATIONS
create or replace package mod_procedures as

--Procedure declarations
  procedure dodaj_rezerwacje(ID_WYCIECZKI_ in int, ID_OSOBY_ in int);
  procedure zmien_status_rezerwacji(NR_REZERWACJI_ in int, STATUS_ in char);
  procedure zmien_liczbe_miejsc(ID_WYCIECZKI_ in int, LICZBA_MIEJSC_ in int);

end mod_procedures;


create or replace package body mod_procedures as

--a) dodaj_rezerwacje(id_wycieczki, id_osoby), procedura powinna kontrolować czy wycieczka
-- jeszcze się nie odbyła, i czy sa wolne miejsca
procedure dodaj_rezerwacje(ID_WYCIECZKI_ in int, ID_OSOBY_ in int)
  as
    person_exists number;
    trip_exists number;
    new_reservation_id number;

    begin
      select case
          when exists(
                        select * from OSOBY where ID_OSOBY = ID_OSOBY_)
                    then 1
                   else 0
                 end
          into person_exists
          from dual;

      select case
          when exists(
                      select w.ID_WYCIECZKI, w.DATA, dw.WOLNE
                      from WYCIECZKI w
                      join dostepne_wycieczki dw on dw.ID_WYCIECZKI = w.ID_WYCIECZKI
                      where w.ID_WYCIECZKI = ID_WYCIECZKI_ and w.DATA > sysdate and dw.WOLNE > 0
                                          )
                    then 1
                   else 0
                 end
          into trip_exists
          from dual;

          if (person_exists = 0) then
            RAISE_APPLICATION_ERROR(-20001, 'Nie ma takiej osoby');
          end if;

          if (trip_exists = 0) then
            RAISE_APPLICATION_ERROR(-20001, 'Wycieczka nie istnieje bądź już się odbyła');
          end if;

          if (person_exists = 1 and trip_exists = 1) then
            insert into rezerwacje(id_wycieczki, id_osoby, status)
            values (ID_WYCIECZKI_, ID_OSOBY_,'N');

            select max(NR_REZERWACJI)
            into new_reservation_id
            from REZERWACJE;

            insert into REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS)
            values(new_reservation_id, current_date, 'N');

          end if;
  end;

--b) zmien_status_rezerwacji(id_rezerwacji, status), procedura kontrolować czy możliwa jest
--zmiana statusu, np. zmiana statusu już anulowanej wycieczki (przywrócenie do stanu
--aktywnego nie zawsze jest możliwe)
procedure zmien_status_rezerwacji(NR_REZERWACJI_ in int, STATUS_ in char)
  as
    reservation_exists number;
    in_past_and_cancelled number;
    begin
        select case
          when exists(select * from REZERWACJE where NR_REZERWACJI_ = NR_REZERWACJI)
                    then 1
                   else 0
                 end
          into reservation_exists
          from dual;

        select case
          when exists(
                          select
                              r.NR_REZERWACJI,
                              r.STATUS,
                              w.ID_WYCIECZKI,
                              w.NAZWA,
                              w.DATA
                          from wycieczki w
                          join rezerwacje r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
                          where w.DATA < sysdate and STATUS in('A') and r.NR_REZERWACJI = NR_REZERWACJI_
                                          )
                    then 1
                   else 0
                 end
          into in_past_and_cancelled
          from dual;

          if (reservation_exists = 0) then
            RAISE_APPLICATION_ERROR(-20001, 'Taka rezerwacja nie istnieje');
          end if;

          if (in_past_and_cancelled = 1) then
            RAISE_APPLICATION_ERROR(-20001, 'Anulowana rezerwacja z przeszłości, nie można zmienić stanu');
          end if;

          if(reservation_exists = 1 and in_past_and_cancelled = 0) then
             update REZERWACJE
             set STATUS = STATUS_
             where NR_REZERWACJI = NR_REZERWACJI_;

             insert into REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS)
             values(NR_REZERWACJI_, current_date, STATUS_);

          end if;
    end;


--c) zmien_liczbe_miejsc(id_wycieczki, liczba_miejsc), nie wszystkie zmiany liczby miejsc są
--dozwolone, nie można zmniejszyć liczby miesc na wartość poniżej liczby zarezerwowanych
--miejsc
procedure zmien_liczbe_miejsc(ID_WYCIECZKI_ in int, LICZBA_MIEJSC_ in int)
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
                              w.LICZBA_MIEJSC - (select count(ID_WYCIECZKI) from REZERWACJE r where w.ID_WYCIECZKI = r.ID_WYCIECZKI) wolne
                        from WYCIECZKI w
                        join REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
                        where w.LICZBA_MIEJSC - (select count(ID_WYCIECZKI) from REZERWACJE r where w.ID_WYCIECZKI = r.ID_WYCIECZKI) >= 0
                        and LICZBA_MIEJSC_ >= (select count(ID_WYCIECZKI) from REZERWACJE r where w.ID_WYCIECZKI = r.ID_WYCIECZKI)
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
        end if;
  end;

end mod_procedures;