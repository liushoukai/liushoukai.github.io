---
layout: post
title: Java构建工具Maven
categories: java
tags: java maven
---

### Maven 版本管理

---

mvnw 全名是 [Maven Wrapper][4]{:target="_blank"}，它的原理是在`maven-wrapper.properties`文件中记录你要使用的 Maven 版本。
当用户执行`mvnw clean`命令时，发现当前用户的 Maven 版本和期望的版本不一致，那么就下载期望的版本，然后使用用期望的版本来执行命令。

```shell
# 添加mvnw支持
mvn -N io.takari:maven:wrapper

# 切换Maven版本
mvn -N io.takari:maven:wrapper -Dmaven=3.3.9
```

---

### Maven 依赖范围

---

* 对于`<scope>compile</scope>`的情况，依赖在项目编译、测试，运行阶段有效；
* 对于`<scope>provided</scope>`的情况，依赖在项目编译、测试阶段有效，在运行阶段无效；
* 对于`<scope>test</scope>`的情况，依赖在项目测试阶段有效；

---

### Maven 继承机制

---

[http://maven.apache.org/pom.html#Inheritance][1]{:target="_blank"}

利用`mvn help:effective-pom`命令可以查看子POM中实际生效的文件。

通过继承父POM配置，可以继承的元素包括：

* groupId
* version
* description
* url
* inceptionYear
* organization
* licenses
* developers
* contributors
* mailingLists
* scm
* issueManagement
* ciManagement
* properties
* dependencyManagement
* dependencies
* repositories
* pluginRepositories
* build(plugin executions with matching ids, plugin configuration, etc.)
* reporting
* profiles

注意⚠️：无法通过继承获取的元素包括：`artifactId`,`name`,`prerequisites`。

---

### 如何禁用 Maven 中央仓库

---

使用Nexus私有仓库时候，需要禁用Maven中央仓库。

不建议在`settings.xml`中设置`<mirrorOf>*</mirrorOf>`全局代理配置，全局代理配置适用于已定义的仓库。除非用户显示覆盖，它将取代但不会隐藏内置的Maven中央仓库和快照仓库。它定义了一个粗粒度的代理规则，该规则不区分release和snapshot，并且依靠代理到的镜像仓库来执行此分辨过滤。

```xml
<mirrors>
    <mirror>
      <id>artifactory</id>
      <mirrorOf>*</mirrorOf>
      <url>http://[host]:[port]/artifactory/repo</url>
      <name>Artifactory</name>
    </mirror>
</mirrors>
```

最佳实践是覆盖[Super POM of Maven][3]{:target="_blank"}中的默认配置，分别禁用依赖与插件的 Maven 中央仓库。

```xml
<repositories>
    <repository>
        <id>central</id>
        <url>http://repo1.maven.org/maven2</url>
        <releases>
            <enabled>false</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </repository>
</repositories>
<pluginRepositories>
    <pluginRepository>
        <id>central</id>
        <url>http://repo1.maven.org/maven2</url>
        <releases>
            <enabled>false</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </pluginRepository>
</pluginRepositories>
```

---

### Maven 常用命令

---

```shell
# 打印出项目依赖的树状图
mvn dependency:tree -Dverbose
mvn dependency:analyze

# 查看插件的描述信息
mvn -Dplugin=install help:describe

# 忽略javadoc
mvn install -Dmaven.javadoc.skip=true

# 生成测试覆盖率报告
mvn cobertura:cobertura

# 动态指定测试用例
mvn test -Dtest=CalFa*toryTest,StrategyContextTest

# 编译自模块模块及其依赖的子模块并且不编译单元测试代码
mvn clean install -pl sub-module-name --am -Dmaven.test.skip=true

# 忽略单元测试
mvn install -DskipTests            // 编译但不执行单元测试代码
mvn install -Dmaven.test.skip=true // 不编译不执行单元测试代码

# 指定编码格式
mvn install -Dfile.encoding=UTF-8

# 复制依赖的jar到工程目录下的lib里面
mvn dependency:copy-dependencies -DoutputDirectory=C:/lib -DincludeScope=compile

-pl  指定构建项目的列表，通过artifactId指定具体的项目
-am  构建-pl列表指定的项目及其依赖的项目
-amd 构建-pl列表执行的项目以及依赖它们的项目
-e   输出执行错误信息
-U   强制检查更新
-B   在批处理中以非交互的模式运行
-V   在构建的时显示Maven版本信息
-P   指定要激活的profile
```

---

### Spring 依赖配置

---

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.3.7.RELEASE</version>
    <relativePath/> <!-- lookup parent from repository -->
</parent>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>Hoxton.SR9</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

---

### 参考资料

---

1.[https://stackoverflow.com/questions/4997219/disable-maven-central-repository][2]{:target="_blank"}

[1]:http://maven.apache.org/pom.html#Inheritance
[2]:https://stackoverflow.com/questions/4997219/disable-maven-central-repository
[3]:http://maven.apache.org/pom.html#The_Super_POM
[4]:https://github.com/takari/maven-wrapper
