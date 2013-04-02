//
//  LPLine.m
//  LeapPuzz
//
//  Created by cj on 4/2/13.
//
//

#import "LPLine.h"

@implementation LPLine

@synthesize points;
@synthesize width;

- (id) init
{
	if ((self = [super init]) == nil) {
        
        
        self.points = [[NSMutableArray alloc] init];
		self.width = 1.0f;
	} // end if
    


	
    return self;
    
} // end initWithNSPoint

@end
