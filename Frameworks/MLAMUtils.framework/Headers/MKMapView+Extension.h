//
//  MKMapView+Extension.h
//  FrameworkFactory
//
//  Created by Michael on 7/25/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Extension)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end
