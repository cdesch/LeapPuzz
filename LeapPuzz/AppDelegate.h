//
//  AppDelegate.h
//  LeapPuzz
//
//  Created by cj on 2/3/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"


@interface LeapPuzzAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (strong) IBOutlet NSWindow	*window;
@property (strong) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
