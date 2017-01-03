drop schema classic;
create schema classic;
use classic;

create table accounts
(
account_id int(9) auto_increment primary key,
account_balance double(9,2)
);
create table advisor 
(
adv_id int(9) auto_increment primary key,
adv_fname varchar(32),
adv_lname varchar(32),
adv_password varchar(32)
);
create table recepient 
(
rec_id int(9) auto_increment primary key,
rec_fname varchar(32),
rec_lname varchar(32),
adv_id int(9),
foreign key (adv_id) references advisor(adv_id)
);
create table loan 
(
loan_id int(9) auto_increment primary key,
loan_int_amt double(9,2),
loan_current_due double(9,2),
loan_start_date datetime,
rec_id int(9),
account_id int(9),
foreign key (rec_id) references recepient(rec_id),
foreign key (account_id) references accounts(account_id)
);
create table invoice
(
inv_id int(9) auto_increment primary key,
inv_date datetime,
inv_amt double(9,2),
loan_id int(9),
foreign key (loan_id) references loan(loan_id)
);
create table email
(
email_id int(9) auto_increment primary key,
email varchar(100),
rec_id int(9),
foreign key (rec_id) references recepient(rec_id)
);

insert into advisor (`adv_fname`, `adv_lname`, `adv_password`) values
('Sean', 'Bradley', 'seanbradley'),
('Corey', 'Smith', 'coreysmith'),
('Bryce', 'Schmitt', 'bryceschmitt'),
('Tony', 'Resendiz', 'tonyresendiz');

insert into accounts(`account_balance`) values (1000000);