---
layout: post
title: MySQL 定时任务
categories: database
tags: mysql
---

```mysql
show VARIABLES LIKE 'event_scheduler';
```

### 使用定时任务自动创建月表

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
