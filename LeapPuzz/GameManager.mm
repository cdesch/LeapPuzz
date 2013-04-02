//
//  GameManager.m
//  LeapPuzz
//
//  Created by cj on 4/2/13.
//
//

#import "GameManager.h"

@implementation GameManager

@synthesize hudLayer;
@synthesize drawingLayer;
@synthesize controller;
@synthesize leapScreen;

#define kVelMax 1000
#define kVelMin 0

#define kNormalizedVelMax 15
#define kNormalizedVelMin 0

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        NSLog(@"loaded");
        
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Leap Paint" fontName:@"Marker Felt" fontSize:64];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height - 50 );
        
		// add the label as a child to this Layer
		[self addChild: label];
        
        [self run];
        
        inputMode = kDepthMode;
        
        
	}
	return self;
}

#pragma mark - SampleDelegate Callbacks
- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addListener:self];
    
    
    //NSArray* screens = controller.calibratedScreens;
    //leapScreen = [screens objectAtIndex:0];
    //
    //NSLog(@"Screens: %0.0ld", (unsigned long)[screens count]);
    NSLog(@"running");
    
    
}

- (void)onInit:(NSNotification *)notification{
    NSLog(@"Leap: Initialized");
}

- (void)onConnect:(NSNotification *)notification;
{
    NSLog(@"Leap: Connected");
    LeapController *aController = (LeapController *)[notification object];
    //[aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
    //[aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
    //[aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
    //[aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
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
        
        LeapTool* tool = [tools objectAtIndex:0];
        
        //Get the screen
        NSArray* screens = controller.calibratedScreens;
        LeapScreen* leapScreen2 = [screens objectAtIndex:0];
        LeapVector* normalized = [leapScreen2 intersect:tool normalize:YES clampRatio:2.0];
        
        
        
        if ([leapScreen2 isValid]){
            double x = normalized.x * [leapScreen2 widthPixels];
            double y = normalized.y * [leapScreen2 heightPixels];
            
            CGPoint pointer = CGPointMake(x, y);
            
            //Convert to Local coordinates from Screen Coordinates
            CCDirector* director = [CCDirector sharedDirector];
            NSPoint var = [director.view.window convertScreenToBase:pointer];
            
            NSLog(@"x %0.0f y %0.0f Pointer: x %0.0f y %0.0f", x, y, var.x, var.y);
            
            //Update the HUD View
            
            if (var.x >= 0 && var.y >= 0){
                [self.hudLayer toolMoved:var toolID:[NSString stringWithFormat:@"%0.0d",tool.id]];
                //[self movedTool:var tool:tool];
                //[self movedToolGeo:var tool:tool];
                [self movedToolSimple:var tool:tool];
            }else{
                NSLog(@"NEgative Points");
            }
            
        }else{
            NSLog(@"Leap Screen is invalid");
        }
        
        
        
        
    }else{
        
        //Remove the marker from the HUD view
        
        if ( currentPointable != nil) {
            //[self endLineDrawing:currentPoint tool:currentPointable];
            //[self endLineDrawingGeo:currentPoint tool:currentPointable];
            [self endLineDrawingSimple:currentPoint tool:currentPointable];
        }

        [self.hudLayer endTrackingTool];
    }
    
}


- (void)movedTool:(CGPoint)point tool:(LeapPointable*)pointable{
    
    if (currentPointable != nil){
        
        [self moveLineDrawing:point tool:pointable];
        currentPointable = pointable;
    }else{
        [self beginLineDrawing:point tool:pointable];
        currentPointable = pointable;
    }
    
}


- (void)beginLineDrawing:(CGPoint)point tool:(LeapPointable*)pointable{
    float magnitude = [self calcMagnitude:pointable];
    NSLog(@" mag %0.0f", magnitude);
    [self.lineDrawer beginLineDrawing:point withSize:magnitude];
    currentPoint = point;
    
}

- (void)moveLineDrawing:(CGPoint)point tool:(LeapPointable*)pointable{

    float magnitude = [self calcMagnitude:pointable];
        NSLog(@" mag %0.0f", magnitude);
    [self.lineDrawer moveLineDrawing:point withSize:magnitude];
    currentPoint = point;
    
}

- (void)endLineDrawing:(CGPoint)point tool:(LeapPointable*)pointable{
    
    float magnitude = [self calcMagnitude:pointable];
        NSLog(@" mag %0.0f", magnitude);
    [self.lineDrawer endLineDrawing:point withSize:magnitude];

    currentPointable = nil;
    
}

- (float)calcMagnitude:(LeapPointable*)finger{
    //Simple Pathag theroem
    float veloticy = sqrtf((finger.tipVelocity.x * finger.tipVelocity.x) + (finger.tipVelocity.y * finger.tipVelocity.y));
    
    
    return (((kNormalizedVelMax - kNormalizedVelMin)* (veloticy - kVelMin))/(kVelMax - kVelMin)) + kNormalizedVelMin;
    
}


- (void)movedToolGeo:(CGPoint)point tool:(LeapPointable*)pointable{
    
    if (currentPointable != nil){
        
        [self moveLineDrawingGeo:point tool:pointable];
        currentPointable = pointable;
    }else{
        [self beginLineDrawingGeo:point tool:pointable];
        currentPointable = pointable;
    }
    
}


- (void)beginLineDrawingGeo:(CGPoint)point tool:(LeapPointable*)pointable{

    [self.geometryDrawLayer beginDraw:point];
    currentPoint = point;
    
}

- (void)moveLineDrawingGeo:(CGPoint)point tool:(LeapPointable*)pointable{
    
    [self.geometryDrawLayer updateDraw:point];
    currentPoint = point;
    
}

- (void)endLineDrawingGeo:(CGPoint)point tool:(LeapPointable*)pointable{
    [self.geometryDrawLayer endDraw:point];

    
    currentPointable = nil;
    
}


#pragma mark - SimplePaint

- (void)movedToolSimple:(CGPoint)point tool:(LeapPointable*)pointable{
    
    if (currentPointable != nil){
        
        [self moveLineDrawingSimple:point tool:pointable];
        currentPointable = pointable;
    }else{
        [self beginLineDrawingSimple:point tool:pointable];
        currentPointable = pointable;
    }
    
}


- (void)beginLineDrawingSimple:(CGPoint)point tool:(LeapPointable*)pointable{
    
    [self.simplePaint beginDraw:point];
    currentPoint = point;
    
}

- (void)moveLineDrawingSimple:(CGPoint)point tool:(LeapPointable*)pointable{
    
    [self.simplePaint updateDraw:point];
    currentPoint = point;
    
}

- (void)endLineDrawingSimple:(CGPoint)point tool:(LeapPointable*)pointable{
    [self.simplePaint endDraw:point];
    
    
    currentPointable = nil;
    
}





@end
