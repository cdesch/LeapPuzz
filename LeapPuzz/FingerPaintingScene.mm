//
//  FingerPaintingScene.m
//  LeapPuzz
//
//  Created by cj on 2/18/13.
//
//

#import "FingerPaintingScene.h"


#define PTM_RATIO 32

enum {
	kTagParentNode = 1,
};



@implementation FingerPaintingScene

-(id) init
{
	if( (self=[super init])) {
		
		// enable events

		self.isMouseEnabled = YES;

		CGSize s = [CCDirector sharedDirector].winSize;
		
		
		// create reset button
		[self createResetButton];
		
		//Set up sprite
		
#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
		
				
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"MotionStreak" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
		
		//[self scheduleUpdate];
        
        trackableList = [[NSMutableDictionary alloc] init];
        
        [self run];
        
        
	}
	return self;
}


- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addDelegate:self];
    NSLog(@"running");
}

#pragma mark - SampleDelegate Callbacks

- (void)onInit:(LeapController *)aController
{
    NSLog(@"Initialized");
}

- (void)onConnect:(LeapController *)aController
{
    NSLog(@"Connected");
}

- (void)onDisconnect:(LeapController *)aController
{
    NSLog(@"Disconnected");
}

- (void)onExit:(LeapController *)aController
{
    NSLog(@"Exited");
}

- (void)onFrame:(LeapController *)aController
{
    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];
    /*
     NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, fingers: %ld, tools: %ld",
     [frame id], [frame timestamp], [[frame hands] count],
     [[frame fingers] count], [[frame tools] count]);
     
     */
    if ([[frame hands] count] != 0) {
        // Get the first hand
        LeapHand *hand = [[frame hands] objectAtIndex:0];
        
        
        // Check if the hand has any fingers
        NSArray *fingers = [hand fingers];
        
        if ([fingers count] != 0) {
            
            // Calculate the hand's average finger tip position
            LeapVector *avgPos = [[LeapVector alloc] init];
            for (int i = 0; i < [fingers count]; i++) {
                LeapFinger *finger = [fingers objectAtIndex:i];
                avgPos = [avgPos plus:[finger tipPosition]];
                
                if (avgPos.z < 0){
                    NSString* fingerID = [NSString stringWithFormat:@"%d", finger.id];
                    
                    //Check if the Finger ID exists in the list already
                    if ([trackableList objectForKey:fingerID]) {
                        
                        //If it does exist update the position on the screen
                        RedDot* sprite = [trackableList objectForKey:fingerID];
                        sprite.position = [self covertLeapCoordinates:CGPointMake(finger.tipPosition.x, finger.tipPosition.y)];
                        sprite.updated = TRUE;
                        
                        CCMotionStreak* streak = [self getMotionStreak:[sprite.fingerID intValue] withSprite:sprite];
                        streak.position = sprite.position;
                        
                        
                    }else{
                        
                        NSLog(@"x %0.0f y %0.0f z %0.0f", finger.tipPosition.x, finger.tipPosition.y, finger.tipPosition.z);
                        // CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
                        //CGPoint mouseLocation = [self convertToNodeSpace:point];
                        
                        //Add it to the dictionary
                        RedDot* redDot = [self addRedDot:CGPointMake(finger.tipPosition.x, finger.tipPosition.y) finger:fingerID];
                        [trackableList setObject:redDot forKey:fingerID];
                    }
                }

            }
            
            avgPos = [avgPos divide:[fingers count]];
            
            //NSLog(@"Hand has %ld fingers, average finger tip position %@", [fingers count], avgPos);
            for (LeapFinger* finger in fingers){
                
                //NSLog(@"Finger ID %d %ld", finger.id, (unsigned long)[finger hash]);
            }
            
        }
        
        //
        [self checkFingerExists];
        
        // Get the hand's sphere radius and palm position
        /*
         NSLog(@"Hand sphere radius: %f mm, palm position: %@",
         [hand sphereRadius], [hand palmPosition]);
         */
        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];
        
        /*
         // Calculate the hand's pitch, roll, and yaw angles
         NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
         [direction pitch] * LEAP_RAD_TO_DEG,
         [normal roll] * LEAP_RAD_TO_DEG,
         [direction yaw] * LEAP_RAD_TO_DEG);
         */
    }
}

