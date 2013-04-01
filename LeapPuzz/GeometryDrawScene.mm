//
//  GeometryDrawScene.m
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import "GeometryDrawScene.h"
#import "SimplePointObject.h"
#import "TrackedFinger.h"
#define PTM_RATIO 32

enum {
    kTagParentNode = 1,
};

@implementation GeometryDrawScene
-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		
		// create reset button
		[self createResetButton];
		
		//Set up sprite
		
#if 1
		// Use batch node. Faster
		//CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		//spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		//spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		//CCNode *parent = [CCNode node];
#endif
		//[self addChild:parent z:0 tag:kTagParentNode];
		
		plataformPoints = [[NSMutableArray alloc] init];
		
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"GeoDraw" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
		
		[self scheduleUpdate];
        
        trackableList = [[NSMutableDictionary alloc] init];
        
    
        target = [CCRenderTexture renderTextureWithWidth:s.width height: s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        target.position = ccp(s.width / 2, s.height / 2);
        [self addChild:target];
        
    
        brush = [CCSprite spriteWithFile:@"largeBrush.png"];

        trackableList = [[NSMutableDictionary alloc] init];
        trackableBrushList = [[NSMutableDictionary alloc] init];
        
        [self run];
        
        
	}
	return self;
}


#pragma mark -

-(void) createResetButton
{
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		CCScene *s = [CCScene node];
		id child = [GeometryDrawScene node];
		[s addChild:child];
		[[CCDirector sharedDirector] replaceScene: s];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:reset, nil];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	menu.position = ccp(s.width/2, 30);
	[self addChild: menu z:-1];
	
}

- (LPTool*)addLPTool:(CGPoint)p objectID:(NSString*)objectID{


    //CCNode *parent = [self getChildByTag:kTagParentNode];

	LPTool *sprite = [LPTool spriteWithFile:@"Block.png"];
    //LPTool *sprite = [LPTool spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];
    [self addChild:sprite];
    //[parent addChild:sprite];
    sprite.updated = TRUE;
    sprite.toolID = objectID;
    sprite.position = ccp( p.x, p.y);
    
    
    
    return sprite;
}


-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
    

	
    //Gravity
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
    
    _world = world;
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
    _groundBody = groundBody;
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();
	
	kmGLPopMatrix();

}

//void HelloWorld::addRectangleBetweenPointsToBody(b2Body *body, CCPoint start, CCPoint end)
- (void)addRectangleBetweenPointsToBody:(b2Body *)body withStart:(CGPoint) start withEnd:(CGPoint)end{


    float distance = sqrt( pow(end.x - start.x, 2) + pow(end.y - start.y, 2));

    float sx=start.x;
    float sy=start.y;
    float ex=end.x;
    float ey=end.y;
    float dist_x=sx-ex;
    float dist_y=sy-ey;
    float angle= atan2(dist_y,dist_x);
    
    float px = (sx+ex)/2/PTM_RATIO - body->GetPosition().x;
    float py = (sy+ey)/2/PTM_RATIO - body->GetPosition().y;
    
    float width = abs(distance)/PTM_RATIO;

    float height =  brush.boundingBox.size.height/PTM_RATIO;
    
    b2PolygonShape boxShape;
    boxShape.SetAsBox(width / 2, height / 2, b2Vec2(px,py),angle);
    

    b2FixtureDef boxFixtureDef;
    boxFixtureDef.shape = &boxShape;
    boxFixtureDef.density = 5;
    
    boxFixtureDef.filter.categoryBits = 2;
    
    body->CreateFixture(&boxFixtureDef);

}


- (void)addRectangleBetweenPointsToDynamicBody:(b2Body *)body withStart:(CGPoint) start withEnd:(CGPoint)end{
    
    float distance = sqrt( pow(end.x - start.x, 2) + pow(end.y - start.y, 2));

    float sx=start.x;
    float sy=start.y;
    float ex=end.x;
    float ey=end.y;
    
    
    float dist_x=abs(sx-ex);
    float dist_y=abs(sy-ey);
    
    
    float angle= atan2(dist_y,dist_x);
    
    float px = (sx+ex)/2/(float)PTM_RATIO - body->GetPosition().x;
    float py = (sy+ey)/2/(float)PTM_RATIO - body->GetPosition().y;
    
    float width = abs(distance)/(float)PTM_RATIO;
    
    float height =  brush.boundingBox.size.height/PTM_RATIO;
    
    b2PolygonShape boxShape;

    boxShape.SetAsBox(width / 2, height / 2, b2Vec2(px,py),angle);
    b2FixtureDef boxFixtureDef;
    boxFixtureDef.shape = &boxShape;
    boxFixtureDef.density = 5;
    
    boxFixtureDef.filter.categoryBits = 2;

    
    body->CreateFixture(&boxFixtureDef);

}

