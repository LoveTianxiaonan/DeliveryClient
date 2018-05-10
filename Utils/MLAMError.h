//
//  MLAMError.h
//  MaxLeapGit
//
//  Created by Michael on 15/10/9.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MLAMErrorType) {
    MLAMErrorTypeDefault,
    MLAMErrorTypeServerNotReturnDesiredData = 1000,
    MLAMErrorTypeServerDataFormateError,
    MLAMErrorTypeServerDataNil,
    MLAMErrorTypeServerResponseError,
    MLAMErrorTypeBadCredentials,
    MLAMErrorTypeNoOnlineAccount,
    MLAMErrorTypeAccountAlreadyRegistered,
    MLAMErrorTypeAccountInexistent,
    MLAMErrorTypeAccountCellPhoneApplied,
    MLAMErrorTypeWrongPassword,
    
    MLAMErrorTypeWrongValidationCode,
    MLAMErrorTypeProductInfoChanged,
    MLAMErrorTypePaymentCancelled,
    MLAMErrorTypePaymentFailed,
    MLAMErrorTypePaymentUnknownError,
    MLAMErrorTypeSessionTokenExpired,
    MLAMErrorTypeThirdPartyInfoUnmatched,
    MLAMErrorTypeConnectLost = NSURLErrorNotConnectedToInternet,
    MLAMErrorTypeTimeOut = NSURLErrorTimedOut,
    MLAMErrorTypeCannotConnectToHost = NSURLErrorCannotConnectToHost,
    MLAMErrorTypePostContentEmpty,
    
    MLAMErrorTypeArticleNotExist,
    MLAMErrorTypeProductNotExist,
    MLAMErrorTypeProductInvalid, //商品被禁用（下架）
    MLAMErrorTypeNotExistAccount,
    MLAMErrorTypeCreateLiveIMRoom
};

@interface MLAMError : NSError
+ (NSError *)errorWithCode:(MLAMErrorType)errorType message:(NSString *)message;
@end
