---
layout: post
title: iOS内购流程
categories: iOS
tags: iOS IAP
---

### iOS内购支付模式
两种模式主要的不同之处在于对 AppStore 返回的付款凭证（receipt）的验证方式。

* 内置模式：使用APP客户端验证付款凭证（receipt），简单快捷，但容易被破解。主要适用于类似非联网APP应用内购，比如旅行青蛙中游戏道具购买。

* 服务器模式：使用服务端验证付款凭证（receipt），流程相对复杂，但相对安全性更高，主要适用于联网APP应用的内购，比如直播APP中虚拟货币的充值购买。

#### 内置模式流程
1. APP 从服务器获取产品标识列表
2. APP 从 AppStore 获取产品信息
3. 用户选择需要购买的产品
4. APP 发送支付请求到 AppStore
5. AppStore 处理支付请求，用户完成支付后，AppStore 返回付款收据 (receipt) 给APP
6. APP 验证返回的付款收据(receipt)，判定用户是否付款成功并提供对应的服务

#### 服务器模式
<div class="mermaid">
sequenceDiagram
	participant StoreKit as StoreKit
	participant App as iPhone
	participant Server
	participant AppStore
	App->>+Server: 1.获取业务订单号
	Server-->>-App: 2.返回业务订单号

	rect rgba(0, 0, 255, .1)
	Note over App,StoreKit: 苹果支付
	App->>+StoreKit: 3.请求商品信息（productId)
	StoreKit-->>App: 4.返回商品信息
	App->>StoreKit: 5.加入交易队列
	StoreKit-->>App: 6.弹出交易弹窗
	App->>StoreKit: 7.用户支付
	StoreKit-->>-App: 8.交易成功，返回付款收据
	end
	
	App->>+Server: 9.验证订单状态（根据收据、订单号）
	Server->>AppStore: 10.验证收据有效性
	AppStore-->>Server: 11.返回收据有效性
	Server-->>-App: 12.返回处理结果
	
	App->>StoreKit: 13.关闭交易
</div>

### iOS内购沙盒账号
在开发过程中，需要测试应用是否能够正常的进行支付，但是又不可能每一次测试都进行实际的支付，因此需要使用苹果提供的Sandbox Store测试。
苹果提供了沙盒账号的方式，这个沙箱账号其实是虚拟的AppleID，在开发者账号后台的iTune Connect上配置了之后就能使用沙盒账号测试内购。
StoreKit不能在iOS模拟器中使用，因此，测试StoreKit必须在真机上进行。
```text
Sandbox环境验证付款收据(receipt): https://sandbox.itunes.apple.com/verifyReceipt
Product环境验证付款收据(receipt): https://buy.itunes.apple.com/verifyReceipt
```
#### 沙盒账号的使用流程
1. 在iPhone上安装测试包
2. 退出iPhone的AppStore账号，设置 iTunes Store 与 App Store -> 选中AppleID -> 退出登录。(注意：退出之后，不需要在App Store登录沙盒账号，因为沙盒账号是一个虚拟的AppleID，因此不能直接登录。只能使用在支付时使用。)
3. 在测试包中点击购买商品，系统会提示你进行登录，这里点击"使用现有的AppleID"后输入沙盒测试账号进行登录。
4. 点击确认购买，购买成功。

#### 区分是否为沙盒充值
* 解析付款收据(receipt)中的 environment 字段，判断 `environment=Sandbox`。
* 根据生产环境收据验证接口返回的状态码。如果 status=21007，则表示当前的收据为沙盒环境下收据。

#### APP提审
苹果审核APP是在沙盒环境下验证充值相关功能的。
因此，当APP提交苹果审核时，服务端需换成沙盒环境，否则就无法通过苹果审核。

方案一：提供一个APP提审专用的审核服务器用于苹果审核，审核服使用沙盒环境，正式服使用正式环境。

方案二：服务器默认使用Product环境验证付款收据，如果验证结果返回的status = 21007时，则将请求地址换成Sandbox环境验证付款收据，再次请求验单。