//Cycle through all the trackable dots and check if the fingers still exist.
//If they don't, delete them.
- (void)checkFingerExists{
    
    for (id key in [trackableList allKeys]) {
        RedDot* sprite = [trackableList objectForKey:key];
        if (sprite.updated) {
            sprite.updated = FALSE;
            //return;
        }else{
            CCNode *parent = [self getChildByTag:kTagParentNode];
            [trackableList removeObjectForKey:key];
            [parent removeChild:sprite cleanup:YES];
            //Get rid of the motion streak
            [self removeMotionStreak:[sprite.fingerID intValue]];
            
        }
    }
}


- (RedDot*)addRedDot:(CGPoint)p finger:(NSString*)fingerID{
    
    CCNode *parent = [self getChildByTag:kTagParentNode];
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
    
	//RedDot *sprite = [RedDot spriteWithFile:@"redcrosshair.png"];
    RedDot *sprite = [RedDot spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[parent addChild:sprite];
    sprite.updated = TRUE;
    sprite.fingerID = fingerID;
    sprite.position = ccp( p.x, p.y);
    
    [self createMotionStreak:[sprite.fingerID intValue] withSprite:sprite];
    
    return sprite;
}

- (CGPoint)covertLeapCoordinates:(CGPoint)p{
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    float screenCenter = 0.0f;
    float xScale = 1.75f;
    float yScale = 1.25f;
    return CGPointMake((s.width/2)+ (( p.x - screenCenter) * xScale), p.y * yScale);
}
#pragma mark -

-(void) createResetButton
{
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		CCScene *s = [CCScene node];
		id child = [FingerPaintingScene node];
		[s addChild:child];
		[[CCDirector sharedDirector] replaceScene: s];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:reset, nil];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	menu.position = ccp(s.width/2, 30);
	[self addChild: menu z:-1];
	
}

-(void)createMotionStreak:(NSInteger)touchHash withSprite:(CCSprite*)sprite
{

    CCMotionStreak* streak = [CCMotionStreak streakWithFade:1.7f minSeg:10 width:32 color:ccc3(0, 255, 255) texture:sprite.texture];
    [self addChild:streak z:5 tag:touchHash];
    

}

-(void)removeMotionStreak:(NSInteger)touchHash
{
    [self removeChildByTag:touchHash cleanup:YES];
}

- (CCMotionStreak*)getMotionStreak:(NSInteger)touchHash withSprite:(CCSprite*)sprite
{
    CCNode* node = [self getChildByTag:touchHash];
    if(![node isKindOfClass:[CCMotionStreak class]]) {
        [self createMotionStreak:touchHash withSprite:sprite];
    }
    return (CCMotionStreak*)node;
}

-(void) addMotionStreakPoint:(CGPoint)point on:(NSInteger)touchHash withSprite:(CCSprite*)sprite
{
    CCMotionStreak* streak = [self getMotionStreak:touchHash withSprite:sprite];
    streak.position = point;
    //[streak.ribbon addPointAt:point width:32];
}
/*
-(CGPoint)locationFromTouch:(UITouch*)touch
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}*/

/*
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSEnumerator* enumerator = [touches objectEnumerator];
    UITouch* oneTouch = nil;
    while (oneTouch = [enumerator nextObject]) {
        [self addMotionStreakPoint:[self locationFromTouch:oneTouch] on:oneTouch.hash];
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSEnumerator* enumerator = [touches objectEnumerator];
    UITouch* oneTouch = nil;
    while (oneTouch = [enumerator nextObject]) {
        [self removeMotionStreak:oneTouch.hash];
    }
}
 */


@end
