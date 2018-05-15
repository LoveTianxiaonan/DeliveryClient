//
//  MLAMError.m
//  MaxLeapGit
//
//  Created by Michael on 15/10/9.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLAMError.h"

NSString* const MLAMErrorDomain = @"MLAMErrorDomain";

@implementation MLAMError

+ (NSError *)errorWithCode:(MLAMErrorType)errorType message:(NSString *)message {
    NSError *error;
    
    if (message.length > 0) {
        error = [NSError errorWithDomain:MLAMErrorDomain
                                    code:errorType
                                userInfo:@{NSLocalizedDescriptionKey:SAFE_STRING(message)}];
    } else {
        switch (errorType) {
            case MLAMErrorTypeServerDataNil:
                message = NSLocalizedString(@"服务器返回数据为空", nil);
                break;
            case MLAMErrorTypeServerDataFormateError:
                message = NSLocalizedString(@"服务器返回数据格式不正确", nil);
                break;
            case MLAMErrorTypeServerResponseError:
                message = NSLocalizedString(@"请求响应失败", nil);
                break;
            case MLAMErrorTypeServerNotReturnDesiredData:
                message = NSLocalizedString(@"服务器没有返回期望的数据", nil);
                break;
            case MLAMErrorTypeBadCredentials:
                message = NSLocalizedString(@"非法Access Token", nil);
                break;
            case MLAMErrorTypeNoOnlineAccount:
                message = NSLocalizedString(@"没有登录的账号", nil);
                break;
            case MLAMErrorTypeAccountAlreadyRegistered:
                message = NSLocalizedString(@"此帐户已被注册", nil);
                break;
            case MLAMErrorTypeAccountCellPhoneApplied:
                message = NSLocalizedString(@"此手机号正在被审核", nil);
                break;
            case MLAMErrorTypeAccountInexistent:
                message = NSLocalizedString(@"此帐户不存在", nil);
                break;
            case MLAMErrorTypeWrongPassword:
                message = NSLocalizedString(@"密码错误", nil);
                break;
            case MLAMErrorTypeWrongValidationCode:
                message = NSLocalizedString(@"验证码错误", nil);
                break;
            case MLAMErrorTypePaymentCancelled:
                message = NSLocalizedString(@"取消支付", nil);
                break;
            case MLAMErrorTypePaymentFailed:
                message = NSLocalizedString(@"支付失败", nil);
                break;
            case MLAMErrorTypePaymentUnknownError:
                message = NSLocalizedString(@"支付发生未知错误", nil);
                break;
            case MLAMErrorTypeSessionTokenExpired:
                message = NSLocalizedString(@"Session token已过期", nil);
                break;
            case MLAMErrorTypeProductInfoChanged:
                message = NSLocalizedString(@"商品信息已变化，请返回更改", nil);
                break;
            case MLAMErrorTypeThirdPartyInfoUnmatched:
                message = NSLocalizedString(@"第三方认证信息不一致", nil);
                break;
            case MLAMErrorTypeConnectLost:
                message = NSLocalizedString(@"没有网络连接", nil);
                break;
            case MLAMErrorTypeTimeOut:
                message = NSLocalizedString(@"请求超时", nil);
                break;
            case MLAMErrorTypeCannotConnectToHost:
                message = NSLocalizedString(@"无法连接到主机", nil);
                break;
            case MLAMErrorTypePostContentEmpty:
                message = NSLocalizedString(@"发帖内容为空", nil);
                break;
            case MLAMErrorTypeCreateLiveIMRoom:
                message = NSLocalizedString(@"没有创建IM聊天室", nil);
                break;
            case MLAMErrorTypeNotExistAccount:
                message = NSLocalizedString(@"账号不存在", nil);
                break;
            default:
                message = NSLocalizedString(@"未知原因", nil);
                break;
        }
      
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        if (message.length > 0) {
            [userInfo setObject:message forKey:NSLocalizedDescriptionKey];
        }
        
        error = [NSError errorWithDomain:MLAMErrorDomain code:errorType userInfo:userInfo];
    }
    
    return error;
}


@end
