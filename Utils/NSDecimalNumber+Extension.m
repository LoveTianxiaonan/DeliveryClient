//
//  NSDecimalNumber+KeepTwoPlaces.m
//  MLAppMaker
//
//  Created by Michael on 11/28/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import "NSDecimalNumber+Extension.h"

@implementation NSDecimalNumber (Extension)

+ (NSNumberFormatter *)twoPlaceNumberFormatter {
    static NSNumberFormatter *kNumberFormatter;
    if (!kNumberFormatter) {
        kNumberFormatter = [[NSNumberFormatter alloc] init];
        [kNumberFormatter setMinimumFractionDigits:2];
        [kNumberFormatter setMaximumFractionDigits:2];
        [kNumberFormatter setMinimumIntegerDigits:1];
    }
    
    return kNumberFormatter;
}

+ (NSNumberFormatter *)flexiblePlaceNumberFormatter {
    static NSNumberFormatter *kNumberFormatter;
    if (!kNumberFormatter) {
        kNumberFormatter = [[NSNumberFormatter alloc] init];
        [kNumberFormatter setMinimumFractionDigits:0];
        [kNumberFormatter setMaximumFractionDigits:2];
        [kNumberFormatter setMinimumIntegerDigits:1];
    }
    
    return kNumberFormatter;
}

- (NSString *)twoPlaceDecimalString {
    return [self twoPlaceDecimalString:YES];
}

- (NSString *)twoPlaceDecimalString:(BOOL)RoundUp {
    if (RoundUp) {
        NSNumberFormatter *formater = [self.class twoPlaceNumberFormatter];
        [formater setRoundingMode:NSNumberFormatterRoundUp];
        return [formater stringFromNumber:self];
    } else {
        NSNumberFormatter *formater = [self.class twoPlaceNumberFormatter];
        [formater setRoundingMode:NSNumberFormatterRoundDown];        
        return [formater stringFromNumber:self];
    }
}

- (NSString *)flexiblePlaceDecimalString {
    NSNumberFormatter *formater = [self.class flexiblePlaceNumberFormatter];
    return [formater stringFromNumber:self];
}

- (NSDecimalNumber *)dividingBy100 {
    return [self decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
}
- (NSDecimalNumber *)multiplyingBy100 {
    return [self decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:100]];
}
@end
