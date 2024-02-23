---
layout: post
title: OpenLDAP配置
categories: linux
tags: openLDAP
---

## LDAP协议

`LDAP`是轻量目录访问协议，英文全称是`Lightweight Directory Access Protocol`，一般都简称为`LDAP`。`LDAP`是一个开放的，中立的，工业标准的应用协议，通过`IP`协议提供访问控制和维护分布式信息的目录信息。`OpenLDAP`使用`LMDB`数据库软件`LMDB`是基于`Btree-based`的高性能`mmap key-value`数据库，是在`BerkeleyDB`的基础上改进来的。
支持事务操作，支持多进程访问。只产生两个文件`data.mdb`与`lock.mdb`。

LDAP是一种通讯协议，LDAP连接服务器的连接字串格式为：`ldap://servername/DN`，其中`DN`的元素包含包含`UID/CN + OU + DC`。

|Name|Description|
| :---: | :---: |
|dc (Domain Component)          |域名的部分，其格式是将完整的域名分成几部分，如域名为`localdomain.com`变成`dc=localdomain,dc=com`。 |
|ou（Organization Unit）         |组织单位，组织单位可以包含其他各种对象(包括其他组织单元)。理解成公司的组织和单位：ou=Tech |
|uid（User Id）                  |用户ID Alex（一条记录的ID） |
|dn （Distinguished Name）       |每一个条目都有一个唯一的标识名，dn在ldap中全局唯一，相当于该条目的唯一ID。“uid=Alex,ou=Tech,dc=localdomain,dc=com”|
|cn （Common Name）              |名称，可用作分组的名字，或者用户的全名。如“Alex”（一条记录的名称）。简单理解用于描述UID的 |
|sn （Surname）                  |姓氏 |
|rdn（Relative dn）              |相对`DN`，一般指dn逗号最左边的部分，如`cn=group,dc=localdomain,dc=com`的`rdn`就是`cn=group`。|
|Base DN                        |LDAP目录树的最顶部就是根，比如上边示例中的`base dn`为`dc=localdomain,dc=net`。|
|description                    |在不同类别中，对应不同类别的说明信息，比如用户的说明信息，分组的说明信息。|

## 安装 OpenLDAP

OpenLDAP 是轻量级目录访问协议 (LDAP) 的软件实现。 OpenLDAP 是免费的开源软件，带有自己的 BSD 样式许可证，称为 OpenLDAP 公共许可证。它的命令行驱动器 LDAP 软件可用于大多数 Linux 发行版，例如 CentOS、Ubuntu、Debian、SUSE 等。 OpenLDAP 是用于 LDAP 服务器的完整软件套件，其中包括 SLAPD（独立 LDAP 守护进程）、SLURPD（独立 LDAP 更新复制守护进程）以及一些用于管理 LDAP 服务器的实用程序和工具。 OpenLDAP 是一个高度可定制的 LDAP 服务器，支持所有主要的计算平台。

### 设置 FQDN（完全限定域名）

在开始安装 OpenLDAP 服务器之前，需要确保 OpenLDAP 服务器的 FQDN（完全限定域名）配置正确。
在此演示中，我们将使用服务器主机名“ldap”和域“localdomain.com”以及 IP 地址“192.168.5.25”设置一个 OpenLDAP 服务器。

```shell
# 运行以下命令将 FQDN 设置为 ldap.localdomain.com
sudo hostnamectl set-hostname ldap.localdomain.com

# 使用以下命令编辑配置文件 /etc/hosts，添加配置如下
sudo vim /etc/hosts

10.211.56.3     ldap.localdomain.com ldap

最后，运行以下命令来检查和验证 LDAP 服务器的 FQDN。在此演示中，您应该得到诸如 ldap.localdomain.com 之类的输出。此外，如果您尝试对主机名 ldap 执行 ping 操作，您应该从服务器 IP 地址 192.168.5.25 而不是 localhost 获得响应。

sudo hostname -f
ping ldap
```

### 安装 OpenLDAP 包

在您拥有正确的 FQDN 之后，是时候安装默认情况下在 Ubuntu 存储库中可用的 OpenLDAP 包了。

```shell
在开始安装软件包之前，请运行下面的 apt 命令来更新和刷新您的 Ubuntu 系统存储库。

sudo apt update
现在使用以下命令安装 OpenLDAP 包。输入Y确认安装，回车，开始安装。

sudo apt install slapd ldap-utils
卸载命令：sudo apt -y autoremove --purge slapd ldap-utils

```

