//
//  MLAMOrder.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/6.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MLAMOrderItem;
@class MLAMUser;
@interface MLAMOrder : NSObject
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *billNum;
@property (nullable, nonatomic, retain) NSNumber *deliveryDistance;         //店铺距离送达地址
@property (nullable, nonatomic, retain) NSNumber *mallDistance;             //骑手距离店铺
@property (nullable, nonatomic, retain) NSNumber *expectedDeliveryTime;     //分钟

@property (nullable, nonatomic, retain) NSString *orderId;
@property (nullable, nonatomic, retain) NSNumber *orderState;
@property (nullable, nonatomic, retain) NSString *memberId;

@property (nullable, nonatomic, retain) NSString *mallId;
@property (nullable, nonatomic, retain) NSString *mallName;
@property (nullable, nonatomic, retain) NSString *mallPhone;
@property (nullable, nonatomic, retain) NSString *mallAddress;
@property (nullable, nonatomic, retain) NSNumber *mallLatitude;
@property (nullable, nonatomic, retain) NSNumber *mallLongitude;

@property (nullable, nonatomic, retain) NSString *invoiceHead;//发票抬头
@property (nullable, nonatomic, retain) NSString *remarks;//发票抬头

@property (nullable, nonatomic, retain) NSDecimalNumber *realPrice;
@property (nullable, nonatomic, retain) NSDecimalNumber *totalPrice;
@property (nullable, nonatomic, retain) NSDecimalNumber *freightFee;
@property (nullable, nonatomic, retain) NSDecimalNumber *discountFee;
@property (nullable, nonatomic, retain) NSDecimalNumber *balanceFee;
@property (nullable, nonatomic, retain) NSDecimalNumber *integralActualFee;


@property (nullable, nonatomic, retain) NSString *receiverName;
@property (nullable, nonatomic, retain) NSString *receiverAddress;
@property (nullable, nonatomic, retain) NSString *receiverPhone;
@property (nullable, nonatomic, retain) NSNumber *receiverAddressId;
@property (nullable, nonatomic, retain) NSNumber *receiverLatitude;
@property (nullable, nonatomic, retain) NSNumber *receiverLongitude;
@property (nullable, nonatomic, retain) NSDate *grabOrderTime;
@property (nullable, nonatomic, retain) NSDate *deliveryStartTime;
@property (nullable, nonatomic, retain) NSDate *deliveryEndTime;
@property (nullable, nonatomic, retain) NSString *deliveryTimeRemark;
@property (nullable, nonatomic, retain) NSNumber *orderType;

@property (nullable, nonatomic, retain) NSArray<MLAMOrderItem *> *orderItems;
@property (nullable, nonatomic, retain) NSDictionary *customFields;
- (void)fillOrderMOFromOrderDict:(NSDictionary *_Nullable)orderDict;
- (void)fillOrderMOFromDetail:(NSDictionary *_Nullable)orderDict;
@end
