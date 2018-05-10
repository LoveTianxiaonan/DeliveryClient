//
//  MLAMWebService.h
//  LiveVideo
//
//  Created by Michael on 10/24/16.
//  Copyright © 2016 xiexufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MLAMOrder;

typedef NS_ENUM(NSInteger, MLAMOrderState) {
    MLAMOrderStateNew = 2,
    MLAMOrderStateGotoTake = 10,
    MLAMOrderStateInDelivery = 11,
    MLAMOrderStateCompleted = 12
};
static NSUInteger const kPerPageForCollectionView = 20;
static NSUInteger const kPerPage = 6;

#define kSharedWebService [MLAMWebService sharedInstance]

@interface MLAMWebService : NSObject
+ (MLAMWebService *)sharedInstance;

- (void)loginWithPhone:(NSString *)phoneNum
              password:(NSString *)password
          validateCode:(NSString *)validateCode
              security:(NSString *)security
            completion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)updateDeliverInfoWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)obtainValidateCodeCompletion:(void(^)(NSString *secret, UIImage *validateImage, NSError *error))completion;
- (void)fetchAppleStoreIDWithBundleID:(NSString *)bundleID completion:(void(^)(NSNumber *appleStoreID, NSError *error))completion;

- (void)fetchOrdersWithState:(MLAMOrderState)state page:(NSInteger)page completion:(void(^)(NSMutableArray *orders,BOOL didReachEnd, NSError *error))completion;
- (void)fetchOrderDetail:(MLAMOrder *)order completion:(void(^)(MLAMOrder *order, NSError *error))completion;
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
