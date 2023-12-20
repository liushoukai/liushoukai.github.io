---
layout: post
title: Spring Bean生命周期
categories: spring
tags: spring spring-boot
---

## Spring Bean 生命周期

### 应用场景

缓存预热

为什么要关注Spring Bean的创建和销毁流程，最常见的一个应用场景是服务的缓存预热，通常是放在Bean的初始化阶段。

线上就因为对初始化的流程理解存不够深入，预热的代码存在BUG，导致数据预热完成之前，已经开始监听端口接收流量导致的线上故障。

## Bean初始化/销毁方式

* init-method/destroy-method
* InitializingBean/DisposableBean
* @PostConstruct/@PreDestroy
* ContextStartedEvent/ContextClosedEvent

## Bean初始化/销毁的顺序

<div class="mermaid">
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart TD

subgraph A["Bean Initialization"]
direction LR
markdown1 --> markdown2 --> markdown3 --> markdown4 --> markdown5
markdown1["`@PostConstruct`"]
markdown2["`InitializingBean`"]
markdown3["`init-method`"]
markdown4["`ContextStartedEvent`"]
markdown5["`Spring Started`"]
end

subgraph B["Bean Destruction"]
direction RL
markdown6 --> markdown7 --> markdown8 --> markdown9 --> markdown10
markdown6["`Spring Stoped`"]
markdown7["`ContextedClosedEvent`"]
markdown8["`@PreDestroy`"]
markdown9["`DisposableBean`"]
markdown10["`destroy-method`"]
end
 
A --> B
</div>

### init-method/destroy-method

通过自定义的初始化和销毁方法。

```java
@Configurable
public class AppConfig {
    @Bean(initMethod = "init", destroyMethod = "destroy")
    public HelloService hello() {
        return new HelloService();
    }
}
```

### InitializingBean/DisposableBean

继承 Spring 的 InitializingBean / DisposableBean 接口，其中 InitializingBean 用于初始化操作，而 DisposableBean 用于在销毁之前执行清理操作。

```java
@Service
public class HelloService implements InitializingBean, DisposableBean {
    @Override
    public void destroy() throws Exception {
        System.out.println("hello destroy...");
    }
    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("hello init....");
    }
}
```



### @PostConstruct/@PreDestroy



与上述两种方法相比，该方法最容易使用。您只需要在相应的方法上使用注释。

注意⚠️：如果在JDK9之后使用该版本，则@ PostConstruct / @ PreDestroy需要使用maven单独引入javax.annotation-api，否则注释将不会生效。

```java
@Service
public class HelloService {
    @PostConstruct
    public void init() {
        System.out.println("hello @PostConstruct");
    }
    @PreDestroy
    public void PreDestroy() {
        System.out.println("hello @PreDestroy");
    }
}
```

### ContextStartedEvent/ContextClosedEvent

通过这种方式，使用了Spring事件机制，并且很少进行日常业务开发，通常将其与框架集成在一起。

ContextStartedEvent 事件将在 Spring 启动之后发送，而 ContextClosedEvent 事件将在 Spring 关闭之前发送。我们需要实现 ApplicationListener 接口来侦听上述两个事件。

注意⚠️：ContextStartedEvent仅在调用ApplicationContext时发送。如果您不想那么麻烦，可以改为监听ContextRefreshedEvent事件。一旦Spring容器被初始化，就发送一个ContextRefreshedEvent。

```java
// 实现ApplicationListener接口
@Service
public class HelloListener implements ApplicationListener {
    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        if(event instanceof ContextClosedEvent){
            System.out.println("hello ContextClosedEvent");
        }else if(event instanceof ContextStartedEvent){
            System.out.println("hello ContextStartedEvent");
        }
    }
}
// 使用@EventListener注解
public class HelloListener {
    @EventListener(value = {ContextClosedEvent.class, ContextStartedEvent.class})
    public void receiveEvents(ApplicationEvent event) {
        if (event instanceof ContextClosedEvent) {
            System.out.println("hello ContextClosedEvent");
        } else if (event instanceof ContextStartedEvent) {
            System.out.println("hello ContextStartedEvent");
        }
    }
}
```

