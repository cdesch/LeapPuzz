//
//  ColorWheelLayer.h
//  LeapPuzz
//
//  Created by cj on 3/5/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LeapObjectiveC.h"
#import "LeapMath.h"


@interface ColorWheelLayer : CCLayer <LeapListener> {
    
    CCLabelTTF * titleLabel;
    CCSprite* colorWheel;
    CCSprite* colorChoiceIndicator;
    LeapController* controller;
    CCSprite *background;
    CCLabelTTF* angleLabel;
    
    CCSprite* indicatorNeedle;
    
}
// define delegate property
//@property (nonatomic, strong) id  delegate;

@end

/*
// define the protocol for the delegate
@protocol ColorWheelLayerDelegate

// define protocol functions that can be used in any class using this delegate
-(void)showColorLayer:(ColorWheelLayer *)customClass;
-(void)hideColorLayer:(ColorWheelLayer *)customClass;

@end

*/