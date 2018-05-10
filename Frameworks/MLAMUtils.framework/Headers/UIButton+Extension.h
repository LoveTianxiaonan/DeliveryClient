//
//  UIButton+Extension.h
//  FrameworkFactory
//
//  Created by Michael on 7/19/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extension)
// 图片和标题水平居中放置，图片在前，标题在后
- (void)centerHorizontalImageAndTitleWithSpacing:(CGFloat)spacing;

// 标题和图片水平放置，标题居中，图片右对齐
- (void)centerHorizontalTitleAndImageWithSpacing:(CGFloat)spacing;

// 按钮和标题垂直放置，图标在上，文本在下
- (void)centerVerticallyWithPadding:(float)padding;
- (void)centerVertically;
@end
