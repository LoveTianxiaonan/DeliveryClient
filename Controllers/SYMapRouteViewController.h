//
//  SYMapRouteViewController.h
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYMapRouteViewController : UIViewController

@property (nonatomic, assign) SYOrder *order;
+ (instancetype)instantiateFromStoryboard;

@end
