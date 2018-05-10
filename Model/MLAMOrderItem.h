//
//  MLAMOrderItem.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/6.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MLAMProduct;
@interface MLAMOrderItem : NSObject
@property (nullable, nonatomic, retain) NSString *coverIcon;
@property (nullable, nonatomic, retain) NSString *orderItemId;//id
@property (nullable, nonatomic, retain) NSString *orderId;
@property (nullable, nonatomic, retain) NSNumber *quantity; //count
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDecimalNumber *price; //price
@property (nullable, nonatomic, retain) NSString *customAttrInfo;

- (void)fillOrderItem:(NSDictionary *_Nullable)dic;
@end
