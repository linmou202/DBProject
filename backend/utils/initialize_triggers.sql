use `flat`;

DELIMITER |

create function `get_mtid`()
returns int
reads sql data
begin
    declare count int default 0;
    declare new_mtid int default 0;
    select count(*) into count from `maintenance`;
    if count > 0 then
        select `mtid` into new_mtid from `maintenance` order by `mtid` desc limit 1;
        set new_mtid = new_mtid + 1;
    end if;
    return new_mtid;
end|

create function `get_resid`()
returns int
reads sql data
begin
    declare count int default 0;
    declare new_resid int default 0;
    select count(*) into count from `reservation`;
    if count > 0 then
        select `resid` into new_resid from `reservation` order by `resid` desc limit 1;
        set new_resid = new_resid + 1;
    end if;
    return new_resid;
end|

create trigger `assign_mtid` before insert on `maintenance` for each row
begin
    set new.`mtid` = get_mtid();
    set new.`status` = 0;
    set new.`subtime` = curdate();
    set new.`admid` = null;
    set new.`fintime` = null;
end|

create trigger `assign_default_vis` before update on `visitor` for each row
begin
    if new.`name` = '' then
        set new.`name` = old.`name`;
    end if;
    if new.`telephone` = '' then
        set new.`telephone` = old.`telephone`;
    end if;
end|

create trigger `assign_default_res` before update on `reservation` for each row
begin
    if new.`visid` = '' then
        set new.`visid` = old.`visid`;
    end if;
    if new.`date` is null then
        set new.`date` = old.`date`;
    end if;
    if new.`reason` = '' then
        set new.`reason` = old.`reason`;
    end if;
end|

create trigger `assign_resid` before insert on `reservation` for each row
begin
    set new.`resid` = get_resid();
end|

DELIMITER ;