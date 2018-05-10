//
//  MLAMOrderListViewController.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/24.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLAMOrderListViewController : UIViewController
@property(nonatomic, assign) MLAMOrderState orderState;
@property(copy, nonatomic) void(^ showEmptyTipHandler)(BOOL show);
- (BOOL)isEmptyResult;
- (void)loadData:(BOOL)animation;
@end
