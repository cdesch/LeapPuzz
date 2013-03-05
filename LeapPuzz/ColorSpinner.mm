//
//  ColorSpinner.m
//  LeapPuzz
//
//  Created by cj on 3/5/13.
//
//

#import "ColorSpinner.h"

@implementation ColorSpinner


- (ccColor3B)getColor{
    if (self.rotation >0 && self.rotation <  25){
        return ccc3(0,0,255);
    }else if (self.rotation >0 && self.rotation <  25){
        return ccc3(0,0,255);
    }
}

@end
