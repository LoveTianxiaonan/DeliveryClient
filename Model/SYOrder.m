//
//  SYOrder.m
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYOrder.h"

@implementation SYOrder

- (void)fillOrderMOFromOrderDict:(NSDictionary *)orderDict
{
    self.orderId = [NULL_TO_NIL(orderDict[@"id"]) stringValue];
    self.orderState = NULL_TO_NIL(orderDict[@"status"]);
    self.memberId = [NULL_TO_NIL(orderDict[@"memberId"]) stringValue];
    NSNumber *createTimeInterval = NULL_TO_NIL(orderDict[@"createdAt"]);
    self.createdAt = [NSDate dateWithTimeIntervalSince1970:createTimeInterval.doubleValue/1000];
    
    self.billNum = NULL_TO_NIL(orderDict[@"billNum"]);
    NSNumber *realPrice = NULL_TO_NIL(orderDict[@"payPrice"]);
    NSNumber *totalPrice = NULL_TO_NIL(orderDict[@"totalPrice"]);
    NSNumber *freightFee = NULL_TO_NIL(orderDict[@"freightFee"]);
    
    self.realPrice = [NSDecimalNumber decimalNumberWithDecimal:realPrice.decimalValue];
    self.totalPrice = [NSDecimalNumber decimalNumberWithDecimal:totalPrice.decimalValue];
    self.freightFee = [NSDecimalNumber decimalNumberWithDecimal:freightFee.decimalValue];
    
    self.deliveryDistance = NULL_TO_NIL(orderDict[@"deliveryDistance"]);
    self.mallDistance = NULL_TO_NIL(orderDict[@"mallDistance"]);
    self.expectedDeliveryTime = NULL_TO_NIL(orderDict[@"expectedDeliveryTime"]);
    
    self.mallId = NULL_TO_NIL(orderDict[@"mallId"]);
    self.mallLatitude = NULL_TO_NIL(orderDict[@"mallLatitude"]);
    self.mallLongitude = NULL_TO_NIL(orderDict[@"mallLongitude"]);
    self.mallName = NULL_TO_NIL(orderDict[@"mallName"]);
    self.mallPhone = NULL_TO_NIL(orderDict[@"mallPhone"]);
    
    self.receiverAddress = NULL_TO_NIL(orderDict[@"receiverAddress"]);
    self.receiverAddressId = NULL_TO_NIL(orderDict[@"receiverAddressId"]);
    self.receiverLatitude = NULL_TO_NIL(orderDict[@"receiverLatitude"]);
    self.receiverLongitude = NULL_TO_NIL(orderDict[@"receiverLongitude"]);
    self.receiverPhone = NULL_TO_NIL(orderDict[@"receiverPhone"]);
    
    self.grabOrderTime = [NSDate dateWithTimeIntervalSince1970:[NULL_TO_NIL(orderDict[@"shipperGrabTime"]) doubleValue]/1000];
    double endTime = [NULL_TO_NIL(orderDict[@"deliveryEndTime"]) doubleValue];
    if (endTime > 0) {
        self.deliveryEndTime = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
    }else {
        self.deliveryEndTime = nil;
    }
    double startTime = [NULL_TO_NIL(orderDict[@"deliveryStartTime"]) doubleValue];
    if (startTime > 0) {
        self.deliveryStartTime = [NSDate dateWithTimeIntervalSince1970:startTime/1000];
    }else {
        self.deliveryStartTime = nil;
    }
    self.deliveryTimeRemark = NULL_TO_NIL(orderDict[@"deliveryTimeRemark"]);
    self.orderType = NULL_TO_NIL(orderDict[@"orderType"]);
}


- (void)fillOrderMOFromDetail:(NSDictionary *)orderDict
{
    self.orderId = [NULL_TO_NIL(orderDict[@"id"]) stringValue];
    self.orderState = NULL_TO_NIL(orderDict[@"status"]);
    self.memberId = [NULL_TO_NIL(orderDict[@"memberId"]) stringValue];
    self.createdAt = [NSDate dateWithTimeIntervalSince1970:[NULL_TO_NIL(orderDict[@"createdAt"]) doubleValue]/1000];
    self.billNum = NULL_TO_NIL(orderDict[@"billNum"]);
    
    NSNumber *realPrice = NULL_TO_NIL(orderDict[@"payPrice"]);
    NSNumber *totalPrice = NULL_TO_NIL(orderDict[@"totalPrice"]);
    NSNumber *freightFee = NULL_TO_NIL(orderDict[@"freightFee"]);
    NSNumber *discountFee = NULL_TO_NIL(orderDict[@"discountFee"]);
    NSNumber *balanceFee = NULL_TO_NIL(orderDict[@"balanceFee"]);
    NSNumber *integralActualFee = NULL_TO_NIL(orderDict[@"integralActualFee"]);
    self.realPrice = [NSDecimalNumber decimalNumberWithDecimal:realPrice.decimalValue];
    self.totalPrice = [NSDecimalNumber decimalNumberWithDecimal:totalPrice.decimalValue];
    self.freightFee = [NSDecimalNumber decimalNumberWithDecimal:freightFee.decimalValue];
    self.discountFee = [NSDecimalNumber decimalNumberWithDecimal:discountFee.decimalValue];
    self.balanceFee = [NSDecimalNumber decimalNumberWithDecimal:balanceFee.decimalValue];
    self.integralActualFee = [NSDecimalNumber decimalNumberWithDecimal:integralActualFee.decimalValue];
    
    
    self.expectedDeliveryTime = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.expectedDeliveryTime"]);
    
    self.mallId = NULL_TO_NIL(orderDict[@"mallId"]);
    self.mallLatitude = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.mallLatitude"]);
    self.mallLongitude = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.mallLongitude"]);
    self.mallAddress = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.mallAddress"]);
    self.mallPhone = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.mallPhone"]);
    self.mallName = NULL_TO_NIL(orderDict[@"mallTitle"]);
    
    
    self.receiverAddress = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.receiverAddress"]);
    self.receiverLatitude = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.receiverLatitude"]);
    self.receiverLongitude = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.receiverLongitude"]);
    self.receiverPhone = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.receiverPhone"]);
    self.receiverName = NULL_TO_NIL([orderDict valueForKeyPath:@"distInfo.receiverName"]);
    self.grabOrderTime = [NSDate dateWithTimeIntervalSince1970:[NULL_TO_NIL(orderDict[@"shipperGrabTime"]) doubleValue]/1000];
    
    self.invoiceHead = NULL_TO_NIL(orderDict[@"invoiceHead"]);
    self.remarks = NULL_TO_NIL(orderDict[@"remarks"]);
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dic in orderDict[@"items"]) {
        SYOrderItem *item = [SYOrderItem new];
        [item fillOrderItem:dic];
        [items addObject:item];
    }
    self.orderItems = items;
    double endTime = [NULL_TO_NIL(orderDict[@"deliveryEndTime"]) doubleValue];
    if (endTime > 0) {
        self.deliveryEndTime = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
    }else {
        self.deliveryEndTime = nil;
    }
    double startTime = [NULL_TO_NIL(orderDict[@"deliveryStartTime"]) doubleValue];
    if (startTime > 0) {
        self.deliveryStartTime = [NSDate dateWithTimeIntervalSince1970:startTime/1000];
    }else {
        self.deliveryStartTime = nil;
    }
    
    self.deliveryTimeRemark = NULL_TO_NIL(orderDict[@"deliveryTimeRemark"]);
    self.customFields =  NULL_TO_NIL(orderDict[@"customFields"]);
    self.orderType = NULL_TO_NIL(orderDict[@"orderType"]);
}


@end
