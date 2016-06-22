//
//  ViewController.swift
//  UnipayDemo
//
//  Created by 易行 on 16/6/21.
//  Copyright © 2016年 Demeijia. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CRUltimatePayDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startUnipay(sender: UIButton) {
        let testUrl = "http://101.231.204.84:8091/sim/getacptn"
        
        CRUltimatePay.sharedInstance().setUnipay(url: testUrl, viewController: self, delegate: self)
        CRUltimatePay.sharedInstance().startUnipay { result, sign in
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
    }
    
    private func generateTradeNo() -> String {
        let number = 15
        let sourceStr = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var resultStr = ""
        
        for _ in 0 ..< number {
            let index = Int(arc4random()) % sourceStr.characters.count
            let range: Range<String.Index> = sourceStr.startIndex.advancedBy(index) ..< sourceStr.startIndex.advancedBy(index + 1)
            let oneStr = sourceStr.substringWithRange(range)
            resultStr += oneStr
        }
        
        return resultStr
    }
    
    @IBAction func startAlipay(sender: UIButton) {
        let partner = "2088811956033819";
        let seller = "xinyuxingbangxinxi@163.com"
        let privateKey = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAJ3U/F+CuYUTwIlefRyWcwNvecIx756fbYFKp3Ymfy3MNdzccPc7Kk62RKCpVTgshHGVx0UUpRGzSV1y6M17teOTY/1KVSxhB6wvlOkTxF9SYiXWyr6ioHyl1etxjnQOtL0zqA3ID1vjOzMZZXM0+QE8dnc3rXoOSE7xOvkIb+RJAgMBAAECgYAdE0Rer+1PN6FLbQ2tO4X6hwmuHZbf6My6ea8508OwAyOVCUMCOHMFxwwDcM5TJ9hKOGZaMoBqL1X/khCS8gxCkwVEsIqr0/A4b2wBcJqtYXYx9onhUDjpfc/DjJ/DJx0VDDuEpeM5++djBTDxEjzDmEgK27trfPwm7cNbJjxPJQJBANb6bBpmUnml22bUu4jMeVAQZekg+ho3tMr8aa/np0CK8Jdq9je/HBhPXkVMGDhXlX4hAOYGI6wF2vrmz7ExRdMCQQC78v+lCXRtmsMzJQzE6tZAVG8ErFYpfm+23Ebn+36w8E+VNT+8wquoCD8tXsBssvBwdT6ZRqmEeEV77mdZ18/zAkBvcl1OhlMlW1VVht09uvr9BbM/W2gs5UolnRtRJN+w9xZo+PtxxPJUq/isJhm8Q7NtMsDbfr1JdbOjNLrhGjEfAkEArFeroeskjuit+7UKm3r3ka+ayX851vywdc5RWqGbz6XcY+abFnyvqPo+7FyJOGNw5L4t86D/CpC6rmSy8ohZjwJBALiHGihuWHU8Xw9Qz5l6nWzN2w/vQa9Brm3XOkVLfoirPdOx0oo6OU7wwdgBMz+86+QLMAwx+ZooIHpGiZ0mWR8="
        
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
        
        CRUltimatePay.sharedInstance().setAlipay(partner: partner, seller: seller, privateKey: privateKey, delegate: self)
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
    }
    
    // MARK: Ultimate class delegate
    
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
}

