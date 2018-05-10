//
//  MainViewController.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/5.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MainViewController.h"
#import "MLAMSettingViewController.h"
#import "MLAMOrderListViewController.h"
@interface MainViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *button0;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIView *stateline;

@property (weak, nonatomic) IBOutlet UIView *locationTipView;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel1;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel2;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


@property (weak, nonatomic) IBOutlet UIView *emptyTipView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyTipImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyTipLabel2;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLineLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;


@property (strong, nonatomic) NSMutableArray<MLAMOrderListViewController *>    *listViewControllers;
@end

@implementation MainViewController
+ (instancetype)instantiateFromStoryboard {
    MainViewController *vc = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MainViewController"];
    return vc;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"配送端", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ImageNamed(@"btn_delivery_personal")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showPersonalViewController)];
    self.selectedIndex = 0;
    [self updateDeliverInfo];
    [self configureTopView];
    [self configureTipView];
    [self configureScrollView];
    [self updateSelectionState:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOrderList:) name:kReloadOrderListNotificationName object:nil];
}
- (void)updateDeliverInfo {
    [kSharedWebService getProductCustomFieldsComplention:^(BOOL success, NSError *error) {
    }];
    [kSharedWebService updateDeliverInfoWithCompletion:^(BOOL succeeded, NSError *error) {
    }];
}
- (void)configureTopView {
    [self.button0 setTitle:NSLocalizedString(@"新订单", nil) forState:UIControlStateNormal];
    [self.button1 setTitle:NSLocalizedString(@"待取货", nil) forState:UIControlStateNormal];
    [self.button2 setTitle:NSLocalizedString(@"配送中", nil) forState:UIControlStateNormal];
    self.stateline.backgroundColor = kControlTextColor;
}
- (void)configureTipView {
    self.emptyTipView.hidden = YES;
    self.emptyTipLabel2.hidden = YES;
    self.emptyTipLabel.textColor = kDefaultTextColor;
    self.emptyTipLabel.text = NSLocalizedString(@"暂时没有订单", nil);
    self.emptyTipLabel2.text = NSLocalizedString(@"快去抢单吧", nil);
    self.emptyTipImageView.image = ImageNamed(@"ic_delivery_indent");
    
    self.locationImageView.image = ImageNamed(@"ic_delivery_location");
    self.locationLabel1.textColor = kDefaultTextColor;
    self.locationLabel2.textColor = kDefaultGrayColor;
    self.locationLabel1.text = NSLocalizedString(@"定位服务已关闭", nil);
    self.locationLabel2.text = NSLocalizedString(@"请在设备的设置中开启定位服务,\n以便平台给您派发任务", nil);
    [self.locationButton setTitle:NSLocalizedString(@"开启定位服务", nil) forState:UIControlStateNormal];
    [self.locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.locationButton.backgroundColor = kButtonBGColor;
    self.locationButton.layer.cornerRadius = 2;
    self.locationButton.layer.masksToBounds = YES;
    
    [self refreshLocationManagerState:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLocationManagerState:) userInfo:nil repeats:YES];
}

- (void)refreshLocationManagerState:(NSTimer *)timer {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    self.locationTipView.hidden = status >= kCLAuthorizationStatusAuthorizedAlways && [CLLocationManager locationServicesEnabled];
    if (self.locationTipView.hidden && timer) {
        [timer invalidate];
    }
}

