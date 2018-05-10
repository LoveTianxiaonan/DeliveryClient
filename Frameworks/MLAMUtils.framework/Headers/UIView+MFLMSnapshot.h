//
//  UIView+Image.h
//  iKeyboardForMessenger
//
//  Created by XiaJun on 15/4/17.
//  Copyright (c) 2015年 XiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MFLMSnapshot)
- (UIImage *)snapshotWithArea:(CGRect)clipArea;
@end
