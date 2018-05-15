//
//  NewOrderViewController.h
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNewOrderViewController : UIViewController

@property(nonatomic, assign) SYOrderState orderState;
+ (instancetype)initNewOrderVCFromNibFile;

@end
