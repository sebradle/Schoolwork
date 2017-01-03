drop schema civideo;
create schema civideo;
use civideo;
create table membership (
mem_num decimal(4,0) primary key,
mem_fname varchar(20),
mem_lname varchar(20),
mem_street varchar(70),
mem_city varchar(50),
mem_state char(2),
mem_zip char(5),
mem_balance decimal(8,2)
);

create table rental (
rent_num decimal(4,0) primary key,
rent_date date,
mem_num decimal(4,0),
foreign key(mem_num) references membership(mem_num)
);

create table price (
price_code decimal(4,0) primary key,
price_description varchar(50),
price_rentfee decimal(8,2),
price_latefee decimal(8,2)
);

create table movie (
movie_num decimal(4,0) primary key,
movie_title varchar(100),
movie_year decimal(4,0),
movie_cost decimal(8,2),
movie_genre varchar(20),
price_code decimal(4,0),
foreign key(price_code) references price(price_code)
);

create table video (
vid_num decimal (5,0) primary key,
vid_indate date,
movie_num decimal(4,0),
foreign key(movie_num) references movie(movie_num)
);

create table detailrental (
rent_num decimal(4,0),
vid_num decimal(5,0),
detail_fee decimal (8,2),
detail_duedate date,
detail_returndate date,
detail_dailylatefee decimal (8,2),
primary key(rent_num, vid_num),
foreign key(rent_num) references rental(rent_num),
foreign key(vid_num) references video(vid_num)
);

INSERT INTO membership (mem_num, mem_fname, mem_lname, mem_street, mem_city, mem_state, mem_zip, mem_balance) VALUES
(102,'Tami','Dawson','2632 Takli Circle','Norene','TN','37136',11),
(103,'Curt','Knight','4025 Cornell Court','Flatgap','KY','41219',6),
(104,'Jamal','Melendez','788 East 145th Avenue','Quebeck','TN','38579',0),
(105,'Iva','McClain','6045 Musket Ball Circle','Summit','KY','42783',15),
(106,'Miranda','Parks','4469 Maxwell Place','Germantown','TN','38183',0),
(107,'Rosario','Elliott','7578 Danner Avenue','Columbia','TN','38402',5),
(108,'Mattie','Guy','4390 Evergreen Street','Lily','KY','40740',0),
(109,'Clint','Ochoa','1711 Elm Street','Greeneville','TN','37745',10),
(110,'Lewis','Rosales','4524 Southwind Circle','Counce','TN','38326',0),
(111,'Stacy','Mann','2789 East Cook Avenue','Murfreesboro','TN','37132',8),
(112,'Luis','Trujillo','7267 Melvin Avenue','Heiskell','TN','37754',3),
(113,'Minnie','Gonzales','6430 Vaisili Drive','Willison','TN','38076',0);

INSERT INTO rental (rent_num, rent_date, mem_num) VALUES
(1001,' 2013-03-01',103),
(1002,' 2013-03-01',105),
(1003,' 2013-03-02',102),
(1004,' 2013-03-02',110),
(1005,' 2013-03-02',111),
(1006,' 2013-03-02',107),
(1007,' 2013-03-02',104),
(1008,' 2013-03-03',105),
(1009,' 2013-03-03',111);

INSERT INTO price (PRICE_CODE, PRICE_DESCRIPTION, PRICE_RENTFEE, PRICE_LATEFEE) VALUES
(1,'Standard',2,1),
(2,'New Release',3.5,3),
(3,'Discount',1.5,1),
(4,'Weekly Special',1,0.5);

