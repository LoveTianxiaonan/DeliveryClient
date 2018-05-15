//
//  SYWebService.m
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYWebService.h"

@implementation SYWebService

+ (SYWebService *)sharedInstance {
    static SYWebService *sharedInstance = nil;
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        sharedInstance = [self new];
        return sharedInstance;
    });
}

- (void)loginWithPhone:(NSString *)phoneNum password:(NSString *)password validateCode:(NSString *)validateCode security:(NSString *)security completion:(void (^)(BOOL, NSError *))completion {
    NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
    if ([phoneNum containsString:@"@"]) {
        [parametersDict setObject:phoneNum forKey:@"email"];
    } else {
        [parametersDict setObject:phoneNum forKey:@"phone"];
    }
    [parametersDict setObject:[@(kSharedDeliveryPerson.latitude) stringValue] forKey:@"latitude"];
    [parametersDict setObject:[@(kSharedDeliveryPerson.longitude) stringValue] forKey:@"longitude"];
    [parametersDict setObject:[MLInstallation currentInstallation].installationId?:@"" forKey:@"installationId"];
    [parametersDict setObject:password forKey:@"password"];
    [parametersDict setObject:ApplicationID forKey:@"sourceApp"];
    if (validateCode.length > 0 && security.length > 0) {
        [parametersDict setObject:@{@"challenge":validateCode, @"secret": security} forKey:@"captcha"];
    }
    
    NSString *endPoint = @"/mall/users/distUserLogin";
    NSURLRequest *urlRequest = [kSharedNetworkClient postRequestWithEndPoint:endPoint parameters:parametersDict];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            NSLog(@"/passwordLogin api error:%@", error.localizedDescription);
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        
        NSString *appId = [responseData valueForKeyPath:@"appId"];
        NSString *apiKey = [responseData valueForKeyPath:@"apiKey"];
        NSString *sessionToken = [responseData valueForKeyPath:@"sessionToken"];
        NSString *userName = [responseData valueForKeyPath:@"username"];
        NSString *userIcon = [responseData valueForKeyPath:@"ico"];
        NSString *userPhone = [responseData valueForKeyPath:@"phone"];
        NSString *userId = [[responseData valueForKeyPath:@"id"] stringValue];
        NSArray *productCustomFields = NULL_TO_NIL(responseData[@"customFields"]);
        kSharedDeliveryPerson.productCustomFields = productCustomFields;
        kSharedDeliveryPerson.appid = appId;
        kSharedDeliveryPerson.apiKey = apiKey;
        kSharedDeliveryPerson.userSession = sessionToken;
        kSharedDeliveryPerson.userName = userName;
        kSharedDeliveryPerson.userIcon = userIcon;
        kSharedDeliveryPerson.userPhone = userPhone;
        kSharedDeliveryPerson.sysUserId = userId;
        [kSharedDeliveryPerson updateCurrentLocationToServer];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion,YES, nil);
    }];
}

- (void)updateDeliverInfoWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
    if (kSharedDeliveryPerson.sysUserId.length == 0) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
        return;
    }
    NSString *endPoint = [NSString stringWithFormat:@"/mallDistUser/bySysUserId/simplify/%@",kSharedDeliveryPerson.sysUserId];
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest
                           patternFile:nil
                            completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
                                if  (error) {
                                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
                                    return;
                                }
                                kSharedDeliveryPerson.userIcon = responseData[@"icon"];
                                kSharedDeliveryPerson.userName = responseData[@"name"];
                                kSharedDeliveryPerson.userPhone = responseData[@"phone"];
                                BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
                            }];
}

- (void)obtainValidateCodeCompletion:(void(^)(NSString *secret, UIImage *validateImage, NSError *error))completion {
    [self obtainValidateSecurityCompletion:^(NSString *validateCode, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil, error);
            return;
        }
        
        [self obtainValidateImageWithSecurity:validateCode completion:^(UIImage *validateImage, NSError *error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, validateCode, validateImage, error);
        }];
    }];
}

