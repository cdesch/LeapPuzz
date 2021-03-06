//
//  HUDLayer.m
//  LeapPuzz
//
//  Created by cj on 4/1/13.
//
//

#import "HUDLayer.h"

@implementation HUDLayer
@synthesize delegate;

- (id)init
{
	if ((self = [super init]))
	{
		// Get window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// Add a button which takes us back to HelloWorldScene
		
		// Create a label with the text we want on the button
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap Here" fontName:@"Helvetica" fontSize:32.0];
		
		// Create a button out of the label, and tell it to run the "switchScene" method
		CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(testing:)];
		
		// Add the button to a menu - "nil" terminates the list of items to add
		CCMenu *menu = [CCMenu menuWithItems:button, nil];
		
		// Place the menu in center of screen
		[menu setPosition:ccp(size.width / 2, size.height / 2)];
		
		// Finally add the menu to the layer
		//[self addChild:menu];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
        self.isKeyboardEnabled= YES;
        
#endif
        inputMode = kDepthMode;
        
	}
	
	return self;
}

- (void)testing:(id)sender{
    NSLog(@"working ... testing");
    
    
}

- (LPTool*)addLPTool:(CGPoint)p objectID:(NSString*)objectID{
    
    
    //CCNode *parent = [self getChildByTag:kTagParentNode];
    
	LPTool *sprite = [LPTool spriteWithFile:@"Ball.png"];
    //LPTool *sprite = [LPTool spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];
    [self addChild:sprite];
    //[parent addChild:sprite];
    sprite.updated = TRUE;
    sprite.toolID = objectID;
    sprite.position = ccp( p.x, p.y);
    
    
    
    return sprite;
}

/* Tool Moved */
- (void)toolMoved:(CGPoint)point toolID:(NSString*)toolid{
    
    if (primaryTool == nil){
        [self startTrackingTool:point toolID:toolid];
    }else{
        [self moveTrackingTool:point toolID:toolid];
    }
    
    
}

/* Start Tracking Tool */

- (void)startTrackingTool:(CGPoint)point toolID:(NSString*)toolid{
    if (primaryTool == nil){
        primaryTool = [self addLPTool:point objectID:toolid];
    }

    
}
/* Move Tracking Tool*/
- (void)moveTrackingTool:(CGPoint)point toolID:(NSString*)toolid{
    
    //Create tool if it does not exist
    if (primaryTool == nil){
        
        primaryTool = [self addLPTool:point objectID:toolid];
        
    }else{
        //Update since it does exist
        
        //primaryTool.position =  CGPointMake(x, y);
        primaryTool.position =  point;
        
        if ([toolid isNotEqualTo:primaryTool.toolID]){
            primaryTool.toolID = toolid;
            
        }else{

        }
    }

}

/* End Trackingn Tool */
- (void)endTrackingTool{
    
    if (primaryTool != nil){
        [self removeChild:primaryTool cleanup:YES];
        primaryTool = nil;
    }
}



-(BOOL) ccKeyUp:(NSEvent*)event{

    unichar ch = [event keyCode];

    if (inputMode == kPressKeyMode){
        if ( ch == 49){
        
            [self.delegate painting:FALSE];
        }
        
    }
    
    NSLog(@"%0.0u",ch);

    if ( ch == 18){
        NSLog(@"switch Mode");
        inputMode = kPressKeyMode;
        [self.delegate changeMode:inputMode];
    }else if(ch == 19){
        
        NSLog(@"switch Mode");
        inputMode = kDepthMode;
        [self.delegate changeMode:inputMode];
    }
    
    

    
    return YES;
}
-(BOOL) ccKeyDown:(NSEvent*)event{
    unichar ch = [event keyCode];
    
    if (inputMode == kPressKeyMode){
        if ( ch == 49){
            
            NSLog(@"SpaceBar");
            [self.delegate painting:TRUE];
        }
    }

    return YES;
}


- (void)changeColor:(float)percentage{
    
    
    float red   = (percentage > 50 ? 1-2*(percentage-50)/100.0 : 1.0);
    float green = (percentage > 50 ? 1.0 : 2*percentage/100.0);
    float blue  = 0.0;
    
    if(primaryTool != nil){
        
        [primaryTool runAction:[CCTintTo actionWithDuration:0 red:red  green:green blue:blue]];
    }
}


@end
