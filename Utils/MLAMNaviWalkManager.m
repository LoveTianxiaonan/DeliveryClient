//
//  MLAMNaviWalkManager.m
//  MLDelivery
//
//  Created by Miracle on 2017/5/3.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMNaviWalkManager.h"
@interface MLAMNaviWalkManager()<AMapNaviWalkManagerDelegate>
@end
@implementation MLAMNaviWalkManager
+ (MLAMNaviWalkManager *)sharedManager {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        MLAMNaviWalkManager *sharedManager = [MLAMNaviWalkManager new];
        sharedManager.delegate = sharedManager;
        sharedManager.naviRoutes = [NSMutableArray array];
        return sharedManager;
    });
}


#pragma mark - AMapNaviDriveManager Delegate

- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"onCalculateRouteSuccess");
    if (self.calculateRouteSuccessHandler) {
        self.calculateRouteSuccessHandler();
    }
    [self.naviRoutes addObject:walkManager.naviRoute];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
    if (self.calculateRouteFailureHandler) {
        self.calculateRouteFailureHandler();
    }
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)walkManagerNeedRecalculateRouteForYaw:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
}

- (void)walkManagerDidEndEmulatorNavi:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)walkManagerOnArrivedDestination:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"onArrivedDestination");
}
@end
