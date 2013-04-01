//
//  LPTool.h
//  LeapPuzz
//
//  Created by cj on 3/29/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GLES-Render.h"

@interface LPTool : CCSprite

@property (nonatomic, strong) NSString* toolID;
@property (nonatomic, readwrite) BOOL updated;
//@property (nonatomic, readwrite) CGPoint position;



@end