- (void)obtainValidateSecurityCompletion:(void(^)(NSString *security, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/captcha/secret?_=0.5305990553330922"];
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest
                           patternFile:nil
                            completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
                                if  (error) {
                                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
                                    return;
                                }
                                
                                NSString *security = responHeaderFields[@"X-LAS-SECRET"];
                                BLOCK_SAFE_ASY_RUN_MainQueue(completion, security, nil);
                            }];
}

- (void)obtainValidateImageWithSecurity:(NSString *)security completion:(void(^)(UIImage *validateImage, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/captcha?secret=%@", security];
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest
                           patternFile:nil
                            completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
                                if  (statusCode != 200) {
                                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
                                    return;
                                }
                                
                                UIImage *image = [UIImage imageWithData:responseData];
                                BLOCK_SAFE_ASY_RUN_MainQueue(completion, image, nil);
                            }];
}

- (void)fetchAppleStoreIDWithBundleID:(NSString *)bundleID completion:(void(^)(NSNumber *appleStoreID, NSError *error))completion {
    NSString *requestURLString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleID];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURLString.toURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *receiveData, NSURLResponse *response, NSError *error) {
        if (error)  {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
            return;
        }
        
        if (receiveData.length == 0) {
            error = [MLAMError errorWithCode:MLAMErrorTypeServerDataNil message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
            return;
        }
        
        NSString *returnString=[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        returnString = [returnString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"%@", returnString);
        NSData *jsonData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
            return;
        }
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            error = [MLAMError errorWithCode:MLAMErrorTypeServerDataFormateError message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
            return;
        }
        
        NSArray *results = [responseObject valueForKey:@"results"];
        
        if (![results isKindOfClass:[NSArray class]]) {
            error = [MLAMError errorWithCode:MLAMErrorTypeServerDataFormateError message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
            return;
        }
        
        NSDictionary *firstObject = [results firstObject];
        if (![firstObject isKindOfClass:[NSDictionary class]]) {
            error = [MLAMError errorWithCode:MLAMErrorTypeServerDataFormateError message:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
            return;
        }
        
        NSNumber *appleStoreID = firstObject[@"trackId"];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, appleStoreID, nil);
    }];
    
    [sessionTask resume];
}

- (void)fetchOrdersWithState:(SYOrderState)state page:(NSInteger)page completion:(void(^)(NSMutableArray *orders,BOOL didReachEnd, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/status/%d",(int)state];
    NSDictionary *dic = @{@"limit" : @(kPerPage),
                          @"skip": @(kPerPage*page),
                          @"order": @"-updatedAt,-createdAt",
                          @"la":[@(kSharedDeliveryPerson.latitude) stringValue],
                          @"lo" :[@(kSharedDeliveryPerson.longitude) stringValue]};
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:dic];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil,YES, error);
            return;
        }
        NSMutableArray *orderArray = [NSMutableArray array];
        NSArray *orderDics = responseData[@"results"];
        [orderDics enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SYOrder *order = [SYOrder new];
            [order fillOrderMOFromOrderDict:obj];
            [orderArray addObject:order];
        }];
        
        /*
         //test code
         MLAMOrder *order = [MLAMOrder new];
         order.createdAt = [NSDate date];
         order.billNum = @"123131212312343543534";
         order.expectedDeliveryTime = @(40);
         order.orderId = @"12";
         order.orderState = @(state);
         order.deliveryDistance = @(2.8);
         order.mallDistance = @(1.8);
         order.memberId = @"56";
         order.mallId = @"100";
         order.mallName = @"三米粥店铺(吴中路店)";
         order.mallPhone = @"1800000063";
         order.mallAddress = @"上海市徐汇区虹桥镇的店吴中路 962号";
         order.mallLatitude = @(31.1747800000);
         order.mallLongitude = @(121.418082000);
         order.invoiceHead = @"上海力谱宿云信息科技有限公司";
         order.remarks = @"开发票，上次和这次开一张,开发票，上次和这次开一张,开发票，上次和这次开一张,开发票，上次和这次开一张";
         order.realPrice = [NSDecimalNumber decimalNumberWithDecimal:@(6000).decimalValue];
         order.totalPrice = [NSDecimalNumber decimalNumberWithDecimal:@(7800).decimalValue];
         order.freightFee = [NSDecimalNumber decimalNumberWithDecimal:@(500).decimalValue];
         order.discountFee = [NSDecimalNumber decimalNumberWithDecimal:@(1300).decimalValue];
         order.receiverLatitude = @(31.1672500000);
         order.receiverLongitude = @(121.4287900000);
         order.receiverAddress = @"新银大厦(上海市徐汇区宜山路888号新银大厦21楼)";
         order.receiverPhone = @"18602166463";
         order.receiverName = @"丽丽";
         order.grabOrderTime = [NSDate dateWithTimeIntervalSinceNow:-60*50];
         NSMutableArray *items = [NSMutableArray array];
         for (int i = 0; i < 3; i++) {
         MLAMOrderItem *item = [MLAMOrderItem new];
         item.orderItemId = @"123";
         item.orderId = @"12";
         item.quantity = @(i+1);
         item.title = [NSString stringWithFormat:@"冬天暖袜子-冬天暖袜子冬天暖袜子冬天暖袜子-%d",i+1];
         item.price = [NSDecimalNumber decimalNumberWithDecimal:@(1000).decimalValue];
         [items addObject:item];
         }
         order.orderItems = items;
         [orderArray addObject:order];
         //test code------
         */
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, orderArray,orderArray.count < kPerPage, nil);
    }];
}

