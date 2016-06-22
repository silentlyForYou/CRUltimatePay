//
//  CRUnipayClass.swift
//  MedicalInOne
//
//  Created by 易行 on 16/6/20.
//
//

import UIKit

// 支付宝订单数据
struct CRUltimatePayAlipayOrder {
    /*********************************支付四要素*********************************/
    
    // 商户在支付宝签约时，支付宝为商户分配的唯一标识号(以2088开头的16位纯数字)。
    var partner: String?
    
    // 卖家支付宝账号对应的支付宝唯一用户号(以2088开头的16位纯数字),订单支付金额将打入该账户,一个partner可以对应多个seller_id。
    var sellerID: String?
    
    // 商户网站商品对应的唯一订单号。
    var outTradeNo: String?
    
    //该笔订单的资金总额，单位为RMB(Yuan)。取值范围为[0.01，100000000.00]，精确到小数点后两位。
    var totalFee: String?
    
    /*********************************商品相关*********************************/
    
    // 商品的标题/交易标题/订单标题/订单关键字等。
    var subject: String?
    
    // 对一笔交易的具体描述信息。如果是多种商品，请将商品描述字符串累加传给body。
    var body: String?
    
    /*********************************其他必传参数*********************************/
    
    // 接口名称，固定为mobile.securitypay.pay。
    let service = "mobile.securitypay.pay"
    
    // 商户网站使用的编码格式，固定为utf-8。
    var inputCharset: String?
    
    // 支付宝服务器主动通知商户网站里指定的页面http路径。
    var notifyURL: String?
    
    /*********************************可选参数*********************************/
    
    // 支付类型，1：商品购买。(不传情况下的默认值)
    var paymentType: String? = "1"
    
    // 具体区分本地交易的商品类型,1：实物交易; (不传情况下的默认值),0：虚拟交易; (不允许使用信用卡等规则)。
    var goodsType: String? = "1"
    
    // 支付时是否发起实名校验,F：不发起实名校验; (不传情况下的默认值),T：发起实名校验;(商户业务需要买家实名认证)
    var rnCheck: String?
    
    // 标识客户端。
    var appID: String?
    
    // 标识客户端来源。参数值内容约定如下：appenv=“system=客户端平台名^version=业务系统版本”
    var appenv: String?
    
    // 设置未付款交易的超时时间，一旦超时，该笔交易就会自动被关闭。当用户输入支付密码、点击确认付款后（即创建支付宝交易后）开始计时。取值范围：1m～15d，或者使用绝对时间（示例格式：2014-06-13 16:00:00）。m-分钟，h-小时，d-天，1c-当天（1c-当天的情况下，无论交易何时创建，都在0点关闭）。该参数数值不接受小数点，如1.5h，可转换为90m。
    var itBPay: String?
    
    // 商品地址
    var showURL: String?
    
    // 业务扩展参数，支付宝特定的业务需要添加该字段，json格式。 商户接入时和支付宝协商确定。
    var outContext: [String:AnyObject]?
    
    var description: String {
        var desStr = ""
        
        if let partner = self.partner {
            desStr += "partner=\(partner)"
        }
        if let seller = self.sellerID {
            desStr += "&seller_id=\(seller)"
        }
        if let outTradeNo = self.outTradeNo {
            desStr += "&out_trade_no=\(outTradeNo)"
        }
        if let subject = self.subject {
            desStr += "&subject=\(subject)"
        }
        if let body = self.body {
            desStr += "&body=\(body)"
        }
        if let totalFee = self.totalFee {
            desStr += "&total_fee=\(totalFee)"
        }
        if let notifyURL = self.notifyURL {
            desStr += "&notify_url=\(notifyURL)"
        }
        
        desStr += "&service=\(service)"
        
        if let paymentType = self.paymentType {
            desStr += "&payment_type=\(paymentType)"
        }
        if let inputCharset = self.inputCharset {
            desStr += "&_input_charset=\(inputCharset)"
        }
        if let itBPay = self.itBPay {
            desStr += "&it_b_pay=\(itBPay)"
        }
        if let showURL = self.showURL {
            desStr += "&show_url=\(showURL)"
        }
        if let appID = self.appID {
            desStr += "&app_id=\(appID)"
        }
        
        if let context = self.outContext {
            context.keys.forEach { key in
                desStr += "&\(key)=\(context[key])"
            }
        }
        
        return desStr
    }
}

