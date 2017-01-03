-- Carlos Adrian Gomez, Sean Bradley
-- COMP420

-- drop database brokerage;
create database brokerage;
use brokerage;

CREATE TABLE company (
  id int(9),
  cname varchar(64),
  stock_symbol varchar(6),
  xchange varchar(6), -- NMS or NYQ
  sector varchar(32),
  date_listed date,
  PRIMARY KEY (id)
);

CREATE TABLE hist_stock (
  id int(9) auto_increment,
  symbol varchar(6),
  hdate date,
  company_id int(9),
  hprice decimal(6,2) default 0,
  PRIMARY KEY (id),
  FOREIGN KEY (company_id)
    REFERENCES company(id)
);

CREATE TABLE personal_info (
  ssn char(9),
  fname varchar(32),
  lname varchar(32),
  email varchar(64),
  phone char(10),
  address varchar(54),
  city varchar(32),
  state char(2),
  PRIMARY KEY (ssn)
);

CREATE TABLE department (
  dpt_id int(3),
  dpt_name varchar(24),
  dpt_desc varchar(256),
  PRIMARY KEY (dpt_id)
);

CREATE TABLE workspace (
  wksp_room int(4),
  wksp_floor int(3),
  wksp_type char(7), -- 0.8 cubicles, 0.2 offices
  PRIMARY KEY (wksp_room)
);

CREATE TABLE employee (
  ssn varchar(9),
  emp_date_hired date,  --  'YYYY-MM-DD'
  dpt_id int(3),
  wksp_room int(4),
  PRIMARY KEY (ssn),
  FOREIGN KEY (dpt_id)
    REFERENCES department(dpt_id),
  FOREIGN KEY (ssn)
    REFERENCES personal_info(ssn),
  FOREIGN KEY (wksp_room)
    REFERENCES workspace(wksp_room)
);

CREATE TABLE broker (
  ssn char(9),
  broker_commission float(2,2), -- from (0.0 -- 0.99)
  salary int(9),
  broker_transactions int,
  PRIMARY KEY (ssn),
  FOREIGN KEY (ssn)
    REFERENCES employee(ssn)
);

CREATE TABLE manager (
  ssn char(9),
  mng_bonus int(9), -- generated randomly
  salary int(9), 
  PRIMARY KEY (ssn),
  FOREIGN KEY (ssn)
    REFERENCES employee(ssn)
);

CREATE TABLE salaried_employee (
    ssn char(9),
    salary int(9),
    PRIMARY KEY (ssn),
    FOREIGN KEY (ssn)
      REFERENCES employee(ssn)
);

CREATE TABLE nonsalaried_employee (
    ssn char(9),
    wage int(9),
    PRIMARY KEY (ssn),
    FOREIGN KEY (ssn)
      REFERENCES employee(ssn)
);

CREATE TABLE customer (
  ssn char(9),
  broker_ssn char(9),
  PRIMARY KEY (ssn),
  FOREIGN KEY (ssn) 
    REFERENCES personal_info(ssn),
  FOREIGN KEY (broker_ssn) 
    REFERENCES broker(ssn)
);

CREATE TABLE beneficiary (
  ssn char(9),
  customer_ssn char(9),
  PRIMARY KEY (ssn),
  FOREIGN KEY (ssn) 
    REFERENCES personal_info(ssn),
  FOREIGN KEY (customer_ssn)
    REFERENCES customer(ssn)
);

CREATE TABLE customer_account (
  id int(9) auto_increment,
  cust_ssn char(9),
  acct_value decimal(13, 2) default 0, -- 9 digit integer (billionaire club), 4 digit decimal
  PRIMARY KEY (id),
  FOREIGN KEY (cust_ssn)
    REFERENCES customer(ssn)
);

CREATE TABLE account_type (
  acct_id int(9),
  acct_type varchar(12),
  acct_min decimal(8, 4) default 0, -- 6 digit integer, 4 digit decimal
  PRIMARY KEY (acct_id),
  FOREIGN KEY (acct_id)
    REFERENCES customer_account(id)
);

CREATE TABLE cust_transaction (
  acct_id int(9),
  trans_date date, --  'YYYY-MM-DD'
  stock_symbol varchar(6),
  trans_quantity int(9) default 0,
  trans_type varchar(4), -- "buy", "sell",
  hist_id int(9),
  PRIMARY KEY (acct_id, trans_date, stock_symbol),
  FOREIGN KEY (acct_id)
    REFERENCES customer_account(id),
  FOREIGN KEY (hist_id)
    REFERENCES hist_stock(id)
);

-- Views
DROP VIEW IF EXISTS vw_high_value_accts;
CREATE VIEW `vw_high_value_accts` AS
SELECT  personal_info.fname AS 'First',
        personal_info.lname AS 'Last',
        customer_account.id AS 'Account ID',
        account_type.acct_type AS 'Type',
        customer_account.acct_value AS 'Value'
FROM personal_info
JOIN customer ON personal_info.ssn=customer.ssn
JOIN customer_account ON customer.ssn=customer_account.cust_ssn
JOIN account_type ON customer_account.id=account_type.acct_id
WHERE customer_account.acct_value >= 250000
ORDER BY customer_account.acct_value DESC;

DROP VIEW IF EXISTS vw_cash_accts;
CREATE VIEW `vw_cash_accts` AS
SELECT  personal_info.fname AS 'First',
        personal_info.lname AS 'Last',
        customer_account.id AS 'Account ID', 
        account_type.acct_type AS 'Type', 
        customer_account.acct_value AS 'Value'
FROM personal_info
JOIN customer ON personal_info.ssn=customer.ssn
JOIN customer_account ON customer.ssn=customer_account.cust_ssn
JOIN account_type ON customer_account.id=account_type.acct_id
WHERE account_type.acct_type='Cash'
ORDER BY customer_account.acct_value DESC;

DROP VIEW IF EXISTS vw_total_cash_value_traded;
CREATE VIEW `vw_total_cash_value_traded` AS
SELECT  sum(trans_quantity) AS 'Sum of Stocks', 
        trans_type as 'Transaction'
FROM cust_transaction
GROUP BY trans_type; 

DROP VIEW IF EXISTS vw_most_valuable_monthly_brokers;
CREATE VIEW `vw_most_valuable_monthly_brokers` AS
SELECT personal_info.ssn as 'SSN', concat(personal_info.fname, " ", personal_info.lname) as 'Name', count(trans_type) as 'Number of transactions', sum(trans_type) as 'Total value exchanged'
FROM personal_info
JOIN broker on personal_info.ssn=broker.ssn
JOIN customer on broker.ssn = customer.broker_ssn
JOIN customer_account on customer_account.cust_ssn = broker.ssn
JOIN cust_transaction on customer_account.id = cust_transaction.acct_id
WHERE cust_transaction.trans_date BETWEEN now() - INTERVAL 30 DAY AND now()
ORDER BY count(trans_type) desc;

DROP VIEW IF EXISTS vw_personal_info;
CREATE VIEW `vw_personal_info` AS
SELECT ssn as 'SSN', concat(fname, " ", lname), email as 'Email', phone as 'Phone Number', address as 'Address', city as 'City', state as 'State'
FROM personal_info;

DROP VIEW IF EXISTS vw_salaried_employees;
CREATE VIEW `vw_salaried_employees` AS
SELECT personal_info.ssn as 'SSN',
      concat(personal_info.fname, ' ', personal_info.lname) as 'Name',
      salaried_employee.salary AS 'Salary', personal_info.email as 'Email', 
      personal_info.phone as 'Phone Number', personal_info.address as 'Address',
      personal_info.city as 'City', personal_info.state as 'State'
FROM salaried_employee 
JOIN personal_info ON salaried_employee.ssn=personal_info.ssn;

DROP VIEW IF EXISTS vw_nonsalaried_employees;
CREATE VIEW `vw_nonsalaried_employees` AS
SELECT personal_info.ssn as 'SSN',
      concat(personal_info.fname, ' ', personal_info.lname) as 'Name',
      nonsalaried_employee.wage AS 'Wage', personal_info.email as 'Email', 
      personal_info.phone as 'Phone Number', personal_info.address as 'Address',
      personal_info.city as 'City', personal_info.state as 'State'
FROM nonsalaried_employee 
JOIN personal_info ON nonsalaried_employee.ssn=personal_info.ssn;


-- SP
-- 12 Stored Procedures

-- 1. sp: sp_buy_stock(varchar sector(32))
delimiter //
create procedure sp_buy_stock(in acct int(9), ticker varchar(6), qty int(9))
begin
declare stock_price decimal(6,2);
declare hist_id int(9);
set hist_id = (select hist_stock.id from hist_stock where (hist_stock.hdate = now()) and (hist_stock.symbol like ticker));
set stock_price = (select hist_stock.hprice from hist_stock where hist_stock.id = hist_id);

insert into cust_transaction (acct_id, trans_date, stock_symbol, trans_quantity, trans_type, hist_id)
values (acct, now(), ticker, qty, 'buy', hist_id);

update customer_account 
set customer_account.acct_value = ((select customer_account.acct_value from customer_account where customer_account.id = acct) + (stock_price * qty))
where customer_account.id = acct;
end //
delimiter ;