- (void)fetchOrderDetail:(SYOrder *)order completion:(void(^)(SYOrder *order, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/%@",order.orderId];
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion,order, error);
            return;
        }
        [order fillOrderMOFromDetail:responseData];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, order, nil);
    }];
    
}

- (void)grabOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/grab/%@",orderId];
    NSURLRequest *urlRequest = [kSharedNetworkClient postRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        BOOL grabed = [error.localizedDescription containsString:@"43002"];
        if (error && !grabed) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, !grabed, nil);
    }];
}

- (void)giveupOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/giveup/%@",orderId];
    NSURLRequest *urlRequest = [kSharedNetworkClient postRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
    }];
}

- (void)shippingOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/shipping/%@",orderId];
    NSURLRequest *urlRequest = [kSharedNetworkClient postRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
    }];
}

- (void)completedOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/shipped/%@",orderId];
    NSURLRequest *urlRequest = [kSharedNetworkClient postRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
    }];
}

- (void)updateLocation:(double)latitude longitude:(double)longitude {
    if (kSharedDeliveryPerson.sysUserId.length == 0) {
        return;
    }
    NSString *endPoint = [NSString stringWithFormat:@"/mallDistUser/updateDistUserCoordinateBySysUserId/%@",kSharedDeliveryPerson.sysUserId];
    NSDictionary *dic = @{@"latitude":[@(latitude) stringValue],@"longitude":[@(longitude) stringValue]};
    NSURLRequest *urlRequest = [kSharedNetworkClient putRequestWithEndPoint:endPoint parameters:dic];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            NSLog(@"更新配送员经纬度失败:%@", error);
            return;
        }
    }];
}