@objc
protocol CRUltimatePayDelegate: NSObjectProtocol {
    // 开始发起支付请求
    optional func ultimatePayDidStartPay()
    // 支付成功，如果是银联支付返回sign以供校验或调试，其他返回空字符串
    optional func ultimatePayDidPaySuccess(sign: String)
    // 支付失败
    optional func ultimatePayDidPayFailed()
    // 支付取消
    optional func ultimatePayDidPayCancel()
    
    // 开始请求订单的Tn号，银联专用
    optional func ultimatePayDidStartRequestUnipayTn()
    // 接收到Tn号，银联专用
    optional func ultimatePayDidReceivedUnipayTnNumber(tn: String)
    // 无效的请求Tn的URL地址，银联专用
    optional func ultimatePayUnavailableUnipayUrl(url: String)
    // 返回了无效的Tn（Tn为空字符串或者数据无法转为字符串处理），银联专用
    optional func ultimatePayReturnUnavailableUnipayTn(url: String)
}

@objc
enum CRUltimatePayResult: Int {
    case success = 0, process, fail, cancel
    
    case signNull, verifyFail // 银联签名验证用
}

class CRUltimatePay: NSObject {
    
    // App Scheme
    private var scheme: String = ""
    
    // 是否是正式环境
    private var forProduction: Bool = false
    
    // 委托
    private weak var delegate: CRUltimatePayDelegate? = nil
    
    // 签名验证块，默认不启用
    private var verifyBlock: (String -> Bool)? = nil
    
    // 银联变量声明
    // 银联支付回调host
    private let unipayPaymentResultHost = "uppayresult"
    
    // 银联tn订单号获取服务器地址，用于订单支付
    private var tnServerUrl: String = ""
    
    // 银联调用该类的View Controller
    private weak var viewController: UIViewController? = nil
    
    // 银联支付完成后的回调
    typealias UnipayResultType = (CRUltimatePayResult, String) -> Void
    private var unipayResultBlock: UnipayResultType? = nil
    
    // 支付宝变量声明
    // 支付宝支付回调host
    private let alipayPaymentResultHost = "safepay"
    
    // 支付宝商户合作伙伴
    private var partner: String = ""
    
    // 支付宝商户零售商
    private var seller: String = ""
    
    // 支付宝商户私钥
    private var privateKey: String = ""
    
    // 支付宝支付完成后的回调
    typealias AlipayResultType = (CRUltimatePayResult, [NSObject:AnyObject]) -> Void
    private var alipayResultBlock: AlipayResultType? = nil
    
    struct Static {
        static var instance: CRUltimatePay! = nil
        static var predicate: dispatch_once_t = 0
    }
    
    class func sharedInstance() -> CRUltimatePay! {
        if Static.instance == nil {
            dispatch_once(&Static.predicate) {
                Static.instance = self.init()
            }
        }
        
        return Static.instance
    }
    
    internal required override init() {
        super.init()
    }
    
    // 初始化设置调试环境和scheme
    func initialize(forProduction forProduction: Bool, scheme: String) {
        self.forProduction = forProduction
        self.scheme = scheme
    }
    
    // 初始化设置调试环境、scheme以及验证方式
    func initialize(forProduction forProduction: Bool, scheme: String, verify: String -> Bool) {
        initialize(forProduction: forProduction, scheme: scheme)
        self.verifyBlock = verify
    }
    
    // 设置支付密钥验证
    func setVerify(block: String -> Bool) {
        self.verifyBlock = block
    }
    
    func handlePaymentResult(url: NSURL) {
        guard let host = url.host else { return }
        
        switch host {
        case unipayPaymentResultHost:
            handleUnipayPaymentResult(url)
        case alipayPaymentResultHost:
            handleAlipayPaymentResult(url)
        default:
            break
        }
    }
}

// MARK: - 添加银联支持
extension CRUltimatePay {
    
    // 设置支付参数
    func setUnipay(url url: String, viewController: UIViewController!, delegate: CRUltimatePayDelegate?, paymentResultBlock: UnipayResultType?) {
        self.tnServerUrl = url
        self.viewController = viewController
        self.delegate = delegate
        self.unipayResultBlock = paymentResultBlock
    }
    
