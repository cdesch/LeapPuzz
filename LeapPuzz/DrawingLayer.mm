//
//  DrawingLayer.m
//  LeapPuzz
//
//  Created by cj on 4/2/13.
//
//

#import "DrawingLayer.h"

@implementation DrawingLayer
- (id)init
{
	if ((self = [super init]))
	{
		// Get window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// Add a button which takes us back to HelloWorldScene
		
		// Create a label with the text we want on the button
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Drawing layer Here" fontName:@"Helvetica" fontSize:32.0];
		
        //[self addChild:label];
		
		
	}
	
	return self;
}



-(void)keyUp:(NSEvent*)event
{
    NSLog(@"Key released: %@", event);
}

-(void)keyDown:(NSEvent*)event
{
    // I added these based on the addition to your question :)
    switch( [event keyCode] ) {
    	case 126:	// up arrow
    	case 125:	// down arrow
    	case 124:	// right arrow
    	case 123:	// left arrow
    		NSLog(@"Arrow key pressed!");
    		break;
    	default:
    		NSLog(@"Key pressed: %@", event);
    		break;
    }
}

@end