- (void)fetchHistoryOrdersWithYear:(NSInteger)year month:(NSInteger)month page:(NSInteger)page completion:(void(^)(NSMutableArray *orders,BOOL didReachEnd, NSError *error))completion {
    NSString *endPoint = [NSString stringWithFormat:@"/mall/distOrders/status/%d",(int)SYOrderStateCompleted];
    NSMutableDictionary *dic = [@{@"limit" : @(kPerPage),
                                  @"skip": @(kPerPage*page),
                                  @"order":@"-createdAt"} mutableCopy];
    if (year > 0 && month > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        NSDate *beginDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-01 00:00",(long)year,(long)month]];
        if (month+1 > 12) {
            year = year+1;
            month = 1;
        }else {
            month = month+1;
        }
        NSDate *endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-01 00:00",(long)year,(long)month]];
        NSString *where = [NSString stringWithFormat:@"{\"$and\":[{\"createdAt\":{\"$gt\":%lld}}, {\"createdAt\":{\"$lt\":%lld}}]}",
                           (long long)[beginDate timeIntervalSince1970]*1000,(long long)[endDate timeIntervalSince1970]*1000];
        [dic setObject:where forKey:@"where"];
    }
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:dic];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil,YES, error);
            return;
        }
        NSMutableArray *orderArray = [NSMutableArray array];
        NSArray *orderDics = responseData[@"results"];
        [orderDics enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SYOrder *order = [SYOrder new];
            [order fillOrderMOFromOrderDict:obj];
            [orderArray addObject:order];
        }];
        /*
         //test code
         MLAMOrder *order = [MLAMOrder new];
         order.createdAt = [NSDate date];
         order.billNum = @"123131212312343543534";
         order.expectedDeliveryTime = @(40);
         order.orderId = @"12";
         order.orderState = @(MLAMOrderStateCompleted);
         order.deliveryDistance = @(2.8);
         order.mallDistance = @(1.8);
         order.memberId = @"56";
         order.mallId = @"100";
         order.mallName = @"三米粥店铺(吴中路店)";
         order.mallPhone = @"1800000063";
         order.mallAddress = @"上海市徐汇区虹桥镇的店吴中路 962号";
         order.mallLatitude = @(31.1747800000);
         order.mallLongitude = @(121.418082000);
         order.invoiceHead = @"上海力谱宿云信息科技有限公司";
         order.remarks = @"开发票，上次和这次开一张,开发票，上次和这次开一张,开发票，上次和这次开一张,开发票，上次和这次开一张";
         order.realPrice = [NSDecimalNumber decimalNumberWithDecimal:@(6000).decimalValue] ;
         order.totalPrice = [NSDecimalNumber decimalNumberWithDecimal:@(7800).decimalValue];
         order.freightFee = [NSDecimalNumber decimalNumberWithDecimal:@(500).decimalValue];
         order.discountFee = [NSDecimalNumber decimalNumberWithDecimal:@(1300).decimalValue];
         order.receiverLatitude = @(31.1672500000);
         order.receiverLongitude = @(121.4287900000);
         order.receiverAddress = @"新银大厦(上海市徐汇区宜山路888号新银大厦21楼)";
         order.receiverPhone = @"18602166463";
         order.receiverName = @"丽丽";
         NSMutableArray *items = [NSMutableArray array];
         for (int i = 0; i < 3; i++) {
         MLAMOrderItem *item = [MLAMOrderItem new];
         item.orderItemId = @"123";
         item.orderId = @"12";
         item.quantity = @(i+1);
         item.title = [NSString stringWithFormat:@"冬天暖袜子--%d",i+1];
         item.price = [NSDecimalNumber decimalNumberWithDecimal:@(1000).decimalValue];
         [items addObject:item];
         }
         order.orderItems = items;
         [orderArray addObject:order];
         //test code
         */
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, orderArray,orderArray.count < kPerPage, nil);
    }];
}


- (void)fetchPushNotificationSwitchStateWithCompletion:(void(^)(BOOL open, NSError *error))completion {
    NSString *endPoint = @"/settings/mall/sys/push";
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, [responseData[@"mallDeliveryPush"] boolValue], nil);
    }];
}

- (void)updatePushNotificationSwitchState:(BOOL)open completion:(void(^)(BOOL success, NSError *error))completion {
    NSString *endPoint = @"/settings/mall/sys/push";
    NSURLRequest *urlRequest = [kSharedNetworkClient putRequestWithEndPoint:endPoint parameters:@{@"mallDeliveryPush":[@(open) stringValue]}];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
    }];
}
- (void)getProductCustomFieldsComplention:(void(^)(BOOL success, NSError *error))completion{
    NSString *endPoint = @"/apps/product/customFields";
    NSURLRequest *urlRequest = [kSharedNetworkClient getRequestWithEndPoint:endPoint parameters:nil];
    [kSharedNetworkClient startRequest:urlRequest patternFile:nil completion:^(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        NSArray *productCustomFields = NULL_TO_NIL(responseData[@"customFields"]);
        kSharedDeliveryPerson.productCustomFields = productCustomFields;
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
    }];
}

@end
