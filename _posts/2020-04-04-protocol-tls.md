---
layout: post
title: SSL/TLS协议运行机制
categories: protocol
tags: tcp
---

### SSL（Secure Socket Layer）

---

HTTP 协议在传输数据时存在的问题：

* 窃听风险（eavesdropping）：HTTP在网络传输过程中使用的是明文传输，存在传输过程中被窃听的风险。
* 篡改风险（tampering）：传输的数据可能被劫持，存在内容被篡改的风险。
* 冒充风险（pretending）：

`为了解决 HTTP 协议在传输数据时使用明文的安全性问题，网景公司（Netscape）提出了 SSL 安全套接字协议层的解决方案。`

SSL（Secure Socket Layer） 安全套接层是介于 HTTP 与 TCP 协议间的一个协议层，是基于 HTTP 标准并对 TCP 传输数据时进行加密，所以 HPPTS 是 HTTP+SSL/TCP 的简称。

---

### SSL Handshake

---

![protocol-tls](/assets/img/protocol-tls.drawio.png){:width="100%"}

---

### SSL 数字证书

---

数字证书解决了什么问题?

由于直接使用公钥存在中间人攻击，因此必须对公钥进行认证，以确保公钥来自目标服务器。与直接使用公钥不同，数字证书中包含了服务器的名称、主机名、公钥、证书签名颁发机构的名称以及来自签名颁发机构的签名。为了得到数字证书，需要通过私钥生成 CSR 证书签名请求文件，CA(Certificate Authority，数字证书认证中心)即权威的数字证书颁发机构将通过 CSR 生成对应的数字证书 CRT。

SSL证书认证分两种形式:

* 一种是DV（Domain Validated）需要验证域名；
* 一种是OV（Organization Validated）需要验证域名\组织或公司；

SSL证书申请信息描述

{:class="table table-striped table-bordered table-hover"}
| Field | Meaning             | 含义      | 示例1            | 示例2                |
| ----- | ------------------- | -------- | --------------- | -------------------- |
| /C=   | Country             | 国家      | GB              | CN                   |
| /ST=  | State               | 省份      | London          | GUANGDONG            |
| /L=   | Location            | 城市      | London          | SHENZHEN             |
| /O=   | Organization        | 公司或组织 | Global Security | Tenpay.com Root CA   |
| /OU=  | Organizational Unit | 部门      | IT Department   | Tenpay.com CA Center |
| /CN=  | Common Name         | 域名      | example.com/    | tenpay.com           |

---

#### 证书申请流程

---

1、生成私钥和CSR(Certificate Signing Request)证书签名请求文件

```shell
# 注意⚠️：现在的第三方 SSL 证书签发机构 CA 都要求至少2048位 RSA 加密的私钥
openssl req -nodes -newkey rsa:2048 -sha256 -keyout ponderers.key -out ponderers.csr -subj "/C=CN/ST=Guangdong/L=Guangzhou/O=ponderers.org/OU=Ponderers Trust Network /CN=ponderers.org/emailAddress=ponderers@qq.com"
```

2、将 CSR 信息提交给 CA 证书签发机构，当你的域名/组织通过认证审核后，认证机构就会颁发给你一个数字证书：ponderers_com.crt。该证书内包含组织/企业的信息和公钥，同时还附有 CA 证书颁发机构的签名信息。

---

#### 自签名证书(self-signed certificate)

---

```shell
# 生成私钥
openssl genrsa -out key.pem 2048
# 生成CSR
openssl req -new -key key.pem -out csr.pem
# 签名证书
openssl x509 -req -in csr.pem -signkey key.pem -out cert.pem
# 模拟请求
openssl s_client -connect 127.0.0.1:8000
```

---

#### CA bundle

---

CA bundle is a file that contains root and intermediate certificates.

The server does not support Forward Secrecy with the reference browsers

注意⚠️：nginx在设置证书文件时只能使用相对路径，根目录为/usr/local/nginx/conf/。最好是创建一个软链处理证书目录：ln -s /data/config/pem /usr/local/nginx/conf/pem
