//
//  SketchRenderTextureScene.h
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "cocos2d.h"
#import "SimplePoint.h"

@interface SketchRenderTextureScene : CCScene 
{
	CCSprite* brush;
	NSMutableArray* touches;
}

- (void)beginDraw:(CGPoint)point;
- (void)updateDraw:(CGPoint)point;
- (void)endDraw:(CGPoint)point;


@end
