//
//  GeometryDrawScene.h
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "RedDot.h"
#import "LPTool.h"

@interface GeometryDrawScene : CCLayer {
    

    
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    CCSprite* targetSprite;
    b2MouseJoint *_mouseJoint;
    b2World* _world;
    b2Body *_groundBody;
    
//
    CCRenderTexture *target;
    CCSprite *brush;
    
    CGPoint previousLocation;
	b2Body* currentPlatformBody;
    

    NSMutableArray* plataformPoints;
    
    NSMutableDictionary* trackableBrushList;
    NSMutableDictionary* trackableList;
    

    

}

- (void)beginDraw:(CGPoint)point;
- (void)updateDraw:(CGPoint)point;
- (void)endDraw:(CGPoint)point;


@end
