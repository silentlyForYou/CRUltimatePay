//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                break;
            case WXErrCodeUserCancel:
                strMsg = @"支付结果：用户取消！";
                break;
            case WXErrCodeCommon:
                strMsg = @"支付结果：支付失败！";
                break;
            case WXErrCodeSentFail:
                strMsg = @"支付结果：发送失败！";
                break;
            case WXErrCodeAuthDeny:
                strMsg = @"支付结果：授权失败！";
                break;
            case WXErrCodeUnsupport:
                strMsg = @"支付结果：微信不支持！";
                break;
                
            default:
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

@end
