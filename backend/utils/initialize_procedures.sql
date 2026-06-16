use `flat`;

delimiter |

create procedure `reset_database`()
begin
    delete from `reservation`;
    delete from `visitor`;
    delete from `maintenance`;
    delete from `student`;
    delete from `admin`;
    delete from `room`;
    delete from `flat`;

    insert into `flat`(`flatid`, `address`) values
    ('F001', 'USTC South'),
    ('F002', 'USTC North');

    insert into `room`(`flatid`, `roomid`, `capacity`) values
    ('F001', '101', 4),
    ('F001', '102', 6),
    ('F002', '101', 6),
    ('F002', '102', 4);

    insert into `admin`(`admid`, `name`, `password`, `telephone`, `flatid`) values
    ('A001', 'alice', 'alice', '2000', 'F001'),
    ('A002', 'bob', 'bob', '2001', 'F001'),
    ('A003', 'charlie', 'charlie', '2002', 'F002');

    insert into `student`(`stuid`, `name`, `password`, `telephone`, `flatid`, `roomid`, `bedid`) values
    ('S001', 'Jane', 'Jane', '3000', 'F001', '101', '1'),
    ('S002', 'Kevin', 'Kevin', '3001', 'F001', '101', '4'),
    ('S003', 'Larry', 'Larry', '3002', 'F001', '102', '2'),
    ('S004', 'Mary', 'Mary', '3003', 'F002', '101', '6'),
    ('S005', 'Nate', 'Nate', '3004', 'F002', '102', '3'),
    ('S006', 'Ori', 'Ori', '3005', null, null, null);

    insert into `maintenance`(`mtid`, `request`, `status`, `flatid`, `roomid`, `stuid`, `subtime`, `admid`, `fintime`) values
    (6, 'please fix the air conditioner.', 1, 'F001', '101', 'S001', '2026-06-01', 'A001', null),
    (10, "the lights are'nt working.", 0, 'F002', '102', 'S005', '2026-06-10', null, null);

    insert into `visitor`(`visid`, `stuid`, `name`, `telephone`) values
    ('V001', 'S001', 'Violet', '4000');

    insert into `reservation`(`resid`, `visid`, `stuid`, `date`, `reason`) values
    (0, 'V001', 'S001', '2026-06-18', 'for a tour');
end|

