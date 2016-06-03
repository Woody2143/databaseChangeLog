CREATE TABLE `Change_Log` (
      `id` bigint(20) unsigned NOT NULL auto_increment,
      `filename` varchar(120) DEFAULT NULL,
      PRIMARY KEY  (`id`),
      KEY `filename_idx` (`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
