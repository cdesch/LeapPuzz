//
//  GameScene.h
//  LeapPuzz
//
//  Created by cj on 4/1/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HUDLayer.h"
#import "LeapObjectiveC.h"
@interface GameScene : CCScene <LeapListener> {
    
}


@property (nonatomic,strong) CCLayer* hudLayer;
@property (nonatomic,strong) CCLayer* drawingLayer;
@property (nonatomic,strong) LeapController* controller;
@property (nonatomic,strong) LeapScreen* leapScreen;


@end
