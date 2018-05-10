//
//  MLAMOrderDetailTableViewCell.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/27.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLAMOrderDetailTableViewCell : UITableViewCell
- (void)configureOrder:(MLAMOrder *)order;
@end



@interface MLAMOrderItemView : UIView
@property(strong, nonatomic) UILabel *itemNameLabel;
@property(strong, nonatomic) UILabel *quantityLabel;
@property(strong, nonatomic) UILabel *itemPriceLabel;
@end
