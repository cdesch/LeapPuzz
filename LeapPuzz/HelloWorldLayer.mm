//
//  HelloWorldLayer.mm
//  LeapPuzz
//
//  Created by cj on 2/3/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

enum {
	kTagParentNode = 1,
};


#pragma mark - PhysicsSprite
@implementation PhysicsSprite

-(void) setPhysicsBody:(b2Body *)body
{
    //[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:0];
    //[[[CCDirector sharedDirector] eventDispatcher] addMouseDelegate:self priority:-1];
    hasTarget = NO;
    //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:50 swallowsTouches:YES];
	body_ = body;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

-(void) setTarget:(CGPoint)p
{
    hasTarget = YES;
    target = p;
}

-(void) delTarget
{
    hasTarget = NO;
}


- (BOOL)ccTouchesMovedWithEvent:(NSEvent *)event{
    
    NSLog(@"Sprite Moved!!");
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (mouseLocation);

    
    return YES;
    
}

- (BOOL)ccMouseDragged:(NSEvent *)event{
    
    //NSLog(@"Mouse dragged in Sprite");
    if (hasTarget){
        NSLog(@"Mouse dragged in Sprite");
        CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
        //CGPoint mouseLocation = [self convertToNodeSpace:point];
        CGPoint translation = (point);
        
        //NSLog(@"Dragged %0.0f , %0.0f ", translation.x, translation.y);
            //self.position = translation;
        //body_->Get
        self.position = ccp(translation.x, translation.y);
    }
    
    return YES;
    
}

- (BOOL)ccMouseDown:(NSEvent *)event{
    
    //NSLog(@"Mouse Down");
    
    
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    //CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (point);
    //NSLog(@"Dragged %0.0f , %0.0f ", translation.x, translation.y);
    //NSLog(@"Bouding Box %0.0f %0.0f %0.0f %0.0f", self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.height,self.boundingBox.size.width );
    
    if (CGRectContainsPoint([self boundingBox], translation)){
        NSLog(@"Sprite inside Touched");
        [self setTarget:translation];
        return YES;
        
    }
    /*
    CCNode *parent = [self getChildByTag:kTagParentNode];
    for (PhysicsSprite *sprite in parent.children){
        
        
        if (CGRectContainsPoint([sprite boundingBox], translation)){
            NSLog(@"Sprite Touched");
            
            [self setTarget:translation ];
            
            //Move Sprite with
        
            //sprite.position = translation;
            
        }
        
    }
     */
    
    return NO;
}

- (BOOL)ccMouseMoved:(NSEvent *)event{
    
    
    NSLog(@"Mouse Moved in Sprite");
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event{
    
    [self delTarget];
    
    return YES;
    
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );	
	
	return transform_;
}


@end

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createResetButton;
@end

@implementation HelloWorldLayer

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
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
		
		
		[self addNewSpriteAtPosition:ccp(s.width/2, s.height/2)];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"LeapPuzz" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
		
		[self scheduleUpdate];
        

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
    NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, fingers: %ld, tools: %ld",
          [frame id], [frame timestamp], [[frame hands] count],
          [[frame fingers] count], [[frame tools] count]);
    
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
            }
            avgPos = [avgPos divide:[fingers count]];
            NSLog(@"Hand has %ld fingers, average finger tip position %@",
                  [fingers count], avgPos);
        }
        
        // Get the hand's sphere radius and palm position
        NSLog(@"Hand sphere radius: %f mm, palm position: %@",
              [hand sphereRadius], [hand palmPosition]);
        
        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];
        
        // Calculate the hand's pitch, roll, and yaw angles
        NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
              [direction pitch] * LEAP_RAD_TO_DEG,
              [normal roll] * LEAP_RAD_TO_DEG,
              [direction yaw] * LEAP_RAD_TO_DEG);
    }
}



#pragma mark - 

-(void) createResetButton
{
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		CCScene *s = [CCScene node];
		id child = [HelloWorldLayer node];
		[s addChild:child];
		[[CCDirector sharedDirector] replaceScene: s];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:reset, nil];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	menu.position = ccp(s.width/2, 30);
	[self addChild: menu z:-1];	
	
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
    //Gravity
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
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

-(void) addNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCNode *parent = [self getChildByTag:kTagParentNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];						
	[parent addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);

    //bodyDef.userData  = (void *) CFBridgingRetain(sprite);
    bodyDef.userData  = (__bridge void *)sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
}

-(void) addPieceAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCNode *parent = [self getChildByTag:kTagParentNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[parent addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);	
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteAtPosition: location];
        
        
	}
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
/*
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];
    return TRUE;
}
 */




#pragma mark - Touch Handling

- (BOOL) ccMouseDown:(NSEvent *)event{
    
    if (_mouseJoint != NULL) return NO;
    

    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (mouseLocation);
    CGPoint location = translation;
    //location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    
    // Loop through all of the Box2D bodies in our Box2D world..
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        
        
        // See if there's any user data attached to the Box2D body
        // There should be, since we set it in addBoxBodyForSprite
        
        if (b->GetUserData() != NULL) {
            // We know that the user data is a sprite since we set
            // it that way, so cast it...
            
            //PhysicsSprite *sprite = (PhysicsSprite *)CFBridgingRelease(b->GetUserData());
            
            
            for(b2Fixture *fixture = b->GetFixtureList(); fixture; fixture=fixture->GetNext()) {
                
                if(fixture->TestPoint(locationWorld)){
                    //NSLog(@"Touched itemType %d", sprite.itemType);
                    b2MouseJointDef md;
                    md.bodyA = _groundBody;
                    md.bodyB = b;
                    md.target = locationWorld;
                    md.collideConnected = true;
                    md.maxForce = 1000.0f * b->GetMass();
                    
                    _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                    b->SetAwake(true);
                }else{
                    //NSLog(@"NOT TOUCHED");
                }
            }
        }
    }
    return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event {
    
    if (_mouseJoint == NULL) return NO;
    

    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (mouseLocation);
    CGPoint location = translation;
    //location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
    
    return YES;
    
}

- (BOOL)ccMouseUp:(NSEvent *)event{
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
        
        //Check for any dangling mouse joints
        if(_world->GetJointCount() > 0){
            //NSLog(@"Found %d Extra Joints", _world->GetJointCount() );
            for(b2Joint *b = _world->GetJointList(); b; b=b->GetNext()) {
                //NSLog(@"Destproying the Dangling Joint");
                //Should check type first
                if(b){
                    _world->DestroyJoint(b);
                    b = NULL;
                    return YES;
                }
            }
        }
    }else{
        
        
        CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
        CGPoint mouseLocation = [self convertToNodeSpace:point];
        CGPoint translation = (mouseLocation);
        CGPoint location = translation;
    
		
		[self addNewSpriteAtPosition: location];
        
    }
    return YES;
}

#endif

@end