- (void)configureScrollView {
    if (iPhoneX) {
         self.contentViewHeightConstraint.constant = ScreenRect.size.height - 88 - 50 - 34;
    }else {
         self.contentViewHeightConstraint.constant = ScreenRect.size.height - 64 - 50;
    }
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __weak typeof(self) wSelf = self;
    if ([segue.identifier isEqualToString:@"listView0"]) {
        MLAMOrderListViewController *viewcontroller = segue.destinationViewController;
        viewcontroller.orderState = MLAMOrderStateNew;
        [viewcontroller setShowEmptyTipHandler:^(BOOL show) {
            [wSelf refreshEmptyTipViewState];
        }];
        [self.listViewControllers replaceObjectAtIndex:0 withObject:viewcontroller];
    }else if ([segue.identifier isEqualToString:@"listView1"]) {
        MLAMOrderListViewController *viewcontroller = segue.destinationViewController;
        viewcontroller.orderState = MLAMOrderStateGotoTake;
        [viewcontroller setShowEmptyTipHandler:^(BOOL show) {
            [wSelf refreshEmptyTipViewState];
        }];
        [self.listViewControllers replaceObjectAtIndex:1 withObject:viewcontroller];
    }else if ([segue.identifier isEqualToString:@"listView2"]) {
        MLAMOrderListViewController *viewcontroller = segue.destinationViewController;
        viewcontroller.orderState = MLAMOrderStateInDelivery;
        [viewcontroller setShowEmptyTipHandler:^(BOOL show) {
            [wSelf refreshEmptyTipViewState];
        }];
        [self.listViewControllers replaceObjectAtIndex:2 withObject:viewcontroller];
    }
}
#pragma - Actions
- (void)showSettingView {
    MLAMSettingViewController *settingViewController = [MLAMSettingViewController new];
    [self.navigationController pushViewController:settingViewController animated:YES];
}
- (void)refreshEmptyTipViewState {
    self.emptyTipView.hidden = ![self.listViewControllers[_selectedIndex] isEmptyResult];
    self.emptyTipLabel2.hidden = _selectedIndex == 0;
}
- (void)updateSelectionState:(BOOL)animation {
    [UIView animateWithDuration:(animation?0.3f:0) animations:^{
        self.stateLineLeftConstraint.constant = ScreenRect.size.width*_selectedIndex/3 + 4;
        [self.topView layoutSubviews];
    }];
    NSArray *buttons = @[self.button0,self.button1,self.button2];
    for (UIButton *btn in buttons) {
        NSInteger index = [buttons indexOfObject:btn];
        if (index == self.selectedIndex) {
            [btn setTitleColor:kControlTextColor forState:UIControlStateNormal];
        }else {
            [btn setTitleColor:kNormalTabTextColor forState:UIControlStateNormal];
        }
    }
    if (!animation) {
        self.scrollView.contentOffset = CGPointMake(_selectedIndex*ScreenRect.size.width, 0);
    }
}

- (IBAction)button0Pressed:(id)sender {
    self.selectedIndex = 0;
    [self updateSelectionState:NO];
    [self refreshEmptyTipViewState];
}

- (IBAction)button1Pressed:(id)sender {
    self.selectedIndex = 1;
    [self updateSelectionState:NO];
    [self refreshEmptyTipViewState];
}

- (IBAction)button2Pressed:(id)sender {
    self.selectedIndex = 2;
    [self updateSelectionState:NO];
    [self refreshEmptyTipViewState];
}

- (IBAction)openLocationService:(id)sender {
    [[UIApplication sharedApplication] openURL:[UIApplicationOpenSettingsURLString toURL]];
}

- (void)showPersonalViewController {
    [self performSegueWithIdentifier:@"showMemberViewController" sender:nil];
}

- (void)reloadOrderList:(NSNotification *)no {
    for (MLAMOrderListViewController *listViewController in self.listViewControllers) {
        if ([no.userInfo[@"notification"] boolValue] && listViewController.orderState == MLAMOrderStateNew) {
            [listViewController loadData:YES];
            break;
        }
        if ([no.userInfo[@"currentOrderState"] integerValue] !=  listViewController.orderState) {
            [listViewController loadData:[no.userInfo[@"animation"] boolValue]];
        }
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = ScreenRect.size.width;
    NSUInteger newPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (newPage != self.selectedIndex) {
        self.selectedIndex = newPage;
        [self updateSelectionState:YES];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.emptyTipView.hidden = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self refreshEmptyTipViewState];
}
#pragma mark - Helper
- (NSMutableArray *)listViewControllers {
    if (!_listViewControllers) {
        _listViewControllers = [@[@"0",@"1",@"2"] mutableCopy];
    }
    return _listViewControllers;
}

@end
