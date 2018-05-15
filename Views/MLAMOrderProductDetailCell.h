//
//  MLAMOrderProductDetailCell.h
//  MLDelivery
//
//  Created by wangwenjuan on 2018/4/12.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLAMOrderProductDetailCell : UITableViewCell
@property (nonatomic, strong) SYOrderItem *orderItem;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
