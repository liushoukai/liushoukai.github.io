---
layout: post
title: 苹果内购
categories: payment
tags: iap
---


# PEM格式证书

- 以“-----BEGIN CERTIFICATE-----”开头，以“-----END CERTIFICATE-----”结尾。
- 每行64个字符，最后一行可以不足64个字符。

Root CA机构颁发的证书
Root CA机构颁发的证书是唯一的，


苹果推送通知服务(Apple Push Notification Service)


# APNS .p8 file
The APNS(Apple Push Notification service) .p8 file contains the PRIVATE KEY that is used to SIGN the JWT content for APNS messages. The file itself is a pure text file, the KEY inside is formatted in PEM format.

The part between the -----BEGIN PRIVATE KEY----- and -----END PRIVATE KEY----- is a base64 formatted ASN.1 PKCS#8 representation of the key itself. Some can use the following web service to extract its contents (ASN1JS).

The KEY itself is 32 bytes long and is used to create the required ECDSA P-256 SHA-256 signature for the JWT. The resulting JWT looks like this '{JWT header base64 encoded}.{JWT payload base64 encoded}.Signature (64 bytes) base64 encoded'.

# Apple证书链

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
