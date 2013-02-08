//
//  PhysicsSprite.h
//  LeapPuzz
//
//  Created by cj on 2/8/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LeapObjectiveC.h"


@interface PhysicsSprite :  CCSprite <CCMouseEventDelegate>
{	CGPoint target;
	uint ticker;
    bool hasTarget;
	b2Body *body_;	// strong ref
}

-(void) setPhysicsBody:(b2Body*)body;
-(void) setTarget:(CGPoint)p;
-(void) delTarget;

@end
