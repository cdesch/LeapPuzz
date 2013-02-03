//
//  Piece.h
//  LeapPuzz
//
//  Created by cj on 2/3/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#import "GLES-Render.h"


@interface Piece : CCSprite <CCTouchEventDelegate>
{
	b2Body *body_;	// strong ref
}
-(void) setPhysicsBody:(b2Body*)body;
@end
