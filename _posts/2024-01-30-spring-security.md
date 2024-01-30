---
layout: post
title: Spring Security 核心代码
categories: spring
tags: spring spring-boot
---

```java
FilterChainProxy - Trying to match request against DefaultSecurityFilterChain 
[
RequestMatcher=any request,
Filters=[
org.springframework.security.web.session.DisableEncodeUrlFilter
org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter
org.springframework.security.web.context.SecurityContextHolderFilter
org.springframework.security.web.header.HeaderWriterFilter
org.springframework.security.web.csrf.CsrfFilter
org.springframework.security.web.authentication.logout.LogoutFilter
org.springframework.security.web.savedrequest.RequestCacheAwareFilter
org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter
org.springframework.security.web.authentication.AnonymousAuthenticationFilter
org.springframework.security.web.access.ExceptionTranslationFilter
org.springframework.security.web.access.intercept.AuthorizationFilter
]
```

1. No AuthenticationProvider found for org.springframework.security.authentication.UsernamePasswordAuthenticationToken

![Alt text](/assets/img/WX20240201-205506@2x.png){:width="100%"}

If you create your own UserDetailsService bean, there is no need to manually define a bean for AuthenticationProvider, cos by default a DaoAuthenticationProvider bean will be automatically created for us, which will automatically pick up your defined UserDetailsService bean.

But if you define 2 or more UserDetailsService beans, then u need to define your own Authenticationprovider. I made a mistake, as i don't realize I have another class that implements UserDetailsService interface and annotated with @service , which create a second UserDetailsService bean.
