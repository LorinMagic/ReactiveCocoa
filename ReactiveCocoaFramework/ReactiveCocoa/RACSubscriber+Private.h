//
//  RACSubscriber+Private.h
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2013-06-13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "RACSubscriber.h"

@class RACCompoundDisposable;

/// A block-based subscriber to one signal.
@interface RACSubscriber : NSObject <RACSubscriber>

/// A disposable representing the subscription. When disposed, events will no
/// longer cause the receiver's blocks to be invoked.
@property (nonatomic, readonly, strong) RACCompoundDisposable *disposable;

/// Initializes a subscriber to invoke the given blocks when events are received.
///
/// next       - A block to invoke when the signal sends a `next` event. This
///              may be nil.
/// error      - A block to invoke when the signal sends an `error` event. This
///              may be nil.
/// completed  - A block to invoke when the signal sends a `completed` event.
///              This may be nil.
- (id)initWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

@end