-- 2. sp: sp_get_company_by_sector(varchar sector(32))
delimiter //
create procedure sp_get_company_by_sector(in sect varchar(32))
begin
SELECT id as 'Company ID', cname as 'Company Name', stock_symbol as 'Stock Symbol', xchange as 'Trade Exchange', date_listed as 'Date Listed'
FROM company
WHERE sect like company.sector;
end //
delimiter ;

-- 3. sp: sp_get_company_by_popularity(begin_date date, end_date date)
-- display rows of companys (max to min) with company name and # of transactions next to it
-- eg 
-- Google     9324
-- Microsoft  5769
-- Yahoo      163
delimiter //
create procedure sp_get_company_by_popularity(in startd date, endd date)
begin
select company.cname, company.stock_symbol, count(cust_transaction.acct_id)
from company
join hist_stock on company.id = hist_stock.company_id
join cust_transaction on hist_stock.id = cust_transaction.hist_id
group by company.cname
order by count(cust_transaction.acct_id) desc;
end //
delimiter ;


-- 4. sp: sp_stock_change_in_value(varchar ticker, begin_date date, end_date date)
delimiter //
create procedure sp_stock_change_in_value(in ticker varchar(6), startd date, endd date)
begin
select abs((select hprice from hist_stock where hdate = startd) - (select hprice from hist_stock where hdate = endd)) as 'Change in Value';
end //
delimiter ;


-- 5. sp: sp_stocks_by_account(id int)
delimiter //
create procedure sp_stocks_by_account(in id int(9))
begin
declare p int;
declare m int;
drop temporary table if exists plus;
drop temporary table if exists minus;

create temporary table plus engine=memory
select stock_symbol, count(stock_symbol) as plus
from hist_stock
where (trans_type like 'buy') and (acct_id = id)
group by stock_symbol;

create temporary table minus engine=memory
select stock_symbol, count(stock_symbol) as minus
from hist_stock
where (trans_type like 'sell') and (acct_id = id)
group by stock_symbol;

select plus.stock_symbol, (plus.plus - ifnull(minus.minus, 0)) as 'Owned'
from plus
left join minus on plus.stock_symbol like minus.stock_symbol;

drop temporary table if exists plus;
drop temporary table if exists minus;
end //
delimiter ;

-- 6. sp: sp_stock_mode(varchar ticker, begin_date date, end_date date)
-- between start and end date, find the stock price that occurs the most
-- sp: sp_stock_mode(varchar ticker, begin_date date, end_date date)
-- between start and end date, find the stock price that occurs the most
delimiter //
create procedure sp_stock_mode(in ticker varchar(6), startd date, endd date)
begin
select hist_stock.hprice, max(occurs) from (
select hist_stock.hprice, count(hist_stock.hprice) as occurs
from hist_stock
where (hdate between startd and endd) and (hist_stock.symbol like ticker)
group by hist_stock.hprice) T1; 
end //
delimiter ;

-- 7. sp: sp_find_mean_of_stock
delimiter //
create procedure sp_stock_mean(in ticker varchar(6), startd date, endd date)
begin
select avg(hist_stock.hprice) 
from hist_stock
where (hdate between startd and endd) and (hist_stock.symbol like ticker);
end //
delimiter ;

-- 8. sp: sp_get_stock_low
delimiter //
create procedure sp_get_stock_low(in ticker varchar(6), startd date, endd date)
begin
select min(hist_stock.hprice) 
from hist_stock
where (hdate between startd and endd) and (hist_stock.symbol like ticker);
end //
delimiter ;

-- 9. sp: sp_get_stock_high
delimiter //
create procedure sp_get_stock_high(in ticker varchar(6), startd date, endd date)
begin
select max(hist_stock.hprice) 
from hist_stock
where (hdate between startd and endd) and (hist_stock.symbol like ticker);
end //
delimiter ;

-- 10. sp: sp_get_latest_price
delimiter //
create procedure sp_get_latest_price(in ticker varchar(6))
begin
select hist_stock.hprice
from hist_stock
where hist_stock.hdate in (select max(hist_stock.hdate) from hist_stock where hist_stock.symbol like ticker);
end //
delimiter ;

-- 11. These two are the same, since they all use SSN
-- sp: sp_get_employee_personal_info
delimiter //
create procedure sp_get_personal_info(in ssn varchar(9))
begin
select * from personal_info
where ssn like personal_info.ssn;
end //
delimiter ;

-- 12. sp: sp_employees_in_dept ... Just a stub for now
-- Note: Could use dept_name for friendlier usage, else dept_id's can be had by
-- select * from department;
-- sp: sp_employees_in_dept
DELIMITER $$
create procedure sp_employees_in_dept(in sp_dpt_id int(3))
begin
-- -- depts 1...4 are salary, 5-6 are HR, sales and are wage
  IF sp_dpt_id IN (5,6) THEN
    SELECT personal_info.ssn as 'SSN',
          concat(personal_info.fname, ' ', personal_info.lname) as 'Name',
          nonsalaried_employee.wage AS 'Wage', department.dpt_name as 'Dept'
    FROM employee
    JOIN department on employee.dpt_id=department.dpt_id
    JOIN nonsalaried_employee ON employee.ssn = nonsalaried_employee.ssn
    JOIN personal_info ON employee.ssn=personal_info.ssn
    WHERE employee.dpt_id=sp_dpt_id;
  ELSE
    SELECT personal_info.ssn as 'SSN',
          concat(personal_info.fname, ' ', personal_info.lname) as 'Name',
          salaried_employee.salary AS 'Salary', department.dpt_name as 'Dept'
    FROM employee
    JOIN department on employee.dpt_id=department.dpt_id
    JOIN salaried_employee ON employee.ssn = salaried_employee.ssn
    JOIN personal_info ON employee.ssn=personal_info.ssn
    WHERE employee.dpt_id=sp_dpt_id;
  END IF;
END $$
DELIMITER ;


