//
//  GameScene.m
//  LeapPuzz
//
//  Created by cj on 4/1/13.
//
//

#import "GameScene.h"

@implementation GameScene

@synthesize hudLayer;
@synthesize drawingLayer;
@synthesize controller;
@synthesize leapScreen;

- (id)init
{
	if ((self = [super init]))
	{
		// All this scene does upon initialization is init & add the layer class
		hudLayer = [HUDLayer node];
		[self addChild:hudLayer];
        
        [self run];
	}
	
	return self;
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
    
}
@end
