//
//  SYOrderDetailViewController.m
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYOrderDetailViewController.h"
#import "MLAMOrderDetailTableViewCell.h"
#import "MLAMDeliveryDetailTableViewCell.h"
#import "MLAMOrderDetailTableViewCell.h"
#import "MLAMDeliveryMapTableViewCell.h"
//#import "MLAMMapRouteViewController.h"
#import "MLAMOrderTipCell.h"
#import "MLAMOrderProductDetailCell.h"

@interface SYOrderDetailViewController ()<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (nonatomic, strong) NSArray *customFields;

@end

@implementation SYOrderDetailViewController

+ (instancetype)initOrderDetailVCFromNibFile {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SYOrderDetailViewController *VC = [sb instantiateViewControllerWithIdentifier:@"SYOrderDetailViewController"];
    return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"订单详情", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ImageNamed(@"ic_delivery_top_phone")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(callAction:)];
    [self configureTabelView];
    [self configureBottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateButtonState];
}

- (void)configureTabelView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenRect.size.width, 10)];
    footView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footView;
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [kSharedWebService fetchOrderDetail:weakSelf.order completion:^(SYOrder *order, NSError *error) {
            [weakSelf.tableView.mj_header endRefreshing];
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                return ;
            }
            weakSelf.order = order;
            [weakSelf.tableView reloadData];
        }];
    }];
    [self.tableView.mj_header beginRefreshing];
}

-(void)setOrder:(SYOrder *)order{
    _order = order;
    NSArray *customFieldsArr = kSharedDeliveryPerson.productCustomFields;
    if (!customFieldsArr || ![customFieldsArr isKindOfClass:[NSArray class]]) {
        return;
    }
    NSMutableArray *customArr = [NSMutableArray array];
    for (NSDictionary *dic in customFieldsArr) {
        if ([self.order.customFields.allKeys containsObject:dic[@"key"]]) {
            NSMutableDictionary *customFieldsDic = [NSMutableDictionary dictionary];
            if ([dic[@"text"] isKindOfClass:[NSString class]] && [self.order.customFields[dic[@"key"]] isKindOfClass:[NSString class]]) {
                if (((NSString *)(dic[@"text"])).length && ((NSString *)self.order.customFields[dic[@"key"]]).length) {
                    [customFieldsDic setObject:self.order.customFields[dic[@"key"]] forKey:dic[@"text"]];
                    [customArr addObject:customFieldsDic];
                }
            }
        }
    }
    self.customFields = customArr;
}

- (BOOL)isOrderUncompleted {
    return  (self.order.orderState.integerValue == SYOrderStateNew ||
             self.order.orderState.integerValue == SYOrderStateGotoTake ||
             self.order.orderState.integerValue == SYOrderStateInDelivery);
}

- (void)configureBottomView {
    if (self.order.orderState.integerValue == SYOrderStateCompleted) {
        self.bottomViewHeightConstraint.constant = 0;
        self.bottomView.hidden = YES;
        return;
    }
    [self.bottomView addTopBorderWithColor:[UIColor groupTableViewBackgroundColor] width:0.5];
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
    [self updateButtonState];
}

- (void)updateButtonState {
    [self.centerButton setTitle:self.order.orderState.integerValue==SYOrderStateNew?NSLocalizedString(@"抢单", nil):NSLocalizedString(@"确认送达", nil)
                       forState:UIControlStateNormal];
    self.leftButton.hidden = self.rightButton.hidden = self.order.orderState.integerValue!=SYOrderStateGotoTake;
    self.centerButton.hidden = self.order.orderState.integerValue==SYOrderStateGotoTake;
}

