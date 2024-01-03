---
layout: post
title:  PowerDesigner使用
categories: tool
tags: powerdesigner
---

数据库的反向工程

==============

1.首先新建一个“PhysicalDataModel”类型的文件，然后点击“Database”->"Configure Connections"，弹出窗口“Configure Data Connections”，并选择"Connection Profiles"。

2.新建Mysql数据源文件mysql.dcp，填写完相关信息后点击左下角的“Test Connection...”测试连接是否连接成功。
如果遇到“Could not Initialize JavaVM!”错误，检查JDK版本是否32位版本，Powerdesigner默认不支持64位JDK。

3.连接成功后，点击“Database”->"Update Model from Database"，弹出窗口“Database Reverse Engineering Options”，使用“Using a data source”选项，选中步骤2中创建的mysql.dcp数据源文件。

4.完成配置后，选择需要进行反向工程的数据库表，然后点击“OK”即可成数据库的反向工程操作。

设置Oracle中表主键存储使用的表空间

#### 1.设置表主键的存储表空间

#### 2.设置后可以查看表的Preview，可以看到配置的效果：