-- INSERTS
INSERT INTO workspace VALUES(1, 1, 'Office');
INSERT INTO workspace VALUES(2, 2, 'Cubicle');
INSERT INTO workspace VALUES(3, 3, 'Cubicle');
INSERT INTO workspace VALUES(4, 5, 'Cubicle');
INSERT INTO workspace VALUES(5, 2, 'Office');
INSERT INTO workspace VALUES(6, 2, 'Cubicle');
INSERT INTO workspace VALUES(7, 3, 'Office');
INSERT INTO workspace VALUES(8, 2, 'Cubicle');
INSERT INTO workspace VALUES(9, 2, 'Cubicle');
INSERT INTO workspace VALUES(10, 2, 'Cubicle');
INSERT INTO workspace VALUES(11, 2, 'Cubicle');
INSERT INTO workspace VALUES(12, 4, 'Cubicle');
INSERT INTO workspace VALUES(13, 3, 'Cubicle');
INSERT INTO workspace VALUES(14, 2, 'Office');
INSERT INTO workspace VALUES(15, 1, 'Cubicle');
INSERT INTO workspace VALUES(16, 3, 'Cubicle');
INSERT INTO workspace VALUES(17, 3, 'Cubicle');
INSERT INTO workspace VALUES(18, 3, 'Cubicle');
INSERT INTO workspace VALUES(19, 5, 'Cubicle');
INSERT INTO workspace VALUES(20, 1, 'Cubicle');
INSERT INTO department VALUES(1, 'Brokerage', 'We sell stocks');
INSERT INTO department VALUES(2, 'Legal', 'We''ll sue!');
INSERT INTO department VALUES(3, 'Facilities', 'We run day to day operations');
INSERT INTO department VALUES(4, 'Payroll', 'We pay people');
INSERT INTO department VALUES(5, 'HR', 'Toby works here');
INSERT INTO department VALUES(6, 'Sales', 'We try to get clients');
INSERT INTO personal_info VALUES('411736459',  'Hung', 'Funk', 'schmitttosha@gmail.com', '583019452', '9934 Toy Bypass Suite 310', 'Dooleyburgh', 'OH');
INSERT INTO employee VALUES('411736459', CURDATE(), 3, 9);
INSERT INTO manager VALUES('411736459', 46504.5, 23234);
INSERT INTO salaried_employee VALUES('411736459', 23234);
INSERT INTO personal_info VALUES('662883979',  'Dwayne', 'Balistreri', 'whoppe@jones.info', '007296976', '45627 Von Mountain', 'Susanatown', 'MD');
INSERT INTO employee VALUES('662883979', CURDATE(), 5, 2);
INSERT INTO manager VALUES('662883979', 39633.0, 33360);
INSERT INTO salaried_employee VALUES('662883979', 33360);
INSERT INTO personal_info VALUES('646988853',  'Loriann', 'Toy', 'reynoldscarrie@walsh.com', '147188881', '3346 Chet Road Apt. 745', 'Port Brandt', 'GU');
INSERT INTO employee VALUES('646988853', CURDATE(), 3, 4);
INSERT INTO manager VALUES('646988853', 19681.0, 142088);
INSERT INTO salaried_employee VALUES('646988853', 142088);
INSERT INTO personal_info VALUES('562043436',  'Shonda', 'Herman', 'rocio39@hotmail.com', '899491695', '0665 Tremblay Villages', 'Leonachester', 'AZ');
INSERT INTO employee VALUES('562043436', CURDATE(), 1, 8);
INSERT INTO broker VALUES('562043436', 0.16, 11903, 0);
INSERT INTO salaried_employee VALUES('562043436', 11903);
INSERT INTO personal_info VALUES('029295063',  'Florida', 'Beier', 'irma80@denesik.com', '123506509', '6823 Hickle Garden Apt. 305', 'South Bernadinetown', 'MH');
INSERT INTO employee VALUES('029295063', CURDATE(), 1, 18);
INSERT INTO broker VALUES('029295063', 0.26, 68564, 0);
INSERT INTO salaried_employee VALUES('029295063', 68564);
INSERT INTO personal_info VALUES('561755475',  'Shade', 'McKenzie', 'bell24@bartell.com', '106903884', '3260 Lewis Locks', 'Rubyfort', 'MI');
INSERT INTO employee VALUES('561755475', CURDATE(), 1, 19);
INSERT INTO broker VALUES('561755475', 0.34, 38293, 0);
INSERT INTO salaried_employee VALUES('561755475', 38293);
INSERT INTO personal_info VALUES('868817119',  'Bryn', 'Kertzmann', 'liam08@gmail.com', '029032943', '311 Amore Bypass', 'North Shadefort', 'SD');
INSERT INTO employee VALUES('868817119', CURDATE(), 1, 8);
INSERT INTO broker VALUES('868817119', 0.57, 137474, 0);
INSERT INTO salaried_employee VALUES('868817119', 137474);
INSERT INTO personal_info VALUES('476032129',  'Danniel', 'Mayer', 'sal60@herzog.com', '187167451', '81440 Sawayn Valleys', 'Deandreborough', 'KS');
INSERT INTO employee VALUES('476032129', CURDATE(), 1, 15);
INSERT INTO broker VALUES('476032129', 0.65, 7932, 0);
INSERT INTO salaried_employee VALUES('476032129', 7932);
INSERT INTO personal_info VALUES('683660942',  'Hiroshi', 'Williamson', 'lawrance45@crooks.com', '410528763', '49823 Zulauf Inlet', 'Brynleeside', 'OK');
INSERT INTO employee VALUES('683660942', CURDATE(), 1, 7);
INSERT INTO broker VALUES('683660942', 0.19, 80658, 0);
INSERT INTO salaried_employee VALUES('683660942', 80658);
INSERT INTO personal_info VALUES('280224020',  'Atha', 'Wiza', 'egreen@mertz.biz', '092740907', '71661 Bernier Field', 'Doyleberg', 'OK');
INSERT INTO employee VALUES('280224020', CURDATE(), 1, 4);
INSERT INTO broker VALUES('280224020', 0.62, 125897, 0);
INSERT INTO salaried_employee VALUES('280224020', 125897);
INSERT INTO personal_info VALUES('730494892',  'Flint', 'Fisher', 'alerdman@hilpert-bergnaum.biz', '576782154', '072 Bayard Locks Apt. 684', 'East Mathiasmouth', 'UT');
INSERT INTO employee VALUES('730494892', CURDATE(), 2, 9);
INSERT INTO personal_info VALUES('650378934',  'Bridger', 'White', 'johnsalfie@gmail.com', '013156941', '6714 Brynlee Divide Suite 396', 'Morissettechester', 'IA');
INSERT INTO employee VALUES('650378934', CURDATE(), 6, 6);
INSERT INTO nonsalaried_employee VALUES('650378934', 32.54);
INSERT INTO personal_info VALUES('662904856',  'Jamey', 'Parisian', 'coloneltorphy@hotmail.com', '665495391', '0656 Caryl Valleys', 'Lumside', 'AK');
INSERT INTO employee VALUES('662904856', CURDATE(), 2, 2);
INSERT INTO personal_info VALUES('830598480',  'Maliyah', 'Corkery', 'reba30@yost-wunsch.info', '788027715', '1809 Roob Brook Apt. 848', 'Skilesmouth', 'PW');
INSERT INTO employee VALUES('830598480', CURDATE(), 1, 9);
INSERT INTO personal_info VALUES('567968364',  'Eva', 'Cassin', 'oharabetsey@haag.com', '168172564', '8595 Pouros Oval', 'Streichview', 'LA');
INSERT INTO employee VALUES('567968364', CURDATE(), 2, 15);
INSERT INTO personal_info VALUES('249733636',  'Manila', 'Bergnaum', 'twitting@gmail.com', '559432913', '84893 Shelbi Causeway Suite 681', 'North Clydieberg', 'KS');
INSERT INTO employee VALUES('249733636', CURDATE(), 4, 5);
INSERT INTO personal_info VALUES('667233299',  'Inell', 'Reilly', 'pershinglowe@gmail.com', '654224429', '960 Stephenie Inlet Apt. 755', 'Evanville', 'DC');
INSERT INTO employee VALUES('667233299', CURDATE(), 6, 11);
INSERT INTO nonsalaried_employee VALUES('667233299', 31.39);
INSERT INTO personal_info VALUES('012716237',  'Christina', 'Hauck', 'adrielwalker@gmail.com', '117030977', '696 Luc Street Suite 758', 'West Deliah', 'AL');
INSERT INTO employee VALUES('012716237', CURDATE(), 1, 10);
INSERT INTO personal_info VALUES('496692372',  'Dakotah', 'Block', 'ngibson@block-kemmer.com', '124369028', '36481 Beatriz Summit Apt. 455', 'Shanahantown', 'VT');
INSERT INTO employee VALUES('496692372', CURDATE(), 5, 2);
INSERT INTO nonsalaried_employee VALUES('496692372', 42.69);
INSERT INTO personal_info VALUES('805763656',  'Cinnamon', 'Cummings', 'hodkiewiczjammie@yahoo.com', '017318201', '1470 Robel Skyway', 'Angelamouth', 'ME');
INSERT INTO employee VALUES('805763656', CURDATE(), 5, 3);
INSERT INTO nonsalaried_employee VALUES('805763656', 68.6);
INSERT INTO personal_info VALUES('180961362',  'Shasta', 'Stracke', 'vswift@gorczany.com', '233034912', '38868 Darcy Rapids', 'Neveahburgh', 'MD');
INSERT INTO employee VALUES('180961362', CURDATE(), 3, 14);
INSERT INTO personal_info VALUES('516986062',  'Charlsie', 'McDermott', 'skyler53@yahoo.com', '153024617', '09250 Maybelle Cape', 'Chrissyborough', 'TX');
INSERT INTO employee VALUES('516986062', CURDATE(), 5, 7);
INSERT INTO nonsalaried_employee VALUES('516986062', 38.16);
INSERT INTO personal_info VALUES('334385164',  'Bradley', 'Satterfield', 'cdouglas@will.net', '169765384', '71827 Kunze Estate Apt. 253', 'New Lenonside', 'IN');
INSERT INTO employee VALUES('334385164', CURDATE(), 2, 17);
INSERT INTO personal_info VALUES('182194668',  'Shawnte', 'Smitham', 'xmcglynn@yahoo.com', '064676677', '427 Sommer Cliffs Suite 743', 'Karrieshire', 'CO');
INSERT INTO employee VALUES('182194668', CURDATE(), 4, 7);
INSERT INTO personal_info VALUES('106544911',  'Leesa', 'Schultz', 'armincronin@schmeler.com', '495692935', '6808 Dwane Locks Apt. 672', 'Haaghaven', 'MN');
INSERT INTO employee VALUES('106544911', CURDATE(), 5, 8);
INSERT INTO nonsalaried_employee VALUES('106544911', 2.07);
INSERT INTO personal_info VALUES('389493863',  'Harlan', 'Kautzer', 'adelaide22@effertz.com', '818808650', '42678 Schneider Green', 'Shieldsborough', 'PR');
INSERT INTO employee VALUES('389493863', CURDATE(), 2, 2);
INSERT INTO personal_info VALUES('819956559',  'Yareli', 'Hane', 'bonny68@gmail.com', '582952481', '78161 Hilpert Divide', 'Bryanamouth', 'OH');
INSERT INTO employee VALUES('819956559', CURDATE(), 2, 7);
INSERT INTO personal_info VALUES('629600993',  'Jayson', 'Macejkovic', 'jasmyn28@bruen.com', '441652910', '690 Kem Ports', 'Port Rohanshire', 'OR');
INSERT INTO employee VALUES('629600993', CURDATE(), 4, 11);
INSERT INTO personal_info VALUES('197210441',  'Kandace', 'Beahan', 'metha63@ratke.net', '847335127', '9802 Hara Divide Apt. 999', 'Lake Earnestinebury', 'WY');
INSERT INTO employee VALUES('197210441', CURDATE(), 2, 13);
INSERT INTO personal_info VALUES('567850217',  'Ocie', 'Runolfsson', 'fredric36@hotmail.com', '489698851', '835 Stamm Groves Suite 210', 'Kirstiebury', 'DE');
INSERT INTO employee VALUES('567850217', CURDATE(), 3, 17);
INSERT INTO personal_info VALUES('006244439',  'Mellissa', 'Barrows', 'bergejaxson@yahoo.com', '280844370', '3815 Prosacco Forest', 'West Kembury', 'NE');
INSERT INTO customer VALUES('006244439', '562043436');
INSERT INTO customer_account VALUES(1, '006244439', 3962);
INSERT INTO account_type VALUES(1, 'Cash', 0);
INSERT INTO customer_account VALUES(2, '006244439', 3962);
INSERT INTO account_type VALUES(2, 'Traditional', 0);
INSERT INTO personal_info VALUES('793906908',  'Finley', 'Bartoletti', 'geary05@gmail.com', '727384182', '4909 Cronin Plains', 'Florenceview', 'CO');
INSERT INTO beneficiary VALUES('793906908', '006244439');
INSERT INTO personal_info VALUES('402366371',  'Karis', 'McLaughlin', 'jarrad62@yahoo.com', '638694901', '34966 Quitzon Ways Suite 895', 'North Junie', 'NJ');
INSERT INTO customer VALUES('402366371', '029295063');
INSERT INTO customer_account VALUES(3, '402366371', 387);
INSERT INTO account_type VALUES(3, 'Cash', 0);
INSERT INTO personal_info VALUES('624275043',  'Nolia', 'Wisozk', 'novella31@hotmail.com', '330043699', '8668 Howell Isle Suite 469', 'Migdaliashire', 'GU');
INSERT INTO beneficiary VALUES('624275043', '402366371');
INSERT INTO personal_info VALUES('589498605',  'Lovie', 'Hammes', 'ratkedamarcus@okon.com', '052421428', '725 Becker Drive', 'Armindaborough', 'CO');
INSERT INTO customer VALUES('589498605', '561755475');
INSERT INTO customer_account VALUES(4, '589498605', 392);
INSERT INTO account_type VALUES(4, 'Cash', 0);
INSERT INTO personal_info VALUES('667545075',  'Cleveland', 'Lynch', 'jerald84@reinger.com', '481686253', '188 Yesenia Alley', 'Vickitown', 'AL');
INSERT INTO beneficiary VALUES('667545075', '589498605');
INSERT INTO personal_info VALUES('271195250',  'Infant', 'Ondricka', 'arnettachristiansen@corkery-flatley.org', '326949954', '0832 Murazik Turnpike Apt. 265', 'Lake Renitachester', 'MO');
INSERT INTO customer VALUES('271195250', '868817119');
INSERT INTO customer_account VALUES(5, '271195250', 3258);
INSERT INTO account_type VALUES(5, 'Cash', 0);
INSERT INTO customer_account VALUES(6, '271195250', 3258);
INSERT INTO account_type VALUES(6, 'Educational', 0);
INSERT INTO personal_info VALUES('514383226',  'Garey', 'Schuppe', 'kristicorkery@altenwerth-gibson.org', '708708862', '60778 Gusikowski Via Apt. 413', 'Port Alvenaview', 'WV');
INSERT INTO beneficiary VALUES('514383226', '271195250');
INSERT INTO personal_info VALUES('445101233',  'Linna', 'Goldner', 'donnellykenny@hotmail.com', '357689695', '42219 Hartmann Divide Apt. 245', 'Wintheiserberg', 'IL');
INSERT INTO customer VALUES('445101233', '476032129');
INSERT INTO customer_account VALUES(7, '445101233', 4995);
INSERT INTO account_type VALUES(7, 'Cash', 0);
INSERT INTO customer_account VALUES(8, '445101233', 4995);
INSERT INTO account_type VALUES(8, 'Educational', 0);
INSERT INTO personal_info VALUES('826164526',  'Laraine', 'Sporer', 'fhettinger@mitchell.com', '717936583', '11899 Sebrina Cliff Suite 346', 'North Kunta', 'PA');
INSERT INTO beneficiary VALUES('826164526', '445101233');
INSERT INTO personal_info VALUES('134949569',  'Trevin', 'Berge', 'howecristin@wintheiser-hammes.net', '143809725', '96792 Cronin Squares Apt. 081', 'West Melodymouth', 'FL');
INSERT INTO customer VALUES('134949569', '683660942');
INSERT INTO customer_account VALUES(9, '134949569', 783);
INSERT INTO account_type VALUES(9, 'Cash', 0);
INSERT INTO personal_info VALUES('797963371',  'Emilie', 'Rempel', 'else88@mitchell.com', '111088481', '172 Fawn Lodge Apt. 415', 'Port Shavonstad', 'HI');
INSERT INTO beneficiary VALUES('797963371', '134949569');
INSERT INTO personal_info VALUES('441372999',  'Terance', 'Ondricka', 'connorgreenholt@steuber.info', '014816453', '58435 Elianna River', 'East Arnav', 'IA');
INSERT INTO customer VALUES('441372999', '280224020');
INSERT INTO customer_account VALUES(10, '441372999', 2822);
INSERT INTO account_type VALUES(10, 'Cash', 0);
INSERT INTO customer_account VALUES(11, '441372999', 2822);
INSERT INTO account_type VALUES(11, 'Educational', 0);
INSERT INTO personal_info VALUES('809830408',  'Tracey', 'Wintheiser', 'gaylordjoey@gmail.com', '301660113', '837 Sipes Views Apt. 191', 'North Wyatt', 'AZ');
INSERT INTO beneficiary VALUES('809830408', '441372999');
INSERT INTO personal_info VALUES('627366073',  'Nyla', 'Kreiger', 'trau@orn.com', '265047801', '073 Sauer Haven', 'Roseannville', 'ID');
INSERT INTO customer VALUES('627366073', '280224020');
INSERT INTO customer_account VALUES(12, '627366073', 4062);
INSERT INTO account_type VALUES(12, 'Cash', 0);
INSERT INTO personal_info VALUES('719987683',  'Pepper', 'Swift', 'adolfoturner@gmail.com', '278657282', '33042 Clarine Brooks', 'Schmidtburgh', 'MS');
INSERT INTO beneficiary VALUES('719987683', '627366073');
INSERT INTO personal_info VALUES('155352417',  'Ailene', 'Beatty', 'frenner@cormier.com', '194279200', '63596 Bergnaum Stravenue', 'Port Kiyoshi', 'MS');
INSERT INTO customer VALUES('155352417', '476032129');
INSERT INTO customer_account VALUES(13, '155352417', 4464);
INSERT INTO account_type VALUES(13, 'Cash', 0);
INSERT INTO customer_account VALUES(14, '155352417', 4464);
INSERT INTO account_type VALUES(14, 'Educational', 0);
INSERT INTO personal_info VALUES('675252929',  'Alferd', 'Parisian', 'salvatorecronin@crist-schmidt.biz', '480731685', '00066 Morar Avenue', 'Wymanmouth', 'AR');
INSERT INTO beneficiary VALUES('675252929', '155352417');
INSERT INTO personal_info VALUES('234783511',  'Augustin', 'Haag', 'boscophebe@boyer.com', '997291148', '98541 Glynn Pike Suite 678', 'Port Luciana', 'OH');
INSERT INTO customer VALUES('234783511', '561755475');
INSERT INTO customer_account VALUES(15, '234783511', 402);
INSERT INTO account_type VALUES(15, 'Cash', 0);
INSERT INTO personal_info VALUES('627436000',  'Daquan', 'Denesik', 'effertzsidney@farrell.com', '700216989', '0455 Will Lakes Apt. 799', 'Ernsermouth', 'WY');
INSERT INTO beneficiary VALUES('627436000', '234783511');
INSERT INTO personal_info VALUES('476968488',  'Marylee', 'Beier', 'lednermont@kerluke.com', '499283407', '92441 Levin Courts Suite 072', 'Constanceville', 'AR');
INSERT INTO customer VALUES('476968488', '683660942');
INSERT INTO customer_account VALUES(16, '476968488', 2471);
INSERT INTO account_type VALUES(16, 'Cash', 0);
INSERT INTO personal_info VALUES('605139088',  'Trista', 'Hintz', 'waylandgislason@gmail.com', '906007708', '992 Murphy Streets', 'East Cieraport', 'FM');
INSERT INTO beneficiary VALUES('605139088', '476968488');
INSERT INTO personal_info VALUES('194258184',  'Arvin', 'Kozey', 'caylee76@yahoo.com', '474380305', '951 Kuhlman Summit Apt. 036', 'Lake Christian', 'FL');
INSERT INTO customer VALUES('194258184', '683660942');
INSERT INTO customer_account VALUES(17, '194258184', 3921);
INSERT INTO account_type VALUES(17, 'Cash', 0);
INSERT INTO customer_account VALUES(18, '194258184', 3921);
INSERT INTO account_type VALUES(18, 'Traditional', 0);
INSERT INTO personal_info VALUES('804387271',  'Bascom', 'Sauer', 'prohaskaethen@yahoo.com', '124557723', '73692 Amaris Hill Suite 444', 'Fisherton', 'MO');
INSERT INTO beneficiary VALUES('804387271', '194258184');
INSERT INTO personal_info VALUES('598130386',  'Hildur', 'Mayer', 'dsanford@hotmail.com', '132885868', '162 Jaslyn Heights', 'Hilaryside', 'NM');
INSERT INTO customer VALUES('598130386', '280224020');
INSERT INTO customer_account VALUES(19, '598130386', 3259);
INSERT INTO account_type VALUES(19, 'Cash', 0);
INSERT INTO customer_account VALUES(20, '598130386', 3259);
INSERT INTO account_type VALUES(20, 'Roth IRA', 0);
INSERT INTO personal_info VALUES('062273234',  'Betha', 'Brakus', 'kesslerkim@gmail.com', '504104298', '20229 Katelynn Points Apt. 240', 'Robbyton', 'PW');
INSERT INTO beneficiary VALUES('062273234', '598130386');
INSERT INTO personal_info VALUES('491303620',  'Jaylyn', 'Rutherford', 'trompharlie@hotmail.com', '170983016', '618 Auer Divide', 'Satterfieldchester', 'NJ');
INSERT INTO customer VALUES('491303620', '562043436');
INSERT INTO customer_account VALUES(21, '491303620', 4471);
INSERT INTO account_type VALUES(21, 'Cash', 0);
INSERT INTO personal_info VALUES('217646152',  'Emery', 'Bradtke', 'elisabethgleason@ernser.com', '868488548', '414 Dale Road', 'Jaleelberg', 'LA');
INSERT INTO beneficiary VALUES('217646152', '491303620');
INSERT INTO personal_info VALUES('326835543',  'Robin', 'Satterfield', 'flatleyjunius@kulas-stiedemann.com', '079067625', '83785 Bauch Meadows Suite 562', 'Alexhaven', 'FM');
INSERT INTO customer VALUES('326835543', '561755475');
INSERT INTO customer_account VALUES(22, '326835543', 2397);
INSERT INTO account_type VALUES(22, 'Cash', 0);
INSERT INTO customer_account VALUES(23, '326835543', 2397);
INSERT INTO account_type VALUES(23, 'Educational', 0);
INSERT INTO personal_info VALUES('032398052',  'Lilburn', 'Powlowski', 'kilbackmoises@schaden-schultz.info', '819990146', '19727 Shane Way', 'Willmsfurt', 'LA');
INSERT INTO beneficiary VALUES('032398052', '326835543');
INSERT INTO personal_info VALUES('775526335',  'Jessee', 'Dach', 'tyquankshlerin@yahoo.com', '193022167', '21766 Hollis Mountains Suite 451', 'Launaberg', 'MD');
INSERT INTO customer VALUES('775526335', '561755475');
INSERT INTO customer_account VALUES(24, '775526335', 65);
INSERT INTO account_type VALUES(24, 'Cash', 0);
INSERT INTO personal_info VALUES('471228910',  'Rosanna', 'Prohaska', 'hilllillya@weissnat.com', '398333440', '96924 Schuster Lock', 'West Juniushaven', 'DC');
INSERT INTO beneficiary VALUES('471228910', '775526335');
INSERT INTO personal_info VALUES('008307142',  'Oakley', 'Walter', 'eppierau@gmail.com', '209298881', '845 Jaclyn Haven Apt. 231', 'East Izaiah', 'NM');
INSERT INTO customer VALUES('008307142', '029295063');
INSERT INTO customer_account VALUES(25, '008307142', 1622);
INSERT INTO account_type VALUES(25, 'Cash', 0);
INSERT INTO personal_info VALUES('128938740',  'Duard', 'Skiles', 'germaine25@bogan.info', '159608009', '15216 Conn Lake', 'North Daniellehaven', 'AS');
INSERT INTO beneficiary VALUES('128938740', '008307142');
INSERT INTO personal_info VALUES('349292573',  'Saul', 'Carter', 'gschroeder@oreilly-heidenreich.com', '919171009', '9312 Simpson Harbor', 'Smithamville', 'PR');
INSERT INTO customer VALUES('349292573', '280224020');
INSERT INTO customer_account VALUES(26, '349292573', 1945);
INSERT INTO account_type VALUES(26, 'Cash', 0);
INSERT INTO personal_info VALUES('573144202',  'Etta', 'Bartoletti', 'bmertz@gmail.com', '159357683', '0405 Sanford Fort Suite 446', 'McCulloughmouth', 'MN');
INSERT INTO beneficiary VALUES('573144202', '349292573');
INSERT INTO personal_info VALUES('629796859',  'Jamel', 'Stamm', 'bayerernestine@gibson.com', '069887897', '4554 Ankunding Underpass Suite 208', 'Devinberg', 'MD');
INSERT INTO customer VALUES('629796859', '562043436');
INSERT INTO customer_account VALUES(27, '629796859', 3341);
INSERT INTO account_type VALUES(27, 'Cash', 0);
INSERT INTO customer_account VALUES(28, '629796859', 3341);
INSERT INTO account_type VALUES(28, 'Educational', 0);
INSERT INTO personal_info VALUES('430686183',  'Eduardo', 'Gislason', 'creolanader@gmail.com', '405693440', '343 Johnson Lights Suite 738', 'Port Tommie', 'NC');
INSERT INTO beneficiary VALUES('430686183', '629796859');
INSERT INTO personal_info VALUES('545821661',  'Sable', 'Jast', 'jennifer41@gmail.com', '907675461', '82883 Cassidy Ranch Apt. 415', 'South Carroll', 'MI');
INSERT INTO customer VALUES('545821661', '868817119');
INSERT INTO customer_account VALUES(29, '545821661', 2139);
INSERT INTO account_type VALUES(29, 'Cash', 0);
INSERT INTO personal_info VALUES('046515159',  'Arvid', 'Huel', 'mcarthurbartell@yahoo.com', '243648295', '50165 Laken Ferry', 'Robertsborough', 'KY');
INSERT INTO beneficiary VALUES('046515159', '545821661');