    // 向服务器端获取Tn订单号用于后续支付
    func startUnipay() {
        guard let url = NSURL(string: tnServerUrl) else {
            delegate?.ultimatePayUnavailableUnipayUrl?(tnServerUrl)
            return
        }
        
        delegate?.ultimatePayDidStartRequestUnipayTn?()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // 获取Tn订单号
            guard let data = NSData(contentsOfURL: url) where String(data: data, encoding: NSUTF8StringEncoding) != nil else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.ultimatePayReturnUnavailableUnipayTn?(self.tnServerUrl)
                }
                return
            }
            
            // 检查Tn号码有效性
            if let tn = String(data: data, encoding: NSUTF8StringEncoding) where tn != "" {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.ultimatePayDidReceivedUnipayTnNumber?(tn)
                    
                    // 调用银联支付接口
                    let result = UPPaymentControl.defaultControl().startPay(tn, fromScheme: self.scheme, mode: self.forProduction ? "00" : "01", viewController: self.viewController)
                    if result {
                        self.delegate?.ultimatePayDidStartPay?()
                    } else {
                        self.delegate?.ultimatePayDidPayFailed?()
                    }
                }
            } else {
                self.delegate?.ultimatePayReturnUnavailableUnipayTn?(self.tnServerUrl)
            }
        }
    }
    
    // 银联支付返回app回调处理
    private func handleUnipayPaymentResult(url: NSURL) {
        UPPaymentControl.defaultControl().handlePaymentResult(url) { [unowned self] code, data in
            dispatch_async(dispatch_get_main_queue()) {
                var result = CRUltimatePayResult.process
                var sign = ""
                
                if code == "success" {
                    result = .success
                    
                    if let signStr = data["sign"] as? String {
                        sign = signStr
                        
                        if let block = self.verifyBlock where !block(sign) {
                            result = .verifyFail
                        }
                    } else {
                        result = .signNull
                    }
                    
                    self.delegate?.ultimatePayDidPaySuccess?(sign)
                } else if code == "fail" {
                    result = .fail
                    self.delegate?.ultimatePayDidPayFailed?()
                } else if code == "cancel" {
                    result = .cancel
                    self.delegate?.ultimatePayDidPayCancel?()
                }
                
                self.unipayResultBlock?(result, sign)
            }
        }
    }
}

// MARK: - 添加支付宝支持
extension CRUltimatePay {
    
    // 设置支付参数
    func setAlipay(partner partner: String, seller: String, privateKey: String, delegate: CRUltimatePayDelegate?, paymentResultBlock: AlipayResultType?) {
        self.partner = partner
        self.seller = seller
        self.privateKey = privateKey
        
        self.delegate = delegate
        self.alipayResultBlock = paymentResultBlock
    }
    
    // 支付宝支付请求
    func startAlipay(order order: CRUltimatePayAlipayOrder) {
        let signedString = CreateRSADataSigner(privateKey).signString(order.description)
        let orderString = "\(order.description)&sign=\"\(signedString)\"&sign_type=\"RSA\""
        
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: scheme) { [unowned self] resultDic in
            dispatch_async(dispatch_get_main_queue()) {
                var result = CRUltimatePayResult.process
                
                if let errorStr = resultDic["resultStatus"] as? String {
                    if errorStr == "9000" {
                        result = .success
                        self.delegate?.ultimatePayDidPaySuccess?("")
                    } else if errorStr == "4000" || errorStr == "6002" {
                        result = .fail
                        self.delegate?.ultimatePayDidPayFailed?()
                    } else if errorStr == "6001" {
                        result = .cancel
                        self.delegate?.ultimatePayDidPayCancel?()
                    }
                }
                
                self.alipayResultBlock?(result, resultDic)
            }
        }
        
        delegate?.ultimatePayDidStartPay?()
    }
    
    // 支付宝支付返回app回调处理
    private func handleAlipayPaymentResult(url: NSURL) {
        AlipaySDK.defaultService().processOrderWithPaymentResult(url) { [unowned self] resultDic in
            dispatch_async(dispatch_get_main_queue()) {
                var result = CRUltimatePayResult.process
                
                if let errorStr = resultDic["resultStatus"] as? String {
                    if errorStr == "9000" {
                        result = .success
                        self.delegate?.ultimatePayDidPaySuccess?("")
                    } else if errorStr == "4000" || errorStr == "6002" {
                        result = .fail
                        self.delegate?.ultimatePayDidPayFailed?()
                    } else if errorStr == "6001" {
                        result = .cancel
                        self.delegate?.ultimatePayDidPayCancel?()
                    }
                }
                
                self.alipayResultBlock?(result, resultDic)
            }
        }
    }
}
