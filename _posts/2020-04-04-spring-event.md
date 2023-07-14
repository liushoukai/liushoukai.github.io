---
layout: post
title: Spring 事件
categories: spring
tags: spring spring-boot
---

## ApplicationListener

```java
// META-INF/spring.factories
org.springframework.context.ApplicationListener=<class implements ApplicationListener>
```


## SpringApplicationRunListener

```java
// META-INF/spring.factories
org.springframework.boot.SpringApplicationRunListener=<class implements SpringApplicationRunListener>
```