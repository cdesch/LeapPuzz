//
//  FingerPaintingScene.h
//  LeapPuzz
//
//  Created by cj on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LeapObjectiveC.h"
#import "RedDot.h"


@interface FingerPaintingScene : CCLayer <LeapListener> {
    
    LeapController *controller;
    
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    CCSprite* targetSprite;
    b2MouseJoint *_mouseJoint;
    b2World* _world;
    b2Body *_groundBody;
    
    CIColor* brushColor;
    
    
    NSMutableDictionary* trackableList;
    NSMutableDictionary* brushesList;
    
    NSTimer* updateDraw;
    
    
    RedDot* mouseCursor;
    
    
    
}



@end
