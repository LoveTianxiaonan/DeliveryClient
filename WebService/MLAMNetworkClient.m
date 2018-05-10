//
//  MLGMAccountManager+Convenience.m
//  MaxLeapGit
//
//  Created by Michael on 15/10/9.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLAMNetworkClient.h"

#define kTimeOutInvervalForRequest 30

typedef void(^SessionrResponse)(NSInteger statusCode, NSData *receiveData, NSError *error);

@implementation MLAMNetworkClient
+ (MLAMNetworkClient *)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        MLAMNetworkClient *networkClient = [MLAMNetworkClient new];
        return networkClient;
    });
}

- (JSONValidation *)jsonValidation {
    static JSONValidation *jsonValidation = nil;
    if (!jsonValidation) {
        jsonValidation = [JSONValidation new];
    }
    
    return jsonValidation;
}

- (NSURLRequest *)getRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)queryParameters {
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", kMaxLeapBaseName, endPoint];
    requestURLString = [requestURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (queryParameters) {
        requestURLString = [requestURLString stringByAppendingFormat:@"?%@", queryParameters.queryParameter];
    }
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    request.timeoutInterval = kTimeOutInvervalForRequest;
    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([MAXLEAP_APPID length] > 0) {
        [request setValue:MAXLEAP_APPID forHTTPHeaderField:@"X-ML-AppId"];
    }
    
    if ([MAXLEAP_CLIENTKEY length] > 0) {
        [request setValue:MAXLEAP_CLIENTKEY forHTTPHeaderField:@"X-ML-APIKey"];
    }
    
    if (kMaxLeapSessionToken.length > 0) {
        [request setValue:kMaxLeapSessionToken forHTTPHeaderField:@"X-ML-Session-Token"];
    }

    return request;
}

- (NSURLRequest *)postRequestWithEndPoint:(NSString *)endPoint parameters:(id)postParameters {
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", kMaxLeapBaseName, endPoint];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.timeoutInterval = kTimeOutInvervalForRequest;
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([MAXLEAP_APPID length] > 0) {
        [request setValue:MAXLEAP_APPID forHTTPHeaderField:@"X-ML-AppId"];
    }
    
    if ([MAXLEAP_CLIENTKEY length] > 0) {
        [request setValue:MAXLEAP_CLIENTKEY forHTTPHeaderField:@"X-ML-APIKey"];
    }
    
    if (kMaxLeapSessionToken.length > 0) {
        [request setValue:kMaxLeapSessionToken forHTTPHeaderField:@"X-ML-Session-Token"];
    }
    
    NSLog(@"%@", kMaxLeapSessionToken);
    
    [request setHTTPMethod:@"POST"];
    NSString *jsonParameterString = nil;
    if ([postParameters isKindOfClass:[NSDictionary class]]) {
        jsonParameterString = ((NSDictionary *)postParameters).jsonParameter;
    } else if ([postParameters isKindOfClass:[NSArray class]]) {
        jsonParameterString = ((NSArray *)postParameters).jsonParameter;
    }
    NSData *postData = [jsonParameterString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    
    return request;
}

- (NSURLRequest *)putRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)postParameters {
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", kMaxLeapBaseName, endPoint];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.timeoutInterval = kTimeOutInvervalForRequest;
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    
    if ([MAXLEAP_APPID length] > 0) {
        [request setValue:MAXLEAP_APPID forHTTPHeaderField:@"X-ML-AppId"];
    }
    
    if ([MAXLEAP_CLIENTKEY length] > 0) {
        [request setValue:MAXLEAP_CLIENTKEY forHTTPHeaderField:@"X-ML-APIKey"];
    }
    
    if (kMaxLeapSessionToken.length > 0) {
        [request setValue:kMaxLeapSessionToken forHTTPHeaderField:@"X-ML-Session-Token"];
    }
    
    [request setHTTPMethod:@"PUT"];
    NSData *postData = [postParameters.jsonParameter dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    
    return request;
}

- (NSURLRequest *)deleteRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)postParameters {
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", kMaxLeapBaseName, endPoint];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.timeoutInterval = kTimeOutInvervalForRequest;
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([MAXLEAP_APPID length] > 0) {
        [request setValue:MAXLEAP_APPID forHTTPHeaderField:@"X-ML-AppId"];
    }
    
    if ([MAXLEAP_CLIENTKEY length] > 0) {
        [request setValue:MAXLEAP_CLIENTKEY forHTTPHeaderField:@"X-ML-APIKey"];
    }
    
    if (kMaxLeapSessionToken.length > 0) {
        [request setValue:kMaxLeapSessionToken forHTTPHeaderField:@"X-ML-Session-Token"];
    }
    
    [request setHTTPMethod:@"DELETE"];
    NSData *postData = [postParameters.jsonParameter dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    
    return request;
}

- (void)startRequest:(NSURLRequest *)request patternFile:(NSString *)normalResponsePatternFile completion:(CompleteHanderBlock)completion {
    NSLog(@"sessionToken = %@", kMaxLeapSessionToken);
    NSURLSessionDataTask *sessionTask = [self.class.sharedAppURLSession dataTaskWithRequest:request completionHandler:^(NSData *receiveData, NSURLResponse *response, NSError *error) {
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (error) {
            if (error.code == NSURLErrorNotConnectedToInternet) {
                error = [MLAMError errorWithCode:MLAMErrorTypeConnectLost message:nil];
            }
            
            if (error.code == NSURLErrorTimedOut) {
                error = [MLAMError errorWithCode:MLAMErrorTypeTimeOut message:nil];
            }
            
            if (error.code == NSURLErrorCannotConnectToHost) {
                error = [MLAMError errorWithCode:MLAMErrorTypeCannotConnectToHost message:nil];
            }
            
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            return;
        }
        
        if (statusCode != 200) {
            if (receiveData.length > 0) {
                NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:receiveData options:0 error:nil];
                if ([responseData isKindOfClass:[NSDictionary class]]) {
                    NSInteger errorCode = [responseData[@"errorCode"] integerValue];
                    NSString *errorMessage = responseData[@"errorMessage"];
                    
                    //90100 - SESSION_TOKEN_INVALID
                    //90101 - SESSION_TOKEN_EXPIRED
                    if (errorCode == 90101 || errorCode == 90100 || statusCode == 401) {
                        dispatch_async(dispatch_get_main_queue(),^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutNotification" object:nil userInfo:nil];
                        });
                    }
                    //MLAMErrorTypeAccountInexistent
                    
                    if (errorCode == 301 || errorCode == 903 || errorCode == 904) {
                        NSError *responseError = [MLAMError errorWithCode:MLAMErrorTypeWrongValidationCode message:errorMessage];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, responseError);
                        return;
                        
                    } else if (errorCode == 900) {
                        NSError *responseError = [MLAMError errorWithCode:MLAMErrorTypeAccountAlreadyRegistered message:errorMessage];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, responseError);
                        return;
                        
                    }else if (errorCode == 901 || errorCode == 40010) {
                        NSError *responseError = [MLAMError errorWithCode:MLAMErrorTypeWrongPassword message:errorMessage];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, responseError);
                        return;
                        
                    } else if (errorCode == 902) {
                        NSError *responseError = [MLAMError errorWithCode:MLAMErrorTypeAccountInexistent message:errorMessage];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, responseError);
                        return;
                        
                    } else if (errorCode == 905) {
                        NSError *responseError = [MLAMError errorWithCode:MLAMErrorTypeAccountCellPhoneApplied message:errorMessage];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, responseError);
                        return;
                        
                    } else if (errorCode == 401 || errorCode == 90100) {
                        NSError *responseError = [MLAMError errorWithCode:MLAMErrorTypeBadCredentials message:errorMessage];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, responseError);
                        return;
                        
                    } else if (errorCode == 90101) {
                        error = [MLAMError errorWithCode:MLAMErrorTypeSessionTokenExpired message:nil];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                        return;
                    } else if (errorCode == 217) {
                        error = [MLAMError errorWithCode:MLAMErrorTypeProductInfoChanged message:nil];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                        return;
                    } else if (errorCode == 40207) {
                        error = [MLAMError errorWithCode:MLAMErrorTypeArticleNotExist message:nil];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                        return;
                    } else if (errorCode == 651) {
                        error = [MLAMError errorWithCode:MLAMErrorTypeProductNotExist message:nil];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                        return;
                    } else if (errorCode == 650) {
                        error = [MLAMError errorWithCode:MLAMErrorTypeProductInvalid message:NSLocalizedString(@"商品已下架", nil)];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                        return;
                        
                    } else if (errorCode == 406) {
                        error = [MLAMError errorWithCode:MLAMErrorTypeNotExistAccount message:nil];
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                        return;
                    }
                    error = [MLAMError errorWithCode:MLAMErrorTypeServerResponseError message:errorMessage];
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                    return;
                }
            }
            NSString *errorMessage;
            
            if (receiveData.length > 0) {
                errorMessage = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
            } else {
                errorMessage = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            }
            error = [MLAMError errorWithCode:MLAMErrorTypeServerResponseError message:errorMessage];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            return;
        }
        
        // 以下处理statuscode=200情况
        if (receiveData.length == 0) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, nil);
            return;
        }
        
        NSError *parseError = nil;
        id responseObject = [NSJSONSerialization JSONObjectWithData:receiveData options:0 error:&parseError];
        if (parseError) {
            NSError *error = [MLAMError errorWithCode:MLAMErrorTypeServerDataFormateError message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, receiveData, error);
            return;
        }
        
        BOOL (^exceptionResponseBlock)(void) = ^BOOL {
            NSString *exceptionResponsePatternFile = @"ErrorResponsePattern.json";
            id exceptionResponsePattern = [[NSBundle mainBundle] jsonFromResource:exceptionResponsePatternFile];
            BOOL exceptionResponseValid = [kSharedNetworkClient.jsonValidation verifyJSON:responseObject pattern:exceptionResponsePattern];
            if (exceptionResponseValid) {
                NSString *errorMessage = responseObject[@"errorMessage"];
                NSNumber *errorCode = responseObject[@"errorCode"];
                NSString *errorDesc = [NSString stringWithFormat:@"%@(%@)", errorMessage, errorCode];
                NSError *error = [MLAMError errorWithCode:MLAMErrorTypeServerResponseError message:errorDesc];
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            }
            
            return exceptionResponseValid;
        };
        
        
        //有正确的patter文件时先校验，不正确时：校验ErrorResponsePattern，符合错误格式则提示服务器响应错误；也不符合ErrorResponsePattern时，返回相对正确模式文件而言错误的patternStack
        if (normalResponsePatternFile.length > 0) {
            NSError *jsonVerifyError;
            id normalResponsePattern = [[NSBundle mainBundle] jsonFromResource:normalResponsePatternFile];
            BOOL normalResponseValid = [kSharedNetworkClient.jsonValidation verifyJSON:responseObject pattern:normalResponsePattern error:&jsonVerifyError];
            if (!normalResponseValid) {
                BOOL exceptionResponseValid = exceptionResponseBlock();
                if (!exceptionResponseValid) {
                    if (jsonVerifyError) {
                        NSLog(@"verifyJSON - Error: %@", jsonVerifyError);
                        error = [MLAMError errorWithCode:MLAMErrorTypeServerDataFormateError message:nil];
                    }
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
                }
                return;
            }
        } else {
            BOOL exceptionResponseValid = exceptionResponseBlock();
            if (exceptionResponseValid) {
                return;
            }
        }
        
        NSDictionary *responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, responseHeaderFields, statusCode, responseObject, nil);
    }];
    
    [sessionTask resume];
}

