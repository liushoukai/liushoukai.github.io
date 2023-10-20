---
layout: post
title: git
categories: git
tags: git-command
---

## 类加载器

### Default Class Loaders

默认的类加载器加载各自类路径上的类和资源：

- AppClassLoader：应用类加载器搜索应用程序的类路径（classpath）加载类和资源；
- SystemClassLoader：扩展类加载器搜索扩展类路径（JRE/lib/ext）加载类和资源；
- BootstrapClassLoader：引导类装入器搜索引导类路径（JRE/lib/rt.jar）加载类和资源；

Bootstrap 或 Primordial 类加载器是所有类加载器的父类。它加载 Java 运行时，即运行JVM本身所需的类。

#### 默认类加载器加载机制

Java中的类加载机制是双亲委派模型，即按照 `AppClassLoader → SystemClassLoader → BootstrapClassLoader` 的顺序。

当前的类加载器以线性、分层的方式搜索资源。如果类加载器无法定位一个类，它会向相应的子类加载器抛出`java.lang.ClassNotFoundException`异常。
然后，由子类加载器捕获异常后，继续在其对应的类路径上尝试搜索该类，对于在层次结构中任何类加载器的类路径上都找不到所需资源的场景，
将得到与`java.lang.ClassNotFoundException`相关的错误消息。

双亲委派模型存在一个限制，即无法在父加载器中加载存在于子加载器类路径上的类和资源，无法实现类似SPI机制的需求。
为了解决这个问题，Java设计团队只好引入了一个不太优雅的设计：`Thread ContextClassLoader`（线程上下文类加载器）。
这个ClassLoader可以通过 `java.lang.Thread` 类的 `setContextClassLoaser()` 方法进行设置；
如果创建线程时没有设置，则它会从父线程中继承；如果在应用程序的全局范围内都没有设置过的话，那这个类加载器默认为 AppClassLoader。

### Context Class Loaders

JDBC是Java提出的一个有关数据库访问和操作的一个标准，也就是定义了一系列接口。不同的数据库厂商提供对该接口的实现，即提供的Driver驱动包。Java定义的JDBC接口位于JDK的rt.jar中（java.sql包），因此这些接口会由BootstrapClassLoader进行加载；而数据库厂商提供的Driver驱动包一般由我们自己在应用程序中引入（比如位于CLASSPATH下），这已经超出了BootstrapClassLoader的加载范围，即这些驱动包中的JDBC接口的实现类无法被BootstrapClassLoader加载，只能由AppClassLoader或自定义的ClassLoader来加载。

下面就查看下JDK中的DriverManager类的源码，核心步骤是静态初始化`loadInitialDrivers()`方法中加载初始JDBC驱动程序。
该方法通过调用`ServiceLoader.load(Class<S> service)`方法加载JDBC的Driver驱动程序。

```java
public class DriverManager {

    ...
    
    /**
     * Load the initial JDBC drivers by checking the System property
     * jdbc.properties and then use the {@code ServiceLoader} mechanism
     */
    static {
        loadInitialDrivers();
        println("JDBC DriverManager initialized");
    }

    ...
    
    private static void loadInitialDrivers() {
        String drivers;
        try {
            drivers = AccessController.doPrivileged(new PrivilegedAction<String>() {
                public String run() {
                    return System.getProperty("jdbc.drivers");
                }
            });
        } catch (Exception ex) {
            drivers = null;
        }
        // If the driver is packaged as a Service Provider, load it.
        // Get all the drivers through the classloader
        // exposed as a java.sql.Driver.class service.
        // ServiceLoader.load() replaces the sun.misc.Providers()

        AccessController.doPrivileged(new PrivilegedAction<Void>() {
            public Void run() {

                ServiceLoader<Driver> loadedDrivers = ServiceLoader.load(Driver.class);
                Iterator<Driver> driversIterator = loadedDrivers.iterator();

                /* Load these drivers, so that they can be instantiated.
                 * It may be the case that the driver class may not be there
                 * i.e. there may be a packaged driver with the service class
                 * as implementation of java.sql.Driver but the actual class
                 * may be missing. In that case a java.util.ServiceConfigurationError
                 * will be thrown at runtime by the VM trying to locate
                 * and load the service.
                 *
                 * Adding a try catch block to catch those runtime errors
                 * if driver not available in classpath but it's
                 * packaged as service and that service is there in classpath.
                 */
                try{
                    while(driversIterator.hasNext()) {
                        driversIterator.next();
                    }
                } catch(Throwable t) {
                // Do nothing
                }
                return null;
            }
        });

        println("DriverManager.initialize: jdbc.drivers = " + drivers);

        if (drivers == null || drivers.equals("")) {
            return;
        }
        String[] driversList = drivers.split(":");
        println("number of Drivers:" + driversList.length);
        for (String aDriver : driversList) {
            try {
                println("DriverManager.Initialize: loading " + aDriver);
                Class.forName(aDriver, true,
                        ClassLoader.getSystemClassLoader());
            } catch (Exception ex) {
                println("DriverManager.Initialize: load failed: " + ex);
            }
        }
    }
    ...
}
```

被调用的`ServiceLoader<S> load(Class<S> service)`方法内部使用到了`ContextClassLoader`，即上下文类加载器。

```java

public final class ServiceLoader<S> implements Iterable<S> {

    private static final String PREFIX = "META-INF/services/";
    ...
    /**
     * Creates a new service loader for the given service type, using the
     * current thread's {@linkplain java.lang.Thread#getContextClassLoader
     * context class loader}.
     *
     * <p> An invocation of this convenience method of the form
     *
     * <blockquote><pre>
     * ServiceLoader.load(<i>service</i>)</pre></blockquote>
     *
     * is equivalent to
     *
     * <blockquote><pre>
     * ServiceLoader.load(<i>service</i>,
     *                    Thread.currentThread().getContextClassLoader())</pre></blockquote>
     *
     * @param  <S> the class of the service type
     *
     * @param  service
     *         The interface or abstract class representing the service
     *
     * @return A new service loader
     */
    public static <S> ServiceLoader<S> load(Class<S> service) {
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        return ServiceLoader.load(service, cl);
    }
    ...
}
```

除了默认的类加载器之外，J2SE还引入了上下文类加载器。

Java中的每个线程都有一个关联的上下文类加载器。

我们可以使用thread类的`getContextClassLoader()`和`setContextClassLoader()`方法访问/修改线程的上下文类加载器。

上下文类加载器在创建线程时设置。如果未显式设置，则默认为父线程的上下文类加载器。

上下文类加载器也遵循层次结构模型。在这种情况下，根类加载器是原始线程的上下文类加载器。原始线程是操作系统创建的初始线程。

当应用程序开始执行时，可能会创建其他线程。原始线程的上下文类加载器最初设置为装入应用程序的类加载器，即系统类加载器。

假设我们不为层次结构的任何级别的任何线程更新上下文类加载器。因此，我们可以说，默认情况下，线程的上下文类加载器与系统类加载器是相同的。对于这种情况，如果我们执行`Thread.currentThread().getcontextclassloader()`和`getClass(). getclassloader()`操作，两者将返回相同的对象。
