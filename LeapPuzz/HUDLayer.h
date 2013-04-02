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

@interface HUDLayer : CCLayer {
    NSString* primaryToolID;
    LPTool* primaryTool;
    

}

- (void)toolMoved:(CGPoint)point toolID:(NSString*)toolid;
- (void)startTrackingTool:(CGPoint)point toolID:(NSString*)toolid;
- (void)moveTrackingTool:(CGPoint)point toolID:(NSString*)toolid;
- (void)endTrackingTool;
@end
