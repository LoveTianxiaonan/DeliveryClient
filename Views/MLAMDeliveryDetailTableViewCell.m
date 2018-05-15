//
//  MLAMDeliveryDetailTableViewCell.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/27.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMDeliveryDetailTableViewCell.h"
@interface MLAMDeliveryDetailTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *takeIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation MLAMDeliveryDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.takeIconLabel.layer.cornerRadius = self.deliveryIconLabel.layer.cornerRadius = 10;
    self.takeIconLabel.layer.masksToBounds = self.deliveryIconLabel.layer.masksToBounds = YES;
    self.takeIconLabel.layer.borderWidth = self.deliveryIconLabel.layer.borderWidth = 1;
    self.takeIconLabel.textColor = kButtonBGColor;
    self.deliveryIconLabel.textColor = kSelectedTabTextColor;
    self.takeIconLabel.layer.borderColor = kButtonBGColor.CGColor;
    self.deliveryIconLabel.layer.borderColor = kSelectedTabTextColor.CGColor;
    
    self.takeAddressLabel.textColor = self.deliveryAddressLabel.textColor = kDefaultTextColor;
    self.takeDetailLabel.textColor = self.userInfoLabel.textColor = kDefaultGrayColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureOrder:(SYOrder *)order {
    self.takeAddressLabel.text = order.mallName;
    self.deliveryAddressLabel.text = order.receiverAddress;
    self.takeDetailLabel.text = [order.mallAddress displayAddressString];
    if (order.orderState.integerValue == SYOrderStateNew) {
        self.bottomConstraint.constant = 8;
        self.userInfoLabel.hidden = YES;
    }else {
        self.userInfoLabel.hidden = NO;
        self.bottomConstraint.constant = 34;
        self.userInfoLabel.text = [NSString stringWithFormat:@"%@ %@",order.receiverName,order.receiverPhone];
    }
}

@end
