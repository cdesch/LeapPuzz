//
//  GameManager.h
//  LeapPuzz
//
//  Created by cj on 4/2/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LeapObjectiveC.h"
#import "HUDLayer.h"
#import "DrawingLayer.h"
#import "LineDrawer.h"
#import "GeometryDrawScene.h"
#import "SimplePaint.h"
#import "SketchRenderTextureScene.h"



@interface GameManager : CCScene <LeapListener, HUDDelegate>
{
    InputMode inputMode;
    LeapPointable* currentPointable;
    CGPoint currentPoint;
    BOOL painting;
    
}

@property (nonatomic,strong) HUDLayer* hudLayer;
@property (nonatomic,strong) DrawingLayer* drawingLayer;
@property (nonatomic,strong) LineDrawer *lineDrawer;
@property (nonatomic,strong) GeometryDrawScene *geometryDrawLayer;
@property (nonatomic,strong) SimplePaint *simplePaint;
@property (nonatomic,strong) SketchRenderTextureScene* textureScene;
@property (nonatomic,strong) LeapController* controller;
@property (nonatomic,strong) LeapScreen* leapScreen;

@end
