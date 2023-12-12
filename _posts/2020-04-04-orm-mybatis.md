---
layout: post
title: mybatis
categories: orm
tags: mybatis
---

## 安装配置

注解 @MapperScan 的作用 同 MapperScannerConfigurer 等价，通过 MapperScannerRegistrar 。

MapperScannerRegistrar

```java
@Configuration
@MapperScan(value = "org.ponderers.totoro.management.dao.d_totoro_management.mapper",
        sqlSessionFactoryRef="sessionFactory@d_totoro_management")
public class MyBatisConfig {

}
```
