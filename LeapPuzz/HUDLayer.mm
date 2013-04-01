//
//  HUDLayer.m
//  LeapPuzz
//
//  Created by cj on 4/1/13.
//
//

#import "HUDLayer.h"

@implementation HUDLayer
- (id)init
{
	if ((self = [super init]))
	{
		// Get window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// Add a button which takes us back to HelloWorldScene
		
		// Create a label with the text we want on the button
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap Here" fontName:@"Helvetica" fontSize:32.0];
		
		// Create a button out of the label, and tell it to run the "switchScene" method
		CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(testing:)];
		
		// Add the button to a menu - "nil" terminates the list of items to add
		CCMenu *menu = [CCMenu menuWithItems:button, nil];
		
		// Place the menu in center of screen
		[menu setPosition:ccp(size.width / 2, size.height / 2)];
		
		// Finally add the menu to the layer
		[self addChild:menu];
	}
	
	return self;
}

- (void)testing:(id)sender{
    NSLog(@"working ... testing");
    
    
}

@end