## Bean初始化/销毁源码分析

使用ClassPathXmlApplicationContext启动Spring容器将调用refresh()来初始化容器。

初始化过程将创建Bean，当一切准备就绪时，将发送 ContextRefreshedEvent 事件。

初始化容器后，调用 context.start() 时，将发送 ContextStartedEvent 事件。

### Bean初始化源码分析

AbstractApplicationContext.refresh()，源代码如下：

```java
public void refresh() throws BeansException, IllegalStateException {
    synchronized (this.startupShutdownMonitor) {
        // ...
        // Instantiate all remaining (non-lazy-init) singletons.
        finishBeanFactoryInitialization(beanFactory);
        // Last step: publish corresponding event.
        finishRefresh();
        // ...
    }
}
protected void finishRefresh() {
    // ...
    // Publish the final event.
    publishEvent(new ContextRefreshedEvent(this));
    // ...
}
```

追踪finishBeanFactoryInitialization()源代码，直到定位AbstractAutowireCapableBeanFactory.initializeBean()，源代码如下：

```java
protected Object initializeBean(final String beanName, final Object bean, RootBeanDefinition mbd) {
    if (System.getSecurityManager() != null) {
        AccessController.doPrivileged(new PrivilegedAction<Object>() {
            @Override
            public Object run() {
                invokeAwareMethods(beanName, bean);
                return null;
            }
        }, getAccessControlContext());
    }
    else {
        invokeAwareMethods(beanName, bean);
    }

    Object wrappedBean = bean;
    if (mbd == null || !mbd.isSynthetic()) {
        // 调用@PostConstruct注解方法
        wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
    }

    try {
        // 调用InitializingBean.afterPropertiesSet()方法和自定义的@Bean(initMethod = "init")方法
        invokeInitMethods(beanName, wrappedBean, mbd);
    }
    catch (Throwable ex) {
        throw new BeanCreationException(
                (mbd != null ? mbd.getResourceDescription() : null),
                beanName, "Invocation of init method failed", ex);
    }

    if (mbd == null || !mbd.isSynthetic()) {
        wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
    }
    return wrappedBean;
}
```

BeanPostProcessor将充当拦截器，一旦Bean满足条件，它将执行一些处理。

带有@PostConstruct注解的Bean将被CommonAnnotationBeanPostProcessor类拦截，并且@PostConstruct注解的方法会被内部调用。

然后执行AbstractAutowireCapableBeanFactory.invokeInitMethods()方法，如果Bean实现了InitializingBean接口，会调用调用InitializingBean.afterPropertiesSet()方法。

```java
protected void invokeInitMethods(String beanName, final Object bean, RootBeanDefinition mbd) throws Throwable {

    boolean isInitializingBean = (bean instanceof InitializingBean);
    if (isInitializingBean && (mbd == null || !mbd.isExternallyManagedInitMethod("afterPropertiesSet"))) {
        // Omit irrelevant code
        // If the Bean inherits the InitializingBean, the afterpropertieset method will be executed
        ((InitializingBean) bean).afterPropertiesSet();
    }

    if (mbd != null) {
        String initMethodName = mbd.getInitMethodName();
        if (initMethodName != null && !(isInitializingBean && "afterPropertiesSet".equals(initMethodName)) &&
                !mbd.isExternallyManagedInitMethod(initMethodName)) {
            // Execute XML definition init method
            invokeCustomInitMethod(beanName, bean, mbd);
        }
    }
}
```

上述源代码都是围绕Bean创建过程中执行的，当所有的Bean都成功创建后，回调用Spring上下文context.start()方法并发送ContextStartedEvent事件，源码如下：

```java
public void start() {
    getLifecycleProcessor().start();
    publishEvent(new ContextStartedEvent(this));
}
```



### Bean销毁源码分析



调用classpathxmlapplicationcontext吗？方法将关闭容器，并且特定的逻辑将在doClose方法中执行。 doClose方法首先发送ContextClosedEvent，然后开始销毁Bean。

灵魂折磨：如果我们颠倒以上两个的顺序，结果会是一样的吗

