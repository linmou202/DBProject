create schema `flat`;

use `flat`;

create table `flat` (
  `flatid` char(8) not null,
  `address` varchar(100) not null,
  primary key (`flatid`));

create table `room` (
  `flatid` char(8) not null,
  `roomid` char(8) not null,
  `capacity` int not null,
  primary key (`flatid`, `roomid`),
  foreign key (`flatid`) References `flat`(`flatid`)
  on delete no action on update no action);

create table `admin` (
  `admid` char(10) not null,
  `name` varchar(50) not null,
  `password` varchar(16) not null,
  `telephone` varchar(16) not null,
  `email` varchar(40) null,
  `flatid` char(8) null,
  primary key (`admid`),
  check (`telephone` regexp '^[0-9,-]+$'),
  check (`email` like '%@%'),
  foreign key (`flatid`) References `flat`(`flatid`)
  on delete no action on update no action);

create table `student` (
  `stuid` char(10) not null,
  `name` varchar(50) not null,
  `password` varchar(16) not null,
  `telephone` varchar(16) not null,
  `email` varchar(40) null,
  `photo` varchar(100) null,
  `flatid` char(8) null,
  `roomid` char(8) null,
  `bedid` int null,
  primary key (`stuid`),
  check (`telephone` regexp '^[0-9,-]+$'),
  check (`email` like '%@%'),
  foreign key (`flatid`, `roomid`) References `room`(`flatid`, `roomid`)
  on delete no action on update no action);

create table `maintenance` (
  `mtid` int not null,
  `request` varchar(100) not null,
  `status` int not null,
  `flatid` char(8) not null,
  `roomid` char(8) not null,
  `stuid` char(10) not null,
  `subtime` date not null,
  `admid` char(10) null,
  `fintime` date null,
  primary key (`mtid`),
  check (status in (0, 1, 2)),
  foreign key (`flatid`, `roomid`) References `room`(`flatid`, `roomid`)
  on delete no action on update no action,
  foreign key (`stuid`) References `student`(`stuid`)
  on delete no action on update no action,
  foreign key (`admid`) References `admin`(`admid`)
  on delete no action on update no action);

create table `visitor` (
  `visid` char(20) not null,
  `stuid` char(10) not null,
  `name` varchar(50) not null,
  `telephone` varchar(16) not null,
  primary key(`visid`, `stuid`),
  check (`telephone` regexp '^[0-9,-]+$'));

create table `reservation` (
  `resid` int not null,
  `visid` char(20) not null,
  `stuid` char(10) not null,
  `date` date not null,
  `reason` varchar(100) not null,
  primary key(`resid`),
  foreign key (`visid`, `stuid`) References `visitor`(`visid`, `stuid`)
  on delete no action on update no action);