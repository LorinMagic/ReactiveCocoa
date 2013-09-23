//
//  RACSubscriber.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/1/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACSubscriber.h"
#import "RACSubscriber+Private.h"
#import "EXTScope.h"
#import "RACCompoundDisposable.h"
#import "RACScheduler+Private.h"

@interface RACSubscriber ()

// If not `nil`, a block to invoke upon `next` events.
//
// This should only be used while synchronized on `self`.
@property (nonatomic, copy) void (^next)(id value);

// If not `nil`, a block to invoke upon any `error` event.
//
// This should only be used while synchronized on `self`.
@property (nonatomic, copy) void (^error)(NSError *error);

// If not `nil`, a block to invoke upon any `completed` event.
//
// This should only be used while synchronized on `self`.
@property (nonatomic, copy) void (^completed)(void);

@end

@implementation RACSubscriber

#pragma mark Lifecycle

- (id)init {
	NSCAssert(NO, @"Use -initWithNext:error:completed: instead");
	return nil;
}

- (id)initWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed {
	self = [super init];
	if (self == nil) return nil;

	_next = [next copy];
	_error = [error copy];
	_completed = [completed copy];
	_disposable = [RACCompoundDisposable compoundDisposable];

	@weakify(self);
	[self.disposable addDisposable:[RACDisposable disposableWithBlock:^{
		@strongify(self);
		if (self == nil) return;

		@synchronized (self) {
			self.next = nil;
			self.error = nil;
			self.completed = nil;
		}
	}]];

	return self;
}

- (void)dealloc {
	[self.disposable dispose];
}

#pragma mark Generators

- (void)startWithGenerator:(RACSignalGeneratorBlock)generatorBlock {
	NSCParameterAssert(generatorBlock != nil);

	RACScheduler *scheduler = RACScheduler.subscriptionScheduler;
	[scheduler schedule:^{
		if (self.disposable.disposed) return;

		RACSignalStepBlock stepBlock = generatorBlock(self, self.disposable);
		if (stepBlock == nil) return;

		RACDisposable *recursiveDisposable = [scheduler scheduleRecursiveBlock:^(dispatch_block_t reschedule) {
			stepBlock();
			reschedule();
		}];

		if (recursiveDisposable != nil) [self.disposable addDisposable:recursiveDisposable];
	}];
}

#pragma mark RACSubscriber

- (void)sendNext:(id)value {
	if (self.disposable.disposed) return;

	@synchronized (self) {
		if (self.next != nil) self.next(value);
	}
}

- (void)sendError:(NSError *)error {
	if (self.disposable.disposed) return;

	@synchronized (self) {
		// Preserve the error block through disposal.
		__typeof__(self.error) errorBlock = self.error;

		[self.disposable dispose];
		if (errorBlock != nil) errorBlock(error);
	}
}

- (void)sendCompleted {
	if (self.disposable.disposed) return;

	@synchronized (self) {
		// Preserve the completion block through disposal.
		__typeof__(self.completed) completedBlock = self.completed;

		[self.disposable dispose];
		if (completedBlock != nil) completedBlock();
	}
}

@end
