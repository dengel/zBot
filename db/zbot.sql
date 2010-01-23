connect mysql;

REPLACE INTO user ( host, user, password )
VALUES (
    'localhost',
    'zbot',
    password('mypass')
);

REPLACE INTO db ( host, db, user, select_priv, insert_priv, update_priv, delete_priv, create_priv, drop_priv, alter_priv )
VALUES (
    'localhost',
    'zbot_db',
    'zbot',
    'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y'
);
 
create DATABASE zbot_db;

CONNECT zbot_db;

DROP TABLE IF EXISTS `canales`;
CREATE TABLE `canales` (
  `id` int(11) NOT NULL auto_increment,
  `nombre` varchar(80) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `value` (`nombre`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `urls`;
CREATE TABLE `urls` (
  `u_id` int(11) NOT NULL auto_increment,
  `nick` varchar(255) NOT NULL default '',
  `channel` varchar(255) NOT NULL default '',
  `url` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`u_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `nick` varchar(255) NOT NULL default '',
  `mask` varchar(255) NOT NULL default '',
  `level` int(11) NOT NULL default '0',
  `channel` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
