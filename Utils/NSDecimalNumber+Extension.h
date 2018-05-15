//
//  NSDecimalNumber+KeepTwoPlaces.h
//  MLAppMaker
//
//  Created by Michael on 11/28/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Extension)
/**
 * 固定保留两位： 1.2 -> 1.20
 * 保留两位小数, 默认第三位小数大于等于5进位
 *
 */
- (NSString *)twoPlaceDecimalString;

- (NSString *)twoPlaceDecimalString:(BOOL)RoundUp;

/**
 *灵活位数: 1.2->1.2
 */
- (NSString *)flexiblePlaceDecimalString;

- (NSDecimalNumber *)dividingBy100;
- (NSDecimalNumber *)multiplyingBy100;
@end
