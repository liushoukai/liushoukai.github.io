---
layout: post
title: 模板示例（请勿编辑）
categories: java
tags: threadsafe jvm
---

https://github.com/mbosecke/template-benchmark

### Run complete. Total time: 00:10:23

| Benchmark           | Version        |  Mode | Cnt |     Score |     Error  | Units |
| ------------------- | -------------- | ----- | --- | --------- | ---------- | ----- |
|Freemarker.benchmark | 2.3.23         | thrpt |  50 | 12831.470 | ±  862.381 | ops/s |
|Handlebars.benchmark | 4.0.1          | thrpt |  50 | 14488.231 | ±  262.421 | ops/s |
|Mustache.benchmark   | 0.9.1          | thrpt |  50 | 18330.852 | ±  170.543 | ops/s |
|Pebble.benchmark     | 2.2.0          | thrpt |  50 | 27200.105 | ±  180.668 | ops/s |
|Rocker.benchmark     | 0.10.3         | thrpt |  50 | 32606.249 | ±  600.979 | ops/s |
|Thymeleaf.benchmark  | 2.1.4.RELEASE  | thrpt |  50 |   829.909 | ±   27.656 | ops/s |
|Trimou.benchmark     | 1.8.2.Final    | thrpt |  50 | 17977.711 | ±  308.920 | ops/s |
|Velocity.benchmark   | 1.7            | thrpt |  50 | 17097.452 | ±   94.573 | ops/s |

### Run complete. Total time: 00:10:18

| Benchmark           | Version        |  Mode | Cnt |     Score |     Error  | Units |
| ------------------- | -------------- | ----- | --- | --------- | ---------- | ----- |
|Freemarker.benchmark | 2.3.23         | thrpt |  50 | 13270.997 | ±  216.178 | ops/s |
|Handlebars.benchmark | 4.0.1          | thrpt |  50 | 14775.847 | ±  335.934 | ops/s |
|Mustache.benchmark   | 0.9.1          | thrpt |  50 | 18052.613 | ±  445.689 | ops/s |
|Pebble.benchmark     | 2.2.0          | thrpt |  50 | 25420.277 | ± 1059.726 | ops/s |
|Rocker.benchmark     | 0.10.3         | thrpt |  50 | 33687.571 | ±  557.921 | ops/s |
|Thymeleaf.benchmark  | 3.0.11.RELEASE | thrpt |  50 |  3644.559 | ±   63.977 | ops/s |
|Trimou.benchmark     | 1.8.2.Final    | thrpt |  50 | 18117.914 | ±  305.510 | ops/s |
|Velocity.benchmark   | 1.7            | thrpt |  50 | 16610.908 | ±  214.678 | ops/s |

结论
虽然纵向比较Thymeleaf 3.x版本对比2.x性能有了大幅度的提升，但是横向与其他模板引擎对比，


1、gunplot:画图工具，python下使用libsvm必须是用的吧，matlab下面可能不需要安装

安装gnuplot
java -jar target/benchmarks.jar -rff results.csv -rf csv
gnuplot benchmark.plot

1. 在ubuntu中安装gnuplot-x11包, `sudo apt-get -y install gnuplot-x11`，检查是否安装`dpkg -s gnuplot-x11`
2. 安装后输入gnuplot进入Gnuplot命令界面
3. 输入plot sin(x)结果如下图所示
4. 退出gnuplot按q


-rff results.csv -rf csv

- "org.ponderers.benchmark.StringBuilderTest.testStringAdd","thrpt",2,15,10780.077210,1110.554348,"ops/ms"
- "org.ponderers.benchmark.StringBuilderTest.testStringBuilderAdd","thrpt",2,15,26546.021272,6819.037910,"ops/ms"

