//
//  SimplePaint.m
//  LeapPuzz
//
//  Created by cj on 4/2/13.
//
//

#import "SimplePaint.h"
#define PTM_RATIO 32

@implementation SimplePaint

-(id) init
{
	if( (self=[super init])) {
		
		
		plataformPoints = [[NSMutableArray alloc] init];
		
		

		
		[self scheduleUpdate];

        
        


        
        brush = [CCSprite spriteWithFile:@"largeBrush.png"];
        
        trackableList = [[NSMutableDictionary alloc] init];
        trackableBrushList = [[NSMutableDictionary alloc] init];
        
        
	}
	return self;
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


-(void) update: (ccTime) dt{
    
    
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	/*
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
     */
    
}


- (void)paintIt{
    

}



//The further negative, the thicker the line.
- (void)beginDraw:(CGPoint)point{
    
    
    CGPoint location = point;
    

    previousLocation = location;
    
    
}

- (void)updateDraw:(CGPoint)point{
    
    
    CGPoint start = previousLocation;
    CGPoint end = point;
    
    float distance = ccpDistance(previousLocation, point);
    
    
    
    if (distance > 1)
    {
        int d = (int)distance;
        
        b2Vec2 s(start.x/PTM_RATIO, start.y/PTM_RATIO);
        b2Vec2 e(end.x/PTM_RATIO, end.y/PTM_RATIO);
        b2BodyDef bd;
        bd.type = b2_staticBody;
        bd.position.Set(0, 0);
        
        
        b2Body* body = _world->CreateBody(&bd);
        b2PolygonShape shape;

       // shape.SetAsEdge(b2Vec2(s.x, s.y), b2Vec2(e.x, e.y));
        
        b2Vec2 rectangle1_vertices[2];
        rectangle1_vertices[0].Set(s.x, s.y);
        rectangle1_vertices[1].Set(e.x, e.y);
        //rectangle1_vertices[2].Set(len/2, width/2);
        //rectangle1_vertices[3].Set(-len/2, width/2);
        shape.Set(rectangle1_vertices, 2);
        
        
        body->CreateFixture(&shape, 0.0f);
        
        CGPoint diff = ccpSub(start, end);
        float rads = atan2f( diff.y, diff.x);
        float degs = -CC_RADIANS_TO_DEGREES(rads);
        float dist = ccpDistance(end, start);
        CCSprite *obj = [CCSprite spriteWithFile:@"largeBrush.png"];
        [obj setAnchorPoint:ccp(0.0f, 0.5f)];
        [obj setPosition:end];
        [obj setScaleX:dist/obj.boundingBox.size.width];
        [obj setRotation: degs];
        [self addChild:obj];
    }
    
    previousLocation = end;
}

- (void)endDraw:(CGPoint)point{
    
    
    
}


- (void)test{
    CGPoint startPt = CGPointMake(10,10);
    CGPoint endpt = CGPointMake(100,100);
    
    //length of the stick body
    float len = abs(ccpDistance(startPt, endpt))/PTM_RATIO;
    
    
    //to calculate the angle and position of the body.
    float dx = endpt.x-startPt.x;
    float dy = endpt.y-startPt.y;
    
    
    //position of the body
    float xPos = startPt.x+dx/2.0f;
    float yPos = startPt.y+dy/2.0f;
    
    
    //width of the body.
    float width = 10.0f/PTM_RATIO;
    
    
    b2BodyDef bodyDef;
    bodyDef.position.Set(xPos/PTM_RATIO, yPos/PTM_RATIO);
    bodyDef.angle = atan(dy/dx);
    CCSprite *sp = [CCSprite spriteWithFile:@"image.png"];
    sp.scaleX = len/200.0f;	//200 is the length of the sprite in pixels.
    [self addChild:sp z:1 ];
    //bodyDef.userData = sp;
    
    
    b2Body* rectangle1 = world->CreateBody(&bodyDef);
    b2PolygonShape shape;
    b2Vec2 rectangle1_vertices[4];
    rectangle1_vertices[0].Set(-len/2, -width/2);
    rectangle1_vertices[1].Set(len/2, -width/2);
    rectangle1_vertices[2].Set(len/2, width/2);
    rectangle1_vertices[3].Set(-len/2, width/2);
    shape.Set(rectangle1_vertices, 4);
    
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;	
    rectangle1->CreateFixture(&fd);
}

@end