INSERT INTO movie (MOVIE_NUM, MOVIE_TITLE, MOVIE_YEAR, MOVIE_COST, MOVIE_GENRE, PRICE_CODE) VALUES
(1234,'The Cesar Family Christmas',2011,39.95,'FAMILY',2),
(1235,'Smokey Mountain Wildlife',2008,59.95,'ACTION',1),
(1236,'Richard Goodhope',2012,59.95,'DRAMA',2),
(1237,'Beatnik Fever',2011,29.95,'COMEDY',2),
(1238,'Constant Companion',2012,89.95,'DRAMA',2),
(1239,'Where Hope Dies',2002,25.49,'DRAMA',3),
(1245,'Time to Burn',2009,45.49,'ACTION',1),
(1246,'What He Doesnt Know',2010,58.29,'COMEDY',1);

INSERT INTO video (VID_NUM, VID_INDATE, MOVIE_NUM) VALUES
(54321,' 2012-06-18',1234),
(54324,' 2012-06-18',1234),
(54325,' 2012-06-18',1234),
(34341,' 2011-01-22',1235),
(34342,' 2011-01-22',1235),
(34366,' 2013-03-02',1236),
(34367,' 2013-03-02',1236),
(34368,' 2013-03-02',1236),
(34369,' 2013-03-02',1236),
(44392,' 2012-10-21',1237),
(44397,' 2012-10-21',1237),
(59237,' 2013-02-14',1237),
(61388,' 2011-01-25',1239),
(61353,' 2010-01-28',1245),
(61354,' 2010-01-28',1245),
(61367,' 2012-07-30',1246),
(61369,' 2012-07-30',1246);

INSERT INTO detailrental (RENT_NUM, VID_NUM, DETAIL_FEE, DETAIL_DUEDATE, DETAIL_RETURNDATE, DETAIL_DAILYLATEFEE) VALUES
(1001,34342,2,' 2013-03-04',' 2013-03-02',null),
(1001,61353,2,' 2013-03-04',' 2013-03-03',1),
(1002,59237,3.5,' 2013-03-04',' 2013-03-04',3),
(1003,54325,3.5,' 2013-03-04',' 2013-03-09',3),
(1003,61369,2,' 2013-03-06',' 2013-03-09',1),
(1003,61388,0,' 2013-03-06',' 2013-03-09',1),
(1004,44392,3.5,' 2013-03-05',' 2013-03-07',3),
(1004,34367,3.5,' 2013-03-05',' 2013-03-07',3),
(1004,34341,2,' 2013-03-07',' 2013-03-07',1),
(1005,34342,2,' 2013-03-07',' 2013-03-05',1),
(1005,44397,3.5,' 2013-03-05',' 2013-03-05',3),
(1006,34366,3.5,' 2013-03-05',' 2013-03-04',3),
(1006,61367,2,' 2013-03-07',null,1),
(1007,34368,3.5,' 2013-03-05',null,3),
(1008,34369,3.5,' 2013-03-05',' 2013-03-05',3),
(1009,54324,3.5,' 2013-03-05',null,3),
(1001,34366,3.5,' 2013-03-04',' 2013-03-02',3);

delimiter //
create procedure sp_new_member(in fname varchar(20), lname varchar(20), street varchar(70), city varchar(50), state char(2), zip char(5))
begin
declare mem_id_max double(4,0);

set mem_id_max = (select max(mem_num) from membership);
if mem_id_max is null
then set mem_id_max = 1;
else set mem_id_max = mem_id_max + 1;
end if;

insert into membership(mem_num, mem_fname, mem_lname, mem_street, mem_city, mem_state, mem_zip, mem_balance) 
values (mem_id_max, fname, lname, street, city, state, zip, 0);

end //
delimiter ;

select video.vid_num as 'Video ID', movie_title as 'Movie Title', movie_year as 'Movie Year', price_rentfee as 'Rental Cost', 
rent_date as 'Rent Date', detail_duedate as 'Due Date', mem_num as 'Rented By'
from video
left join detailrental on video.vid_num = detailrental.vid_num
left join rental on detailrental.rent_num = rental.rent_num
join movie on video.movie_num = movie.movie_num
join price on movie.price_code = price.price_code
group by video.vid_num
order by video.vid_num desc;