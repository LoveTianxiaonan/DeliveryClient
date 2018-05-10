//
//  MAAnnotationView+Helper.m
//  MLDelivery
//
//  Created by Miracle on 2017/5/5.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MAAnnotationView+Helper.h"

@implementation MAAnnotationView (Helper)

- (void)rotateWithRotationDegree:(CLLocationDegrees)degree {
    double headings = M_PI * degree / 180.0;
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D formValue = self.layer.transform;
    CATransform3D toValue = CATransform3DMakeRotation(headings, 0, 0, 1);
    rotateAnimation.fromValue = [NSValue valueWithCATransform3D:formValue];
    rotateAnimation.toValue = [NSValue valueWithCATransform3D:toValue];
    rotateAnimation.duration = 0.35;
    rotateAnimation.removedOnCompletion = YES;
    
    self.layer.transform = toValue;
    [self.layer addAnimation:rotateAnimation forKey:nil];
    
}

@end
