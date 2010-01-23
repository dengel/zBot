--
-- Table structure for table `canales`
--

DROP TABLE IF EXISTS `canales`;
CREATE TABLE `canales` (
  `id` int(11) NOT NULL auto_increment,
  `nombre` varchar(80) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `value` (`nombre`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `urls`
--

DROP TABLE IF EXISTS `urls`;
CREATE TABLE `urls` (
  `u_id` int(11) NOT NULL auto_increment,
  `nick` varchar(255) NOT NULL default '',
  `channel` varchar(255) NOT NULL default '',
  `url` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`u_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `nick` varchar(255) NOT NULL default '',
  `mask` varchar(255) NOT NULL default '',
  `level` int(11) NOT NULL default '0',
  `channel` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