- (void)uploadRequest:(NSURLRequest *)request data:(NSData *)data completion:(CompleteHanderBlock)completion {
    NSURLSessionUploadTask *uploadTask = [self.class.sharedAppURLSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable receiveData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            return;
        }
        
        if (statusCode == 401) {
            error = [MLAMError errorWithCode:MLAMErrorTypeBadCredentials message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            return;
        }
        
        if (statusCode == 304) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, nil);
            return;
        }
        
        if (statusCode >= 400) {
            NSString *errorMessage;
            if (receiveData.length > 0) {
                errorMessage = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
            } else {
                errorMessage = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            }
            error = [MLAMError errorWithCode:MLAMErrorTypeServerResponseError message:errorMessage];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            return;
        }

        
        NSError *parseError = nil;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:receiveData options:0 error:&parseError];
        if (parseError) {
            NSError *error = [MLAMError errorWithCode:MLAMErrorTypeServerDataFormateError message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, statusCode, nil, error);
            return;
        }
        
        NSDictionary *responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, responseHeaderFields, statusCode, responseObject, nil);
    }];
    
    [uploadTask resume];
}

- (void)cancelAllDataTasksCompletion:(void(^)())completion {
    [[NSURLSession sharedSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [dataTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask *oneDataTask, NSUInteger idx, BOOL *stop) {
            if (oneDataTask.state == NSURLSessionTaskStateRunning) {
                [oneDataTask cancel];
            }
        }];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil);
    }];
}

+ (NSURLSession *)sharedAppURLSession {
    static NSURLSession *kSharedAppURLSessionUsession;
    if (!kSharedAppURLSessionUsession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 60;
        kSharedAppURLSessionUsession = [NSURLSession sessionWithConfiguration:configuration];
    }
    
    return kSharedAppURLSessionUsession;
}

@end
