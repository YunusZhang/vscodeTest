


CREATE DATABASE eesy_mybatis;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL COMMENT '用户名称',
  `birthday` datetime DEFAULT NULL COMMENT '生日',
  `sex` char(1) DEFAULT NULL COMMENT '性别',
  `address` varchar(256) DEFAULT NULL COMMENT '地址',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;


INSERT INTO `user` VALUES ('1', '李一', '2020-02-01 17:47:08', '男', '北京');
INSERT INTO `user` VALUES ('2', '刘二', '2020-02-02 15:09:37', '女', '上海');
INSERT INTO `user` VALUES ('3', '张三', '2020-03-03 11:34:34', '女', '广东');
INSERT INTO `user` VALUES ('4', '赵四', '2020-03-04 12:04:06', '男', '杭州');
INSERT INTO `user` VALUES ('5', '王五', '2020-03-05 17:37:26', '男', '深圳');



CREATE TABLE `account` (
  `id` int(11) NOT NULL COMMENT '编号',
  `uid` int(11) default NULL COMMENT '用户编号',
  `money` double default NULL COMMENT '金额',
  PRIMARY KEY  (`id`),
  KEY `FK_Reference_8` (`uid`),
  CONSTRAINT `FK_Reference_8` FOREIGN KEY (`uid`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert  into `account`(`id`,`uid`,`money`) values (11,3,1000),(12,5,1000),(13,3,2000);



CREATE TABLE `role` (
  `id` int(11) NOT NULL COMMENT '编号',
  `role_name` varchar(30) default NULL COMMENT '角色名称',
  `role_desc` varchar(60) default NULL COMMENT '角色描述',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert  into `role`(`id`,`role_name`,`role_desc`) values (1,'院长','管理整个学院'),(2,'总裁','管理整个公司'),(3,'校长','管理整个学校');

CREATE TABLE `user_role` (
  `uid` int(11) NOT NULL COMMENT '用户编号',
  `rid` int(11) NOT NULL COMMENT '角色编号',
  PRIMARY KEY  (`uid`,`rid`),
  KEY `FK_Reference_10` (`rid`),
  CONSTRAINT `FK_Reference_10` FOREIGN KEY (`rid`) REFERENCES `role` (`id`),
  CONSTRAINT `FK_Reference_9` FOREIGN KEY (`uid`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert  into `user_role`(`uid`,`rid`) values (3,1),(5,1),(3,2);