- (CGRect) getBodyRectangle:(b2Body*) body
//CCRect HelloWorld::getBodyRectangle(b2Body* body)
{
    CGSize s = [[CCDirector sharedDirector] winSize];

    
    float minX2 = s.width;
    float maxX2 = 0;
    float minY2 = s.height;
    float maxY2 = 0;
    
    const b2Transform& xf = body->GetTransform();
    for (b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext())
    {
        
        b2PolygonShape* poly = (b2PolygonShape*)f->GetShape();
        int32 vertexCount = poly->m_vertexCount;
        b2Assert(vertexCount <= b2_maxPolygonVertices);
        
        for (int32 i = 0; i < vertexCount; ++i)
        {
            b2Vec2 vertex = b2Mul(xf, poly->m_vertices[i]);
            
            
            if(vertex.x < minX2)
            {
                minX2 = vertex.x;
            }
            
            if(vertex.x > maxX2)
            {
                maxX2 = vertex.x;
            }
            
            if(vertex.y < minY2)
            {
                minY2 = vertex.y;
            }
            
            if(vertex.y > maxY2)
            {
                maxY2 = vertex.y;
            }
        }
    }
    
    maxX2 *= PTM_RATIO;
    minX2 *= PTM_RATIO;
    maxY2 *= PTM_RATIO;
    minY2 *= PTM_RATIO;
    
    float width2 = maxX2 - minX2;
    float height2 = maxY2 - minY2;
    
    float remY2 = s.height - maxY2;
    
    return CGRectMake(minX2, remY2, width2, height2);
}


-(void) update: (ccTime) dt{


	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    //Iterate over the bodies in the physics world
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != Nil) {

            //Synchronize the AtlasSprites position and rotation with the corresponding body
            
            CCSprite* myActor = (__bridge CCSprite*)b->GetUserData();
            myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            myActor.rotation = ( -1 * CC_RADIANS_TO_DEGREES(b->GetAngle()) );
        }
    }
    
}

#pragma mark - Touch Handling

