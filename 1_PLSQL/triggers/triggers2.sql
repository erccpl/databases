------------------------------------------------------------------------------------------------------------------------------------------------

-- 9. CHANGE HANDLING OF FREE SPOTS

----------------------------------------------------------------------------------------------------------------------------------------------

--Triggers
--a) Trigger obsługujący dodanie rezerwacji
drop trigger nowa_rezerwacja_trig1;
create or replace trigger nowa_rezerwacja_trig2
after insert on rezerwacje
  declare
    new_res_id number;
    id_wyc number;

    begin
      select max(NR_REZERWACJI)
      into new_res_id
      from REZERWACJE;

      select ID_WYCIECZKI
      into id_wyc
      from REZERWACJE where NR_REZERWACJI = new_res_id;

      insert into REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS)
      values(new_res_id, current_date, 'N');

      oblicz_wolne_miejsca(id_wyc); --ponowne przeliczenie
    end;

select * from WYCIECZKI;
--b) Trigger obsługujący zmianę statusu
drop trigger zmiana_statusu_rezerwacji_trig2;

create or replace trigger zmiana_statusu_rezerwacji_trig2
for update on rezerwacje compound trigger
 after each row is
    begin
     insert into REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS)
     values(:NEW.NR_REZERWACJI, current_date, :NEW.STATUS);
     oblicz_wolne_miejsca(:NEW.ID_WYCIECZKI);
  end after each row;
end;



select * from table (read_funcs.uczestnicy_wycieczki(5));
call triggered.zmien_status_rezerwacji3(101,'A');

call oblicz_wolne_miejsca(1);
select * from WYCIECZKI;

select * from wycieczki_osoby order by id_wycieczki;
select * from osoby;

select * from wycieczki_osoby
order by ID_WYCIECZKI;

call triggered.dodaj_rezerwacje3(5, 3);

select * from wycieczki;
select * from REZERWACJE_LOG;

select * from rezerwacje;


--c) Triger obsługujący zmianę liczby miejsc na poziomie wycieczki
drop trigger przelicz_wolne_miesjca;
create or replace trigger przelicz_wolne_miesjca
 before update on wycieczki for each row
   declare
     begin
       OBLICZ_WOLNE_MIEJSCA(:NEW.ID_WYCIECZKI);
    end;


create or replace procedure zmien_liczbe_miejsc3(ID_WYCIECZKI_ in int, LICZBA_MIEJSC_ in int)
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
        end if;
  end;

call zmien_liczbe_miejsc3(1, 12);
select * from WYCIECZKI;