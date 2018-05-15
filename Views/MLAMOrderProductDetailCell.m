//
//  MLAMOrderProductDetailCell.m
//  MLDelivery
//
//  Created by wangwenjuan on 2018/4/12.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "MLAMOrderProductDetailCell.h"
@interface MLAMOrderProductDetailCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *customAttributesLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantityLabel;

@end

@implementation MLAMOrderProductDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"MLAMOrderProductDetailCell_ID";
    id cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"MLAMOrderProductDetailCell" owner:nil options:nil][0];
    }
    return cell;
    
}
-(void)setOrderItem:(SYOrderItem *)orderItem{
    _orderItem = orderItem;
 //   [self.iconImageView sd_setImageWithURL:orderItem.coverIcon.toURL placeholderImage:ImageNamed(@"ic_item_default")];
    self.productTitleLabel.text = orderItem.title;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",[[orderItem.price decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]] twoPlaceDecimalString]];
    self.customAttributesLabel.text = orderItem.customAttrInfo;
    self.itemQuantityLabel.text = [NSString stringWithFormat:@"x%@",orderItem.quantity];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
