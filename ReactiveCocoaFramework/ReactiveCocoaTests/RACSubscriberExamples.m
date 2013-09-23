//
//  RACSubscriberExamples.m
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2012-11-27.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACSubscriberExamples.h"

#import "RACDisposable.h"
#import "RACSubscriber.h"

NSString * const RACSubscriberExamples = @"RACSubscriberExamples";
NSString * const RACSubscriberExampleSubscriber = @"RACSubscriberExampleSubscriber";
NSString * const RACSubscriberExampleValuesReceivedBlock = @"RACSubscriberExampleValuesReceivedBlock";
NSString * const RACSubscriberExampleErrorReceivedBlock = @"RACSubscriberExampleErrorReceivedBlock";
NSString * const RACSubscriberExampleSuccessBlock = @"RACSubscriberExampleSuccessBlock";

SharedExampleGroupsBegin(RACSubscriberExamples)

sharedExamplesFor(RACSubscriberExamples, ^(NSDictionary *data) {
	__block NSArray * (^valuesReceived)(void);
	__block NSError * (^errorReceived)(void);
	__block BOOL (^success)(void);
	__block id<RACSubscriber> subscriber;
	
	beforeEach(^{
		valuesReceived = data[RACSubscriberExampleValuesReceivedBlock];
		errorReceived = data[RACSubscriberExampleErrorReceivedBlock];
		success = data[RACSubscriberExampleSuccessBlock];
		subscriber = data[RACSubscriberExampleSubscriber];
		expect(subscriber).notTo.beNil();
	});

	it(@"should accept a nil error", ^{
		[subscriber sendError:nil];

		expect(success()).to.beFalsy();
		expect(errorReceived()).to.beNil();
		expect(valuesReceived()).to.equal(@[]);
	});

	describe(@"with values", ^{
		__block NSSet *values;
		
		beforeEach(^{
			NSMutableSet *mutableValues = [NSMutableSet set];
			for (NSUInteger i = 0; i < 20; i++) {
				[mutableValues addObject:@(i)];
			}

			values = [mutableValues copy];
		});

		it(@"should send nexts serially, even when delivered from multiple threads", ^{
			NSArray *allValues = values.allObjects;
			dispatch_apply(allValues.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), [^(size_t index) {
				[subscriber sendNext:allValues[index]];
			} copy]);

			expect(success()).to.beTruthy();
			expect(errorReceived()).to.beNil();

			NSSet *valuesReceivedSet = [NSSet setWithArray:valuesReceived()];
			expect(valuesReceivedSet).to.equal(values);
		});
	});
});

SharedExampleGroupsEnd
