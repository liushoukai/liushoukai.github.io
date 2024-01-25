---
layout: post
title: Spring扩展接口
categories: spring
tags: spring spring-boot
---

## HandlerMethodArgumentResolver

通过扩展`HandlerMethodArgumentResolver`的方式，实现参数的自定义解析。

```java
public class CustomResolver implements HandlerMethodArgumentResolver {
    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(RequestBody.class) && ParamName.class.isAssignableFrom(parameter.getParameterType());
    }
}

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private CustomResolver customResolver;

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(customResolver);
    }
}
```

重写`WebMvcConfigurer`接口的`addArgumentResolvers`方法，接口注释该接口不会覆盖内置的参数解析器，
如果需要重制内置的解析器，必须设置`RequestMappingHandlerAdapter`接口。
![Alt text](/assets/img/WX20240124-113126@2x.png){:width="100%"}

## RequestMappingHandlerAdapter

通过`RequestMappingHandlerAdapter#setCustomArgumentResolvers`将添加自定义的参数解析器。
![Alt text](/assets/img/WX20240124-113646@2x.png){:width="100%"}

参数解析器的初始化过程是通过`RequestMappingHandlerAdapter#afterPropertiesSet`的方法来实现的。
注意⚠️：自定义解析器是追加在内建解析器的后面的。
![Alt text](/assets/img/WX20240124-113917@2x.png){:width="100%"}
![Alt text](/assets/img/WX20240124-114101@2x.png){:width="100%"}
![Alt text](/assets/img/WX20240124-114426@2x.png){:width="100%"}
