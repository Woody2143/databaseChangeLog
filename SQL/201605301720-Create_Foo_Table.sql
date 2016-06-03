CREATE TABLE `foo` (
      `autoid` bigint(20) unsigned NOT NULL auto_increment,
      `foo` varchar(40) default NULL,
      `bar_id` bigint(20) default NULL,
      PRIMARY KEY  (`autoid`),
      KEY `ani_idx` (`foo`),
      KEY `bar_id_idx` (`bar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
