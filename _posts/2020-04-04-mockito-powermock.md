---
layout: post
title: 单元测试之Mockito与Powermock
categories: unit-test
tags: java unit-test
---

### 依赖引入

---

```java
testCompile group: 'org.mockito', name: 'mockito-core', version: '3.1.0'
testCompile group: 'org.powermock', name: 'powermock-module-junit4', version: '2.0.4'
testCompile group: 'org.powermock', name: 'powermock-api-mockito2', version: '2.0.4'
```

---

### 注解解释

---

* @Mock
* @Spy（监视真实的对象）
* @Captor（参数捕获器）
* @InjectMocks（mock对象自动注入）

---

### Mockito初始化工作

---

```java
// 通过编码初始化Mockito环境
@Before
public void before() {
    MockitoAnnotations.initMocks(this);
}

// 通过注解初始化Mockito环境
@RunWith(MockitoJUnit44Runner.class)  
public class ExampleTest {

}
```

---

### Mockvoid方法

---

基本上对于`void`返回值的方法一般可不用去`mock`它，只需用`verify()`去验证，或者就是像前面一样模拟出现异常时的情况。

```java
doNothing().when(mockObject).methodWithVoidReturn();
doThrow(new RuntimeException()).when(mockObject).methodWithVoidReturn();
```

Mock @PostConstruct注解
Because PostConstruct is only spring concept. But you can call postConstruct manually.
@Before
public void prepare() {
    MockitoAnnotations.initMocks(this);
    this.service.init(); //your Injected bean
}

---

### Mock成员变量

---

```java
Whitebox.setInternalState(underTest, "person", mockedPerson);
```

---

### Mock静态方法

---

```java
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
  }
}
```
