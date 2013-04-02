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

-(void)draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
    
    for(LPLine* line in plataformPoints ){
        
        for (int i = 0 ; i < [line.points count] - 1; i++ ){
            
            SimplePoint* point1 = [line.points objectAtIndex:i];
            SimplePoint* point2 = [line.points objectAtIndex:i+1];
            
            ccDrawColor4B(255, 255, 255, 255); //Color of the line RGBA
            glLineWidth(5.0f); //Stroke width of the line
            
            ccDrawLine(ccp(point1.x, point1.y   ), ccp(point2.x, point2.y));

        }
        
    }
    NSLog(@"Draw");
	

    
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
    
        NSLog(@"begin Draw");
    CGPoint location = point;
    previousLocation = location;
    
    if (currentLine ==  nil){
        
        LPLine* line = [[LPLine alloc] init];
        SimplePoint* pointObject = [[SimplePoint alloc] initWithPosition:point];
        [line.points addObject:pointObject];
        [plataformPoints addObject:line];
        currentLine = line;
    }
    
    
    
    
}

- (void)updateDraw:(CGPoint)point{
    
    
    
    NSLog(@"Update Draw");
    
    CGPoint start = previousLocation;
    CGPoint end = point;
    
    float distance = ccpDistance(previousLocation, point);
    
    if (currentLine !=  nil){
        SimplePoint* pointObject = [[SimplePoint alloc] initWithPosition:point];
        [currentLine.points addObject:pointObject];
    }
    
    if (distance > 1)
    {


    }
    
    previousLocation = end;
}

- (void)endDraw:(CGPoint)point{
    
    
    if (currentLine !=  nil){
        currentLine = nil;
    }

    
}


@end
