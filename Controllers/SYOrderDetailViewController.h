//
//  SYOrderDetailViewController.h
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYOrderDetailViewController : UIViewController

@property (nonatomic, strong) SYOrder *order;

+ (instancetype)initOrderDetailVCFromNibFile;

@end