INSERT INTO company (id, cname, stock_symbol,xchange, sector, date_listed) VALUES
(1,'Microsoft Corporation','MSFT','NASDAQ','Technology','1986-01-01'),
(2,'Alphabet Inc.','GOOG','NASDAQ','Technology','2004-01-01'),
(3,'Apple Inc.','AAPL','NASDAQ','Technology','1980-01-01'),
(4,'Cisco Systems, Inc.','CSCO','NASDAQ','Technology','1990-01-01'),
(5,'Amazon.com, Inc.','AMZN','NASDAQ','Consumer Services','1997-01-01'),
(6,'SanDisk Corporation','SNDK','NASDAQ','Technology','1995-01-01'),
(7,'Staples, Inc.','SPLS','NASDAQ','Consumer Services','1989-01-01'),
(8,'JPMorgan Chase & Co.','JPM','NYSE','Finance','1972-06-30'),
(9,'General Electric Comapny','GE','NYSE','Energy','1972-06-30'),
(10,'Bed Bath & Beyond Inc.','BBBY','NASDAQ','Consumer Services','1992-01-01'),
(11,'Starbucks Corporation','SBUX','NASDAQ','Consumer Services','1992-01-01'),
(12,'Amgen Inc.','AMGN','NASDAQ','Health Care','1983-01-01'),
(13,'Citigroup Inc.','BLW','NYSE','Finance','2003-01-01'),
(14,'Capital One Financial Corporation','COF','NYSE','Finance','1994-01-01'),
(15,'American Financial Group, Inc.','AFGE','NYSE','Finance','2014-01-01'),
(16,'Anthem, Inc.','ANTX','NYSE','Health Care','2015-01-01'),
(17,'Sprint Corporation','S','NYSE','Public Utilities','2013-01-01'),
(18,'Oracle Corporation','ORCL','NYSE','Technology','1986-01-01'),
(19,'Rosetta Stone','RST','NYSE','Technology','2009-01-01'),
(20,'Tiffany & Co.','TIF','NYSE','Consumer Services','1987-01-01'),
(21,'Chegg, Inc.','CHGG','NYSE','Consumer Services','2013-01-01'),
(22,'Waters Corporation','WAT','NYSE','Capital Goods','1995-01-01'),
(23,'Stoneridge, Inc.','SRI','NYSE','Capital Goods','1997-01-01'),
(24,'Pacific Drilling S.A.','PACD','NYSE','Energy','2011-01-01');