create procedure `find_account`(in username char(10), in pwd varchar(16), out ac_type int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set ac_type = 0;

    select count(*) into count from `admin` where `admid` = username and `password` = pwd;
    if count = 1 then
		set ac_type = 1;
	end if;

    select count(*) into count from `student` where `stuid` = username and `password` = pwd;
    if count = 1 then
		set ac_type = 2;
	end if;

    if s > 0 then
        set ac_type = -1;
    end if;
    
	if ac_type > 0 then
		commit;
	else
		rollback;
	end if;
end|

create procedure `add_maintenance_record`(in stu_id char(10), in flat_id char(8), in room_id char(8), in content varchar(100), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare my_flat char(8) default '';
    declare my_room char(8) default '';
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select `flatid`, `roomid` into my_flat, my_room from `student` where `stuid` = stu_id;
    if my_flat != flat_id or my_room != room_id then
        set stat = 2;
    end if;

    select count(*) into count from `maintenance` where `stuid` = stu_id and `status` != 2;
    if count >= 10 then
        set stat = 3;
    end if;

    insert into `maintenance`(`request`, `flatid`, `roomid`, `stuid`) values
    (content, flat_id, room_id, stu_id);
    
    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

create procedure `remove_maintenance_record`(in mt_id int, in stu_id char(10), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `maintenance` where `mtid` = mt_id and `stuid` = stu_id and `status` != 2;
    
	if count = 0 then
		set stat = 2;
	else 
        delete from maintenance where `mtid` = mt_id;
    end if;
    
    if s > 0 then
        set stat = s;
    end if;
    
    if stat > 0 then
        rollback;
    else
        commit;
    end if;
end|

create procedure `acquire_maintenance_record`(in mt_id int, in adm_id char(10), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `maintenance` where `admid` = adm_id and `status` = 1;
    if count >= 10 then
        set stat = 3;
	end if;

    select count(*) into count from `maintenance`, `admin` where `maintenance`.`mtid` = mt_id and `maintenance`.`flatid` = `admin`.`flatid` and `admin`.`admid` = adm_id and `maintenance`.`status` = 0;
	if count = 0 then
		set stat = 2;
	else 
        update `maintenance` set `status` = 1, `admid` = adm_id where `mtid` = mt_id;
    end if;
    
    if s > 0 then
        set stat = s;
    end if;
    
    if stat > 0 then
        rollback;
    else
        commit;
    end if;
end|

create procedure `complete_maintenance_record`(in mt_id int, in adm_id char(10), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `maintenance` where `mtid` = mt_id and `admid` = adm_id and `status` = 1;
	if count = 0 then
		set stat = 2;
	else 
        update `maintenance` set `status` = 2, `fintime` = curdate() where `mtid` = mt_id;
    end if;
    
    if s > 0 then
        set stat = s;
    end if;
    
    if stat > 0 then
        rollback;
    else
        commit;
    end if;
end|

create procedure `discard_maintenance_record`(in mt_id int, in adm_id char(10), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `maintenance` where `mtid` = mt_id and `admid` = adm_id and `status` = 1;
	if count = 0 then
		set stat = 2;
	else 
        update `maintenance` set `status` = 0, `admid` = null where `mtid` = mt_id;
    end if;
    
    if s > 0 then
        set stat = s;
    end if;
    
    if stat > 0 then
        rollback;
    else
        commit;
    end if;
end|

create procedure `add_visitor`(in stu_id char(10), in vis_id char(20), in name_ varchar(50), in telephone_ varchar(16), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `visitor` where `stuid` = stu_id;
    if count >= 10 then
        set stat = 2;
    end if;

    insert into `visitor`(`visid`, `stuid`, `name`, `telephone`) values
    (vis_id, stu_id, name_, telephone_);
    
    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

create procedure `update_visitor`(in stu_id char(10), in vis_id char(20), in name_ varchar(50), in telephone_ varchar(16), in ori_visid char(20), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare ori_name varchar(50) default '';
    declare ori_telephone varchar(16) default '';

    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `visitor` where `visid` = ori_visid and `stuid` = stu_id;
    select `name`, `telephone` into ori_name, ori_telephone from `visitor` where `visid` = ori_visid and `stuid` = stu_id;
    if count = 0 then
        set stat = 2;
    end if;

    if vis_id != ori_visid then
        insert into `visitor`(`visid`, `stuid`, `name`, `telephone`) values (vis_id, stu_id, ori_name, ori_telephone); 
        update `reservation` set `visid` = vis_id where `visid` = ori_visid and `stuid` = stu_id;
        delete from `visitor` where `visid` = ori_visid and `stuid` = stu_id;
    end if;

    update `visitor` set `name` = name_, `telephone` = telephone_ where `visid` = vis_id and `stuid` = stu_id;
    
    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

create procedure `delete_visitor`(in stu_id char(10), in vis_id char(20), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `visitor` where `stuid` = stu_id and `visid` = vis_id;
    if count = 0 then
        set stat = 2;
    end if;

    delete from `reservation` where `visid` = vis_id and `stuid` = stu_id;
    delete from `visitor` where `visid` = vis_id and `stuid` = stu_id;

    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|


create procedure `add_reservation`(in stu_id char(10), in vis_id char(20), in date_ date, in reason_ varchar(100), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `reservation` where `stuid` = stu_id and `date` >= curdate();
    if count >= 10 then
        set stat = 2;
    end if;
    select count(*) into count from `reservation` where `visid` = vis_id and `date` = date_;
    if count >= 1 then 
        set stat = 2;
    end if;

    if date_ < curdate() then
        set stat = 3;
    end if;

    insert into `reservation`(`visid`, `stuid`, `date`, `reason`) values
    (vis_id, stu_id, date_, reason_);
    
    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

create procedure `update_reservation`(in res_id int, in stu_id char(10), in vis_id char(20), in date_ date, in reason_ varchar(100), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare ori_date date;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `reservation` where `stuid` = stu_id and `resid` = res_id;
    select `date` into ori_date from `reservation` where `stuid` = stu_id and `resid` = res_id;
    if count = 0 then
        set stat = 4;
    end if;
    if ori_date < curdate() then
        set stat = 5;
    end if;

    if date_ is not null then
        select count(*) into count from `reservation` where `visid` = vis_id and `date` = date_ and `resid` != res_id;
        if count >= 1 then 
            set stat = 2;
        end if;

        if date_ < curdate() then
            set stat = 3;
        end if;
    end if;

    update `reservation` set `visid` = vis_id, `date` = date_, `reason` = reason_ where `resid` = res_id;
    
    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|


create procedure `delete_reservation`(in stu_id char(10), in res_id int, out stat int)
begin
    declare s int default 0;
    declare count int;
    declare ori_date date;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `reservation` where `stuid` = stu_id and `resid` = res_id;
    select `date` into ori_date from `reservation` where `stuid` = stu_id and `resid` = res_id;
    if count = 0 then
        set stat = 2;
    end if;
    if ori_date < curdate() then
        set stat = 3;
    end if;

    delete from `reservation` where `resid` = res_id and `stuid` = stu_id;

    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

create procedure `assign_dorm`(in stu_id char(10), in flat_id char(8), in room_id char(8), in bed_id int, out stat int)
begin
    declare s int default 0;
    declare count int;
    declare room_capacity int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `student` where `stuid` = stu_id and (`flatid` = flat_id or `flatid` is null);
    if count = 0 then
        set stat = 2;
    end if;

    select count(*) into count from `student` where `flatid` = flat_id and `roomid` = room_id and `bedid` = bed_id;
    if count > 0 then 
        set stat = 3;
    end if;
    select `capacity` into room_capacity from `room` where `flatid` = flat_id and `roomid` = room_id;
    if bed_id < 1 or bed_id > room_capacity then
        set stat = 3;
    end if;

    update `student` set `flatid` = flat_id, `roomid` = room_id, `bedid` = bed_id where `stuid` = stu_id;

    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

create procedure `cancel_dorm`(in stu_id char(10), in flat_id char(8), out stat int)
begin
    declare s int default 0;
    declare count int;
    declare continue handler for sqlexception set s = 1;

    start transaction;
    set stat = 0;

    select count(*) into count from `student` where `stuid` = stu_id and `flatid` = flat_id;
    if count = 0 then
        set stat = 2;
    end if;

    update `student` set `flatid` = null, `roomid` = null, `bedid` = null where `stuid` = stu_id;

    if s > 0 then
        set stat = s;
    end if;

	if stat > 0 then
		rollback;
	else
		commit;
	end if;
end|

delimiter ;