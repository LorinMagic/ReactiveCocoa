//
//  RACSignal+Private.h
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/15/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACSignal.h"

@class RACSubscriber;

@interface RACSignal ()

- (void)addSubscriber:(RACSubscriber *)subscriber;
- (void)performBlockOnEachSubscriber:(void (^)(id<RACSubscriber> subscriber))block;

@end
