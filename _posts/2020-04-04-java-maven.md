---
layout: post
title: Java构建工具Maven
categories: java
tags: java maven
---

## Maven 版本管理

mvnw 全名是 [Maven Wrapper](https://github.com/takari/maven-wrapper){:target="_blank"}，它的原理是在`maven-wrapper.properties`文件中记录你要使用的 Maven 版本。
当用户执行`mvnw clean`命令时，发现当前用户的 Maven 版本和期望的版本不一致，那么就下载期望的版本，然后使用用期望的版本来执行命令。

```shell
# 添加mvnw支持
mvn -N io.takari:maven:wrapper

# 切换Maven版本
mvn -N io.takari:maven:wrapper -Dmaven=3.3.9
```

## Maven 依赖范围

* 对于`<scope>compile</scope>`的情况，依赖在项目编译、测试，运行阶段有效；
* 对于`<scope>provided</scope>`的情况，依赖在项目编译、测试阶段有效，在运行阶段无效；
* 对于`<scope>test</scope>`的情况，依赖在项目测试阶段有效；

## Maven 继承机制

[http://maven.apache.org/pom.html#Inheritance](http://maven.apache.org/pom.html#Inheritance){:target="_blank"}

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

## 如何禁用 Maven 中央仓库

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

最佳实践是覆盖[Super POM of Maven](http://maven.apache.org/pom.html#The_Super_POM){:target="_blank"}中的默认配置，分别禁用依赖与插件的 Maven 中央仓库。

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

## Maven 属性

### 内置属性

Maven内置的属性；

* ${basedir} 项目根目录
* ${version} 项目版本号

### POM属性

通过project.为前缀，引用pom.xml文件中对应元素的值；
| 属性   | 含义 |
| :---: | :---:|
| ${project.build.sourceDirectory}       |项目源代码目录，默认为 src/main/java/   |
| ${project.build.sourceDirectory}       |项目源代码目录，默认为 src/main/java/ |
| ${project.build.testSourceDirectory}   |项目测试源代码目录，默认为 src/test/java/ |
| ${project.build.directory}             |项目构建输出目录，默认为 target/ |
| ${project.outputDirectory}             |项目代码编译输出目录，默认为 target/classes/ |
| ${project.testOutputDirectory}         |项目测试代码编译输出目录，默认为 target/test-classes/ |
| ${project.groupId}                     |项目的groupId |
| ${project.artifactId}                  |项目的artifactId |
| ${project.version}                     |项目的version，与${version}等价 |
| ${project.build.finalName}             |项目打包输出文件的名称，默认为${project.artifactId}-${project.version} |

### 自定义属性

用户在POM的`<properties>`元素下自定义的属性；
`<jdbc.url>jdbc:mysql://127.0.0.1:3306/test</jdbc.url>`

### Settings属性

通过settings.为前缀，引用settings.xml文件中对应元素的值；

* ${settings.localRepository} 用户本地仓库的地址；

### Java系统属性

引用jJava系统属性的值，可以通过mvn help:system查看所有的Java系统属性；

* ${user.home} 用户目录

### 环境变量属性

通过env.为前缀，引用系统环境变量的值，可以通过mvn help:system查看所有的环境变量的值；

* ${env.JAVA_HOME} 表示JAVA_HOME环境变量的值

## 资源过滤

Maven属性默认只有在POM中才会被解析，也就是说`${db.username}`放到POM中会变成test，
但是如果放到src/main/resources/目录下的文件中，构建的时候它将仍然还是${db.username}。

资源文件是由`maven-resources-plugin`插件处理的，默认的行为只是将src/main/resources/和src/test/resources/目录下的资源文件拷贝到对应的编译输出目录中；
因此，必须开启maven-resources-plugin的资源过滤规则，在拷贝资源文件时，会根据Maven属性对资源文件进行过滤，具体配置如下：

```xml
<resources>
    <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
    </resource>
</resources>
<testResources>
    <testResource>
        <directory>src/test/resources</directory>
        <filtering>true</filtering>
    </testResource>
</testResources>
```

注意⚠️：Spring Boot的spring-boot-starter-parent中，修改了默认的分隔符，因此，引用Maven属性，必须使用@jdbc.url@代替${jdbc.url}，详见：
[https://docs.spring.io/spring-boot/docs/current/reference/html/howto-properties-and-configuration.html](https://docs.spring.io/spring-boot/docs/current/reference/html/howto-properties-and-configuration.html){:target="_blank"}

## 利用maven-antrun-plugin插件输出Maven属性的值

执行mvn validate命令

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-antrun-plugin</artifactId>
    <version>1.7</version>
    <executions>
        <execution>
            <phase>validate</phase>
            <goals>
                <goal>run</goal>
            </goals>
            <configuration>
                <tasks>
                    <echo>Displaying value of properties</echo>
                    <echo>项目名称：${project.name}</echo>
                    <echo>项目版本：${project.version}</echo>
                    <echo>项目目录：${basedir}</echo>
                    <echo>项目构件时间：${maven.build.timestamp}</echo>
                    <echo>项目构建输出目录：${project.build.directory}</echo>
                    <echo>项目构建输出目录：${project.build.outputDirectory}</echo>
                    <echo>项目打包文件名称：${project.build.finalName}</echo>
                    <echo>项目打包文件类型：${project.packaging} </echo>
                    <echoproperties prefix="project"/>
                </tasks>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## Maven 常用命令

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

## 配置 Spring 依赖管理

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

## 参考资料

1.[https://stackoverflow.com/questions/4997219/disable-maven-central-repository](https://stackoverflow.com/questions/4997219/disable-maven-central-repository){:target="_blank"}