INSERT INTO hist_stock (symbol, hdate, company_id, hprice) VALUES
('MSFT','2016-05-11',1,51.13),
('MSFT','2016-05-10',1,50.33),
('MSFT','2016-05-09',1,50.49),
('MSFT','2016-05-06',1,49.92),
('MSFT','2016-05-05',1,49.87),
('MSFT','2016-05-04',1,49.84),
('MSFT','2016-05-03',1,50.34),
('MSFT','2016-05-02',1,50.00),
('MSFT','2016-04-29',1,49.35),
('MSFT','2016-04-28',1,50.62),
('MSFT','2016-04-27',1,51.48),
('MSFT','2016-04-26',1,52.26),
('MSFT','2016-04-25',1,51.78),
('MSFT','2016-04-22',1,51.91),
('MSFT','2016-04-21',1,55.80),
('MSFT','2016-04-20',1,56.29),
('MSFT','2016-04-19',1,56.63),
('MSFT','2016-04-18',1,55.49),
('MSFT','2016-04-15',1,55.30),
('MSFT','2016-04-14',1,55.22),
('MSFT','2016-04-13',1,55.12),
('MSFT','2016-04-12',1,54.37),
('GOOG','2016-05-11',2,723.41),
('GOOG','2016-05-10',2,716.75),
('GOOG','2016-05-09',2,712 ),
('GOOG','2016-05-06',2,698.38),
('GOOG','2016-05-05',2,697.7),
('GOOG','2016-05-04',2,690.49),
('GOOG','2016-05-03',2,696.87),
('GOOG','2016-05-02',2,697.63),
('GOOG','2016-04-29',2,690.7),
('GOOG','2016-04-28',2,708.26),
('GOOG','2016-04-27',2,707.29),
('GOOG','2016-04-26',2,725.42),
('GOOG','2016-04-25',2,716.1),
('GOOG','2016-04-22',2,726.3),
('GOOG','2016-04-21',2,755.38),
('GOOG','2016-04-20',2,758 ),
('GOOG','2016-04-19',2,769.51),
('GOOG','2016-04-18',2,760.46),
('GOOG','2016-04-15',2,753.98),
('GOOG','2016-04-14',2,754.01),
('GOOG','2016-04-13',2,749.16),
('GOOG','2016-04-12',2,738 ),
('AAPL','2016-05-11',3,93.48),
('AAPL','2016-05-10',3,93.33),
('AAPL','2016-05-09',3,93),
('AAPL','2016-05-06',3,93.37),
('AAPL','2016-05-05',3,94),
('AAPL','2016-05-04',3,94.7 ),
('AAPL','2016-05-03',3,95.2 ),
('AAPL','2016-05-02',3,94.2 ),
('AAPL','2016-04-29',3,93.97),
('AAPL','2016-04-28',3,93.99),
('AAPL','2016-04-27',3,97.61),
('AAPL','2016-04-26',3,96),
('AAPL','2016-04-25',3,103.91),
('AAPL','2016-04-22',3,105 ),
('AAPL','2016-04-21',3,105.01),
('AAPL','2016-04-20',3,106.93),
('AAPL','2016-04-19',3,106.64),
('AAPL','2016-04-18',3,107.88),
('AAPL','2016-04-15',3,108.89),
('AAPL','2016-04-14',3,112.11),
('AAPL','2016-04-13',3,111.62),
('AAPL','2016-04-12',3,110.8),
('CSCO','2016-05-11',4,27.09),
('CSCO','2016-05-10',4,26.67),
('CSCO','2016-05-09',4,26.52),
('CSCO','2016-05-06',4,26.19),
('CSCO','2016-05-05',4,26.46),
('CSCO','2016-05-04',4,27),
('CSCO','2016-05-03',4,27.16),
('CSCO','2016-05-02',4,27.48),
('CSCO','2016-04-29',4,27.72),
('CSCO','2016-04-28',4,28.45),
('CSCO','2016-04-27',4,28.44),
('CSCO','2016-04-26',4,28.27),
('CSCO','2016-04-25',4,28.11),
('CSCO','2016-04-22',4,28.3 ),
('CSCO','2016-04-21',4,28.42),
('CSCO','2016-04-20',4,28.4 ),
('CSCO','2016-04-19',4,28.33),
('CSCO','2016-04-18',4,27.9 ),
('CSCO','2016-04-15',4,28.1 ),
('CSCO','2016-04-14',4,28.38),
('CSCO','2016-04-13',4,27.96),
('CSCO','2016-04-12',4,27.14),
('AMZN','2016-05-11',5,705.79),
('AMZN','2016-05-10',5,694 ),
('AMZN','2016-05-09',5,673.95),
('AMZN','2016-05-06',5,656.05),
('AMZN','2016-05-05',5,673.31),
('AMZN','2016-05-04',5,663 ),
('AMZN','2016-05-03',5,677.36),
('AMZN','2016-05-02',5,663.92),
('AMZN','2016-04-29',5,666 ),
('AMZN','2016-04-28',5,615.54),
('AMZN','2016-04-27',5,611.8),
('AMZN','2016-04-26',5,626.17),
('AMZN','2016-04-25',5,616.61),
('AMZN','2016-04-22',5,624.47),
('AMZN','2016-04-21',5,631 ),
('AMZN','2016-04-20',5,630 ),
('AMZN','2016-04-19',5,637.14),
('AMZN','2016-04-18',5,625.35),
('AMZN','2016-04-15',5,621.92),
('AMZN','2016-04-14',5,615.07),
('AMZN','2016-04-13',5,607.68),
('AMZN','2016-04-12',5,598.4),
('PACD','2016-05-11',24,0.5 ),
('PACD','2016-05-10',24,0.53 ),
('PACD','2016-05-09',24,0.61 ),
('PACD','2016-05-06',24,0.65 ),
('PACD','2016-05-05',24,0.6 ),
('PACD','2016-05-04',24,0.54 ),
('PACD','2016-05-03',24,0.6 ),
('PACD','2016-05-02',24,0.7 ),
('PACD','2016-04-29',24,0.73 ),
('PACD','2016-04-28',24,0.78 ),
('PACD','2016-04-27',24,0.52 ),
('PACD','2016-04-26',24,0.48 ),
('PACD','2016-04-25',24,0.47 ),
('PACD','2016-04-22',24,0.45 ),
('PACD','2016-04-21',24,0.5 ),
('PACD','2016-04-20',24,0.5 ),
('PACD','2016-04-19',24,0.43 ),
('PACD','2016-04-18',24,0.47 ),
('PACD','2016-04-15',24,0.4 ),
('PACD','2016-04-14',24,0.48 ),
('PACD','2016-04-13',24,0.47 ),
('PACD','2016-04-12',24,0.46 ),
('SRI','2016-05-11',23,14.64),
('SRI','2016-05-10',23,14.25),
('SRI','2016-05-09',23,14.49),
('SRI','2016-05-06',23,14.51),
('SRI','2016-05-05',23,15.39),
('SRI','2016-05-04',23,14.78),
('SRI','2016-05-03',23,14.01),
('SRI','2016-05-02',23,14.35),
('SRI','2016-04-29',23,14.47),
('SRI','2016-04-28',23,14.59),
('SRI','2016-04-27',23,14.39),
('SRI','2016-04-26',23,14.47),
('SRI','2016-04-25',23,14.54),
('SRI','2016-04-22',23,14.43),
('SRI','2016-04-21',23,14.49),
('SRI','2016-04-20',23,14.61),
('SRI','2016-04-19',23,14.27),
('SRI','2016-04-18',23,14.2 ),
('SRI','2016-04-15',23,14.11),
('SRI','2016-04-14',23,14.5 ),
('SRI','2016-04-13',23,14.36),
('SRI','2016-04-12',23,13.9 ),
('WAT','2016-05-11',22,135.15),
('WAT','2016-05-10',22,134.17),
('WAT','2016-05-09',22,132.79),
('WAT','2016-05-06',22,130.89),
('WAT','2016-05-05',22,130.66),
('WAT','2016-05-04',22,130.41),
('WAT','2016-05-03',22,131.96),
('WAT','2016-05-02',22,130.88),
('WAT','2016-04-29',22,130.94),
('WAT','2016-04-28',22,132.73),
('WAT','2016-04-27',22,133.68),
('WAT','2016-04-26',22,138.45),
('WAT','2016-04-25',22,137.46),
('WAT','2016-04-22',22,137.92),
('WAT','2016-04-21',22,136.41),
('WAT','2016-04-20',22,136.93),
('WAT','2016-04-19',22,137.45),
('WAT','2016-04-18',22,135.65),
('WAT','2016-04-15',22,135),
('WAT','2016-04-14',22,134.86),
('WAT','2016-04-13',22,132.77),
('WAT','2016-04-12',22,130.99),
('SNDK','2016-05-11',6,76.53),
('SNDK','2016-05-10',6,76.2),
('SNDK','2016-05-09',6,75.44),
('SNDK','2016-05-06',6,74.52),
('SNDK','2016-05-05',6,75.07),
('SNDK','2016-05-04',6,75),
('SNDK','2016-05-03',6,75.05),
('SNDK','2016-05-02',6,75.07),
('SNDK','2016-04-29',6,76.23),
('SNDK','2016-04-28',6,76.11),
('SNDK','2016-04-27',6,75.57),
('SNDK','2016-04-26',6,75.6),
('SNDK','2016-04-25',6,75.47),
('SNDK','2016-04-22',6,74.87),
('SNDK','2016-04-21',6,75.68),
('SNDK','2016-04-20',6,75.92),
('SNDK','2016-04-19',6,76.15),
('SNDK','2016-04-18',6,75.63),
('SNDK','2016-04-15',6,75.98),
('SNDK','2016-04-14',6,76.57),
('SNDK','2016-04-13',6,76.77),
('SNDK','2016-04-12',6,76.67),
('SPLS','2016-05-11',7,8.74),
('SPLS','2016-05-10',7,10.36),
('SPLS','2016-05-09',7,10.83),
('SPLS','2016-05-06',7,10.15),
('SPLS','2016-05-05',7,10.36),
('SPLS','2016-05-04',7,10),
('SPLS','2016-05-03',7,10.27),
('SPLS','2016-05-02',7,10.26),
('SPLS','2016-04-29',7,10.38),
('SPLS','2016-04-28',7,10.63),
('SPLS','2016-04-27',7,10.62),
('SPLS','2016-04-26',7,10.5),
('SPLS','2016-04-25',7,10.45),
('SPLS','2016-04-22',7,10.6),
('SPLS','2016-04-21',7,11.04),
('SPLS','2016-04-20',7,10.92),
('SPLS','2016-04-19',7,11.14),
('SPLS','2016-04-18',7,11.13),
('SPLS','2016-04-15',7,11.12),
('SPLS','2016-04-14',7,11.24),
('SPLS','2016-04-13',7,11.22),
('SPLS','2016-04-12',7,11.1),
('XOM','2016-05-11',8,89.16),
('XOM','2016-05-10',8,88.9),
('XOM','2016-05-09',8,88.6),
('XOM','2016-05-06',8,87.46),
('XOM','2016-05-05',8,88.76),
('XOM','2016-05-04',8,88.3),
('XOM','2016-05-03',8,88.4),
('XOM','2016-05-02',8,88.24),
('XOM','2016-04-29',8,88.68),
('XOM','2016-04-28',8,87.86),
('XOM','2016-04-27',8,87.95),
('XOM','2016-04-26',8,87.75),
('XOM','2016-04-25',8,87.09),
('XOM','2016-04-22',8,87.24),
('XOM','2016-04-21',8,86.59),
('XOM','2016-04-20',8,86.23),
('XOM','2016-04-19',8,85.85),
('XOM','2016-04-18',8,84.97),
('XOM','2016-04-15',8,85.3),
('XOM','2016-04-14',8,85),
('XOM','2016-04-13',8,84.5),
('XOM','2016-04-12',8,83.69),
('GE','2016-05-11',9,30.5),
('GE','2016-05-10',9,29.99),
('GE','2016-05-09',9,30.05),
('GE','2016-05-06',9,29.68),
('GE','2016-05-05',9,30.14),
('GE','2016-05-04',9,30.4),
('GE','2016-05-03',9,30.64),
('GE','2016-05-02',9,30.64),
('GE','2016-04-29',9,30.75),
('GE','2016-04-28',9,30.74),
('GE','2016-04-27',9,30.94),
('GE','2016-04-26',9,30.84),
('GE','2016-04-25',9,30.81),
('GE','2016-04-22',9,31.03),
('GE','2016-04-21',9,31.12),
('GE','2016-04-20',9,31.2),
('GE','2016-04-19',9,31.14),
('GE','2016-04-18',9,30.9),
('GE','2016-04-15',9,31.07),
('GE','2016-04-14',9,30.99),
('GE','2016-04-13',9,30.98),
('GE','2016-04-12',9,30.68),
('BBBY','2016-05-11',10,45.32),
('BBBY','2016-05-10',10,45.38),
('BBBY','2016-05-09',10,45.26),
('BBBY','2016-05-06',10,45.1),
('BBBY','2016-05-05',10,45.95),
('BBBY','2016-05-04',10,45.73),
('BBBY','2016-05-03',10,46.25),
('BBBY','2016-05-02',10,47.46),
('BBBY','2016-04-29',10,47.98),
('BBBY','2016-04-28',10,49.99),
('BBBY','2016-04-27',10,49.17),
('BBBY','2016-04-26',10,48.41),
('BBBY','2016-04-25',10,49.2),
('BBBY','2016-04-22',10,48.52),
('BBBY','2016-04-21',10,48.89),
('BBBY','2016-04-20',10,48.23),
('BBBY','2016-04-19',10,47.95),
('BBBY','2016-04-18',10,48),
('BBBY','2016-04-15',10,47.95),
('BBBY','2016-04-14',10,48.1),
('BBBY','2016-04-13',10,47.22),
('BBBY','2016-04-12',10,46.65),
('SBUX','2016-05-11',11,57.13),
('SBUX','2016-05-10',11,56.85),
('SBUX','2016-05-09',11,56.32),
('SBUX','2016-05-06',11,55.96),
('SBUX','2016-05-05',11,56.37),
('SBUX','2016-05-04',11,55.98),
('SBUX','2016-05-03',11,56.7),
('SBUX','2016-05-02',11,56.29),
('SBUX','2016-04-29',11,56.02),
('SBUX','2016-04-28',11,56.59),
('SBUX','2016-04-27',11,57.51),
('SBUX','2016-04-26',11,58.05),
('SBUX','2016-04-25',11,57.62),
('SBUX','2016-04-22',11,59.01),
('SBUX','2016-04-21',11,60.9),
('SBUX','2016-04-20',11,61.04),
('SBUX','2016-04-19',11,61.16),
('SBUX','2016-04-18',11,60.69),
('SBUX','2016-04-15',11,60.24),
('SBUX','2016-04-14',11,60.26),
('SBUX','2016-04-13',11,60.32),
('SBUX','2016-04-12',11,58.95),
('AMGN','2016-05-11',12,157.73),
('AMGN','2016-05-10',12,155.95),
('AMGN','2016-05-09',12,153.7),
('AMGN','2016-05-06',12,153.49),
('AMGN','2016-05-05',12,154.13),
('AMGN','2016-05-04',12,155.28),
('AMGN','2016-05-03',12,158.37),
('AMGN','2016-05-02',12,158.62),
('AMGN','2016-04-29',12,159.39),
('AMGN','2016-04-28',12,160.22),
('AMGN','2016-04-27',12,162.72),
('AMGN','2016-04-26',12,163.39),
('AMGN','2016-04-25',12,163.15),
('AMGN','2016-04-22',12,164.52),
('AMGN','2016-04-21',12,162.44),
('AMGN','2016-04-20',12,163.02),
('AMGN','2016-04-19',12,160.8),
('AMGN','2016-04-18',12,159.49),
('AMGN','2016-04-15',12,160.15),
('AMGN','2016-04-14',12,159.81),
('AMGN','2016-04-13',12,159.02),
('AMGN','2016-04-12',12,156.14),
('C','2016-05-11',13,44.66),
('C','2016-05-10',13,44.34),
('C','2016-05-09',13,44.31),
('C','2016-05-06',13,43.81),
('C','2016-05-05',13,44.78),
('C','2016-05-04',13,44.88),
('C','2016-05-03',13,45.77),
('C','2016-05-02',13,46.54),
('C','2016-04-29',13,46.52),
('C','2016-04-28',13,46.79),
('C','2016-04-27',13,46.89),
('C','2016-04-26',13,46.71),
('C','2016-04-25',13,46.63),
('C','2016-04-22',13,46.69),
('C','2016-04-21',13,46.79),
('C','2016-04-20',13,45.74),
('C','2016-04-19',13,45.42),
('C','2016-04-18',13,44.42),
('C','2016-04-15',13,46.45),
('C','2016-04-14',13,44.14),
('C','2016-04-13',13,42.55),
('C','2016-04-12',13,41.28),
('COF','2016-05-11',14,70.83),
('COF','2016-05-10',14,70.01),
('COF','2016-05-09',14,70.31),
('COF','2016-05-06',14,68.8),
('COF','2016-05-05',14,69.93),
('COF','2016-05-04',14,71.16),
('COF','2016-05-03',14,72.56),
('COF','2016-05-02',14,72.87),
('COF','2016-04-29',14,72.99),
('COF','2016-04-28',14,73.56),
('COF','2016-04-27',14,73.13),
('COF','2016-04-26',14,75.03),
('COF','2016-04-25',14,75.08),
('COF','2016-04-22',14,74.5),
('COF','2016-04-21',14,75.25),
('COF','2016-04-20',14,73.35),
('COF','2016-04-19',14,71.96),
('COF','2016-04-18',14,70.89),
('COF','2016-04-15',14,71.72),
('COF','2016-04-14',14,70.66),
('COF','2016-04-13',14,69),
('COF','2016-04-12',14,67.55),
('AFGE','2016-05-11',15,27),
('AFGE','2016-05-10',15,27),
('AFGE','2016-05-09',15,27.09),
('AFGE','2016-05-06',15,27.04),
('AFGE','2016-05-05',15,27.08),
('AFGE','2016-05-04',15,27),
('AFGE','2016-05-03',15,27.19),
('AFGE','2016-05-02',15,26.9),
('AFGE','2016-04-29',15,26.86),
('AFGE','2016-04-28',15,26.86),
('AFGE','2016-04-27',15,26.7),
('AFGE','2016-04-26',15,26.68),
('AFGE','2016-04-25',15,26.68),
('AFGE','2016-04-22',15,26.62),
('AFGE','2016-04-21',15,26.68),
('AFGE','2016-04-20',15,26.57),
('AFGE','2016-04-19',15,26.47),
('AFGE','2016-04-18',15,26.49),
('AFGE','2016-04-15',15,26.45),
('AFGE','2016-04-14',15,26.49),
('AFGE','2016-04-13',15,26.58),
('AFGE','2016-04-12',15,26.51),
('ANTX','2016-05-11',16,46.54),
('ANTX','2016-05-10',16,46.37),
('ANTX','2016-05-09',16,46.11),
('ANTX','2016-05-06',16,45.63),
('ANTX','2016-05-05',16,46.07),
('ANTX','2016-05-04',16,45.84),
('ANTX','2016-05-03',16,46.19),
('ANTX','2016-05-02',16,46.64),
('ANTX','2016-04-29',16,46.84),
('ANTX','2016-04-28',16,47.3),
('ANTX','2016-04-27',16,47.38),
('ANTX','2016-04-26',16,47.79),
('ANTX','2016-04-25',16,48.08),
('ANTX','2016-04-22',16,47.39),
('ANTX','2016-04-21',16,47.4),
('ANTX','2016-04-20',16,47.04),
('ANTX','2016-04-19',16,46.87),
('ANTX','2016-04-18',16,46.8),
('ANTX','2016-04-15',16,47.2),
('ANTX','2016-04-14',16,47.29),
('ANTX','2016-04-13',16,47.49),
('ANTX','2016-04-12',16,47.45),
('S','2016-05-11',17,39.86),
('S','2016-05-10',17,39.58),
('S','2016-05-09',17,39.34),
('S','2016-05-06',17,38.97),
('S','2016-05-05',17,39.44),
('S','2016-05-04',17,39.39),
('S','2016-05-03',17,40.03),
('S','2016-05-02',17,39.9),
('S','2016-04-29',17,40.17),
('S','2016-04-28',17,40.36),
('S','2016-04-27',17,40.51),
('S','2016-04-26',17,40.82),
('S','2016-04-25',17,40.59),
('S','2016-04-22',17,40.79),
('S','2016-04-21',17,41.03),
('S','2016-04-20',17,41.19),
('S','2016-04-19',17,41.41),
('S','2016-04-18',17,40.84),
('S','2016-04-15',17,41.12),
('S','2016-04-14',17,41.31),
('S','2016-04-13',17,40.82),
('S','2016-04-12',17,40.31),
('ORCL','2016-05-11',18,39.86),
('ORCL','2016-05-10',18,39.58),
('ORCL','2016-05-09',18,39.34),
('ORCL','2016-05-06',18,38.97),
('ORCL','2016-05-05',18,39.44),
('ORCL','2016-05-04',18,39.39),
('ORCL','2016-05-03',18,40.03),
('ORCL','2016-05-02',18,39.9),
('ORCL','2016-04-29',18,40.17),
('ORCL','2016-04-28',18,40.36),
('ORCL','2016-04-27',18,40.51),
('ORCL','2016-04-26',18,40.82),
('ORCL','2016-04-25',18,40.59),
('ORCL','2016-04-22',18,40.79),
('ORCL','2016-04-21',18,41.03),
('ORCL','2016-04-20',18,41.19),
('ORCL','2016-04-19',18,41.41),
('ORCL','2016-04-18',18,40.84),
('ORCL','2016-04-15',18,41.12),
('ORCL','2016-04-14',18,41.31),
('ORCL','2016-04-13',18,40.82),
('ORCL','2016-04-12',18,40.31),
('RST','2016-05-11',19,7.55),
('RST','2016-05-10',19,7.58),
('RST','2016-05-09',19,7.31),
('RST','2016-05-06',19,8.27),
('RST','2016-05-05',19,8.15),
('RST','2016-05-04',19,7.93),
('RST','2016-05-03',19,7.93),
('RST','2016-05-02',19,8),
('RST','2016-04-29',19,7.93),
('RST','2016-04-28',19,7.96),
('RST','2016-04-27',19,7.89),
('RST','2016-04-26',19,7.81),
('RST','2016-04-25',19,7.94),
('RST','2016-04-22',19,7.98),
('RST','2016-04-21',19,8.08),
('RST','2016-04-20',19,8),
('RST','2016-04-19',19,7.99),
('RST','2016-04-18',19,7.99),
('RST','2016-04-15',19,7.92),
('RST','2016-04-14',19,8.01),
('RST','2016-04-13',19,7.96),
('RST','2016-04-12',19,7.7),
('TIF','2016-05-11',20,68.19),
('TIF','2016-05-10',20,69.47),
('TIF','2016-05-09',20,69.17),
('TIF','2016-05-06',20,69.74),
('TIF','2016-05-05',20,70.13),
('TIF','2016-05-04',20,70.54),
('TIF','2016-05-03',20,71.32),
('TIF','2016-05-02',20,71.49),
('TIF','2016-04-29',20,72.09),
('TIF','2016-04-28',20,72.69),
('TIF','2016-04-27',20,72.66),
('TIF','2016-04-26',20,72.19),
('TIF','2016-04-25',20,72.63),
('TIF','2016-04-22',20,72.21),
('TIF','2016-04-21',20,72.62),
('TIF','2016-04-20',20,71.83),
('TIF','2016-04-19',20,71.36),
('TIF','2016-04-18',20,71.19),
('TIF','2016-04-15',20,71.01),
('TIF','2016-04-14',20,71.6),
('TIF','2016-04-13',20,70.88),
('TIF','2016-04-12',20,71.05),
('CHGG','2016-05-11',21,4.46),
('CHGG','2016-05-10',21,4.42),
('CHGG','2016-05-09',21,4.34),
('CHGG','2016-05-06',21,4.26),
('CHGG','2016-05-05',21,4.38),
('CHGG','2016-05-04',21,4.49),
('CHGG','2016-05-03',21,4.8),
('CHGG','2016-05-02',21,4.59),
('CHGG','2016-04-29',21,4.62),
('CHGG','2016-04-28',21,4.68),
('CHGG','2016-04-27',21,4.66),
('CHGG','2016-04-26',21,4.6),
('CHGG','2016-04-25',21,4.66),
('CHGG','2016-04-22',21,4.52),
('CHGG','2016-04-21',21,4.46),
('CHGG','2016-04-20',21,4.5),
('CHGG','2016-04-19',21,4.5),
('CHGG','2016-04-18',21,4.44),
('CHGG','2016-04-15',21,4.39),
('CHGG','2016-04-14',21,4.46),
('CHGG','2016-04-13',21,4.42),
('CHGG','2016-04-12',21,4.35);

