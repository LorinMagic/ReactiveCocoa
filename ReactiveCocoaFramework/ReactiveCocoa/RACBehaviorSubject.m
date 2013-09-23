//
//  RACBehaviorSubject.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/16/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACBehaviorSubject.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACScheduler+Private.h"
#import "RACSignal+Private.h"
#import "RACSubscriber+Private.h"

@interface RACBehaviorSubject ()

// This property should only be used while synchronized on self.
@property (nonatomic, strong) id currentValue;

@end

@implementation RACBehaviorSubject

#pragma mark Lifecycle

+ (instancetype)behaviorSubjectWithDefaultValue:(id)value {
	RACBehaviorSubject *subject = [self subject];
	subject.currentValue = value;
	return subject;
}

#pragma mark RACSignal

- (void)addSubscriber:(RACSubscriber *)subscriber {
	[super addSubscriber:subscriber];

	RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
		@synchronized (self) {
			[subscriber sendNext:self.currentValue];
		}
	}];

	if (schedulingDisposable != nil) [subscriber.disposable addDisposable:schedulingDisposable];
}

#pragma mark RACSubscriber

- (void)sendNext:(id)value {
	@synchronized (self) {
		self.currentValue = value;
		[super sendNext:value];
	}
}

@end
