# CRUltimatePay
第三方支付封装，目前集成了银联、支付宝，欢迎支持添加其他支付方式

# 使用方法
#### 1. 添加银联(Unipay)SDK (可选)

可以从这个链接下载最新的银联开发包：[银联SDK下载](https://open.unionpay.com/ajweb/index)

将下面的文件添加到项目中
* UPPaymentControl.h
* libPaymentControl.a

或者从cocoapods安装GreedUPPayPlugin
```
    pod ‘GreedUPPayPlugin’
```

#### 2. 添加支付宝(Alipay)SDK (可选)

可以从这个链接下载最新的支付宝开发包：[支付宝SDK下载](http://aopsdkdownload.cn-hangzhou.alipay-pub.aliyun-inc.com/demo/WS_MOBILE_PAY_SDK_BASE.zip?spm=a219a.7629140.0.0.V6vHUG&file=WS_MOBILE_PAY_SDK_BASE.zip)

将下面的文件或文件夹添加到项目中
* openssl文件夹
* Util文件夹
* AlipaySDK.bundle
* AlipaySDK.framework
* libcrypto.a
* libssl.a

注：Order类已重写，故不需要添加Objective-C文件

#### 3. 添加依赖库
* libz.tbd
* SystemConfiguration.framework
* CoreGraphics.framework
* CFNetwork.framework
* LocalAuthentication.framework
* libc++.tbd
* UIKit.framework
* Foundation.framework
* CoreTelephony.framework
* CoreText.framework
* QuartzCore.framework
* CoreMotion.framework

如果你用的是Xcode7.0之前的版本，只需把tbd替换为dylib即可

#### 4. 设置混编头文件
在Bridging-Header.h文件中添加如下几行
```
#import "UPPaymentControl.h"
#import "DataSigner.h"

#import <AlipaySDK/AlipaySDK.h>
```

#### 5. 添加Scheme字符串

在项目的info属性标签页中，在URL Type中添加一个表示该App的scheme字符串

#### 6. 设置HTTP请求

在info.plist文件中，添加关键字为App Transport Security Settings的键值对，类型为Dictionary，在其中添加关键字为Allow Arbitrary Loads的键值对，类型为Boolean，设置值为YES

#### 7. 添加银联白名单

在info.plist文件中，添加LSApplicationQueriesSchemes数组，并加入uppaysdk、uppaywallet、uppayx1、uppayx2、uppayx3五个item

#### 8. 初始化控件
在AppDelegate的didFinishLaunchingWithOptions函数中添加以下代码
```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    CRUnipayClass.sharedInstance().initialize(forProduction: false, scheme: "CRUnipayDemo")
    
    return true
}
```
注：scheme参数填写在第5步中设置的字符串

#### 9. 设置回调函数
在AppDelegate的回调函数中添加以下代码
```
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    CRUnipayClass.sharedInstance().handlePaymentResult(url)
    
    return true
}

func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    CRUltimatePay.sharedInstance().handlePaymentResult(url)
    
    return true
}
```

#### 10. 使用银联支付
##### 10.1 设置银联支付参数
```
CRUltimatePay.sharedInstance().setUnipay(url: testUrl, viewController: self, delegate: self)
```
##### 10.2 发起银联支付请求
```
CRUltimatePay.sharedInstance().startUnipay() { result, sign in
    var text = ""
    
    switch result {
    case .success:  text = "支付成功"
    case .fail: text = "支付失败"
    case .cancel:   text = "支付取消"
    case .signNull: text = "密钥为空"
    case .verifyFail:   text = "密钥验证失败"
    case .process:  text = "支付进行中"
    }
    
    UIAlertView(title: "提示", message: text, delegate: nil, cancelButtonTitle: "知道了").show()
}
```

#### 11. 使用支付宝支付
##### 11.1 设置商户信息
```
let partner = "" // 商户在支付宝签约时，支付宝为商户分配的唯一标识号(以2088开头的16位纯数字)。
let seller = "" // 卖家支付宝账号
let privateKey = "" // 商户生成的私钥
```

##### 11.2 创建并设置订单数据
```
var order = CRUltimatePayAlipayOrder()
        
order.partner = partner
order.sellerID = seller
order.outTradeNo = generateTradeNo()
order.subject = "1"
order.body = "我是测试数据"
order.totalFee = "0.01"
order.notifyURL = "http://www.baidu.com"
        
order.paymentType = "1"
order.inputCharset = "utf-8"
order.itBPay = "30m"
order.showURL = "m.alipay.com"
```
##### 11.3 设置支付宝支付参数
```
CRUltimatePay.sharedInstance().setAlipay(partner: partner, seller: seller, privateKey: privateKey, delegate: self) 
```
##### 11.4 发起支付宝支付请求
```
CRUltimatePay.sharedInstance().startAlipay(order: order) { result, resultDict in
    var text = ""
            
    switch result {
    case .success:  text = "支付成功"
    case .fail: text = "支付失败"
    case .cancel:   text = "支付取消"
    case .process:  text = "支付进行中"
    default: break
    }
            
    UIAlertView(title: "提示", message: text, delegate: nil, cancelButtonTitle: "知道了").show()
}
```

#### 12. 委托回调函数
可以设置以下委托回调函数，用来监听支付执行过程
```
func unipayDidStartRequestTn() {
    print("开始请求支付订单Tn号码")
}
    
func unipayDidReceivedTnNumber(tn: String) {
    print("获得订单Tn号：\(tn)")
}
    
func unipayDidStartPay() {
    print("开始发起支付请求")
}
    
func unipayDidPaySuccess(sign: String) {
    print("支付成功，密钥字符串：\(sign)")
}
    
func unipayDidPayFailed() {
    print("支付失败")
}
    
func unipayDidPayCancel() {
    print("支付取消")
}
    
func unipayUnavailableUrl(url: String) {
    print("用于获取Tn号码的URL无效, URL: \(url)")
}
    
func unipayReturnUnavailableTn(url: String) {
    print("返回无效的Tn号码，URL: \(url)")
}
```

#### 13. HACK
因支付宝和银联集成在一起，如果单独使用其中某个支付，可手动注释其他extension代码和回调分支代码。最佳方案是能够设置动态加载代码，如何实现？