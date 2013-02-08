//
//  GestureDetectionScene.h
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
#import "RedDot.h"

@interface GestureDetectionScene : CCLayer <LeapDelegate>{
    LeapController *controller;
    
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    CCSprite* targetSprite;
    b2MouseJoint *_mouseJoint;
    b2World* _world;
    b2Body *_groundBody;
    
    
    NSMutableDictionary* trackableList;
    

}

-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createResetButton;

@end
