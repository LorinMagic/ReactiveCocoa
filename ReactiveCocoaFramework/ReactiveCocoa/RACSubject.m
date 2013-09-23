//
//  RACSubject.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACSubject.h"
#import "RACSignal+Private.h"

@implementation RACSubject

#pragma mark Lifecycle

+ (instancetype)subject {
	return [[self alloc] init];
}

#pragma mark RACSubscriber

- (void)sendNext:(id)value {
	[self performBlockOnEachSubscriber:^(id<RACSubscriber> subscriber) {
		[subscriber sendNext:value];
	}];
}

- (void)sendError:(NSError *)error {
	[self performBlockOnEachSubscriber:^(id<RACSubscriber> subscriber) {
		[subscriber sendError:error];
	}];
}

- (void)sendCompleted {
	[self performBlockOnEachSubscriber:^(id<RACSubscriber> subscriber) {
		[subscriber sendCompleted];
	}];
}

@end
