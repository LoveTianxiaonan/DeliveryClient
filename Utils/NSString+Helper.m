//
//  NSString+Helper.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/6.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)
- (NSString *)qiniuSize:(CGSize)size {
    int scale =[UIScreen mainScreen].scale;
    NSString *thumbileURLString = [NSString stringWithFormat:@"%@?imageView2/4/w/%d/h/%d", self, (int)size.width * scale, (int)size.height * scale];
    return thumbileURLString;
}

- (NSString *)displayAddressString {
    NSString *storeInfo = [self stringByReplacingOccurrencesOfString:@"_0"
                                                          withString:@""
                                                             options:NSCaseInsensitiveSearch
                                                               range:NSMakeRange(0, self.length)];
    return [storeInfo stringByReplacingOccurrencesOfString:@"_" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, storeInfo.length)];
}
@end
