---
layout: post
title: 苹果内购
categories: payment
tags: iap
---

## 苹果内购JWS回调解析

## JWS简介

JWS 也就是 Json Web Signature，是构造 JWT 的基础结构（JWT 其实涵盖了 JWS 和 JWE 两类，其中 JWT 的载荷还可以是嵌套的 JWT），包括三部分 JOSE Header、JWS Payload、JWS Signature。
这里的 Signature 可以有两种生成方式，一种是标准的签名，使用非对称加密，因为私钥的保密性，能够确认签名的主体，同时能保护完整性；另一种是消息认证码 MAC（Message Authentication Code），使用对称秘钥，该秘钥需要在签发、验证的多个主体间共享，因此无法确认签发的主体，只能起到保护完整性的作用。

JWS 最终有两种序列化的表现形式，一种是 `JWS Compact Serialization` 为一串字符；另一种是 `JWS JSON Serialization`，是一个标准的 Json 对象，允许为同样的内容生成多个签名/消息认证码。

<div class="mermaid">
mindmap
JWS
  id[JWS Compact Serialization]
    id["base64url (utf8(Protected Header))"]
    id["base64url(Payload)"]
    id["base64url(Signature = ASCII(BASE64URL(UTF8(JWS Protected Header)) ||'
|| BASE64URL(JWS Payload)))."]
  id[JWS Json Serialization]
    id["通用格式"]
      id["payload"]
        id["base64url(Payload)"]
      id["Signatures"]
        id["protected • base64url(utf8(Protected Header))"]
        id["header • Unprotected Header"]
        id["signature • base64url(Signature)"]
    id["扁平格式"]
      id["payload • base64url(Payload)"]
      id["protected • base64url(utf8(Protected Header))"]
      id["header • Unprotected Header"]
      id["signature • base64url(Signature)"]
</div>

### JWS Compact Serialization

JWS Compact Serialization，各部分以 ‘.’ 分隔。

1. BASE64URL(UTF8(JWS Protected Header)) || ’.’ ||
2. BASE64URL(JWS Payload) || ’.’ ||
3. BASE64URL(JWS Signature)

### JWS Json Serialization

JWS Json Serialization 还可以分为两种子格式：通用、扁平。
通用格式，最外层为 payload、signatures。signatures 中可以包含多个 json 对象，内层的 json 对象由 protected、header、signature 组成。不同的 protected header 生成不同的 Signature。

```json
{
  "payload": "<payload contents>",
  "signatures": [
    {
      "protected": "<integrity-protected header 1 contents>",
      "header": "<non-integrity-protected header 1 contents>",
      "signature": "<signature 1 contents>"
    },
    {
      "protected": "<integrity-protected header N contents>",
      "header": "<non-integrity-protected header 1 contents>",
      "signature": "<signature N contents>"
    }
    ......
  ]
}
```
扁平格式，就是为只有一个 signature/mac 准备的。
```json
{
  "payload": "<payload contents>",
  "protected": "<integrity-protected header contents>",
  "header": "<non-integrity-protected header contents>",
  "signature": "<signature contents>"
}
```

## 解析苹果JWS
```php
array:2 [
  "alg" => "ES256"      // 加密算法
  "x5c" => array:3 [    // 证书链 用于链状证书验证
    0 => "..."
    1 => "..."
    2 => "..."
  ]
]
```

## PEM格式证书

- 以“-----BEGIN CERTIFICATE-----”开头，以“-----END CERTIFICATE-----”结尾。
- 每行64个字符，最后一行可以不足64个字符。

Root CA机构颁发的证书
Root CA机构颁发的证书是唯一的，

苹果推送通知服务(Apple Push Notification Service)

## APNS .p8 file

The APNS(Apple Push Notification service) .p8 file contains the PRIVATE KEY that is used to SIGN the JWT content for APNS messages. The file itself is a pure text file, the KEY inside is formatted in PEM format.

The part between the -----BEGIN PRIVATE KEY----- and -----END PRIVATE KEY----- is a base64 formatted ASN.1 PKCS#8 representation of the key itself. Some can use the following web service to extract its contents (ASN1JS).

The KEY itself is 32 bytes long and is used to create the required ECDSA P-256 SHA-256 signature for the JWT. The resulting JWT looks like this '{JWT header base64 encoded}.{JWT payload base64 encoded}.Signature (64 bytes) base64 encoded'.

## Apple证书链

[Apple PKI](https://www.apple.com/certificateauthority/)

> Apple established the Apple PKI in support of the generation, issuance, distribution, revocation, administration, and management of public/private cryptographic keys that are contained in CA-signed X.509 Certificates.

Apple Root Certificates

- Apple Inc. Root
- Apple Computer, Inc. Root
- Apple Root CA - G2 Root
- Apple Root CA - G3 Root

苹果内购 `Apple Root CA - G3 Root` 根证书，下载地址：https://www.apple.com/certificateauthority/AppleRootCA-G3.cer

### AppleRootCA-G3.cer

```shell
issuer:  C=US, O=Apple Inc., OU=Apple Certification Authority, CN=Apple Root CA - G3
subject: C=US, O=Apple Inc., OU=Apple Certification Authority, CN=Apple Root CA - G3
pubKey:  Sun EC public key, 384 bits
  public x coord: 23535137990511115290421369951508534764305243260700707065735329521932707611771784158809154958913304282614187028787810
  public y coord: 14435405095334351309981717949121872711414646696567254157082218517768066483720066805545864120603492238635892368017969
  parameters: secp384r1 [NIST P-384] (1.3.132.0.34)
```

### Certificate Chain

```shell
0 
issuer:  C=US, O=Apple Inc., OU=G6, CN=Apple Worldwide Developer Relations Certification Authority
subject: C=US, O=Apple Inc., OU=Apple Worldwide Developer Relations, CN=Prod ECC Mac App Store and iTunes Store Receipt Signing
pubKey:  Sun EC public key, 256 bits
  public x coord: 105875560977760573362704110707492312876530985252752365448456824391931601077884
  public y coord: 81749158525854997483881028932228477086426192359215335142104399760668517099460
  parameters: secp256r1 [NIST P-256, X9.62 prime256v1] (1.2.840.10045.3.1.7)

1 
issuer:  C=US, O=Apple Inc., OU=Apple Certification Authority, CN=Apple Root CA - G3
subject: C=US, O=Apple Inc., OU=G6, CN=Apple Worldwide Developer Relations Certification Authority
pubKey:  Sun EC public key, 384 bits
  public x coord: 17048413604444047897729297844786556286654967349496789252465404257044270063863748188441962701023444208613540952382975
  public y coord: 27501656975681196006443512326510273450537524051640261912027524398123377119526819560606757859181150143046868151704136
  parameters: secp384r1 [NIST P-384] (1.3.132.0.34)

2 
issuer:  C=US, O=Apple Inc., OU=Apple Certification Authority, CN=Apple Root CA - G3
subject: C=US, O=Apple Inc., OU=Apple Certification Authority, CN=Apple Root CA - G3
pubKey:  Sun EC public key, 384 bits
  public x coord: 23535137990511115290421369951508534764305243260700707065735329521932707611771784158809154958913304282614187028787810
  public y coord: 14435405095334351309981717949121872711414646696567254157082218517768066483720066805545864120603492238635892368017969
  parameters: secp384r1 [NIST P-384] (1.3.132.0.34)
```
