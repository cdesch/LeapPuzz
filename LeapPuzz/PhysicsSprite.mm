//
//  PhysicsSprite.m
//  LeapPuzz
//
//  Created by cj on 2/8/13.
//
//

#import "PhysicsSprite.h"
#define PTM_RATIO 32

enum {
	kTagParentNode = 1,
};

@implementation PhysicsSprite
-(void) setPhysicsBody:(b2Body *)body
{
    //[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:0];
    //[[[CCDirector sharedDirector] eventDispatcher] addMouseDelegate:self priority:-1];
    hasTarget = NO;
    //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:50 swallowsTouches:YES];
	body_ = body;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

-(void) setTarget:(CGPoint)p
{
    hasTarget = YES;
    target = p;
}

-(void) delTarget
{
    hasTarget = NO;
}




- (BOOL)ccMouseDragged:(NSEvent *)event{
    
    //NSLog(@"Mouse dragged in Sprite");
    if (hasTarget){
        NSLog(@"Mouse dragged in Sprite");
        CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
        //CGPoint mouseLocation = [self convertToNodeSpace:point];
        CGPoint translation = (point);
        
        //NSLog(@"Dragged %0.0f , %0.0f ", translation.x, translation.y);
        //self.position = translation;
        //body_->Get
        self.position = ccp(translation.x, translation.y);
    }
    
    return YES;
    
}

- (BOOL)ccMouseDown:(NSEvent *)event{
    
    //NSLog(@"Mouse Down");
    
    
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    //CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (point);
    //NSLog(@"Dragged %0.0f , %0.0f ", translation.x, translation.y);
    //NSLog(@"Bouding Box %0.0f %0.0f %0.0f %0.0f", self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.height,self.boundingBox.size.width );
    
    if (CGRectContainsPoint([self boundingBox], translation)){
        NSLog(@"Sprite inside Touched");
        [self setTarget:translation];
        return YES;
        
    }
    /*
     CCNode *parent = [self getChildByTag:kTagParentNode];
     for (PhysicsSprite *sprite in parent.children){
     
     
     if (CGRectContainsPoint([sprite boundingBox], translation)){
     NSLog(@"Sprite Touched");
     
     [self setTarget:translation ];
     
     //Move Sprite with
     
     //sprite.position = translation;
     
     }
     
     }
     */
    
    return NO;
}

- (BOOL)ccMouseMoved:(NSEvent *)event{
    
    
    NSLog(@"Mouse Moved in Sprite");
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event{
    
    [self delTarget];
    
    return YES;
    
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );
	
	return transform_;
}



@end
