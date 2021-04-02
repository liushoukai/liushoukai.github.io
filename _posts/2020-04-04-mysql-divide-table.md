---
layout: post
title: MySQL 数据库分表
categories: database
tags: mysql
---


## 自动创建月表

---

通过结合MySQL存储过程与定时任务自动创建月表

* 优势：由于使用数据内置实现无外部依赖，不会因为网络环境和外部服务的变化导致稳定性相关的问题；
* 缺点：缺乏针对定时任务漏执行配套的监控设施；

```sql
-- 自动建表存储过程
DELIMITER $$
CREATE PROCEDURE `P_AUTO_CREATE_TABLE`()
BEGIN
 set @t_test1 = "CREATE TABLE `t_test1_${month}` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `addTime` int(11) DEFAULT NULL COMMENT '添加时间',
  `updateTime` int(11) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
  ) ENGINE=InnoDB COMMENT='测试表1'";
  
  set @t_test2 = "CREATE TABLE `t_test2_${month}` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `addTime` int(11) DEFAULT NULL COMMENT '添加时间',
  `updateTime` int(11) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
  ) ENGINE=InnoDB COMMENT='测试表2'";
  
 set @yearMonth = date_format( DATE_SUB(sysdate(),INTERVAL -1 month),'%Y%m');

 set @sqlString = replace(@t_test1, '${month}', @yearMonth);
 prepare stmt from @sqlString;
 execute stmt;
  
 set @sqlString = replace(@t_test2, '${month}', @yearMonth);
 prepare stmt from @sqlString;
 execute stmt;
END$$
DELIMITER ;

-- 自动建表执行计划
DROP EVENT IF EXISTS `E_AUTO_CREATE_TABLE`;
DELIMITER ;;
CREATE EVENT `E_AUTO_CREATE_TABLE` ON SCHEDULE EVERY 1 DAY STARTS '2020-01-01 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE DO BEGIN
    call P_AUTO_CREATE_TABLE;
END
;;
DELIMITER ;

-- 查看计划是否生效
show variables like 'event_scheduler';
```

问题🤔️：为什么需要将建表语句放到存储过程里而不通过`create table xxx as ...`的方式根据历史月份表结构来建表？

因为对于数据量过大的月表修改表结构，只能修改次月的月表数据结构，即通过拷贝当前月份的表结构生成次月的表结构，在表结构发生变更的时候可能无法生效。