在安装 OpenLDAP 包期间，系统会要求您设置 OpenLDAP 的管理员密码。输入 OpenLDAP 管理员用户的强密码并选择“确定”，然后重复您的密码。并且 OpenLDAP 安装将完成。

### 配置 OpenLDAP 服务器

要开始配置 OpenLDAP 服务器，请运行以下命令。此命令将重新配置主 OpenLDAP 包“slapd”，您将被要求提供一些基本的 OpenLDAP 配置。

```shell
# 重新配置主 OpenLDAP 包“slapd”
sudo dpkg-reconfigure slapd

当询问“省略 OpenLDAP 服务器配置？”时，选择“否”。这将使用新配置文件和新数据库设置 OpenLDAP 服务器。
输入 OpenLDAP 安装的域名并选择“确定”。此域名将用作您的 OpenLDAP 服务器的 DN（专有名称）。


在此演示中，域名为“localdomain.com”，因此 DN 为“dc=localdomain,dc=com”。

输入将在 DN 中使用的组织名称。您可以为此使用域，但也可以使用其他名称。
```

输入
> The DNS domain name is used to construct the base DN of the LDAP directory. For example, 'foo.example.org' will create the directory with 'dc=foo, dc=example, dc=org' as base DN.
> DNS domain name: localdomain.com

输入组织名称
> Please enter the name of the organization to use in the base DN of your LDAP directory.
> Organization name: localdomain.com

```shell
# 重新配置 slapd 包后，使用以下命令编辑配置文件 /etc/ldap/ldap.conf。
sudo vim /etc/ldap/ldap.conf
```

![Alt text](/assets/img/WX20240124-165250@2x.png){:width="100%"}

```shell
现在运行以下命令以重新启动 slapd OpenLDAP 服务并在 OpenLDAP 服务器上应用新的更改。 
OpenLDAP 服务器现在使用基本 DN dc=localdomain,dc=com 运行。

sudo systemctl restart slapd
sudo systemctl status slapd
```

```shell
# 最后，运行以下命令来检查和验证 OpenLDAP 基本配置。
# 您应该将 OpenLDAP 服务器的基本 DN 作为 dc=localdomain,dc=com。
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:///
```

### 设置基本组

配置 OpenLDAP 服务器的基本 DN（可分辨名称）后，现在您将创建一个新的 OpenLDAP 用户基本组。
在此演示中，您将创建两个不同的基本组，名为“People”的组用于存储用户，然后名为“Groups”的组用于在 OpenLDAP 服务器上存储组。

要创建新的 LDAP 内容，例如用户和组，您可以使用 LDIF 文件（LDAP 数据交换格式）和 LDAP 工具“ldapadd”。

```shell
# 使用以下命令创建一个新的 LDIF 文件 base-groups.ldif。
sudo vim base-groups.ldif
```

文件内容如下：

```text
dn: ou=People,dc=localdomain,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=localdomain,dc=com
objectClass: organizationalUnit
ou: Groups
```

```shell
# 现在通过文件`base-groups.ldif`运行下面的命令到新的基础组。系统将提示您输入 OpenLDAP 管理员密码，因此请务必输入正确的密码。
sudo ldapadd -x -D cn=admin,dc=localdomain,dc=com -W -f base-groups.ldif


# 运行以下命令来检查和验证 OpenLDAP 服务器的基本组。您现在应该看到两个可用的基本组，名为“People”和“Groups”的组。
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:///
```

### 添加新组

在 LDAP 服务器上创建基本组后，现在您可以创建新的 LDAP 组和用户。在本节中，您将通过 LDIF 文件创建一个新组。

使用以下命令创建一个新的 LDIF 文件 group.ldif。

```shell

sudo vim group.ldif

# 将以下配置添加到文件中。在此示例中，我们将创建一个名为“developers”的新组，将其存储在基本组“Groups”中并定义 gidNumber 为“5000”。
dn: cn=developers,ou=Groups,dc=localdomain,dc=com
objectClass: posixGroup
cn: developers
gidNumber: 5000

# 接下来，运行下面的“ldapadd”命令以添加新的“developers”组。并确保输入 OpenLDAP 服务器的管理员密码。
sudo ldapadd -x -D cn=admin,dc=localdomain,dc=com -W -f group.ldif

最后，运行以下命令来检查和验证组 developers。您应该得到组 developers 的输出，它是 Groups 的一部分，gidNumber 为 5000。

sudo ldapsearch -x -LLL -b dc=localdomain,dc=com '(cn=developers)' gidNumber
```

