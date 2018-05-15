//
//  SYWebService.h
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYOrder;

typedef NS_ENUM(NSInteger, SYOrderState) {
    SYOrderStateNew = 2,
    SYOrderStateGotoTake = 10,
    SYOrderStateInDelivery = 11,
    SYOrderStateCompleted = 12
};
static NSUInteger const kPerPageForCollectionView = 20;
static NSUInteger const kPerPage = 6;

#define kSharedWebService [SYWebService sharedInstance]

@interface SYWebService : NSObject
+ (SYWebService *)sharedInstance;

- (void)loginWithPhone:(NSString *)phoneNum
              password:(NSString *)password
          validateCode:(NSString *)validateCode
              security:(NSString *)security
            completion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)updateDeliverInfoWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)obtainValidateCodeCompletion:(void(^)(NSString *secret, UIImage *validateImage, NSError *error))completion;
- (void)fetchAppleStoreIDWithBundleID:(NSString *)bundleID completion:(void(^)(NSNumber *appleStoreID, NSError *error))completion;

- (void)fetchOrdersWithState:(SYOrderState)state page:(NSInteger)page completion:(void(^)(NSMutableArray *orders,BOOL didReachEnd, NSError *error))completion;
- (void)fetchOrderDetail:(SYOrder *)order completion:(void(^)(SYOrder *order, NSError *error))completion;
- (void)fetchHistoryOrdersWithYear:(NSInteger)year
                             month:(NSInteger)month
                              page:(NSInteger)page
                        completion:(void(^)(NSMutableArray *orders,BOOL didReachEnd, NSError *error))completion;

- (void)grabOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion;
- (void)giveupOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion;
- (void)shippingOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion;
- (void)completedOrderWithOrderId:(NSString *)orderId completion:(void(^)(BOOL success, NSError *error))completion;

- (void)updateLocation:(double)latitude longitude:(double)longitude;

- (void)fetchPushNotificationSwitchStateWithCompletion:(void(^)(BOOL open, NSError *error))completion;
- (void)updatePushNotificationSwitchState:(BOOL)open completion:(void(^)(BOOL success, NSError *error))completion;
- (void)getProductCustomFieldsComplention:(void(^)(BOOL success, NSError *error))completion;


@end
