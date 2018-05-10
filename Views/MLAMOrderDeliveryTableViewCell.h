//
//  MLAMOrderDeliveryTableViewCell.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/25.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLAMOrderDeliveryTableViewCellDelegate <NSObject>
- (void)grabOrder:(UITableViewCell *)cell;
- (void)giveupOrder:(UITableViewCell *)cell;
- (void)shippingOrder:(UITableViewCell *)cell;
- (void)completedOrder:(UITableViewCell *)cell;
@end

@interface MLAMOrderDeliveryTableViewCell : UITableViewCell

@property (nonatomic, weak) id <MLAMOrderDeliveryTableViewCellDelegate> delegate;

- (void)configureOrder:(MLAMOrder *)order;
@end
