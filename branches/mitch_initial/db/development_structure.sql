CREATE TABLE `admin_navigation_items` (
  `id` int(11) NOT NULL auto_increment,
  `controller` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `characteristics` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `extensions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `ext_type` varchar(255) default NULL,
  `temp` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `globalize_countries` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(2) default NULL,
  `english_name` varchar(255) default NULL,
  `date_format` varchar(255) default NULL,
  `currency_format` varchar(255) default NULL,
  `currency_code` varchar(3) default NULL,
  `thousands_sep` varchar(2) default NULL,
  `decimal_sep` varchar(2) default NULL,
  `currency_decimal_sep` varchar(2) default NULL,
  `number_grouping_scheme` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `globalize_countries_code_index` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `globalize_languages` (
  `id` int(11) NOT NULL auto_increment,
  `iso_639_1` varchar(2) default NULL,
  `iso_639_2` varchar(3) default NULL,
  `iso_639_3` varchar(3) default NULL,
  `rfc_3066` varchar(255) default NULL,
  `english_name` varchar(255) default NULL,
  `english_name_locale` varchar(255) default NULL,
  `english_name_modifier` varchar(255) default NULL,
  `native_name` varchar(255) default NULL,
  `native_name_locale` varchar(255) default NULL,
  `native_name_modifier` varchar(255) default NULL,
  `macro_language` tinyint(1) default NULL,
  `direction` varchar(255) default NULL,
  `pluralization` varchar(255) default NULL,
  `scope` char(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `globalize_languages_iso_639_1_index` (`iso_639_1`),
  KEY `globalize_languages_iso_639_2_index` (`iso_639_2`),
  KEY `globalize_languages_iso_639_3_index` (`iso_639_3`),
  KEY `globalize_languages_rfc_3066_index` (`rfc_3066`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `globalize_translations` (
  `id` int(11) NOT NULL auto_increment,
  `type` varchar(255) default NULL,
  `tr_key` varchar(255) default NULL,
  `table_name` varchar(255) default NULL,
  `item_id` int(11) default NULL,
  `facet` varchar(255) default NULL,
  `language_id` int(11) default NULL,
  `pluralization_index` int(11) default NULL,
  `text` text,
  PRIMARY KEY  (`id`),
  KEY `globalize_translations_tr_key_index` (`tr_key`,`language_id`),
  KEY `globalize_translations_table_name_index` (`table_name`,`item_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_extensions` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) default '0',
  `extension_id` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `items` (
  `id` int(11) NOT NULL auto_increment,
  `extension_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `temp` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `options` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `value` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `options_name_index` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `permissions_name_index` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `role_extensions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` int(11) default '0',
  `extension_id` int(11) default '0',
  `value` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `role_permissions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` int(11) default '0',
  `permission_id` int(11) default '0',
  `value` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default '0',
  `name` varchar(255) default NULL,
  `is_default` int(11) default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `roles_name_index` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `roles_users` (
  `role_id` int(11) default '0',
  `user_id` int(11) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `login` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `users_login_index` (`login`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO schema_info (version) VALUES (4);
