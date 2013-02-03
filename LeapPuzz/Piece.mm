//
//  Piece.m
//  LeapPuzz
//
//  Created by cj on 2/3/13.
//
//

#import "Piece.h"

@implementation Piece

-(void) setPhysicsBody:(b2Body *)body
{
	body_ = body;
}

- (BOOL)ccTouchesMovedWithEvent:(NSEvent *)event{
    
    NSLog(@"Sprite Moved!!");
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (mouseLocation);
    self.position = translation;
    
    return YES;
    
}

@end
