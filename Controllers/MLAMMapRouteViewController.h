//
//  MLAMMapRouteViewController.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/28.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLAMMapRouteViewController : UIViewController
@property (nonatomic, assign) MLAMOrder *order;
+ (instancetype)instantiateFromStoryboard;
@end
