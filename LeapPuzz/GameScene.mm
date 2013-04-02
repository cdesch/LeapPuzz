//
//  GameScene.m
//  LeapPuzz
//
//  Created by cj on 4/1/13.
//
//

#import "GameScene.h"

@implementation GameScene



+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	//CCScene *scene = [CCScene node];
    GameManager*scene = [GameManager node];
    
    
	// 'layer' is an autorelease object.
	HUDLayer* hudLayer = [HUDLayer node];
    
    hudLayer.delegate = scene;
    //DrawingLayer* drawingLayer = [DrawingLayer node];
    //LineDrawer* lineDrawer = [LineDrawer node];
    //GeometryDrawScene* geometryDrawLayer  = [GeometryDrawScene node];
    //SimplePaint* simplePaint = [SimplePaint node];
    SketchRenderTextureScene* textureScene = [SketchRenderTextureScene node];
    
	// add layer as a child to scene
	[scene addChild:hudLayer z:5];
    //[scene addChild:drawingLayer z:0];
    //[scene addChild:lineDrawer z:1];
    //[scene addChild:geometryDrawLayer z:1];
    //[scene addChild:simplePaint z:1];
    [scene addChild:textureScene z:1];
    
    scene.hudLayer = hudLayer;
    //scene.drawingLayer = drawingLayer;
    //scene.geometryDrawLayer = geometryDrawLayer;
    //scene.lineDrawer = lineDrawer;
    //scene.simplePaint = simplePaint;
    scene.textureScene = textureScene;
    
	// return the scene
	return scene;
}@end
