---
layout: post
title: Spring 事件
categories: spring
tags: spring spring-boot
---



http://localhost:9000/oauth2/authorize?response_type=code&client_id=oidc-client&scope=message.read%20openid&redirect_uri=http://www.baidu.com

https://docs.spring.io/spring-authorization-server/docs/current/reference/html/


http://127.0.0.1:8080/login/oauth2/code/articles-client-oidc?code=USZPD4_dcUEHvAYs4_Zx3lgQ3D3f_JjLLqXZ8NDjo4uotvg3cQ_KbDC25U7VifwjZz3tsQD7t0aAwIUOpBC43yfLJgxMSA5Uwy4IE4l6493X1aGeje55JVv2UPi8jB9r&state=116Wvlm2xNMO7WCEe5BQgT03H_80S-b_tbv6WzWmwqs%3D

### Spring OAuth2文档

https://docs.spring.io/spring-security/reference/servlet/oauth2/login/core.html

```yml
spring:
  security:
    oauth2:
      client:
        registration:
          articles-client-oidc:
            provider: spring
            client-id: articles-client
            client-secret: secret
            authorization-grant-type: authorization_code
            redirect-uri: "http://127.0.0.1:8080/login/oauth2/code/{registrationId}"
            scope: openid
            client-name: articles-client-oidc
```

`spring.security.oauth2.client.registration` 是 OAuth2 客户端属性的前缀，这些属性用于初始化配置`org.springframework.security.oauth2.client.registrationClientRegistration`的类属性。

> spring.security.oauth2.client.registration.[registrationId]

registrationId 是 ClientRegistration 的唯一标识符。这里的 registrationId 是 `articles-client-oidc`。

> spring.security.oauth2.client.registration.[registrationId].redirect-uri

redirect-uri 是应用程序中的路径，终端用户的用户代理在使用谷歌进行身份验证并在Consent页面上授予对OAuth客户机(在上一步中创建)的访问权限后，将被重定向回此路径。
确保授权重定向URI字段设置为：`localhost:8080/login/oauth2/code/google`。默认的 redirect-uri 的模板格式为：`{baseUrl}/login/oauth2/code/{registrationId}`。

> spring.security.oauth2.client.provider.[providerId].issuer-uri

可以通过配置`OpenID Connect Provider’s Configuration endpoint`或者`Authorization Server’s Metadata endpoint`的方式来获取授权服务器的元数据，从而初始化 ClientRegistration 配置。`Authorization Server’s Metadata endpoint` 比如：`http://127.0.0.1:9000/.well-known/openid-configuration`。

<div class="mermaid">
sequenceDiagram
    participant User as User
	participant Client as Client(8080)
	participant Server as Server(9000)
	participant Resource as Resource(8090)

	User->>Client: http://127.0.0.1:8080/articles
    Client-->>Client: [302] http://127.0.0.1:8080/login
    Client->>User: 显示授权方式页面

    User->>Client: http://127.0.0.1:8080/oauth2/authorization/articles-client-oidc（用户选择 articles-client-oidc）
    Client->>Server: [302] http://10.211.56.2:9000/oauth2/authorize
    Server->>User: [302] http://10.211.56.2:9000/login
    User->>Server: http://10.211.56.2:9000/login
    Server->>User: 显示登陆页面
    
    User->>Server: [POST] http://10.211.56.2:9000/login 登陆
    Server->>User: [302] http://10.211.56.2:9000/oauth2/authorize
    User->>Server: http://10.211.56.2:9000/oauth2/authorize
    Server->>User: [302] http://127.0.0.1:8080/login/oauth2/code/articles-client-oidc
    User->>Client: http://127.0.0.1:8080/login/oauth2/code/articles-client-oidc
    Client->>User: [302] http://127.0.0.1:8080/articles?continue
    User->>Client: http://127.0.0.1:8080/articles?continue
    Client->>User: [302] http://10.211.56.2:9000/oauth2/authorize
    User->>Server: http://10.211.56.2:9000/oauth2/authorize
    Server->>User: 显示 Consent Page 页面

    User->>Server: http://10.211.56.2:9000/oauth2/authorize
    Server->>User: [302] http://127.0.0.1:8080/authorized?code
    User->>Client: http://127.0.0.1:8080/authorized?code
    Client->>User: [302] http://127.0.0.1:8080/articles?continue
    User->>Client: http://127.0.0.1:8080/articles?continue
    Client->>User: 显示受保护的资源页面

</div>

## 问题列表

> [authorization_request_not_found]

产生该问题的主要原因本机测试时 server服务 和 client 都是采用localhost，对于浏览器来说同一个域名，导致 JSESSIONID 在跳转到 server 前的值和授权完毕后跳转回来的值不一致，浏览器认为是同一个域名所以 JSESSIONID 会被覆盖，导致在 client 从 session 中获取保存的 authorizationRequest 时获取不到，authorizcationRequest存放在session的Attribute中，key 为 JSESSIONID;

处理该问题方法就是让 server 和 client 使用不同的域名或者ip，确保比如可以修改hosts增加一个域名。本文中OAuth2Server直接使用的局域网ip地址也可以解决这个问题，OAuth2Client使用localhost。
