//
//  Point.h
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import <Foundation/Foundation.h>

@interface SimplePointObject : NSObject {
    
    
}

@property (nonatomic, readwrite) CGPoint point;

- (id)initWithPosition:(CGPoint)p;
- (id)initWithX:(float)x withY:(float)y;

@end
