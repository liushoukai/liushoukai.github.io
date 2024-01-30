---
layout: post
title: Gatling 性能测试
categories: test
tags: gatling
---

## Gatling Injection

[https://gatling.io/docs/gatling/reference/current/core/injection/](https://gatling.io/docs/gatling/reference/current/core/injection/){:target="_blank"}

```java
setUp(
    scn.injectOpen(rampUsersPerSec(100).to(700).during(Duration.ofSeconds(60)))
).protocols(httpProtocol);
```

> 1. constantConcurrentUsers(nbUsers).during(duration): Inject so that number of concurrent users in the system is constant
> 2. rampConcurrentUsers(fromNbUsers).to(toNbUsers).during(duration): Inject so that number of concurrent users in the system ramps linearly from a number to another

## Load profile

### Fixed

![Alt text](/assets/img/WX20240201-113750@2x.png){:width="100%"}

### Ramp up

![Alt text](/assets/img/WX20240201-114014@2x.png){:width="100%"}

### Spike

![Alt text](/assets/img/WX20240201-114116@2x.png){:width="100%"}

## Peak

![Alt text](/assets/img/WX20240201-114224@2x.png){:width="100%"}

## Gatling Maven Plugin

[https://github.com/gatling/gatling-maven-plugin](https://github.com/gatling/gatling-maven-plugin){:target="_blank"}
