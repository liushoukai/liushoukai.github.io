---
layout: post
title: keytool
categories: linux
tags: keytool
---

## cacerts 密钥库

任何Java开发人员都知道Java密钥库(Java Keystores)的默认密码是`changeit`。如果您希望将密钥存储库文件包与Java一起使用(我们不推荐这样做)，请将其更改为强密码。

```shell
# 查看密钥库中的证书
keytool -list -keystore lib/security/cacerts -storepass changeit | grep 'charles' --color

charles-20240112123015, 2024年1月12日, trustedCertEntry,

# 移除密钥库中的证书
keytool -delete -alias charles-20240112123021 -keystore lib/security/cacerts -storepass changeit

```
