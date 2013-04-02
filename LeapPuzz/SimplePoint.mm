//
//  SimplePoint.m
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import "SimplePoint.h"

@implementation SimplePoint 

- (id)initWithPosition:(CGPoint)p{
    if (self = [super init]) {

        self.x = p.x;
        self.y = p.y;
        
    }
    return self;
}

- (id)initWithX:(float)x withY:(float)y{
    
    if (self = [super init]) {
        
        self.x = x;
        self.y = y;
        
    }
    return self;
}

- (CGPoint)point{
    return CGPointMake(self.x, self.y);
}


@end
