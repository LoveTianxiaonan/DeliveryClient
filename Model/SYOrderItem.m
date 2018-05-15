//
//  SYOrderItem.m
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYOrderItem.h"

@implementation SYOrderItem

- (void)fillOrderItem:(NSDictionary *)dic {
    self.coverIcon = NULL_TO_NIL(dic[@"coverIcon"]);
    self.orderItemId = NULL_TO_NIL(dic[@"id"]);
    self.orderId = NULL_TO_NIL(dic[@"orderId"]);
    self.quantity = NULL_TO_NIL(dic[@"count"]);
    self.title = NULL_TO_NIL(dic[@"title"]);
    self.price = [NSDecimalNumber decimalNumberWithString:[NULL_TO_NIL(dic[@"price"]) stringValue]];
    self.customAttrInfo = NULL_TO_NIL(dic[@"customAttrInfo"]);
}

@end
