---
layout: post
title: MySQL 定时任务
categories: database
tags: mysql
---

### 使用定时任务自动创建月表

---

通过结合MySQL存储过程与定时任务自动创建月表

- 优势：由于使用数据内置实现无外部依赖，不会因为网络环境和外部服务的变化导致稳定性相关的问题；

- 缺点：缺乏针对定时任务漏执行配套的监控设施；

问题🤔️：为什么需要将建表语句放到存储过程里面而不是使用`create table t_xxx_202004 as select * from t_xxx_202003 where 1 = 2`的方式去复制表结构？

因为对于数据量过大的月表修改表结构，只能修改次月的月表数据结构，即通过拷贝当前月份的表结构生成次月的表结构，在表结构发生变更的时候可能无法生效。

```sql
DELIMITER //
CREATE PROCEDURE `P_AUTO_CREATE_t_test`()
BEGIN
 set @sqlMonth = date_format( DATE_SUB(sysdate(),INTERVAL -1 month),'%Y%m');
 set @sqlTemplate = "CREATE TABLE `t_test_${month}` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  PRIMARY KEY (`id`)
  ) ENGINE=InnoDB COMMENT='xxxxxx'";
 set @sqlString = replace(@sqlTemplate, '${month}', @sqlMonth);
 prepare stmt from @sqlString;
 execute stmt;
END //

DELIMITER ;
DROP EVENT IF EXISTS `CALL_P_AUTO_CREATE_t_test`;
DELIMITER ;;
CREATE EVENT `CALL_P_AUTO_CREATE_t_test` ON SCHEDULE EVERY 1 DAY STARTS '2020-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
        call P_AUTO_CREATE_t_test;
    END
;;
DELIMITER ;
```

```sql
-- 查看定时任务是否生效
show variables like 'event_scheduler';
```