select 'SNDK' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'ORCL' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'AFGE' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'GE' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'C' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'GE' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'WAT' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(10, @d, @symbol, 1, 'buy', @hid);
select 'XOM' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(14, @d, @symbol, 1, 'buy', @hid);
select 'AMGEN' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;

select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(14, @d, @symbol, 1, 'buy', @hid);
select 'GOOG' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'CSCO' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'RST' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'ORCL' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'WAT' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'GOOG' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'GE' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'COF' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'AAPL' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(18, @d, @symbol, 1, 'buy', @hid);
select 'MSFT' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'AMGEN' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'S' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'AAPL' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'AMGEN' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'SBUX' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'ANTX' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'AMGEN' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'WAT' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'AMZN' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(20, @d, @symbol, 1, 'buy', @hid);
select 'GOOG' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(23, @d, @symbol, 1, 'buy', @hid);
select 'CHGG' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(23, @d, @symbol, 1, 'buy', @hid);
select 'SPLS' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(23, @d, @symbol, 1, 'buy', @hid);
select 'AAPL' into @symbol;
select ('2016-04-12' + interval rand()*30 day) into @d;
select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;
INSERT INTO cust_transaction VALUES(23, @d, @symbol, 1, 'buy', @hid);

-- Trigger
-- 3 Triggers
-- trigger: when customer is created, if no account with ssn found, make cash account
DELIMITER $$
CREATE TRIGGER trg_create_cash_account
AFTER INSERT ON customer FOR EACH ROW BEGIN
SELECT id into @cash_id FROM customer_account JOIN
  account_type ON customer_account.id=account_type.acct_id WHERE cust_ssn=new.ssn 
  AND account_type.acct_type='Cash';
  IF (@cash_id IS NULL) THEN
    INSERT INTO customer_account(cust_ssn, acct_value) 
    VALUES (new.ssn, 0);
    INSERT INTO account_type(acct_id, acct_type, acct_min) 
    VALUES ((SELECT MAX(customer_account.id) from customer_account),'Cash', 0);
  END IF;
END$$
DELIMITER ;

-- trigger: on every insert/update to transaction table, update the broker's commission
delimiter //
create trigger trg_allocate_commission
before insert on cust_transaction for each row
begin
declare acct int(9);
declare broker_acct char(9);

set acct =  (select new.acct_id from new);

set broker_acct = (
select broker.ssn from broker 
join customer on broker.ssn = customer.ssn
join customer_account on customer.ssn = cust_ssn
join cust_transaction on acct = acct_id);

update broker 
set broker_transactions = broker_transactions + 1
where broker.ssn = broker_acct;
end //
delimiter ;


DELIMITER $$
CREATE TRIGGER trg_check_roth
BEFORE INSERT ON account_type FOR EACH ROW BEGIN
IF new.acct_type in ('Roth IRA') THEN
  SELECT acct_value into @value FROM customer_account WHERE 
    customer_account.id=new.acct_id;
        IF @value < 3000 THEN
          signal SQLSTATE '12345';
        END IF;
  END IF;
END$$
DELIMITER ;
