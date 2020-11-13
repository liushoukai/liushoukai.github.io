---
layout: post
title: AppStore内购
categories: in-app-purchase
tags: in-app-purchase
---

### 内购简介

App 内购买 (In‑App Purchase)，简称：IAP内购。

通过 App 内购买项目，直接在 App 里为顾客提供额外的内容和功能，包括特级内容、数字商品和订阅项目。您更可以直接在 App Store 上推广和提供 App 内购买项目。

官方文档：[https://developer.apple.com/cn/in-app-purchase/][1]{:target="_blank"}

------

### 内购模式

两种模式主要的不同之处在于对 AppStore 返回的付款凭证（receipt）的验证方式。

* 客户端验证模式：在客户端验证付款凭证（receipt），简单快捷，但容易被破解。主要适用于非联网APP应用内购，比如旅行青蛙中游戏道具购买。

* 服务器验证模式：在服务端验证付款凭证（receipt），流程相对复杂，但相对安全性更高，主要适用于联网APP应用的内购，比如直播APP中虚拟货币的充值购买。

------

#### 客户端模式

1. APP 从服务器获取产品标识列表
2. APP 从 AppStore 获取产品信息
3. 用户选择需要购买的产品
4. APP 发送支付请求到 AppStore
5. AppStore 处理支付请求，用户完成支付后，AppStore 返回付款收据 (receipt) 给APP
6. APP 验证返回的付款收据(receipt)，判定用户是否付款成功并提供对应的服务

------

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

------

### 付款收据

------

#### 收据风格

* iOS 6-style transaction receipts
* iOS 7-style transaction receipts

------

#### 收据验证

```shell
Sandbox环境验证付款收据(receipt): https://sandbox.itunes.apple.com/verifyReceipt
Product环境验证付款收据(receipt): https://buy.itunes.apple.com/verifyReceipt
```

------

#### 收据结构

1、消耗型产品收据结构
```json
{
    "receipt": {
        "unique_identifier": "...",                     //苹果分配设备唯一标识符
        "original_transaction_id": "...",               //原交易号
        "transaction_id": "...",                        //交易号
        "unique_vendor_identifier": "...",              //唯一供应商标识
        "product_id": "...",                            //交易产品标识
        "quantity": "1",                                //交易产品数量
        "bid": "...",                                   //APP在苹果的唯一标识
        "is_in_intro_offer_period": "false",            //是否特价优惠（详见推介促销）
        "is_trial_period": "false",                     //是否免费试用（详见推介促销）
        "purchase_date_ms": "1531643137200",            //交易付款时间
        "original_purchase_date_ms": "1531643137200",   //原交易付款时间
        "bvrs": "3.96.3.0",
        "app_item_id": "774384491",
        "item_id": "1146328092",
        "version_external_identifier": "827233954",
        "purchase_date": "2018-07-15 08:25:37 Etc/GMT",
        "purchase_date_pst": "2018-07-15 01:25:37 America/Los_Angeles",
        "original_purchase_date": "2018-07-15 08:25:37 Etc/GMT"
        "original_purchase_date_pst": "2018-07-15 01:25:37 America/Los_Angeles",
    },
    "status": 0
}
```

2、自动订阅型产品收据结构
```json
{
  "auto_renew_status": 0,
  "latest_expired_receipt_info": {
    "original_purchase_date_pst": "2018-01-19 16:03:00 America/Los_Angeles",
    "unique_identifier": "9d89432f1fae59f25c05d44553fe40438a865b9f",
    "original_transaction_id": "1000000368245564",
    "expires_date": "1517368991000",
    "transaction_id": "1000000371718901",
    "quantity": "1",
    "product_id": "abc",
    "bvrs": "721180.450460032",
    "bid": "ab.bc",
    "unique_vendor_identifier": "9982B084-BE66-4622-ACCB-6C5B3D9C4CD4",
    "web_order_line_item_id": "1000000037662245",
    "original_purchase_date_ms": "1516406580000",
    "expires_date_formatted": "2018-01-31 03:23:11 Etc/GMT",
    "purchase_date": "2018-01-31 02:53:11 Etc/GMT",
    "is_in_intro_offer_period": "false",
    "purchase_date_ms": "1517367191000",
    "expires_date_formatted_pst": "2018-01-30 19:23:11 America/Los_Angeles",
    "is_trial_period": "false",
    "purchase_date_pst": "2018-01-30 18:53:11 America/Los_Angeles",
    "original_purchase_date": "2018-01-20 00:03:00 Etc/GMT",
    "item_id": "1326212778"
  },
  "status": 21006,
  "auto_renew_product_id": "abc",
  "receipt": {
    "original_purchase_date_pst": "2018-01-19 16:03:00 America/Los_Angeles",
    "unique_identifier": "9d89432f1fae59f25c05d44553fe40438a865b9f",
    "original_transaction_id": "1000000368245564",
    "expires_date": "1517359990000",
    "transaction_id": "1000000371686472",
    "quantity": "1",
    "product_id": "abc",
    "bvrs": "721180.450460032",
    "bid": "ab.bc",
    "unique_vendor_identifier": "9982B084-BE66-4622-ACCB-6C5B3D9C4CD4",
    "web_order_line_item_id": "1000000037544589",
    "original_purchase_date_ms": "1516406580000",
    "expires_date_formatted": "2018-01-31 00:53:10 Etc/GMT",
    "purchase_date": "2018-01-31 00:23:10 Etc/GMT",
    "is_in_intro_offer_period": "false",
    "purchase_date_ms": "1517358190000",
    "expires_date_formatted_pst": "2018-01-30 16:53:10 America/Los_Angeles",
    "is_trial_period": "false",
    "purchase_date_pst": "2018-01-30 16:23:10 America/Los_Angeles",
    "original_purchase_date": "2018-01-20 00:03:00 Etc/GMT",
    "item_id": "1326212778"
  },
  "expiration_intent": "1",
  "is_in_billing_retry_period": "0"
}
```

------

#### 收据解析

详见官方解释：[https://developer.apple.com/documentation/appstorereceipts/status][5]{:target="_blank"}

{:class="table table-striped table-bordered table-hover"}
| <img style="width:80px">Status | Description |
| :-----: | :------- |
| 21000 | The request to the App Store was not made using the HTTP POST request method.|
| 21001 | This status code is no longer sent by the App Store.|
| 21002 | The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.|
| 21003 | The receipt could not be authenticated.|
| 21004 | The shared secret you provided does not match the shared secret on file for your account.|
| 21005 | The receipt server was temporarily unable to provide the receipt. Try again.|
| 21006 | This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. `Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions.`|
| 21007 | This receipt is from the test environment, but it was sent to the production environment for verification.|
| 21008 | This receipt is from the production environment, but it was sent to the test environment for verification.|
| 21009 | Internal data access error. Try again later.|
| 21010 | The user account cannot be found or has been deleted.|
| 21100 | Internal data access error. Try again later.|
| ... | Internal data access error. Try again later.|
| 21199 | Internal data access error. Try again later.|

------

### 沙盒账号

在开发过程中，需要测试应用是否能够正常的进行支付，但是又不可能每一次测试都进行实际的支付，因此需要使用苹果提供的 Sandbox Store 测试。苹果提供了沙盒账号的方式，这个沙箱账号其实是虚拟的AppleID，在开发者账号后台的iTune Connect上配置了之后就能使用沙盒账号测试内购。StoreKit不能在iOS模拟器中使用，因此，测试StoreKit必须在真机上进行。

```shell
Sandbox环境验证付款收据(receipt): https://sandbox.itunes.apple.com/verifyReceipt
Product环境验证付款收据(receipt): https://buy.itunes.apple.com/verifyReceipt
```

------

#### 沙盒账号的使用流程

1. 在iPhone上安装测试包
2. 退出iPhone的AppStore账号，设置 iTunes Store 与 App Store -> 选中AppleID -> 退出登录。(注意：退出之后，不需要在 App Store 登录沙盒账号，因为沙盒账号是一个虚拟的AppleID，因此不能直接登录。只能使用在支付时使用。)
3. 在测试包中点击购买商品，系统会提示你进行登录，这里点击"使用现有的AppleID"后输入沙盒测试账号进行登录。
4. 点击确认购买，购买成功。

------

#### 沙盒测试

沙盒环境下自动续费订阅时，时限会缩短。

{:class="table table-striped table-bordered table-hover"}
|生产自动续费周期|沙盒自动续费周期|
| :-----: | :-------: |
| 1周  |  3分钟|
| 1个月 | 5分钟|
| 2个月 | 10分钟|
| 3个月 | 15分钟|
| 6个月 | 30分钟|
| 1年  |  1小时|

------

#### 区分是否为沙盒充值

* 解析付款收据(receipt)中的 environment 字段，判断 environment=Sandbox。
* 根据生产环境收据验证接口返回的状态码。如果 status=21007，则表示当前的收据为沙盒环境下收据。

------

### 苹果审核

苹果审核APP是在沙盒环境下验证充值相关功能的。因此，当APP提交苹果审核时，服务端需换成沙盒环境，否则就无法通过苹果审核。

收据验证最佳实践：

首先使用 production URL 验证收据，如果收到了21007的状态码，那么继续使用sandbox URL进行验证。

遵循这种方法可以确保你的应用程序在测试、App审核以及AppStore中运行时，不需要在url之间切换。

------

### 内购产品

------

#### 产品类型

`消耗型产品(Consumable)`

* 定义：消耗型项目只可使用一次，使用之后即失效，必须再次购买。
* 特点：购买的商品可消耗，可重复购买。每次购买的值一般都会叠加。如果买了后，用户不消耗，则一直存在用户相关的账号中。
* 举例：游戏《皇室战争》中，购买宝石。

`非消耗型产品(Non‑Consumable)`

* 定义：非消耗品只能购买一次且不会过期。
* 特点：这种类型的商品的特点就是当用户购买后，这个商品就一直生效，不需要重复购买。
* 举例：游戏《旅行青蛙》中，解锁游戏中的特定道具。

`非续期产品(Non‑Renewing Subscriptions)`

* 定义：用户购买有时限性的服务或内容。
* 特点：此类订阅到期后不会自动续订，用户需要逐次续订。
* 举例：腾讯视频VIP会员包月。

`自动续期产品(Auto‑Renewable Subscriptions)`

* 定义：用户购买有时限性的服务或内容，到期后自动续订。
* 特点：到期前24小时，苹果会主动扣费从而为用户自动续订，直用户取消自动订阅。
* 举例：腾讯视频VIP会员自动包月。

------

#### 商品定价

内购商品定价为固定的金额，分为非自动订阅商品定价与自动订阅商品定价两类。注意⚠️：定价并非全部都是整数，自动订阅的定价包含类似`¥1.99`的定价。

`非自动订阅商品定价列表`

{:class="table table-striped table-bordered table-hover"}
|价格      | 等级       |
| :-----: | :-------: |
|CNY 6    |（等级 1）   |
|CNY 12   |（等级 2）   |
|CNY 18   |（等级 3）   |
|CNY 25   |（等级 4）   |
|CNY 30   |（等级 5）   |
|CNY 40   |（等级 6）   |
|CNY 45   |（等级 7）   |
|CNY 50   |（等级 8）   |
|CNY 60   |（等级 9）   |
|CNY 68   |（等级 10）  |
|CNY 73   |（等级 11）  |
|CNY 78   |（等级 12）  |
|CNY 88   |（等级 13）  |
|CNY 93   |（等级 14）  |
|CNY 98   |（等级 15）  |
|CNY 108  |（等级 16）  |
|CNY 113  |（等级 17）  |
|CNY 118  |（等级 18）  |
|CNY 123  |（等级 19）  |
|CNY 128  |（等级 20）  |
|CNY 138  |（等级 21）  |
|CNY 148  |（等级 22）  |
|CNY 153  |（等级 23）  |
|CNY 158  |（等级 24）  |
|CNY 163  |（等级 25）  |
|CNY 168  |（等级 26）  |
|CNY 178  |（等级 27）  |
|CNY 188  |（等级 28）  |
|CNY 193  |（等级 29）  |
|CNY 198  |（等级 30）  |
|CNY 208  |（等级 31）  |
|CNY 218  |（等级 32）  |
|CNY 223  |（等级 33）  |
|CNY 228  |（等级 34）  |
|CNY 233  |（等级 35）  |
|CNY 238  |（等级 36）  |
|CNY 243  |（等级 37）  |
|CNY 248  |（等级 38）  |
|CNY 253  |（等级 39）  |
|CNY 258  |（等级 40）  |
|CNY 263  |（等级 41）  |
|CNY 268  |（等级 42）  |
|CNY 273  |（等级 43）  |
|CNY 278  |（等级 44）  |
|CNY 283  |（等级 45）  |
|CNY 288  |（等级 46）  |
|CNY 298  |（等级 47）  |
|CNY 308  |（等级 48）  |
|CNY 318  |（等级 49）  |
|CNY 328  |（等级 50）  |
|CNY 348  |（等级 51）  |
|CNY 388  |（等级 52）  |
|CNY 418  |（等级 53）  |
|CNY 448  |（等级 54）  |
|CNY 488  |（等级 55）  |
|CNY 518  |（等级 56）  |
|CNY 548  |（等级 57）  |
|CNY 588  |（等级 58）  |
|CNY 618  |（等级 59）  |
|CNY 648  |（等级 60）  |
|CNY 698  |（等级 61）  |
|CNY 798  |（等级 62）  |
|CNY 818  |（等级 63）  |
|CNY 848  |（等级 64）  |
|CNY 898  |（等级 65）  |
|CNY 998  |（等级 66）  |
|CNY 1048 |（等级 67）  |
|CNY 1098 |（等级 68）  |
|CNY 1148 |（等级 69）  |
|CNY 1198 |（等级 70）  |
|CNY 1248 |（等级 71）  |
|CNY 1298 |（等级 72）  |
|CNY 1398 |（等级 73）  |
|CNY 1448 |（等级 74）  |
|CNY 1498 |（等级 75）  |
|CNY 1598 |（等级 76）  |
|CNY 1648 |（等级 77）  |
|CNY 1998 |（等级 78）  |
|CNY 2298 |（等级 79）  |
|CNY 2598 |（等级 80）  |
|CNY 2998 |（等级 81）  |
|CNY 3298 |（等级 82）  |
|CNY 3998 |（等级 83）  |
|CNY 4498 |（等级 84）  |
|CNY 4998 |（等级 85）  |
|CNY 5898 |（等级 86）  |
|CNY 6498 |（等级 87）  |
|CNY 1    |（备用等级 A）|
|CNY 3    |（备用等级 B）|
|CNY 8    |（备用等级 1）|
|CNY 12   |（备用等级 2）|
|CNY 18   |（备用等级 3）|
|CNY 28   |（备用等级 4）|
|CNY 30   |（备用等级 5）|

`自动订阅商品定价列表`

{:class="table table-striped table-bordered table-hover"}
|价格      | 等级       |
| :-----: | :-------: |
|¥1.00 | ¥1.00 |
|¥1.99 | ¥1.99 |
|¥3.00 | ¥3.00 |
|¥3.99 | ¥3.99 |
|¥5.00 | ¥5.00 |
|¥6.00 | ¥6.00 |
|¥7.00 | ¥7.00 |
|¥8.00 | ¥8.00 |
|¥9.00 | ¥9.00 |
|¥10.00 | ¥10.00 |
|¥11.00 | ¥11.00 |
|¥12.00 | ¥12.00 |
|¥13.00 | ¥13.00 |
|¥14.00 | ¥14.00 |
|¥15.00 | ¥15.00 |
|¥16.00 | ¥16.00 |
|¥17.00 | ¥17.00 |
|¥18.00 | ¥18.00 |
|¥19.00 | ¥19.00 |
|¥20.00 | ¥20.00 |
|¥21.00 | ¥21.00 |
|¥22.00 | ¥22.00 |
|¥23.00 | ¥23.00 |
|¥24.00 | ¥24.00 |
|¥25.00 | ¥25.00 |
|¥26.00 | ¥26.00 |
|¥27.00 | ¥27.00 |
|¥28.00 | ¥28.00 |
|¥30.00 | ¥30.00 |
|¥33.00 | ¥33.00 |
|¥35.00 | ¥35.00 |
|¥38.00 | ¥38.00 |
|¥40.00 | ¥40.00 |
|¥43.00 | ¥43.00 |
|¥45.00 | ¥45.00 |
|¥48.00 | ¥48.00 |
|¥50.00 | ¥50.00 |
|¥53.00 | ¥53.00 |
|¥58.00 | ¥58.00 |
|¥60.00 | ¥60.00 |
|¥63.00 | ¥63.00 |
|¥68.00 | ¥68.00 |
|¥70.00 | ¥70.00 |
|¥73.00 | ¥73.00 |
|¥78.00 | ¥78.00 |
|¥80.00 | ¥80.00 |
|¥83.00 | ¥83.00 |
|¥88.00 | ¥88.00 |
|¥90.00 | ¥90.00 |
|¥93.00 | ¥93.00 |
|¥98.00 | ¥98.00 |
|¥100.00 | ¥100.00 |
|¥103.00 | ¥103.00 |
|¥108.00 | ¥108.00 |
|¥113.00 | ¥113.00 |
|¥118.00 | ¥118.00 |
|¥123.00 | ¥123.00 |
|¥128.00 | ¥128.00 |
|¥133.00 | ¥133.00 |
|¥138.00 | ¥138.00 |
|¥143.00 | ¥143.00 |
|¥148.00 | ¥148.00 |
|¥153.00 | ¥153.00 |
|¥158.00 | ¥158.00 |
|¥163.00 | ¥163.00 |
|¥168.00 | ¥168.00 |
|¥173.00 | ¥173.00 |
|¥178.00 | ¥178.00 |
|¥183.00 | ¥183.00 |
|¥188.00 | ¥188.00 |
|¥193.00 | ¥193.00 |
|¥198.00 | ¥198.00 |
|¥203.00 | ¥203.00 |
|¥208.00 | ¥208.00 |
|¥213.00 | ¥213.00 |
|¥218.00 | ¥218.00 |
|¥223.00 | ¥223.00 |
|¥228.00 | ¥228.00 |
|¥233.00 | ¥233.00 |
|¥238.00 | ¥238.00 |
|¥243.00 | ¥243.00 |
|¥248.00 | ¥248.00 |
|¥253.00 | ¥253.00 |
|¥258.00 | ¥258.00 |
|¥263.00 | ¥263.00 |
|¥268.00 | ¥268.00 |
|¥273.00 | ¥273.00 |
|¥278.00 | ¥278.00 |
|¥283.00 | ¥283.00 |
|¥288.00 | ¥288.00 |
|¥293.00 | ¥293.00 |
|¥298.00 | ¥298.00 |
|¥303.00 | ¥303.00 |
|¥308.00 | ¥308.00 |
|¥313.00 | ¥313.00 |
|¥318.00 | ¥318.00 |
|¥323.00 | ¥323.00 |
|¥328.00 | ¥328.00 |
|¥333.00 | ¥333.00 |
|¥338.00 | ¥338.00 |
|¥343.00 | ¥343.00 |
|¥348.00 | ¥348.00 |
|¥353.00 | ¥353.00 |
|¥358.00 | ¥358.00 |
|¥363.00 | ¥363.00 |
|¥368.00 | ¥368.00 |
|¥373.00 | ¥373.00 |
|¥378.00 | ¥378.00 |
|¥383.00 | ¥383.00 |
|¥388.00 | ¥388.00 |
|¥393.00 | ¥393.00 |
|¥398.00 | ¥398.00 |
|¥408.00 | ¥408.00 |
|¥418.00 | ¥418.00 |
|¥428.00 | ¥428.00 |
|¥438.00 | ¥438.00 |
|¥448.00 | ¥448.00 |
|¥458.00 | ¥458.00 |
|¥468.00 | ¥468.00 |
|¥478.00 | ¥478.00 |
|¥488.00 | ¥488.00 |
|¥498.00 | ¥498.00 |
|¥508.00 | ¥508.00 |
|¥518.00 | ¥518.00 |
|¥528.00 | ¥528.00 |
|¥538.00 | ¥538.00 |
|¥548.00 | ¥548.00 |
|¥558.00 | ¥558.00 |
|¥568.00 | ¥568.00 |
|¥578.00 | ¥578.00 |
|¥588.00 | ¥588.00 |
|¥598.00 | ¥598.00 |
|¥608.00 | ¥608.00 |
|¥618.00 | ¥618.00 |
|¥628.00 | ¥628.00 |
|¥638.00 | ¥638.00 |
|¥648.00 | ¥648.00 |
|¥658.00 | ¥658.00 |
|¥668.00 | ¥668.00 |
|¥678.00 | ¥678.00 |
|¥688.00 | ¥688.00 |
|¥698.00 | ¥698.00 |
|¥708.00 | ¥708.00 |
|¥718.00 | ¥718.00 |
|¥728.00 | ¥728.00 |
|¥738.00 | ¥738.00 |
|¥748.00 | ¥748.00 |
|¥758.00 | ¥758.00 |
|¥768.00 | ¥768.00 |
|¥778.00 | ¥778.00 |
|¥788.00 | ¥788.00 |
|¥798.00 | ¥798.00 |
|¥818.00 | ¥818.00 |
|¥848.00 | ¥848.00 |
|¥868.00 | ¥868.00 |
|¥888.00 | ¥888.00 |
|¥898.00 | ¥898.00 |
|¥918.00 | ¥918.00 |
|¥948.00 | ¥948.00 |
|¥968.00 | ¥968.00 |
|¥988.00 | ¥988.00 |
|¥998.00 | ¥998.00 |
|¥1,048.00 | ¥1,048.00 |
|¥1,098.00 | ¥1,098.00 |
|¥1,148.00 | ¥1,148.00 |
|¥1,198.00 | ¥1,198.00 |
|¥1,248.00 | ¥1,248.00 |
|¥1,298.00 | ¥1,298.00 |
|¥1,348.00 | ¥1,348.00 |
|¥1,398.00 | ¥1,398.00 |
|¥1,448.00 | ¥1,448.00 |
|¥1,498.00 | ¥1,498.00 |
|¥1,548.00 | ¥1,548.00 |
|¥1,598.00 | ¥1,598.00 |
|¥1,648.00 | ¥1,648.00 |
|¥1,698.00 | ¥1,698.00 |
|¥1,748.00 | ¥1,748.00 |
|¥1,798.00 | ¥1,798.00 |
|¥1,848.00 | ¥1,848.00 |
|¥1,898.00 | ¥1,898.00 |
|¥1,948.00 | ¥1,948.00 |
|¥1,998.00 | ¥1,998.00 |
|¥2,098.00 | ¥2,098.00 |
|¥2,198.00 | ¥2,198.00 |
|¥2,298.00 | ¥2,298.00 |
|¥2,398.00 | ¥2,398.00 |
|¥2,498.00 | ¥2,498.00 |
|¥2,598.00 | ¥2,598.00 |
|¥2,698.00 | ¥2,698.00 |
|¥2,798.00 | ¥2,798.00 |
|¥2,898.00 | ¥2,898.00 |
|¥2,998.00 | ¥2,998.00 |
|¥3,298.00 | ¥3,298.00 |
|¥3,498.00 | ¥3,498.00 |
|¥3,998.00 | ¥3,998.00 |
|¥4,498.00 | ¥4,498.00 |
|¥4,998.00 | ¥4,998.00 |
|¥5,498.00 | ¥5,498.00 |
|¥5,898.00 | ¥5,898.00 |
|¥6,498.00 | ¥6,498.00 |

------

### 推介促销

推介促销优惠是针对自动续期订阅类商品的优惠促销活动，如果用户参与过推介促销优惠，则无法再享受该商品所属订阅分组的推介促销优惠。

------

### 内购监控

1. 监控iOS内购充值商品列表接口失败率与时延
2. 监控iOS内购下单接口失败率与时延
3. 监控iOS内购上报接口失败率与时延
4. 监控iOS内购退款的监控
5. 监控iOS内购沙盒的监控

------

### 退款处理

------

#### 退款政策

针对退款，不同国家或地区会有不同的“无条件退款期限”。
AppStore 商店退款政策：

* 欧盟区： 14天无条件退款。
* 中国台湾：7天无条件退款。
* 中国/美国/韩国等其它大多数国家：90天有条件退款。

注：中国区 AppStore 的具体退款政策：一个 AppleId 有一次无条件退款机会，一年2次有条件退款，第3次退款会非常难。至于退款到账时间快为36小时内，也有7-15个工作日退还。

------

#### 退款方式

用户可以通过那些方式申请退款：

- 联系Apple客户支持并要求退款
- 登录并使用Apple的自助服务工具 reportaproblem.apple.com 要求退款
- 要求他们的付款方式发行人退款 （比如要求银行取消扣费，或者黑卡无法扣费等）

------

#### 退款流程

在 Apple 全球开发者大会( [WWDC2020][3]{:target="_blank"} )上，Apple宣布从2020年06月24日开始，针对 App 内购买项目的退款通知现已可用。

App Store 服务器通知现在包含所有类型的 App 内购买项目的退款通知 (包括消耗型项目、非消耗型项目和非续期订阅)。详见：[https://developer.apple.com/videos/play/wwdc2020/10661/][4]{:target="_blank"}

2020年06月24日开始，新的退款流程：

<div class="mermaid">
sequenceDiagram
	participant Customer
	participant Apple
	participant Developer
	Customer->>Developer: Purchases 100 gems(购买100宝石)
	Customer->>Developer: Consumes 100 gems(消费100宝石)
	Customer->>Apple: Contacts Apple for support(顾客联系苹果申请退款)
	Apple->>Apple: Issues refund(苹果发起退款)
	Apple->>Developer: Send refund notification(发送退款通知)
	Apple->>Customer: Contacts you for game compensation(通知用户退款成功)
	Developer->>Developer: Check for refunded payment(开发者检查退款订单)
</div>
------

#### 退款通知

在 App Store 服务端通知中，针对消耗型项目、非消耗型项目和非续期订阅三类商品的退款，增添了新的通知类型：`退款（REFUND）`。
注意，不同于取消（CANCEL）通知类型，取消通知类型针对的是自动续期订阅类型商品，用户通过 AppleCare 支持取消订阅并退还购买款项时触发。

在 unified_receipt.latest_receipt_info 是一个数组，其中包含的最近的100次应用内购买交易，包括正常和退款的交易。
如果是退款的交易，交易的收据信息中会包含退款时间（cancellation_date_ms）和退款原因（cancellation_reason）。

服务器应发送HTTP状态代码，以指示服务器到服务器的通知接收是否成功：

* 如果回调接收成功，则发送 HTTP 200。您的服务器不需要返回数据。
* 如果回调接收不成功，请发送 HTTP 50x 或 40x 让 App Store 重试该通知。App Store在一段时间内尝试重试该通知，但在连续失败尝试后最终停止(3次）。

注意事项：

* 当您使用包含退款交易的收据 transaction_data 向苹果服务器校验 verifyReceipt  时，JSON响应中不存在退款交易，自动续订订阅除外。
* 收到 REFUND 通知时，您有责任为每笔退款交易存储，监控并采取适当的措施。（因为苹果只通知一次，暂时无法在苹果后台查询退款的订单。也不能由开发者主动去苹果服务器查询。）

退款（REFUND）通知类型通知的结构如下：

```json
{
    "notification_type":"REFUND",
    "password":"...",
    "environment":"PROD",
    "latest_receipt":"...",
    "latest_receipt_info":{
        "cancellation_reason":"0",
        "is_trial_period":"false",
        "is_in_intro_offer_period":"false",
        "unique_identifier":"00008020-0004482A3628002E",
        "unique_vendor_identifier":"0C4C3E40-21D8-4BC4-992F-1CB9A6CAEA4C",
        "cancellation_date":"2020-07-28 06:00:53 Etc/GMT",
        "cancellation_date_ms":"1595916053000",
        "cancellation_date_pst":"2020-07-27 23:00:53 America/Los_Angeles",
        "purchase_date":"2020-07-27 07:58:43 Etc/GMT",
        "purchase_date_ms":"1595836723000",
        "purchase_date_pst":"2020-07-27 00:58:43 America/Los_Angeles",
        "original_purchase_date":"2020-07-27 07:58:43 Etc/GMT",
        "original_purchase_date_ms":"1595836723000",
        "original_purchase_date_pst":"2020-07-27 00:58:43 America/Los_Angeles",
        "item_id":"1146327846",
        "app_item_id":"774384491",
        "version_external_identifier":"836917695",
        "bid":"...",
        "product_id":"...",
        "transaction_id":"...",
        "original_transaction_id":"...",
        "quantity":"1",
        "bvrs":"4.98.00.1"
    },
    "unified_receipt":{
        "status":0,
        "environment":"Production",
        "latest_receipt_info":[
            {
                "quantity":"1",
                "product_id":"...",
                "transaction_id":"...",
                "purchase_date":"2020-07-27 07:58:43 Etc/GMT",
                "purchase_date_ms":"1595836723000",
                "purchase_date_pst":"2020-07-27 00:58:43 America/Los_Angeles",
                "original_purchase_date":"2020-07-27 07:58:43 Etc/GMT",
                "original_purchase_date_ms":"1595836723000",
                "original_purchase_date_pst":"2020-07-27 00:58:43 America/Los_Angeles",
                "is_trial_period":"false",
                "original_transaction_id":"...",
                "cancellation_date":"2020-07-28 06:00:53 Etc/GMT",
                "cancellation_date_ms":"1595916053000",
                "cancellation_date_pst":"2020-07-27 23:00:53 America/Los_Angeles",
                "cancellation_reason":"0"
            }
        ],
        "latest_receipt":"..."
    },
    "bid":"...",
    "bvrs":"4.98.00.1"
}
```

------

#### 退款操作

![potential-actions](https://liushoukai.github.io/assets/img/potential-actions.jpeg){:width="100%"}

------

[1]:https://developer.apple.com/cn/in-app-purchase/
[2]:https://developer.apple.com/documentation/storekit/in-app_purchase/handling_refund_notifications
[3]:https://developer.apple.com/wwdc20/
[4]:https://developer.apple.com/videos/play/wwdc2020/10661/
[5]:https://developer.apple.com/documentation/appstorereceipts/status