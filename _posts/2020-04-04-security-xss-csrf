---
layout: post
title: 安全
categories: security
tags: xss csrf sql-injection
---

## XSS（跨站脚本攻击）

利用网页开发时留下的漏洞，将恶意指令代码注入到网页，使用户加载并执行攻击者恶意制造的网页程序。

`反射式XSS`

反射式XSS(非存储式XSS)，诱骗用户点击URL带攻击代码的链接，服务器解析后响应，在返回的响应内容中隐藏和嵌入攻击者的XSS代码。
用户访问安全网站时，Web客户端使用Server端脚本生成页面为用户提供数据时，如果未经验证的用户数据被包含在页面中而未经HTML实体编码，客户端代码便能够注入到动态页面中。

攻击过程
1. Alice经常浏览某个网站，此网站为Bob所拥有。Bob的站点运行Alice使用用户名/密码进行登录，并存储敏感信息(比如银行帐户信息)。
2. Charly发现Bob的站点包含反射性的XSS漏洞。
3. Charly编写一个利用漏洞的URL，并将其冒充为来自Bob的邮件发送给Alice。
4. Alice在登录到Bob的站点后，浏览Charly提供的URL。
5. 嵌入到URL中的恶意脚本在Alice的浏览器中执行，就像它直接来自Bob的服务器一样。此脚本盗窃敏感信息(授权、信用卡、帐号信息等)然后在Alice完全不知情的情况下将这些信息发送到Charly的Web站点。



`存储式XSS`

该类型是应用最为广泛而且有可能影响到Web服务器自身安全的漏洞，骇客将攻击脚本上传到Web服务器上，使得所有访问该页面的用户都面临信息泄漏的可能，其中也包括了Web服务器的管理员。

攻击过程
1. Bob拥有一个Web站点，该站点允许用户发布信息/浏览已发布的信息。
2. Charly注意到Bob的站点具有存储式的XSS漏洞。
3. Charly发布一个热点信息，吸引其它用户纷纷阅读。
4. Bob或者是任何的其他人如Alice浏览该信息，其会话cookies或者其它信息将被Charly盗走。


## CSRF

CSRF(Cross Site Request Forgery) 跨站域请求伪造

HTTP Referer 记录HTTP请求的来源地址，值由浏览器提供
服务端检查Http Referer是否在域名白名单中

1.低版本浏览器Referer存在被篡改的漏洞
2.为保护个人隐私部分浏览器在发送请求时不再提供Referer

1.服务器接受到请求，如果用户已登录，将ukey=随机字符串写入cookie
2.客户端从cookie中获取到的ukey,使用hash算法生成csrf_token
3.客户端将csrf_token代入发送到服务器的请求中
4.服务器判断是否为用户登录态下发起的POST
5.读取ukey后根据相同的hash算法生成csrf_token并将其与请求中的token进行比较

为什么读取操作不需要csrf_token?
1.如果查询请求是异步的，必定跨域
2.如果查询请求是同步的，页面跳转
上述两种情形恶意站点脚本都无法获取服务器的响应信息