- (BOOL) ccMouseDown:(NSEvent *)event{
    
    //CGSize s = [[CCDirector sharedDirector] winSize];

    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint location = point;
    
    //b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    [plataformPoints removeAllObjects];

    
    SimplePointObject* pointObject = [[SimplePointObject alloc] initWithPosition:location];
    [plataformPoints addObject:pointObject];
    

        
    previousLocation = location;
        
    b2BodyDef myBodyDef;
    myBodyDef.type = b2_staticBody;
    myBodyDef.position.Set(location.x/PTM_RATIO,location.y/PTM_RATIO);
    currentPlatformBody = world->CreateBody(&myBodyDef);
        
    return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event {
    
    //CGSize s = [[CCDirector sharedDirector] winSize];
    
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint location = point;
    
    //b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    
    
    //CCTouch *touch = (CCTouch *)touches->anyObject();
    CGPoint start = location;
    CGPoint end = previousLocation;

    [target begin];

    
    float distance = ccpDistance(start, end);
    
    for (int i = 0; i < distance; i++)
    {
        float difx = end.x - start.x;
        float dify = end.y - start.y;
        float delta = (float)i / distance;
        brush.position = ccp(start.x + (difx * delta), start.y + (dify * delta));

		//brush->setOpacity(0.1);

        [brush visit];
    }
    [target end];

        
    distance = sqrt( pow(location.x - previousLocation.x, 2) + pow(location.y - previousLocation.y, 2));

        if(distance > 2)
        {
            [self addRectangleBetweenPointsToBody:currentPlatformBody withStart:previousLocation withEnd:location];
            SimplePointObject* pointObject = [[SimplePointObject alloc] initWithPosition:location];
            [plataformPoints addObject:pointObject];

            previousLocation = location;

        }else{
            //NSLog(@"Do Not add");
        }
    
    
    return YES;
    
}

- (BOOL)ccMouseUp:(NSEvent *)event{
    
    
    b2BodyDef myBodyDef;
    myBodyDef.type = b2_dynamicBody; //this will be a dynamic body
 
    myBodyDef.position.Set(currentPlatformBody->GetPosition().x, currentPlatformBody->GetPosition().y); //set the starting position
    myBodyDef.angle = 0;
    
    b2Body* newBody = world->CreateBody(&myBodyDef);
    
    for (int i=0; i < [plataformPoints count] - 1; i++){
        
        SimplePointObject* startPoint = [plataformPoints objectAtIndex:i];
        CGPoint start = startPoint.point;
        
        SimplePointObject* endPoint = [plataformPoints objectAtIndex:i+1];
        CGPoint end = endPoint.point;

        [self addRectangleBetweenPointsToDynamicBody:newBody withStart:start withEnd:end];

    }
    

    world->DestroyBody(currentPlatformBody);
        
        
    CGSize s = [[CCDirector sharedDirector] winSize];
    CGRect bodyRectangle = [self getBodyRectangle:newBody];

    CGImage *pImage = [target newCGImage];
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addCGImage:pImage forKey:nil];
    CCSprite* sprite = [CCSprite spriteWithTexture:tex rect:bodyRectangle];
        
    float anchorX = newBody->GetPosition().x * PTM_RATIO - bodyRectangle.origin.x;
    float anchorY = bodyRectangle.size.height - (s.height - bodyRectangle.origin.y - newBody->GetPosition().y * PTM_RATIO);
    
    [sprite setAnchorPoint:ccp(anchorX / bodyRectangle.size.width,  anchorY / bodyRectangle.size.height)];

    //myBodyDef.userData =  (__bridge void *)sprite;
    newBody->SetUserData((__bridge void *)sprite);
    
    
    [self addChild:sprite];
    [self removeChild:target cleanup:YES];

    target = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    target.position = ccp(s.width / 2, s.height / 2);
    [self addChild:target z:5];
    
    return YES;
}
#pragma mark - 

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
    for (id key in [trackableBrushList allKeys]) {
        TrackedFinger* sprite = [trackableList objectForKey:key];
        if (sprite.updated) {
            sprite.updated = FALSE;
            //return;
        }else{
            [self endFingerDraw:sprite];
            [trackableList removeObjectForKey:key];
            
        }
        
    }

}
#pragma mark - SampleDelegate Callbacks
- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addListener:self];
    
    
    NSArray* screens = controller.calibratedScreens;
    leapScreen = [screens objectAtIndex:0];
    //
    NSLog(@"Screens: %0.0ld", (unsigned long)[screens count]);
    NSLog(@"running");
    

}

- (void)onInit:(NSNotification *)notification{
    NSLog(@"Leap: Initialized");
}

