//
//  MLAMDeliveryPerson.h
//  MLDelivery
//
//  Created by Miracle on 2017/5/2.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSharedDeliveryPerson [MLAMDeliveryPerson sharedDeliveryPerson]

@interface MLAMDeliveryPerson : NSObject
@property (nullable,nonatomic, copy) NSString *appid;
@property (nullable,nonatomic, copy) NSString *apiKey;
@property (nullable,nonatomic, copy) NSString *userSession;

@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *sysUserId;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *userPhone;
@property (nullable, nonatomic, copy) NSString *userIcon;
@property (nullable,nonatomic, strong) NSArray *productCustomFields;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) long long lastUpdateLocationTime;

+ ( MLAMDeliveryPerson * _Nonnull )sharedDeliveryPerson;
- (void)createLocationManager;
- (void)updateCurrentLocationToServer;
@end
