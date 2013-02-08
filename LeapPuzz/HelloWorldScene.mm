//
//  HelloWorldScene.m
//  Cocos2DBreakout2
//
//  Created by Ray Wenderlich on 2/17/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "HelloWorldScene.h"

#import "SimpleAudioEngine.h"
#import "TrackedFinger.h"
#define PTM_RATIO 32

@implementation HelloWorld

+ (id)scene {
 
    CCScene *scene = [CCScene node];
    HelloWorld *layer = [HelloWorld node];
    [scene addChild:layer];
    return scene;
    
}

- (id)init {
 
    if ((self=[super init])) {
        
        CGSize s = [CCDirector sharedDirector].winSize;

        self.isMouseEnabled = YES;
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = true;
        _world = new b2World(gravity);

        // Define the ground body.
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0); // bottom-left corner
        
        // Call the body factory which allocates memory for the ground body
        // from a pool and creates the ground box shape (also from a pool).
        // The body is also added to the world.
        b2Body* groundBody = _world->CreateBody(&groundBodyDef);
        
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
        
        // Create sprite and add it to the layer
        CCSprite *ball = [CCSprite spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 52, 52)];
        ball.position = ccp(100, 100);
        ball.tag = 1;
        [self addChild:ball]; 
        
        // Create ball body 
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
        ballBodyDef.userData =  (__bridge void *) ball;
        b2Body * ballBody = _world->CreateBody(&ballBodyDef);

        // Create circle shape
        b2CircleShape circle;
        circle.m_radius = 26.0/PTM_RATIO;

        // Create shape definition and add to body
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.0f; // We don't want the ball to have friction!
        ballShapeDef.restitution = 1.0f;
        _ballFixture = ballBody->CreateFixture(&ballShapeDef);
        
        // Give shape initial impulse...
        b2Vec2 force = b2Vec2(10, 10);
        ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
        
        // Create paddle and add it to the layer
        CCSprite *paddle = [CCSprite spriteWithFile:@"Paddle.png"];
        paddle.position = ccp(s.width/2, 50);
        [self addChild:paddle];

        // Create paddle body
        b2BodyDef paddleBodyDef;
        paddleBodyDef.type = b2_dynamicBody;
        paddleBodyDef.position.Set(s.width/2/PTM_RATIO, 50/PTM_RATIO);
        paddleBodyDef.userData =  (__bridge void *) paddle;
        _paddleBody = _world->CreateBody(&paddleBodyDef);

        // Create paddle shape
        b2PolygonShape paddleShape;
        paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2, 
                             paddle.contentSize.height/PTM_RATIO/2);

        // Create shape definition and add to body
        b2FixtureDef paddleShapeDef;
        paddleShapeDef.shape = &paddleShape;
        paddleShapeDef.density = 10.0f;
        paddleShapeDef.friction = 0.4f;
        paddleShapeDef.restitution = 0.1f;
        _paddleFixture = _paddleBody->CreateFixture(&paddleShapeDef);
        
        // Restrict paddle along the x axis
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(1.0f, 0.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(_paddleBody, _groundBody, _paddleBody->GetWorldCenter(), worldAxis);
        _world->CreateJoint(&jointDef);
        
        for(int i = 0; i < 10; i++) {
            static int padding=20;
            
            for (int j = 500; j < 1000; j+=100){
                // Create block and add it to the layer
                CCSprite *block = [CCSprite spriteWithFile:@"Block.png"];
                int xOffset = padding+block.contentSize.width/2+((block.contentSize.width+padding)*i);
                int yOffset = j; //padding+block.contentSize.height/2+((block.contentSize.height+padding)*i);
                block.position = ccp(xOffset, yOffset);
                block.tag = 2;
                [self addChild:block];
                
                // Create block body
                b2BodyDef blockBodyDef;
                blockBodyDef.type = b2_dynamicBody;
                blockBodyDef.position.Set(xOffset/PTM_RATIO, yOffset/PTM_RATIO);
                blockBodyDef.userData =  (__bridge void *) block;
                b2Body *blockBody = _world->CreateBody(&blockBodyDef);
                
                // Create block shape
                b2PolygonShape blockShape;
                blockShape.SetAsBox(block.contentSize.width/PTM_RATIO/2,
                                    block.contentSize.height/PTM_RATIO/2);
                
                // Create shape definition and add to body
                b2FixtureDef blockShapeDef;
                blockShapeDef.shape = &blockShape;
                blockShapeDef.density = 10.0;
                blockShapeDef.friction = 0.0;
                blockShapeDef.restitution = 0.1f;
                blockBody->CreateFixture(&blockShapeDef);
            }
            
            

            
        }
        
        
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        
        [self schedule:@selector(tick:)];
        
        [self run];
        fingerTracked = FALSE;
        
        [self addFingerJoint];
        
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
                
                NSString* fingerID = [NSString stringWithFormat:@"%d", finger.id];
                /*
                //Check if the Finger ID exists in the list already
                if ([trackableList objectForKey:fingerID]) {
                    
                    //If it does exist update the position on the screen
                    TrackedFinger* sprite = [trackableList objectForKey:fingerID];
                    sprite.updated = TRUE;
                    
                    
                }else{
                    
                    //NSLog(@"x %0.0f y %0.0f z %0.0f", finger.tipPosition.x, finger.tipPosition.y, finger.tipPosition.z);
                    // CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
                    //CGPoint mouseLocation = [self convertToNodeSpace:point];
                    //Add it to the dictionary
                    TrackedFinger* redDot = [[TrackedFinger alloc] initWithID:fingerID];
                    [trackableList setObject:redDot forKey:fingerID];
                }
                 */
            }
            
            avgPos = [avgPos divide:[fingers count]];
            //NSLog(@"x %0.0f y %0.0f z %0.0f", avgPos.x, avgPos.y, avgPos.z);
            [self fingerMoved:CGPointMake(avgPos.x, avgPos.y)];
            
            
            //NSLog(@"Hand has %ld fingers, average finger tip position %@", [fingers count], avgPos);
            for (LeapFinger* finger in fingers){
                
                //NSLog(@"Finger ID %d %ld", finger.id, (unsigned long)[finger hash]);
            }
            
        }
        
        //[self checkFingerExists];
        
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