- (void)onConnect:(NSNotification *)notification;
{
    NSLog(@"Leap: Connected");
    LeapController *aController = (LeapController *)[notification object];
    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification{
    NSLog(@"Leap: Disconnected");
}

- (void)onExit:(NSNotification *)notification{
    NSLog(@"Leap: Exited");
}

- (void)onFrame:(NSNotification *)notification{
    
    ///NSLog(@"OnFrame");
    LeapController *aController = (LeapController *)[notification object];
    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];


    if ([[frame tools] count] != 0){
        NSArray *tools = [frame tools];
        
        //Create tool if it does not exist
        if (primaryTool == nil){
            
            for (int i = 0; i < [tools count]; i++){
                
                LeapTool* tool = [tools objectAtIndex:i];
                LeapVector* normalized = [leapScreen intersect:tool normalize:NO clampRatio:1.0];
                NSLog(@"x  %0.0f y %0.0f", normalized.x, normalized.y);
                
                primaryTool = [self addLPTool: CGPointMake(normalized.x, normalized.y) objectID:[NSString stringWithFormat:@"%0.0d",tool.id]];
                //primaryTool = [self addLPTool: [self covertLeapCoordinates:CGPointMake(tool.tipPosition.x, tool.tipPosition.y)] objectID:[NSString stringWithFormat:@"%0.0d",tool.id]];
            }
            
        }else{
            //Update since it does exist
            for (int i = 0; i < [tools count]; i++){
                LeapTool* tool = [tools objectAtIndex:i];
                if (tool.id == [primaryTool.toolID intValue]){
                    
                    LeapVector* normalized = [leapScreen intersect:tool normalize:NO clampRatio:1.0];
                    NSLog(@"x  %0.0f y %0.0f", normalized.x, normalized.y);

                    primaryTool.position =  CGPointMake(normalized.x, normalized.y);
                    //primaryTool.position =  [self covertLeapCoordinates:CGPointMake(tool.tipPosition.x, tool.tipPosition.y)];
                    
                }
                
            }
            
        }
        
        
    }else{
        
        CCNode *parent = [self getChildByTag:kTagParentNode];
        [self removeChild:primaryTool cleanup:YES];
        //[parent removeChild:primaryTool cleanup:YES];
        primaryTool = nil;
        
    }
    
    
/*

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
                
                if (avgPos.z > 0){
                    NSString* fingerID = [NSString stringWithFormat:@"%d", finger.id];
                    
                    //Check if the Finger ID exists remove it from the sceen
                    if ([trackableList objectForKey:fingerID]) {
                        
                        //EndDraw
                        
                        TrackedFinger* sprite = (TrackedFinger*)[trackableList objectForKey:fingerID];
                        //CCNode *parent = [self getChildByTag:kTagParentNode];
                        [trackableList removeObjectForKey:fingerID];
                        //[self removeChild:sprite cleanup:YES];
                        //Get rid of the motion streak
                        //[self removeMotionStreak:[sprite.fingerID intValue]];
                        [self endFingerDraw:sprite];
                        
                    }
                }else{
                    //Draw it
                    NSString* fingerID = [NSString stringWithFormat:@"%d", finger.id];
                    
                    //Check if the Finger ID exists in the list already
                    if ([trackableList objectForKey:fingerID]) {
                        
                        //Update
                        //If it does exist update the position on the screen
                        TrackedFinger* sprite = [trackableBrushList objectForKey:fingerID];
                        sprite.position = [self covertLeapCoordinates:CGPointMake(finger.tipPosition.x, finger.tipPosition.y)];
                        sprite.updated = TRUE;
                        
                        [self updateFingerDraw:sprite];
                        
                    }else{
                        //Create//
                        
                        NSLog(@"x %0.0f y %0.0f z %0.0f", finger.tipPosition.x, finger.tipPosition.y, finger.tipPosition.z);
                        //Add it to the dictionary
                        TrackedFinger* redDot = [[TrackedFinger alloc] initWithID:fingerID withPosition:CGPointMake(finger.tipPosition.x, finger.tipPosition.y)];
                        //[self addRedDot:CGPointMake(finger.tipPosition.x, finger.tipPosition.y) finger:fingerID];
                        [trackableBrushList setObject:redDot forKey:fingerID];
                        
                        [self beginFingerDraw:redDot];
                    }
                }
            }
            
            avgPos = [avgPos divide:[fingers count]];
            
            //NSLog(@"Hand has %ld fingers, average finger tip position %@", [fingers count], avgPos);
            for (LeapFinger* finger in fingers){
                
                //NSLog(@"Finger ID %d %ld", finger.id, (unsigned long)[finger hash]);
            }
            
        }
 
        [self checkFingerExists];
 
        //const LeapVector *normal = [hand palmNormal];
        //const LeapVector *direction = [hand direction];
        
    }
 
 */

    
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
//Track fingers at all times,

//if the Z is postive, then put a red dot,

//if z i negative, draw the line

- (void)beginFingerDraw:(id)sender{
    
    TrackedFinger* trackedFinger = (TrackedFinger*)[sender object];
    [self beginDraw:trackedFinger.position];
    
}

- (void)updateFingerDraw:(id)sender{
    TrackedFinger* trackedFinger = (TrackedFinger*)[sender object];
    [self updateDraw:trackedFinger.position];

}

- (void)endFingerDraw:(id)sender{
    TrackedFinger* trackedFinger = (TrackedFinger*)[sender object];
    [self endDraw:trackedFinger.position];
}

//The further negative, the thicker the line. 
- (void)beginDraw:(CGPoint)point{

    
    
    //CGSize s = [[CCDirector sharedDirector] winSize];
    
    //CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint location = point;
    
    //b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    [plataformPoints removeAllObjects];
    
    
    SimplePointObject* pointObject = [[SimplePointObject alloc] initWithPosition:location];
    [plataformPoints addObject:pointObject];
    
    previousLocation = location;
    
    b2BodyDef myBodyDef;
    myBodyDef.type = b2_staticBody;
    myBodyDef.position.Set(location.x/PTM_RATIO,location.y/PTM_RATIO);
    currentPlatformBody = world->CreateBody(&myBodyDef);
    
}

- (void)updateDraw:(CGPoint)point{
    
    
    CGPoint location = point;
    
    CGPoint start = location;
    CGPoint end = previousLocation;
    
    [target begin];
    
    
    float distance = ccpDistance(start, end);
    
    for (int i = 0; i < distance; i++)
    {
        float difx = end.x - start.x;
        float dify = end.y - start.y;
        float delta = (float)i / distance;
        brush.position = ccp(start.x + (difx * delta), start.y + (dify * delta));
        
		//brush->setOpacity(0.1);
        
        [brush visit];
    }
    [target end];
    
    
    distance = sqrt( pow(location.x - previousLocation.x, 2) + pow(location.y - previousLocation.y, 2));
    
    if(distance > 2)
    {
        [self addRectangleBetweenPointsToBody:currentPlatformBody withStart:previousLocation withEnd:location];
        SimplePointObject* pointObject = [[SimplePointObject alloc] initWithPosition:location];
        [plataformPoints addObject:pointObject];
        
        previousLocation = location;
        
    }else{
        //NSLog(@"Do Not add");
    }
}

- (void)endDraw:(CGPoint)point{
    
    
    b2BodyDef myBodyDef;
    myBodyDef.type = b2_dynamicBody; //this will be a dynamic body
    
    myBodyDef.position.Set(currentPlatformBody->GetPosition().x, currentPlatformBody->GetPosition().y); //set the starting position
    myBodyDef.angle = 0;
    
    b2Body* newBody = world->CreateBody(&myBodyDef);
    
    for (int i=0; i < [plataformPoints count] - 1; i++){
        
        SimplePointObject* startPoint = [plataformPoints objectAtIndex:i];
        CGPoint start = startPoint.point;
        
        SimplePointObject* endPoint = [plataformPoints objectAtIndex:i+1];
        CGPoint end = endPoint.point;
        
        [self addRectangleBetweenPointsToDynamicBody:newBody withStart:start withEnd:end];
        
    }
    
    
    world->DestroyBody(currentPlatformBody);
    
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    CGRect bodyRectangle = [self getBodyRectangle:newBody];
    
    CGImage *pImage = [target newCGImage];
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addCGImage:pImage forKey:nil];
    CCSprite* sprite = [CCSprite spriteWithTexture:tex rect:bodyRectangle];
    
    float anchorX = newBody->GetPosition().x * PTM_RATIO - bodyRectangle.origin.x;
    float anchorY = bodyRectangle.size.height - (s.height - bodyRectangle.origin.y - newBody->GetPosition().y * PTM_RATIO);
    
    [sprite setAnchorPoint:ccp(anchorX / bodyRectangle.size.width,  anchorY / bodyRectangle.size.height)];
    
    //myBodyDef.userData =  (__bridge void *)sprite;
    newBody->SetUserData((__bridge void *)sprite);
    
    
    [self addChild:sprite];
    [self removeChild:target cleanup:YES];
    
    target = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    target.position = ccp(s.width / 2, s.height / 2);
    [self addChild:target z:5];
    

}

- (void)createMotionStreak:(NSInteger)touchHash withSprite:(CCSprite*)sprite
{
    CCMotionStreak* streak = [CCMotionStreak streakWithFade:1.7f minSeg:10 width:32 color:ccc3(0, 255, 255) texture:sprite.texture];
    [self addChild:streak z:5 tag:touchHash];
}

- (void)removeMotionStreak:(NSInteger)touchHash
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

- (void)addMotionStreakPoint:(CGPoint)point on:(NSInteger)touchHash withSprite:(CCSprite*)sprite
{
    CCMotionStreak* streak = [self getMotionStreak:touchHash withSprite:sprite];
    streak.position = point;
    //[streak.ribbon addPointAt:point width:32];
}


@end
