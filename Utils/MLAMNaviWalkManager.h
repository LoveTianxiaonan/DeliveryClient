//
//  MLAMNaviWalkManager.h
//  MLDelivery
//
//  Created by Miracle on 2017/5/3.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <AMapNaviKit/AMapNaviKit.h>

@interface MLAMNaviWalkManager : AMapNaviWalkManager
@property (copy, nonatomic) dispatch_block_t calculateRouteSuccessHandler;
@property (copy, nonatomic) dispatch_block_t calculateRouteFailureHandler;
@property (strong, nonatomic) NSMutableArray *naviRoutes;
+ (MLAMNaviWalkManager *)sharedManager;
@end
