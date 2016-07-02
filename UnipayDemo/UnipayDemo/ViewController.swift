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
        
        let partner = ""
        let seller = ""
        let privateKey = ""
        
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
    
    @IBAction func startWeiXinPay(sender: UIButton) {
        
        let urlString   = "http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios"
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string: urlString)!)
        var response: NSURLResponse?
        
        do{
            let data:NSData? = try NSURLConnection.sendSynchronousRequest(request,
                                                                          returningResponse: &response)
            let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if str != nil {
                let dic = try! NSJSONSerialization.JSONObjectWithData(data!,
                                                                      options: NSJSONReadingOptions.MutableContainers)
                let partnerId = dic["partnerid"] as? String ?? ""
                let prepayId = dic["prepayid"] as? String ?? ""
                let nonceStr = dic["noncestr"] as? String ?? ""
                let timeStamp = UInt32(dic["timestamp"] as? Int ?? 0)
                let package = dic["package"] as? String ?? ""
                let sign = dic["sign"] as? String ?? ""

//                print("partid=\(partnerId)\nprepayid=\(prepayId)\nnoncestr=\(nonceStr)\ntimestamp=\(timeStamp)\npackage=\(package)\nsign=\(sign)");

                CRUltimatePay.sharedInstance().setWXpay(partnerId: partnerId, prepayId: prepayId, nonceStr: nonceStr, timeStamp: timeStamp, package: package, sign: sign, delegate: self)
                

                CRUltimatePay.sharedInstance().startWXpay({ (result, string) in
                    
                    var text = ""
                    
                    switch result {
                    case .success:  text = "支付成功"
                    case .fail: text = "支付失败"
                    case .cancel:   text = "支付取消"
                    case .process:  text = "支付进行中"
                    default: break
                    }
                    
                    UIAlertView(title: "提示", message: text, delegate: nil, cancelButtonTitle: "知道了").show()

                })
                
            }
            
        }catch let error as NSError{
            //打印错误消息
            print(error.code)
            print(error.description)
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

