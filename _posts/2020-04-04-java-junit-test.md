---
layout: post
title: Java单元测试
categories: java
tags: java junit mockito powermock
---

### 拆分单元与集成

问题1：单元测试用例与集成测试用例的区别是什么？

单元测试不依赖上下文环境，集成测试依赖上下文环境，比如依赖Spring的容器环境、数据库、缓存等。

问题2：为什么要拆分单元测试用例与集成测试用例？

- 代码组织：为了避免在开发或调试过程中浪费时间，有必要将单元测试从集成测试中区分出来。
- 依赖框架：根据定义，单元测试不需要运行任何框架容器（JDK和JUnit应该足够），集成测试需要运行时所需的所有框架，这极大增加了编译时间。
- 依赖环境：集成测试依赖外部工具（数据库，外部API等），从集成测试中拆分单元可以使编译时间更短，并尽可能快地运行测试。

[拆分单元测试与集成测试][1]{:target="_blank"}

### 单元测试 Mock

使用 Mock 框架 Mockito、Powermock。

```shell
// 依赖管理
testCompile group: 'org.mockito', name: 'mockito-core', version: '3.1.0'
testCompile group: 'org.powermock', name: 'powermock-module-junit4', version: '2.0.4'
testCompile group: 'org.powermock', name: 'powermock-api-mockito2', version: '2.0.4'
```

---

#### Mockito 框架初始化

```java
// 通过注解的方式初始化Mockito环境
@Before
public void before() {
    MockitoAnnotations.initMocks(this);
}
// 通过编码的方式初始化Mockito环境
@RunWith(MockitoJUnit44Runner.class)  
public class ExampleTest {}
```

---

#### Mock void方法

对于 void 返回值的方法，一般可不用去 mock 它，只需用 verify() 去验证，或者模拟出现异常时的情况。

```java
doNothing().when(mockObject).methodWithVoidReturn();
doThrow(new RuntimeException()).when(mockObject).methodWithVoidReturn();
```

---

#### Mock Spring注解

由于`@PostConstruct`是专属于Spring框架的概念，只能手工调用。

```java
@Before
public void prepare() {
    MockitoAnnotations.initMocks(this);
    this.service.init(); //your Injected bean
}
```

---

#### Mock成员变量

```java
Whitebox.setInternalState(underTest, "person", mockedPerson);
```

---

#### Mock静态方法

Mock静态方法的时候，需要使用Powermock框架，Powermock在Mockito框架的基础上，支持Mock静态方法。

```java
@Slf4j
@RunWith(PowerMockRunner.class)
@PowerMockIgnore("javax.net.ssl.*")
@PrepareForTest({ DriverManager.class })
public class Mocker {
  @Test
  public void shouldVerifyParameters() throws Exception {
      //given
      PowerMockito.mockStatic(DriverManager.class);
      BDDMockito.given(DriverManager.getConnection(...)).willReturn(...);
      //when
      sut.execute(); // System Under Test (sut)
      //then
      PowerMockito.verifyStatic();
      DriverManager.getConnection(...);
  }
}
```

---

### 用例的执行顺序

---

JUnit是通过`@FixMethodOrder`注解来控制测试方法的执行顺序的。`@FixMethodOrder`注解的参数是`org.junit.runners.MethodSorters`对象在枚举类`org.junit.runners.MethodSorters`中定义了如下三种顺序类型：

#### MethodSorters.DEFAULT(默认的顺序，以确定但不可预期的顺序执行)

Sorts the test methods in a deterministic, but not predictable, order.

#### MethodSorters.JVM（按照JVM得到的方法顺序，也就是代码中定义的方法顺序）

Leaves the test methods in the order returned by the JVM. Note that the order from the JVM may vary from run to run.

#### MethodSorters.NAME_ASCENDING（按方法名字母顺序执行）

Sorts the test methods by the method name, in lexicographic order, with Method.toString() used as a tiebreaker.

---

### 单测的超时时间

---

问题：为什么要关注测试用例的执行的超时时间？

由于在做自动化持续集成的时候，发现很多项目的集成测试用例由于环境问题，导致执行的时候无限调用等待的情况，最终导致持续集成在跑集成用例的环节卡死，占用资源而无法释放需要人工介入处理。

在编写单元测试的时候，设定单元测试与集成测试的超时时间。

```java
// 设置所有方法执行的超时时间
@ClassRule
public static Timeout globalTimeout = Timeout.seconds(30);
// 设置每个方法执行的超时时间
@Rule
public Timeout methodTimeout = Timeout.seconds(30);
```

---

### 单元测试覆盖率

- jacoco

---

### 集成测试

---

SpringRunner继承自SpringJUnit4ClassRunner，其只是SpringJUnit4ClassRunner的一个别名类。

JUnit的测试用例总是由Runner去执行，JUnit提供`@RunWith`注解用于指定Runner，如果未指定特别的Runner，那么会采用默认的Runner。
因此，`@RunWith(SpringJUnit4ClassRunner.class)`是由Spring定义的Runner，用于加载Spring的配置文件以及与Spring相关的事物。

```java
@SpringBootTest
@RunWith(SpringRunner.class)
public class ApplicationTest {}
```

那么自定义的Runner有什么用呢？它可以截获到@BeforeClass, @AfterClass, @Before, @After这些事件，也就是能在测试类开始和结束执行前后，每个测试方法的执行前后处理点事情。

[编写JUnit4自定义Runner][1]{:target="_blank"}

### 参考资料

---

- [https://blog.worldline.tech/2020/04/10/split-unit-and-integration-tests.html][1]{:target="_blank"}
- [https://yanbin.blog/extend-junit-4-customized-runner/][2]{:target="_blank"}

[1]:https://blog.worldline.tech/2020/04/10/split-unit-and-integration-tests.html
[2]:https://yanbin.blog/extend-junit-4-customized-runner/