### 添加用户

在 OpenLDAP 服务器上创建组后，就可以通过 LDIF 文件创建 LDAP 用户了。

在创建新用户之前，运行以下命令为新的 LDAP 用户生成加密密码。

```shell
% sudo slappasswd
New password: 123456
Re-enter new password: 123456
{SSHA}aWhfwqbiRht1fPG/vCtviKq50NRVYjyJ
```

现在使用以下命令创建一个新的 LDIF 文件 user.ldif。

```shell
sudo vim user.ldif
将以下配置添加到文件中。在此演示中，我们将使用默认主目录 /home/john 和默认 shell /bin/bash 创建一个新用户 john ”。此外，您可以在配置文件的顶部看到，该用户是组 People 的一部分，并使用 gidNumber 5000。

dn: uid=john,ou=People,dc=localdomain,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: john
sn: Doe
givenName: John
cn: John Doe
displayName: John Doe
uidNumber: 10000
gidNumber: 5000
userPassword: {SSHA}aWhfwqbiRht1fPG/vCtviKq50NRVYjyJ
gecos: John Doe
loginShell: /bin/bash
homeDirectory: /home/john
完成后保存并关闭文件。
```

接下来，运行下面的 ldapadd 命令在文件 user.ldif 中添加一个新用户。现在输入 OpenLDAP 服务器的管理员密码。

```shell
sudo ldapadd -x -D cn=admin,dc=localdomain,dc=com -W -f user.ldif
```

最后，运行下面的“ldapsearch”命令来检查和验证新的 LDAP 用户。您应该在 OpenLDAP 服务器上创建并使用用户 john。

```shell
sudo ldapsearch -x -LLL -b dc=localdomain,dc=com '(uid=john)' cn uidNumber gidNumber
```

## objectClass 分类

对象类是属性的集合，LDAP预想了很多人员组织机构中常见的对象，并将其封装成对象类。比如人员（person）含有姓（sn）、名（cn）、电话(telephoneNumber)、密码(userPassword)等属性，单位职工(organizationalPerson)是人员(person)的继承类，除了上述属性之外还含有职务（title）、邮政编码（postalCode）、通信地址(postalAddress)等属性。

* 结构型（structural）：如 person 和 oraganizationUnit
* 辅助型（auxiliary）：如 extensibleObject
* 抽象型（abstract）：如 top，抽象型的 objectClass 不能直接使用。

### 用户配置

```text
objectClass       inetOrgPerson
cn                user.Username
sn                user.Nickname
businessCategory  user.Departments
departmentNumber  user.Position
description       user.Introduction
displayName       user.Nickname
mail              user.Mail
employeeNumber    user.JobNumber
givenName         user.GivenName
postalAddress     user.PostalAddress
mobile            user.Mobile
uid               user.Username
userPassword      user.Password
```

### 分组配置

#### organizationalUnit

`organizationalUnit`必须项为`ou`，我们从基础概念中知道，`ou`是一个组织单位，组织单位可以包含其他各种对象(包括其他组织单元)。
所以这里`ou`的意义在于作为一个分组目录树的顶级组织，而非作为包含用户的实际分组。

```text
ou              g.GroupName
description     g.Remark
objectClass     {"organizationalUnit", "top"}
```

通过命令行创建一个organizationalUnit属性的条目：

```shell
cat << EOF | ldapadd -x -D "cn=admin,dc=localdomain,dc=com" -w 123456
dn: ou=group,dc=localdomain,dc=com
objectClass: organizationalUnit
ou: group
description: technology department
EOF
```

#### groupOfUniqueNames

```text
cn              g.GroupName
description     g.Remark
objectClass     {"groupOfUniqueNames", "top"}
```

可以看到必须项属性为cn，亦即此项`objectCLass`创建时必须包含属性`cn`，另外一项必须项为：`uniqueMember`。

```shell
cat << EOF | ldapadd -x -D "cn=admin,dc=localdomain,dc=com" -w 123456
dn: cn=yunweibu,ou=group,dc=localdomain,dc=com
objectClass: groupOfUniqueNames
cn: tech
description: technology department
uniqueMember: cn=admin,dc=localdomain,dc=com
EOF
```
