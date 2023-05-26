create table account(
   username varchar(50),
   account_number numeric(16),
   password varchar(65),
   first_name varchar(50),
   last_name varchar(50),
   national_id numeric(10),
   date_of_brith date,
   type varchar(10),
   interest_rate int
);
create table login_log(
  username varchar(50),
  login_time timestamp,
  foreign key (username) references account(username) on delete CASCADE
);
create table transactions(
   type varchar(10),
   transaction_time timestamp,
   fromm numeric(16),
   too numeric(16),
   amount numeric(8,3)
   foreign key (fromm) references account(account_number) on delete CASCADE
   foreign key (too) references account(account_number) on delete CASCADE
);
create latest_balances(
    account_number numeric(16),
    amount numeric(8,3),
    foreign key (account_number) references account(account_number) on delete CASCADE
);
create snapshot_log(
    snapshot_id int,
    snapshot_timestamp timestamp
);
CREATE PROCEDURE `deposit` (in amount1 numeric(8,3))
BEGIN
declare username1 varchar(50);
declare account_number1 numeric(16);
set username1 = (select username from login_log where login_time=(select max(login_time) from login_log));
set account_number1 = (select account_number from account where username=username1);
insert into trancactions (type, trancaction_time,fromm, too, amount) values('deposit', now(),null, account_number1, amount1);
END

CREATE PROCEDURE `withdraw` (in amount1 numeric(8,3))
BEGIN
declare username1 varchar(50);
declare account_number1 numeric(16);
set username1 = (select username from login_log where login_time=(select max(login_time) from login_log));
set account_number1 = (select account_number from account where username=username1);
insert into trancactions (type, trancaction_time,fromm, too, amount) values('withdraw',now(),account_number1,null, amount1);
END

CREATE PROCEDURE `transfer` (in accountnumber numeric(16,0), in ammountt numeric(8.3))
BEGIN
declare a int default 0;
declare home_account numeric(16);
declare username1 varchar(40);
set a = (select count(account_number) from account where account_number = accountnumber);
set username1 = (select username from login_log where login_time = (select max(login_time) from login_log));
set home_account = (select account_number from account where username = username1);
#set home_account = (select account_number from (login_log inner join account on login_log.username=account.username));
if a > 0 and accountnumber in (select account_number from account) then
insert into  trancactions(type,trancaction_time,fromm,too,amount) values('transfer',now(),home_account, accountnumber, ammountt);
end if;
END


CREATE PROCEDURE `check_balance` ()
BEGIN
declare accountNumber numeric(16);
declare username1 varchar(50);
set username1 = (select username from login_log where login_time = (select max(login_time) from login_log));
set accountNumber = (select account_number from account where username=username1);
select amount from latest_balances where account_number = accountNumber;
END

CREATE PROCEDURE `interest_payment` ()
BEGIN
declare interest int ;
declare username1 varchar(50);
declare account_number1 numeric(16);
declare n int;
declare i int default 0;
declare login_username varchar(50);
set i = 0;
select username into login_username from login_log where login_time = (select max(login_time) from login_log);
if (select type from account where username = login_username) = 'employee' then
select count(*) into n from account;
while i < n do
if (select type from account order by username limit i,1) = 'client' then
set account_number1 = (select account_number from account order by username limit i,1);
set interest = (select inserted_rate from account order by username limit i,1);
insert into trancactions(type,trancaction_time,fromm,too, amount)values('interest',now(),null,account_number1,interest);
end if;
set i = i + 1;
end while;
end if;
END

CREATE PROCEDURE `log` (in username varchar(50), in passwordd varchar(50))
BEGIN
if (username, sha(passwordd)) in (select username,password from account) then
insert into login_log values(username,now());
else select 'register!!';
end if;
END


CREATE PROCEDURE `update_balances` ()
BEGIN
declare latest_snapshot timestamp;
declare i int default 0;
declare n int;
declare transaction_timee timestamp;
declare typee varchar(20);
declare accountNumber numeric(16);
declare accountNumber2 numeric(16);
declare n_amount numeric(8,3);
declare login_accountNumber numeric(16);
declare c_e_type varchar(10);
declare login_username varchar(50);
select snapshot_timestamp into latest_snapshot from snapshot_log  where snapshot_timestamp = (select max(snapshot_timestamp) from snapshot_log);
select count(*) into n from trancactions;
select username into login_username from login_log where login_time = (select max(login_time) from login_log);
select account_number into login_accountNumber from account where username = login_username;
select type into c_e_type from account where username = login_username;
set i = 0;
if (select type from account where username = login_username) = 'employee' then
while i < n do
select trancaction_time into transaction_timee from trancactions order by trancaction_time limit i, 1;
if transaction_timee > latest_snapshot  or latest_snapshot is null then
select type into typee from trancactions order by trancaction_time limit i,1;
if typee = 'deposit' then
set accountNumber = (select too from trancactions order by trancaction_time limit i, 1);
set n_amount = (select amount from trancactions order by trancaction_time limit i, 1);
update latest_balances set amount = amount + n_amount where account_number = accountNumber;
end if;
if typee = 'withdraw' then
set accountNumber = (select fromm from trancactions order by trancaction_time limit i,1);
set n_amount = (select amount from trancactions order by trancaction_time limit i,1);
if n_amount <= (select amount from latest_balances where account_number = accountNumber) then
update latest_balances set amount = amount - n_amount where account_number = accountNumber;
elseif n_amount > (select amount from latest_balances where account_number = accountNumber) and (c_e_type = 'employee') then
update latest_balances set amount = amount - n_amount where account_number = accountNumber;
end if;
end if;
if typee = 'transfer' then
set accountNumber = (select fromm from trancactions order by trancaction_time limit i,1);
set accountNumber2 = (select too from trancactions order by trancaction_time limit i,1);
set n_amount = (select amount from trancactions order by trancaction_time limit i,1);
if n_amount <= (select amount from latest_balances where account_number = accountNumber) then
update latest_balances set amount = amount - n_amount where account_number = accountNumber;
update latest_balances set amount = amount + n_amount where account_number = accountNumber2;
elseif n_amount > (select amount from latest_balances where account_number = accountNumber) and (c_e_type = 'employee') then
update latest_balances set amount = amount - n_amount where account_number = accountNumber;
update latest_balances set amount = amount + n_amount where account_number = accountNumber2;
end if;
end if;
if typee = 'interest' then
set accountNumber = (select too from trancactions order by trancaction_time limit i,1);
set n_amount = (select amount from trancactions order by trancaction_time limit i,1);
update latest_balances set amount = amount + ((amount * n_amount)/100) where account_number = accountNumber;
end if;
end if;
set i = i + 1;
end while;
end if;
insert into snapshot_log (snapshot_timestamp)values(now());
END

CREATE PROCEDURE `register` (in accountnumber decimal(16,0),passwordd varchar(50), in firstname varchar(50), in lastname varchar(50),nationalid decimal(10,0),in dateofbrith date, in typee varchar(10), in interestrate int)
BEGIN
if year(now())-year(dateofbrith) > 13 then
insert into account (username,account_number, password, first_name, last_name, national_id, date_of_brith, type, inserted_rate) values(null,accountnumber, sha(passwordd), firstname, lastname, nationalid, dateofbrith, typee, interestrate);
insert into latest_balances values(accountnumber, 0);
end if;
END

CREATE  TRIGGER `set_username` BEFORE INSERT ON `account` FOR EACH ROW BEGIN
set new.username = concat(new.first_name,new.last_name,new.national_id);
END


