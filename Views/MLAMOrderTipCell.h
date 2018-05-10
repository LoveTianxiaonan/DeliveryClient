//
//  MLAMOrderTipCell.h
//  MLDelivery
//
//  Created by wangwenjuan on 2018/2/2.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLAMOrderTipCell : UITableViewCell
@property (nonatomic, copy) NSString *tipName;
@property (nonatomic, copy) NSString *orderTip;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
