#!/usr/bin/env bash

mysql -u root -p -e 'DROP DATABASE foo; DROP DATABASE foo_dev; DROP USER "foo"@"localhost"; CREATE DATABASE foo; use foo; CREATE TABLE `Change_Log` (`id` bigint(20) unsigned NOT NULL auto_increment, `filename` varchar(120) DEFAULT NULL, PRIMARY KEY  (`id`), KEY `filename_idx` (`filename`)) ENGINE=MyISAM DEFAULT CHARSET=utf8; INSERT INTO Change_Log (filename) VALUE ("201605301631-Create_Change_Log_Table.sql"); CREATE DATABASE foo_dev; GRANT ALL PRIVILEGES ON foo.* TO "foo"@"localhost" IDENTIFIED BY "foo"; GRANT ALL PRIVILEGES ON foo_dev.* TO "foo"@"localhost" IDENTIFIED BY "foo"; FLUSH PRIVILEGES;';

echo -e "host: localhost\ndb: foo_dev\nuser: foo\npass: foo\nprodDB: foo" > DEVELOPMENT; 
