//
//  MLAMOrderDetailTableViewCell.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/27.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMOrderDetailTableViewCell.h"
@interface MLAMOrderDetailTableViewCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel4;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel1;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel2;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel3;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel4;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *realLabel;
@property (weak, nonatomic) IBOutlet UILabel *realPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountInfoHeightConstraint;
@property (assign, nonatomic) BOOL itemLayouted;
@property (strong, nonatomic) NSMutableArray<UILabel *> *infoLabels;
@property (strong, nonatomic) NSMutableArray<UILabel *> *priceLabels;
@end

@implementation MLAMOrderDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.infoLabel1.textColor = self.infoLabel2.textColor = self.infoLabel3.textColor = self.infoLabel4.textColor = self.realPriceLabel.textColor = kDefaultTextColor;
    self.infoLabel1.hidden = self.infoLabel2.hidden = self.infoLabel3.hidden = self.infoLabel4.hidden = YES;
    self.priceLabel1.hidden = self.priceLabel2.hidden = self.priceLabel3.hidden = self.priceLabel4.hidden = YES;
    self.realLabel.text = NSLocalizedString(@"实付：", nil);
    self.totalPriceLabel.textColor = self.realLabel.textColor = kDefaultGrayColor;
    self.priceLabel1.textColor = self.priceLabel2.textColor = self.priceLabel3.textColor = self.priceLabel4.textColor = kDefaultGrayColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureOrder:(SYOrder *)order {
    self.infoLabels = [@[self.infoLabel1,self.infoLabel2,self.infoLabel3,self.infoLabel4] mutableCopy];
    self.priceLabels = [@[self.priceLabel1,self.priceLabel2,self.priceLabel3,self.priceLabel4] mutableCopy];
    
    NSDecimalNumber *fen = [NSDecimalNumber decimalNumberWithString:@"100"];
    
    
    CGFloat dscountF = order.totalPrice.floatValue - order.realPrice.floatValue;
    NSDecimalNumber *dscountFeeNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",dscountF]];
    if (dscountF > 0) {
        self.infoLabels.firstObject.text = NSLocalizedString(@"费用减免", nil);
        self.priceLabels.firstObject.text = [NSString stringWithFormat:@"-￥%@",[[dscountFeeNumber decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
        self.infoLabels.firstObject.hidden = self.priceLabels.firstObject.hidden = NO;
        [self.infoLabels removeObjectAtIndex:0];
        [self.priceLabels removeObjectAtIndex:0];
    }
    
//    if (order.discountFee.doubleValue > 0) {
//        self.infoLabels.firstObject.text = NSLocalizedString(@"会员优惠", nil);
//        self.priceLabels.firstObject.text = [NSString stringWithFormat:@"-￥%@",[[order.discountFee decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
//        self.infoLabels.firstObject.hidden = self.priceLabels.firstObject.hidden = NO;
//        [self.infoLabels removeObjectAtIndex:0];
//        [self.priceLabels removeObjectAtIndex:0];
//    }
//    if (order.balanceFee.doubleValue > 0) {
//        self.infoLabels.firstObject.text = NSLocalizedString(@"余额抵扣", nil);
//        self.priceLabels.firstObject.text = [NSString stringWithFormat:@"-￥%@",[[order.balanceFee decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
//        self.infoLabels.firstObject.hidden = self.priceLabels.firstObject.hidden = NO;
//        [self.infoLabels removeObjectAtIndex:0];
//        [self.priceLabels removeObjectAtIndex:0];
//    }
//    if (order.integralActualFee.doubleValue > 0) {
//        self.infoLabels.firstObject.text = NSLocalizedString(@"积分抵扣", nil);
//        self.priceLabels.firstObject.text = [NSString stringWithFormat:@"-￥%@",[[order.integralActualFee decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
//        self.infoLabels.firstObject.hidden = self.priceLabels.firstObject.hidden = NO;
//        [self.infoLabels removeObjectAtIndex:0];
//        [self.priceLabels removeObjectAtIndex:0];
//    }
    
    self.infoLabels.firstObject.text = NSLocalizedString(@"配送费", nil);
    self.priceLabels.firstObject.text = [NSString stringWithFormat:@"￥%@",[[order.freightFee decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
    self.infoLabels.firstObject.hidden = self.priceLabels.firstObject.hidden = NO;
    [self.infoLabels removeObjectAtIndex:0];
    [self.priceLabels removeObjectAtIndex:0];
    
    self.discountInfoHeightConstraint.constant = (4-self.infoLabels.count)*27 + 10;
    for (UILabel *label in self.infoLabels) {
        label.hidden = YES;
    }
    for (UILabel *label in self.priceLabels) {
        label.hidden = YES;
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@ ￥%@",NSLocalizedString(@"总计：", nil),[[order.totalPrice decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
    self.realPriceLabel.text = [NSString stringWithFormat:@"￥%@",[[order.realPrice decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
    self.topConstraint.constant = 0;
//    NSInteger itemCount = order.orderItems.count;
//    CGFloat itemHeight = 26;
//    CGFloat itemGap = 8;
//    self.topConstraint.constant = itemGap*2 + itemCount*itemHeight;
//    if (!_itemLayouted) {
//        if (order.orderItems.count > 0) {
//            self.itemLayouted = YES;
//        }
//        for (int i = 0; i < order.orderItems.count; i++) {
//            MLAMOrderItem *item = order.orderItems[i];
//            MLAMOrderItemView *itemView = [MLAMOrderItemView autoLayoutView];
//            itemView.itemNameLabel.text = item.title;
//            itemView.quantityLabel.text = [NSString stringWithFormat:@"x%d",item.quantity.intValue];
//            itemView.itemPriceLabel.text = [NSString stringWithFormat:@"￥%@",[[item.price decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
//            [self.contentView addSubview:itemView];
//            [itemView constrainToHeight:itemHeight];
//            [itemView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
//            [itemView pinToSuperviewEdges:JRTViewPinTopEdge inset:itemGap+itemHeight*i];
//            [itemView layoutIfNeeded];
//        }
//        [self.contentView layoutSubviews];
//
//    }
}

@end





@implementation MLAMOrderItemView
- (id)init {
    self = [super init];
    if (self) {
        self.itemNameLabel = [UILabel autoLayoutView];
        self.quantityLabel = [UILabel autoLayoutView];
        self.itemPriceLabel = [UILabel autoLayoutView];
        self.itemPriceLabel.textColor = kDefaultGrayColor;
        self.quantityLabel.textColor = self.itemNameLabel.textColor = kDefaultTextColor;
        self.itemNameLabel.font = self.quantityLabel.font = self.itemPriceLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_itemNameLabel];
        [self addSubview:_quantityLabel];
        [self addSubview:_itemPriceLabel];
        
        [self.itemNameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh+5 forAxis:UILayoutConstraintAxisHorizontal];
        [self.quantityLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+2 forAxis:UILayoutConstraintAxisHorizontal];
        [self.itemPriceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+2 forAxis:UILayoutConstraintAxisHorizontal];
        
        NSDictionary *dict = @{@"label1":_itemNameLabel,@"label2":_quantityLabel,@"label3":_itemPriceLabel};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[label1]->=10-[label2]-40-[label3]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dict]];
        [_itemNameLabel centerInView:self onAxis:NSLayoutAttributeCenterY];
        [_itemPriceLabel centerInView:self onAxis:NSLayoutAttributeCenterY];
        [_quantityLabel centerInView:self onAxis:NSLayoutAttributeCenterY];
    }
    return self;
}





@end
