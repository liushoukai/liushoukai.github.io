---
layout: post
title: git
categories: git
tags: git-command
---

## 双亲委派模型

Java中的类加载机制是双亲委派模型，即按照 `AppClassLoader → SystemClassLoader → BootstrapClassLoader` 的顺序，子ClassLoader将一个类加载的任务委托给父ClassLoader（父ClassLoader会再委托给父的父ClassLoader）来完成，只有父ClassLoader无法完成该类的加载时，子ClassLoader才会尝试自己去加载该类。所以越基础的类由越上层的ClassLoader进行加载，但如果基础类又要调用回用户的代码，那该怎么办？

为了解决这个问题，Java设计团队只好引入了一个不太优雅的设计：Thread ContextClassLoader（线程上下文类加载器）。这个ClassLoader可以通过 java.lang.Thread 类的 setContextClassLoaser() 方法进行设置；
如果创建线程时没有设置，则它会从父线程中继承（详见 Thread 源码）；如果在应用程序的全局范围内都没有设置过的话，那这个类加载器默认为 AppClassLoader。

```java
/**
 * Returns the context {@code ClassLoader} for this thread. The context
 * {@code ClassLoader} is provided by the creator of the thread for use
 * by code running in this thread when loading classes and resources.
 * If not {@linkplain #setContextClassLoader set}, the default is the
 * {@code ClassLoader} context of the parent thread. The context
 * {@code ClassLoader} of the
 * primordial thread is typically set to the class loader used to load the
 * application.
 *
 *
 * @return  the context {@code ClassLoader} for this thread, or {@code null}
 *          indicating the system class loader (or, failing that, the
 *          bootstrap class loader)
 *
 * @throws  SecurityException
 *          if a security manager is present, and the caller's class loader
 *          is not {@code null} and is not the same as or an ancestor of the
 *          context class loader, and the caller does not have the
 *          {@link RuntimePermission}{@code ("getClassLoader")}
 *
 * @since 1.2
 */
@CallerSensitive
public ClassLoader getContextClassLoader() {
    if (contextClassLoader == null)
        return null;
    SecurityManager sm = System.getSecurityManager();
    if (sm != null) {
        ClassLoader.checkClassLoaderPermission(contextClassLoader, Reflection.getCallerClass());
    }
    return contextClassLoader;
}
```

## Default Class Loaders

> Class loaders load classes and resources present on their respective classpath:
>
> - System or application class loaders load classes from the application classpath
> - Extension class loaders search on the Extension classpath (JRE/lib/ext)
> - Bootstrap class loader looks on the Bootstrap classpath (JRE/lib/rt.jar)

Bootstrap或Primordial类装入器是所有类装入器的父类。它加载Java运行时——运行JVM本身所需的类。

当前的类加载器以线性、分层的方式搜索资源。如果类装入器无法定位一个类，它会向相应的子类装入器抛出java.lang.ClassNotFoundException异常。然后，子类装入器尝试搜索该类。

对于在层次结构中任何类装入器的类路径上都找不到所需资源的场景，我们将得到与java.lang.ClassNotFoundException相关的错误消息。

我们也可以自定义默认的类加载行为。我们可以在动态加载类时显式指定类装入器。

然而，我们应该注意到，如果我们从不同类型的类加载器加载相同的类，这些类将被JVM视为不同的资源。

## Context Class Loaders

除了默认的类装入器之外，J2SE还引入了上下文类装入器。

Java中的每个线程都有一个关联的上下文类加载器。

我们可以使用thread类的getContextClassLoader()和setContextClassLoader()方法访问/修改线程的上下文类装入器。

上下文类装入器在创建线程时设置。如果未显式设置，则默认为父线程的上下文类装入器。

上下文类加载器也遵循层次结构模型。在这种情况下，根类装入器是原始线程的上下文类装入器。原始线程是操作系统创建的初始线程。

当应用程序开始执行时，可能会创建其他线程。原始线程的上下文类装入器最初设置为装入应用程序的类装入器，即系统类装入器。

假设我们不为层次结构的任何级别的任何线程更新上下文类装入器。因此，我们可以说，默认情况下，线程的上下文类装入器与系统类装入器是相同的。对于这种情况，如果我们执行Thread.currentThread(). getcontextclassloader()和getClass(). getclassloader()操作，两者将返回相同的对象。