- (void)tick:(ccTime) dt {
    
    bool blockFound = false;
    _world->Step(dt, 10, 10);    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {    
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *)b->GetUserData();     
            if (sprite.tag == 2) {
                blockFound = true;
            }
            
            if (sprite.tag == 1) {
                static int maxSpeed = 10;
                
                b2Vec2 velocity = b->GetLinearVelocity();
                float32 speed = velocity.Length();
                
                // When the ball is greater than max speed, slow it down by
                // applying linear damping.  This is better for the simulation
                // than raw adjustment of the velocity.
                if (speed > maxSpeed) {
                    b->SetLinearDamping(0.5);
                } else if (speed < maxSpeed) {
                    b->SetLinearDamping(0.0);
                }
                
            }
            
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }        
    }
    
    if (!blockFound) {
        /*
        GameOverScene *gameOverScene = [GameOverScene node];
        [gameOverScene.layer.label setString:@"You Win!"];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
         */
        NSLog(@"GameOver");
    }

    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        if ((contact.fixtureA == _bottomFixture && contact.fixtureB == _ballFixture) ||
            (contact.fixtureA == _ballFixture && contact.fixtureB == _bottomFixture)) {
            
            NSLog(@"GameOver");
        } 
                
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (__bridge CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (__bridge CCSprite *) bodyB->GetUserData();
            
            // Sprite A = ball, Sprite B = Block
            if (spriteA.tag == 1 && spriteB.tag == 2) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                }
            }
            // Sprite B = block, Sprite A = ball
            else if (spriteA.tag == 2 && spriteB.tag == 1) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                }
            }        
        }                 
    }

    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;     
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        _world->DestroyBody(body);
    }
    
    if (toDestroy.size() > 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"blip.caf"];   
    }

}

- (CGPoint)covertLeapCoordinates:(CGPoint)p{
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    float screenCenter = 0.0f;
    float xScale = 3.25f;
    float yScale = 1.25f;
    return CGPointMake((s.width/2)+ (( p.x - screenCenter) * xScale), p.y * yScale);
}


//Cycle through all the trackable dots and check if the fingers still exist.
//If they don't, delete them.
- (void)checkFingerExists{
    for (id key in [trackableList allKeys]) {
        TrackedFinger* sprite = [trackableList objectForKey:key];
        if (sprite.updated) {
            sprite.updated = FALSE;
            return;
        }else{
            
            [trackableList removeObjectForKey:key];
            
        }
    }
    
    if ([trackableList count] == 0){
        [self fingerLost];
    }
}

- (void)addFingerJoint{
    
    b2MouseJointDef md;
    md.bodyA = _groundBody;
    md.bodyB = _paddleBody;
    
    md.target = _paddleBody->GetPosition();
    md.collideConnected = true;
    md.maxForce = 1000.0f * _paddleBody->GetMass();
    
    _fingerJoint = (b2MouseJoint *)_world->CreateJoint(&md);
    _paddleBody->SetAwake(true);

}



- (void)fingerMoved:(CGPoint)point{
   

    if (_fingerJoint == NULL) return;

    

    CGPoint location = [self covertLeapCoordinates:point];
    NSLog(@"Dragged %0.0f , %0.0f ", location.x, location.y);
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _fingerJoint->SetTarget(locationWorld);
}

- (void)fingerLost{
  
    if (_fingerJoint) {
        _world->DestroyJoint(_fingerJoint);
        _fingerJoint = NULL;
    }

}


//- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
- (BOOL) ccMouseDown:(NSEvent *)event{
    
    if (_mouseJoint != NULL) return NO;
    
    if (_fingerJoint) {
        
        //_fingerJoint->SetMaxForce(0);
        _world->DestroyJoint(_fingerJoint);
        _fingerJoint = NULL;
    }
    
    
    /*
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    */
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (mouseLocation);
    CGPoint location = translation;
    
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    if (_paddleFixture->TestPoint(locationWorld)) {
        b2MouseJointDef md;
        md.bodyA = _groundBody;
        md.bodyB = _paddleBody;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 1000.0f * _paddleBody->GetMass();
        
        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
        _paddleBody->SetAwake(true);
    }
    
}

//-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
- (BOOL)ccMouseDragged:(NSEvent *)event {
    
    if (_mouseJoint == NULL) return NO;
    CGPoint point = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint mouseLocation = [self convertToNodeSpace:point];
    CGPoint translation = (mouseLocation);
    CGPoint location = translation;
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
    
}

//-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
- (BOOL)ccMouseUp:(NSEvent *)event{
  
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
        
        [self addFingerJoint];
    }else{
        
        //_fingerJoint->SetMaxForce(1000.0f * _paddleBody->GetMass());
        //_fingerJoint->
        
    }
    
}

@end
