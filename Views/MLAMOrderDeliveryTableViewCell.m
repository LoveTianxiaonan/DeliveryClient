//
//  MLAMOrderDeliveryTableViewCell.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/25.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMOrderDeliveryTableViewCell.h"
@interface MLAMOrderDeliveryTableViewCell()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *takeIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) SYOrder *order;
@end
@implementation MLAMOrderDeliveryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.phoneButton setImage:ImageNamed(@"ic_delivery_phone") forState:UIControlStateNormal];
    self.timeLabel.textColor = kHighlightColor;
    self.takeIconLabel.layer.cornerRadius = self.deliveryIconLabel.layer.cornerRadius = 10;
    self.takeIconLabel.layer.masksToBounds = self.deliveryIconLabel.layer.masksToBounds = YES;
    self.takeIconLabel.layer.borderWidth = self.deliveryIconLabel.layer.borderWidth = 1;
    self.takeIconLabel.textColor = kButtonBGColor;
    self.deliveryIconLabel.textColor = kSelectedTabTextColor;
    self.takeIconLabel.layer.borderColor = kButtonBGColor.CGColor;
    self.deliveryIconLabel.layer.borderColor = kSelectedTabTextColor.CGColor;
    
    self.takeAddressLabel.textColor = self.deliveryAddressLabel.textColor = kDefaultTextColor;
    self.takeDistanceLabel.textColor = self.deliveryDistanceLabel.textColor = kDefaultGrayColor;
    
    self.centerButton.backgroundColor = kButtonBGColor;
    self.rightButton.backgroundColor = kButtonBGColor;
    [self.centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:kDefaultTextColor forState:UIControlStateNormal];
    self.leftButton.layer.cornerRadius = self.rightButton.layer.cornerRadius = self.centerButton.layer.cornerRadius = 2;
    self.leftButton.layer.masksToBounds = self.rightButton.layer.masksToBounds = self.centerButton.layer.masksToBounds = YES;
    self.leftButton.layer.borderColor = kDefaultGrayColor.CGColor;
    self.leftButton.layer.borderWidth = 1;
    
    [self.leftButton setTitle:NSLocalizedString(@"放弃", nil) forState:UIControlStateNormal];
    [self.rightButton setTitle:NSLocalizedString(@"取货", nil) forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.centerButton.backgroundColor = self.rightButton.backgroundColor = kButtonBGColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.centerButton.backgroundColor = self.rightButton.backgroundColor = kButtonBGColor;
}
- (NSString *)stringForDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM月d日(HH:mm-";
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    NSString *dateString1 = [dateFormatter stringFromDate: startDate];
    dateFormatter.dateFormat = @"HH:mm)送达";
    NSString *dateString2 = [dateFormatter stringFromDate: endDate];
    return [NSString stringWithFormat:@"%@%@",dateString1,dateString2];
}
- (void)configureOrder:(SYOrder *)order {
    self.order = order;
    if (self.order.deliveryStartTime && self.order.deliveryEndTime) {
        self.timeLabel.text = [self stringForDate:self.order.deliveryStartTime endDate:self.order.deliveryEndTime];
    }
    else if (self.order.orderState.integerValue == SYOrderStateNew) {
        self.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"预计%d分钟内送达", nil),self.order.expectedDeliveryTime.intValue];
    }else if (self.order.orderState.integerValue == SYOrderStateGotoTake){
        if (self.order.orderType.integerValue == 1) {
            self.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已派单%d分钟", nil),(int)(-[self.order.grabOrderTime timeIntervalSinceNow]/60)];
        }else {
            self.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已抢单%d分钟", nil),(int)(-[self.order.grabOrderTime timeIntervalSinceNow]/60)];
        }
    }else if (self.order.orderState.integerValue == SYOrderStateInDelivery) {
        NSInteger sec = 0;
        if (self.order.deliveryEndTime) {
            sec = [self.order.deliveryEndTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
        }else {
            sec = [self.order.grabOrderTime timeIntervalSince1970] + self.order.expectedDeliveryTime.intValue*60 - [[NSDate date] timeIntervalSince1970];
        }
        if (sec >= 0) {
            self.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"距送达时间还剩%d分钟", nil),sec/60];
        }else {
            self.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"送达时间超时%d分钟", nil),MAX(1,-sec/60)];
        }
    }
    
    self.takeAddressLabel.text = order.mallName;
    self.deliveryAddressLabel.text = order.receiverAddress;
    self.takeDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.2fKM取货", nil),order.mallDistance.doubleValue];
    self.deliveryDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.2fKM送货", nil),order.deliveryDistance.doubleValue];
    
    [self.centerButton setTitle:order.orderState.integerValue==SYOrderStateNew?NSLocalizedString(@"抢单", nil):NSLocalizedString(@"确认送达", nil)
                       forState:UIControlStateNormal];
    self.leftButton.hidden = self.rightButton.hidden = order.orderState.integerValue!=SYOrderStateGotoTake;
    self.centerButton.hidden = order.orderState.integerValue==SYOrderStateGotoTake;
}
- (IBAction)phoneButtonPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    dispatch_block_t addMallPhone = ^(){
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"联系商家", nil),self.order.mallPhone]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSString *url = [NSString stringWithFormat:@"telprompt://%@",self.order.mallPhone];
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                                       }];
        [alertController addAction:action];
    };
    dispatch_block_t addUserPhone = ^(){
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"联系买家", nil),self.order.receiverPhone]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSString *url = [NSString stringWithFormat:@"telprompt://%@",self.order.receiverPhone];
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                                       }];
        [alertController addAction:action];
    };
    
    
    
    if (self.order.orderState.integerValue == SYOrderStateNew || self.order.orderState.integerValue == SYOrderStateGotoTake) {
        addMallPhone();
    }else {
        addUserPhone();
        addMallPhone();
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
  //  [[MLAMViewControllerPresentHelper topViewController] presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)centerButtonPressed:(id)sender {
    if (self.order.orderState.integerValue == SYOrderStateNew) {
        [self.delegate grabOrder:self];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                        message:NSLocalizedString(@"确定已经送达?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                              otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
        alert.tag = 1;
        [alert show];
    }
}

- (IBAction)leftButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                    message:NSLocalizedString(@"确定要放弃此订单?", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                          otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alert.tag = 2;
    [alert show];
}

- (IBAction)rightButtonPressed:(id)sender {
    [self.delegate shippingOrder:self];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 1) {
            [self.delegate completedOrder:self];
        }else if (alertView.tag == 2) {
            [self.delegate giveupOrder:self];
        }
    }
}
@end
