//
//  MLAMOrderDetailViewController.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/26.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLAMOrderDetailViewController : UIViewController
@property (nonatomic, strong) MLAMOrder *order;
+ (instancetype)instantiateFromStoryboard;
@end