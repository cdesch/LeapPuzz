//
//  SimplePoint.h
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import <Foundation/Foundation.h>


@interface SimplePoint : NSObject {

}

@property (nonatomic, readwrite) float x;
@property (nonatomic, readwrite) float y;
//@property (nonatomic, readwrite) float z;
- (id)initWithPosition:(CGPoint)p;
- (id)initWithX:(float)x withY:(float)y;


@end
