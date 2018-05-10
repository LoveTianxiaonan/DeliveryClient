//
//  MLAMOrderTipCell.m
//  MLDelivery
//
//  Created by wangwenjuan on 2018/2/2.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "MLAMOrderTipCell.h"

@interface MLAMOrderTipCell()
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipNameLabel;

@end
@implementation MLAMOrderTipCell
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"MLAMOrderTipCell_ID";
    id cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"MLAMOrderTipCell" owner:nil options:nil][0];
    }
    return cell;
}
-(void)setOrderTip:(NSString *)orderTip{
    _orderTip = orderTip;
    self.tipLabel.text = orderTip;
}
-(void)setTipName:(NSString *)tipName{
    _tipName = tipName;
    self.tipNameLabel.text = tipName;
}
@end
