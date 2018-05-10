//
//  NSOperationQueue+Completion.h
//  QueueTest
//
//  Created by Artem Stepanenko on 23.11.13.
//  Copyright (c) 2013 Artem Stepanenko. All rights reserved.
//

typedef void (^NSOperationQueueCompletion) (void);

@interface NSOperationQueue (Completion)

/**
 * Remarks:
 *
 * 1. Invokes completion handler just a single time when previously added operations are finished.
 * 2. Completion handler is called in a main thread.
 */

- (void)setCompletion:(NSOperationQueueCompletion)completion;

@end
