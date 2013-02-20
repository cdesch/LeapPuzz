//
//  Point.m
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import "SimplePointObject.h"

@implementation SimplePointObject


- (id)initWithPosition:(CGPoint)p{
    if (self = [super init]) {
        
        self.point = p;
        
    }
    return self;
}

- (id)initWithX:(float)x withY:(float)y{
    
    if (self = [super init]) {
        
        self.point = CGPointMake(x, y);
        
    }
    return self;
}
@end