```java
protected void doClose() {
    if (this.active.get() && this.closed.compareAndSet(false, true)) {
        // ...
        try {
            // Publish shutdown event.
            publishEvent(new ContextClosedEvent(this));
        }
        catch (Throwable ex) {
            logger.warn("Exception thrown from ApplicationListener handling ContextClosedEvent", ex);
        }
        // Destroy Bean
        destroyBeans();
        // ...
    }
}
```

AbstractApplicationContext.destroyBeans()最终将执行DefaultListableBeanFactory.destroySingletons()，
最后回调用到@ PreDestroy，DisposableBean和destroy方法将全部在内部执行。

```java
public void destroySingleton(String beanName) {
    // Remove a registered singleton of the given name, if any.
    removeSingleton(beanName);

    // Destroy the corresponding DisposableBean instance.
    DisposableBean disposableBean;
    synchronized (this.disposableBeans) {
        disposableBean = (DisposableBean) this.disposableBeans.remove(beanName);
    }
    destroyBean(beanName, disposableBean);
}
```

DefaultListableBeanFactory.destroySingletons() 回调用到 DefaultSingletonBeanRegistry.destroySingleton()，销毁当前Bean之前，必须先销毁其依赖的Bean。

```java
/**
 * Destroy the given bean. Must destroy beans that depend on the given
 * bean before the bean itself. Should not throw any exceptions.
 * @param beanName the name of the bean
 * @param bean the bean instance to destroy
 */
protected void destroyBean(String beanName, DisposableBean bean) {
    // ...
    // Actually destroy the bean now...
    if (bean != null) {
        try {
            bean.destroy();
        }
        catch (Throwable ex) {
            logger.error("Destroy method on bean with name '" + beanName + "' threw an exception", ex);
        }
    }
    // ...
}
```

首先，执行销毁感知bean后处理器ා销毁前的后处理程序。在这里，该方法类似于上面的BeanPostProcessor。

@PreDestroy批注将被CommonAnnotationBeanPostProcessor阻止，该类还继承了DestructionAwareBeanPostProcessor。

最后，如果Bean是DisposableBean的子类，则将执行destroy方法。如果在xml中定义了destroy方法，则该方法也将执行。

```java
public void destroy() {
    if (!CollectionUtils.isEmpty(this.beanPostProcessors)) {
        for (DestructionAwareBeanPostProcessor processor : this.beanPostProcessors) {
            processor.postProcessBeforeDestruction(this.bean, this.beanName);
        }
    }
    if (this.invokeDisposableBean) {
        // Omit irrelevant code
        // If Bean inherits DisposableBean, execute destroy method
        ((DisposableBean) bean).destroy();   
    }
    if (this.destroyMethod != null) {
        // Execute the destroy method specified by xml
        invokeCustomDestroyMethod(this.destroyMethod);
    }
    else if (this.destroyMethodName != null) {
        Method methodToCall = determineDestroyMethod();
        if (methodToCall != null) {
            invokeCustomDestroyMethod(methodToCall);
        }
    }
}
```

## 排查案例

已经通过BeanDefinition动态注册了`GlobalIdService.Client`的Bean，但是在做类型转换时报错如下：

```java
GlobalIdService.Client globalIdService = (GlobalIdService.Client) applicationContext.getBean("globalIdService");

java.lang.ClassCastException: class org.ponderers.totoro.infrastructure.rpc.thrift.GlobalIdService$Client cannot be cast to class org.ponderers.totoro.infrastructure.rpc.thrift.GlobalIdService$Client (org.ponderers.totoro.infrastructure.rpc.thrift.GlobalIdService$Client is in unnamed module of loader 'app'; org.ponderers.totoro.infrastructure.rpc.thrift.GlobalIdService$Client is in unnamed module of loader org.springframework.boot.devtools.restart.classloader.RestartClassLoader @55c747b)
```

`GlobalIdService$Client`类文件被不同的类加载器各加载了一次，产生两个不同的类，导致在类型转换时失败。

1. 通过默认的未命名模块类加载器'app'加载了一次；
2. 通过 Spring Devtools 的未命名模块类加载器'RestartClassLoader'加载了一次；
