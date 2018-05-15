//
//  SYOrderItem.h
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYOrderItem : NSObject

@property (nullable, nonatomic, retain) NSString *coverIcon;
@property (nullable, nonatomic, retain) NSString *orderItemId;//id
@property (nullable, nonatomic, retain) NSString *orderId;
@property (nullable, nonatomic, retain) NSNumber *quantity; //count
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDecimalNumber *price; //price
@property (nullable, nonatomic, retain) NSString *customAttrInfo;

- (void)fillOrderItem:(NSDictionary *_Nullable)dic;
@end
