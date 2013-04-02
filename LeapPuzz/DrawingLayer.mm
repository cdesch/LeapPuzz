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


@end
