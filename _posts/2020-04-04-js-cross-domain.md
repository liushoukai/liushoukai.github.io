---
layout: post
title:  跨域请求
categories: js
tags: cors
---

## 同源策略

定义：浏览器禁止从一个源上加载的脚本访问加载自另一个源文档属性
判定：如果两个URL的协议、域名、端口相同，则表示同源

## 跨域的充要条件

- 请求必须为ajax请求
- 请求中的Host与Origin不相同（违反同源策略）

以在 a.com 源页面请求 b.com 接口加载数据为例：

Origin: http://a.com ==> Host: b.com

浏览器会检查响应头中是否存在 Access-Control-Allow-Origin：http://a.com 的响应头，
表示服务器端 b.com 是否允许来自 http://a.com 的跨域请求，否则将拒绝加载服务器响应的数据。
可以通过抓包工具看到响应的数据包是完整的，仅是因为浏览器拒绝加载该数据包。

## 跨域请求类型

浏览器将CORS请求分成两类：简单请求（Simple requests）和预检查请求（Prefighted requests），浏览器对这两种类型的CORS请求的处理是不同的。其中，简单请求不会触发CORS prefight（跨域请求预检查）。

`简单请求（Simple requests）`

首先，请求方法必须为HEAD/POST/GET之一；其次，HTTP请求头除了包含浏览器自动设置的HTTP头之外，允许手工设置的HTTP头包括：Accept、Accept-Language、Content-Language、Last-Event-ID、Content-Type、DPR、Save-Data、Viewport-Width、Width；
其中Content-Type的值只能是application/x-www-form-urlencoded、multipart/form-data、text/plain其中之一；

`预检查请求 Prefighted requests`

对于跨域请求，Content-Type设置为"application/x-www-form-urlencoded","multipart/form-data, "text/plain"以外的任何内容，
均会触发浏览器发送一个OPTIONS类型的预先请求（Preflight Request）给服务器。
比如请求方法是 PUT 或 DELETE，或者 Content-Type 字段的类型是 application/json。
预检查请求首先会发送一个OPTIONS方法的请求，检查跨域请求的Origin是否在服务器的许可名单中，以及服务器支持的HTTP方法和HTTP请求头信息等。服务器检查了Origin、Access-Control-Request-Method、Access-Control-Request-Headers之后，确认允许跨域请求，就可以响应客户端允许发起跨域请求；

## Access-Control-Allow-*跨域

`Access-Control-Allow-Origin`
表示接受Origin为指定域名的跨域请求；

`Access-Control-Allow-Credentials `
默认情况下，服务端不允许跨域请求中携带Cookie信息，设置为true，表明服务器允许跨域请求中携带Cookie信息。必须配合前端在发起跨域请求时，设置xhr.withCredentials=true使用；

`Access-Control-Expose-Headers`
在跨域请求中，XMLHttpRequest对象的getResponseHeader()方法，默认只允许获取6个响应头：Content-Language、Content-Type、Expires、Last-Modified、Pragma；
如果想获取服务器其他的响应头信息，就必须在Access-Control-Expose-Headers中进行指定，前端即可通过xhr.getResponseHeader('xxx')获取相应的响应头信息；

## JSONP跨域

浏览器限制 Javascript 加载资源受到同源策略的限制，但浏览器允许`<script>、<img>、<iframe>、<link>`标签通过 src 属性加载资源而不受同源策略限制。

通过 `<script src="http://www.test.com/crossDomain?callback=JsFunctionName"></script>` 请求服务端，服务端返回调用JS函数JsFunctionName(data)的内容，
如此，前端只要在页面上有个`function JsFunctionName(data) { // TODO }`的JS方法定义，就可以实现跨域调用了。

```javascript
$.ajax({
    url: 'http://www.test.com/crossDomain',
    type: 'GET',
    dataType: 'jsonp',
    jsonpCallback: 'callback',
    cache: false,
    success: function(data) {
        console.info(data);
    }
});
```

## Nginx跨域配置

```shell
if ($http_origin ~ test.com) {
    add_header 'Access-Control-Allow-Origin'      "$http_origin";
    add_header 'Access-Control-Allow-Credentials' "true";
    add_header 'Access-Control-Allow-Methods'     "HEAD,GET,POST,OPTIONS,PUT,DELETE";
    add_header 'Access-Control-Allow-Headers'     "Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,X-Requested-With";
    add_header 'Access-Control-Expose-Headers'    "Accept-Ranges,Content-Encoding,Content-Length,Content-Range";
}
```

## withCredentials

不同域下的 XmlHttpRequest 相应，不论其 Access-Control-header 设置什么值，都无法为它自身站点设置cookie值，除非它在请求之前设置 withCredentials=true。
如果在发送来自其他域的XMLHttpRequest请求之前，未设置withCredentials=true，那么就不能为它自己的域设置cookie值。而通过设置withCredentials=true获得的第三方cookies，将会依旧享受同源策略，因此不能被通过document.cookie或者从头部相应请求的脚本等访问。

## 跨域请求过程

1、检查到Ajax请求头中的Origin与Host不一致，表明为跨域请求，会首先发送一个OPTIONS类型的请求至服务端，
通过服务端的响应头中包含的Access-Controll-Allow-*信息来决定是否能够发送对应的请求；

2、如果通过服务端的响应头中包含的Access-Controll-Allow-*信息允许跨域，则发送真正的请求到服务端；

## 参考资料

[http://www.ruanyifeng.com/blog/2016/04/cors.html](http://www.ruanyifeng.com/blog/2016/04/cors.html){:target="_blank"}

[https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS){:target="_blank"}
