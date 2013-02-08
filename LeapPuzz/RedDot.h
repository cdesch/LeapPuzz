//
//  RedDot.h
//  LeapPuzz
//
//  Created by cj on 2/7/13.
//
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GLES-Render.h"

@interface RedDot : CCSprite 
{

}

@property (nonatomic, strong) NSString* fingerID;
@property (nonatomic, readwrite) BOOL updated;

@end
