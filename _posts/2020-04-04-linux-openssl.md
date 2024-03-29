---
layout: post
title: OPENSSL自签名证书
categories: linux
tags: openssl
---

## 使用openssl生成sha256自签名证书

### 生成 RSA 密钥对

```shell
openssl genrsa -out ca.key 2048
# 若想对私钥进行加密可以加上 -des3 参数
```

## 生成 ca crt

```shell
openssl req -new -x509 -days 365 -key ca.key -out ca.crt

You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter ‘.’, the field will be left blank.
Country Name (2 letter code) [XX]:CN # 国家代码
State or Province Name (full name) []:XX # 省份
Locality Name (eg, city) [Default City]:XX # 城市
Organization Name (eg, company) [Default Company Ltd]:XX # 组织名称
Organizational Unit Name (eg, section) []:XX # 组织单元名称
Common Name (eg, your name or your server’s hostname) []:XX # 由此ca签的证书颁发者名
Email Address []:xxx@xxx.com #使用者的邮箱
```

## 站点证书的生成

### 生成证书的RSA密钥

```shell
openssl genrsa -out xxx.key 2048
# 生成csr证书（假设需要签SSL证书的域名为: yoursafe.cn）：
```

```shell
openssl req -new -key xxx.key -subj "/C=CN/ST=XX/L=XX/O=Tenpay.com/OU=Tenpay.com CA Center/CN=Tenpay.com Root CA" -sha256 -out xxx.csr
# 注：中间的参数请参考上方，使用 -subj 可以简化一些证书信息的录入过程，使用 -sha256 将采用sha256加密，openssl默认采用sha1加密，而现代已将 sha1 加密方式认定为非安全，故使用sha2。
```

### 检查 csr 的正确性：

检查 Signature Algorithm 是不是 `Signature Algorithm: sha256WithRSAEncryption`。

```shell
openssl req -in xxx.csr -text
```

利用 csr 生成 crt

```shell
openssl x509 -req -days 365 -in xxx.csr -CA ca.crt -CAkey ca.key -sha256 -out xxx.crt
```

检查 Signature Algorithm 是不是 `Signature Algorithm: sha256WithRSAEncryption`。

```shell
openssl x509 -in xxx.crt -text
```
