//
//  MLAMZoneCodeConvertToProvince.h
//  MLAppMaker
//
//  Created by Michael on 2/22/17.
//  Copyright © 2017 MaxLeapMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLAMZoneCodeConvertToProvince : NSObject
+ (instancetype)sharedInstance;
- (NSString *)converProvinceFromZoneCode:(NSString *)zoneCode;
@end
