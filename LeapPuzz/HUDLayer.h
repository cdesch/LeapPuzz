//
//  HUDLayer.h
//  LeapPuzz
//
//  Created by cj on 4/1/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LPTool.h"
#import "LeapObjectiveC.h"


typedef enum {
    kPressKeyMode,
    kDepthMode,
    
} InputMode;

@protocol HUDDelegate <NSObject>

- (void)changeMode:(InputMode)mode;
- (void)painting:(BOOL)paintingState;

@end


@interface HUDLayer : CCLayer  {
    NSString* primaryToolID;
    LPTool* primaryTool;
    
    InputMode inputMode;

}

@property (nonatomic, weak) id <HUDDelegate> delegate;


- (void)toolMoved:(CGPoint)point toolID:(NSString*)toolid;
- (void)startTrackingTool:(CGPoint)point toolID:(NSString*)toolid;
- (void)moveTrackingTool:(CGPoint)point toolID:(NSString*)toolid;
- (void)endTrackingTool;

- (void)changeColor:(float)percentage;



@end
