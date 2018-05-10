//
//  NSManagedObjectContext+ScratchContext.h
//  MLAppMaker
//
//  Created by julie on 15/12/8.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (ScratchContext)
+ (NSManagedObjectContext *)scratchContext;
+ (NSManagedObjectContext *)tmpContext;
@end
