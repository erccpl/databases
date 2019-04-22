

-- 8. TRIGGERED LOGGING

--a)Trigger obsługujący dodanie rezerwacji
create or replace trigger nowa_rezerwacja_trig1
after insert on rezerwacje
  declare
    new_res_id number;
    begin
      select max(NR_REZERWACJI)
      into new_res_id
      from REZERWACJE;

      insert into REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS)
      values(new_res_id, current_date, 'N');

    end;

--b)Trigger obsługujący zmianę statusu
create or replace trigger zmiana_statusu_rezerwacji_trig1
after update on rezerwacje for each row
  declare
    begin

     insert into REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS)
     values(:NEW.NR_REZERWACJI, current_date, :NEW.STATUS);

    end;


--c)Trigger zabraniający usuwania rezerwacji
create or replace trigger block_res_removal_trig
before delete on rezerwacje
  declare
    begin
      raise_application_error(-20001,'Nie można usuwać rezerwacji');
    end;


create or replace package triggered as

--Declarations
 procedure dodaj_rezerwacje3(ID_WYCIECZKI_ in int, ID_OSOBY_ in int);
 procedure zmien_status_rezerwacji3(NR_REZERWACJI_ in int, STATUS_ in char);

end triggered;


create or replace package body triggered as

procedure dodaj_rezerwacje3(ID_WYCIECZKI_ in int, ID_OSOBY_ in int)
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
          end if;
  end;



--b) zmien_status_rezerwacji(id_rezerwacji, status), procedura kontrolować czy możliwa jest
--zmiana statusu, np. zmiana statusu już anulowanej wycieczki (przywrócenie do stanu
--aktywnego nie zawsze jest możliwe)
procedure zmien_status_rezerwacji3(NR_REZERWACJI_ in int, STATUS_ in char)
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
          end if;
    end;
end triggered;

call triggered.dodaj_rezerwacje3(5, 4);
call triggered.zmien_status_rezerwacji3(62,'Z');

