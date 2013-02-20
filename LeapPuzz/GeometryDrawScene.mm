//
//  GeometryDrawScene.m
//  LeapPuzz
//
//  Created by cj on 2/19/13.
//
//

#import "GeometryDrawScene.h"
#import "SimplePointObject.h"

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
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
		
		plataformPoints = [[NSMutableArray alloc] init];
		
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"LeapPuzz" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
		
		[self scheduleUpdate];
        
        trackableList = [[NSMutableDictionary alloc] init];
        
    
        target = [CCRenderTexture renderTextureWithWidth:s.width height: s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        target.position = ccp(s.width / 2, s.height / 2);
        [self addChild:target];
    
        
    
        brush = [CCSprite spriteWithFile:@"largeBrush.png"];

        
        
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

@end
