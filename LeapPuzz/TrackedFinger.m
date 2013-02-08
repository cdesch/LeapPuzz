//
//  TrackedFinger.m
//  LeapPuzz
//
//  Created by cj on 2/8/13.
//
//

#import "TrackedFinger.h"

@implementation TrackedFinger
- (id)initWithID:(NSString*)finger {
    if (self = [super init]) {
        self.fingerID = finger;
        self.updated = TRUE;
    }
    return self;
}
@end
