//
//  ColorWheelLayer.m
//  LeapPuzz
//
//  Created by cj on 3/5/13.
//
//

#import "ColorWheelLayer.h"

@implementation ColorWheelLayer

- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
      
        titleLabel = [CCLabelTTF labelWithString:@"ColorWheel" fontName:@"Marker Felt" fontSize:32];
		[self addChild:titleLabel z:0];
        [titleLabel setColor:ccc3(0,0,255)];
		titleLabel.position = ccp( winSize.width/2, winSize.height-50);
    
        colorWheel =  [CCSprite spriteWithFile:@"ColorWheel.png"];
        [self addChild:colorWheel];
        colorWheel.position = ccp( winSize.width/2, winSize.height/2);
        
        
        [self scheduleUpdate];
        
        angleLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:32];
		[self addChild:angleLabel z:0];
        [angleLabel setColor:ccc3(0,0,255)];
		angleLabel.position = ccp( winSize.width/2, 50);
        
        
        background = [CCSprite spriteWithFile:@"wooden-bg.jpg"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:-3];
        
        [self run];
        
        
    }
    return self;
}


- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addListener:self];

    //[[NSRunLoop currentRunLoop] run]; // required for performSelectorOnMainThread:withObject
    
    NSLog(@"Leap: running");
}
/*
- (void)showSelf{
    [self.delegate showColorLayer:self];
}

- (void)hideSelf{
    [self.delegate hideColorLayer:self];
}

*/
#pragma mark - Leap Delegates
#pragma mark - SampleDelegate Callbacks


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
    
    
    NSArray *gestures = [frame gestures:nil];
    for (int g = 0; g < [gestures count]; g++) {
        LeapGesture *gesture = [gestures objectAtIndex:g];
        switch (gesture.type) {
            case LEAP_GESTURE_TYPE_CIRCLE: {
                LeapCircleGesture *circleGesture = (LeapCircleGesture *)gesture;
                // Calculate the angle swept since the last frame
                float sweptAngle = 0;
                if(circleGesture.state != LEAP_GESTURE_STATE_START) {
                    LeapCircleGesture *previousUpdate = (LeapCircleGesture *)[[aController frame:1] gesture:gesture.id];
                    sweptAngle = (circleGesture.progress - previousUpdate.progress) * 2 * LEAP_PI;
                }
                //circleGesture.pointable.direction

                //circleGesture.pointable.direction.angleTo()
                //[[circleGesture pointable] direction].angleTo()
               
                 //if (circle.pointable().direction().angleTo(circle.normal()) <= PI/4) { clockwiseness = "clockwise"; } else { clockwiseness = "counterclockwise"; }
                const LeapVector* direction = [circleGesture.pointable direction];
                const LeapVector* normal = circleGesture.normal;
                if ([self vectorAngleTo:direction vector:normal] <= M_PI /4){
                    [self rotateColorWheel:sweptAngle * LEAP_RAD_TO_DEG cw:true];
                }else{
                    [self rotateColorWheel:sweptAngle * LEAP_RAD_TO_DEG cw:false];
                }
                            
                NSLog(@"Circle id: %d, %@, progress: %f, radius %f, angle: %f degrees",
                      circleGesture.id, [ColorWheelLayer stringForState:gesture.state],
                      circleGesture.progress, circleGesture.radius, sweptAngle * LEAP_RAD_TO_DEG);
                break;
            }
            case LEAP_GESTURE_TYPE_SWIPE: {
                LeapSwipeGesture *swipeGesture = (LeapSwipeGesture *)gesture;
                NSLog(@"Swipe id: %d, %@, position: %@, direction: %@, speed: %f",
                      swipeGesture.id, [ColorWheelLayer stringForState:swipeGesture.state],
                      swipeGesture.position, swipeGesture.direction, swipeGesture.speed);
                break;
            }
            case LEAP_GESTURE_TYPE_KEY_TAP: {
                LeapKeyTapGesture *keyTapGesture = (LeapKeyTapGesture *)gesture;
                NSLog(@"Key Tap id: %d, %@, position: %@, direction: %@",
                      keyTapGesture.id, [ColorWheelLayer stringForState:keyTapGesture.state],
                      keyTapGesture.position, keyTapGesture.direction);
                break;
            }
            case LEAP_GESTURE_TYPE_SCREEN_TAP: {
                LeapScreenTapGesture *screenTapGesture = (LeapScreenTapGesture *)gesture;
                NSLog(@"Screen Tap id: %d, %@, position: %@, direction: %@",
                      screenTapGesture.id, [ColorWheelLayer stringForState:screenTapGesture.state],
                      screenTapGesture.position, screenTapGesture.direction);
                break;
            }
            default:
                NSLog(@"Unknown gesture type");
                break;
        }
    }
}

- (void)rotateColorWheel:(float)rotation cw:(BOOL)clockwise{

    
    if (clockwise){
        colorWheel.rotation  += rotation;
        if (colorWheel.rotation > 360){
            colorWheel.rotation -= 360;
            
        }
    }else{
        colorWheel.rotation  -= rotation;
        
        if (colorWheel.rotation < 0){
            colorWheel.rotation += 360;
        }
    }
    //
}


+ (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}

- (float)vectorAngleTo:(const LeapVector*)firstVector vector:(const LeapVector*)secondVector{

    float denom = [self vectorMagintudeSquared:firstVector] * [self vectorMagintudeSquared:secondVector];
    if (denom <= 0.0f) {
        return 0.0f;
    }
    
    return acos([self vectorDot:firstVector vector:secondVector] / sqrt(denom));
}

- (float)vectorMagintudeSquared:(const LeapVector*)vector{
    return vector.x*vector.x + vector.y*vector.y + vector.z*vector.z;
}

- (float)vectorDot:(const LeapVector*)firstVector vector:(const LeapVector*)secondVector{
    
    return (firstVector.x * secondVector.x) + (firstVector.y *  secondVector.y) + (firstVector.z * secondVector.z);
}


- (void) update: (ccTime) dt{
    [angleLabel setString:[NSString stringWithFormat:@"%0.0f",colorWheel.rotation ]];

}

@end
