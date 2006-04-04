/*
SQLyog Enterprise - MySQL GUI v4.1
Host - 5.0.18-nt : Database - railfrog_development
*********************************************************************
Server version : 5.0.18-nt
*/


create database if not exists `railfrog_development`;

USE `railfrog_development`;

/*Table structure for table `users` */

drop table if exists `users`;

CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` char(40) NOT NULL,
  `updated_on` datetime NOT NULL default '1970-01-01 00:00:00',
  `created_on` datetime NOT NULL default '1970-01-01 00:00:00',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `users` */

LOCK TABLES `users` WRITE;

insert into `users` values (1,'test','test','test@test.com','5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8','1970-01-01 00:00:00','1970-01-01 00:00:00');

UNLOCK TABLES;