- (void)callAction:(id)sender {
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
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)centerButtonPressed:(id)sender {
    if (self.order.orderState.integerValue == SYOrderStateNew) {
        [SVProgressHUD show];
        [kSharedWebService grabOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                return ;
            }
            if (success) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"抢单成功", nil)];
                self.order.orderState = @(SYOrderStateGotoTake);
                [self updateButtonState];
            }else {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"该单已经被抢", nil)];
                execute_after_main_queue(.3f, ^(){
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
        }];
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
    [SVProgressHUD show];
    [kSharedWebService shippingOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"取货成功", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
        self.order.orderState = @(SYOrderStateInDelivery);
        [self updateButtonState];
    }];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5 + (self.customFields.count>0?1:0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1 && ![self isOrderUncompleted]) {
        return 0;
    }
    if (section == 3) {
        return self.order.orderItems.count+2;
    }
    if (section == 4) {
        return 5;
    }
    if (section == 5) {
        return self.customFields.count;
    }
    return 2;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if ([self isOrderUncompleted])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"topCellIdnetifier"];
            UILabel *label = [cell.contentView viewWithTag:1];
            label.textColor = kHighlightColor;
            if (self.order.deliveryStartTime && self.order.deliveryEndTime) {
                label.text = [self stringForDate:self.order.deliveryStartTime endDate:self.order.deliveryEndTime];
            }
            else if (self.order.orderState.integerValue == SYOrderStateNew) {
                label.text = [NSString stringWithFormat:NSLocalizedString(@"预计%d分钟内送达", nil),self.order.expectedDeliveryTime.intValue];
            }else if (self.order.orderState.integerValue == SYOrderStateGotoTake){
                if (self.order.orderType.integerValue == 1) {
                    label.text = [NSString stringWithFormat:NSLocalizedString(@"已派单%d分钟", nil),(int)(-[self.order.grabOrderTime timeIntervalSinceNow]/60)];
                }else {
                    label.text = [NSString stringWithFormat:NSLocalizedString(@"已抢单%d分钟", nil),(int)(-[self.order.grabOrderTime timeIntervalSinceNow]/60)];
                }
            }else if (self.order.orderState.integerValue == SYOrderStateInDelivery) {
                NSInteger sec = 0;
                if (self.order.deliveryEndTime) {
                    sec = [self.order.deliveryEndTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
                }else {
                    sec = [self.order.grabOrderTime timeIntervalSince1970] + self.order.expectedDeliveryTime.intValue*60 - [[NSDate date] timeIntervalSince1970];
                }
                if (sec >= 0) {
                    label.text = [NSString stringWithFormat:NSLocalizedString(@"距送达时间还剩%d分钟", nil),sec/60];
                }else {
                    label.text = [NSString stringWithFormat:NSLocalizedString(@"送达时间超时%d分钟", nil),MAX(1,-sec/60)];
                }
            }
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"priceInfoCellIdentifier"];
            UILabel *label1 = [cell.contentView viewWithTag:1];
            UILabel *label2 = [cell.contentView viewWithTag:2];
            UILabel *label3 = [cell.contentView viewWithTag:3];
            UILabel *label4 = [cell.contentView viewWithTag:4];
            label1.textColor = label2.textColor = kHighlightColor;
            NSDecimalNumber *fen = [NSDecimalNumber decimalNumberWithString:@"100"];
            label1.text = [NSString stringWithFormat:@"￥%@",[[self.order.realPrice decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
            label2.text = [NSString stringWithFormat:@"￥%@",[[self.order.freightFee decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
            label3.text = NSLocalizedString(@"实付总价", nil);
            label4.text = NSLocalizedString(@"配送费", nil);
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCellIdnetifier"];
            UILabel *label1 = [cell.contentView viewWithTag:1];
            label1.text = NSLocalizedString(@"送货路线", nil);
        }else {
            MLAMDeliveryMapTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"mapCellIdentifier"];
            [_cell configureOrder:self.order];
            cell = _cell;
        }
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCellIdnetifier"];
            UILabel *label1 = [cell.contentView viewWithTag:1];
            label1.text = NSLocalizedString(@"订单配送", nil);
        }else {
            MLAMDeliveryDetailTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"MLAMDeliveryDetailTableViewCell"];
            [_cell configureOrder:self.order];
            cell = _cell;
        }
    }else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCellIdnetifier"];
            UILabel *label1 = [cell.contentView viewWithTag:1];
            label1.text = NSLocalizedString(@"订单详情", nil);
        }else if(indexPath.row > self.order.orderItems.count){
            MLAMOrderDetailTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"MLAMOrderDetailTableViewCell"];
            [_cell configureOrder:self.order];
            cell = _cell;
        }else{
            MLAMOrderProductDetailCell *orderProductDetailCell = [MLAMOrderProductDetailCell cellWithTableView:tableView];
            orderProductDetailCell.orderItem = self.order.orderItems[indexPath.row - 1];
            cell = orderProductDetailCell;
        }
    }else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCellIdnetifier"];
            UILabel *label1 = [cell.contentView viewWithTag:1];
            label1.text = NSLocalizedString(@"订单信息", nil);
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"twoLabelCellIdentifier"];
            UILabel *label1 = [cell.contentView viewWithTag:1];
            UILabel *label2 = [cell.contentView viewWithTag:2];
            switch (indexPath.row) {
                case 1:
                    label1.text = NSLocalizedString(@"订单号码", nil);
                    label2.text = self.order.billNum;
                    break;
                case 2:
                    label1.text = NSLocalizedString(@"下单时间", nil);
                    label2.text = self.order.createdAt.detailedHumanDateString;
                    break;
                case 3:
                    label1.text = NSLocalizedString(@"发票抬头", nil);
                    label2.text = self.order.invoiceHead.length?self.order.invoiceHead:NSLocalizedString(@"(无)", nil);
                    break;
                case 4:
                    label1.text = NSLocalizedString(@"备注信息", nil);
                    label2.text = self.order.remarks.length?self.order.remarks:NSLocalizedString(@"(无)", nil);
                    break;
                default:
                    break;
            }
        }
    }else if (indexPath.section == 5) {
        MLAMOrderTipCell *tipCell = [MLAMOrderTipCell cellWithTableView:tableView];
        NSDictionary *dic = self.customFields[indexPath.row];
        tipCell.orderTip = [dic.allValues firstObject];
        tipCell.tipName = [NSString stringWithFormat:@"%@： ",[dic.allKeys firstObject]];
        cell = tipCell;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        SYMapRouteViewController *controller = [SYMapRouteViewController instantiateFromStoryboard];
        controller.order = self.order;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 5) {
        return 10;
    }
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 1) {
            [SVProgressHUD show];
            [kSharedWebService completedOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"配送成功", nil)];
                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
                execute_after_main_queue(.3f, ^(){
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }];
        }else {
            [SVProgressHUD show];
            [kSharedWebService giveupOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"放弃成功", nil)];
                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
                self.order.orderState = @(SYOrderStateNew);
                [self updateButtonState];
            }];
        }
    }
}
@end



