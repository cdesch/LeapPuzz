/*
 * Smooth drawing: http://merowing.info
 *
 * Copyright (c) 2012 Krzysztof Zabłocki
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
#import <CoreGraphics/CoreGraphics.h>
#import "cocos2d.h"
#import "LineDrawer.h"
#import "TrackedFinger.h"

typedef struct _LineVertex {
    
  CGPoint pos;
  float z;
  ccColor4F color;
    
} LineVertex;

@interface LinePoint : NSObject
@property(nonatomic, assign) CGPoint pos;
@property(nonatomic, assign) float width;
@end


@implementation LinePoint
@synthesize pos;
@synthesize width;
@end

@interface LineDrawer ()

- (void)fillLineTriangles:(LineVertex *)vertices count:(NSUInteger)count withColor:(ccColor4F)color;

- (void)startNewLineFrom:(CGPoint)newPoint withSize:(CGFloat)aSize;

- (void)endLineAt:(CGPoint)aEndPoint withSize:(CGFloat)aSize;

- (void)addPoint:(CGPoint)newPoint withSize:(CGFloat)size;

- (void)drawLines:(NSArray *)linePoints withColor:(ccColor4F)color;

@end

@implementation LineDrawer {
  NSMutableArray *points;
  NSMutableArray *velocities;
  NSMutableArray *circlesPoints;

  BOOL connectingLine;
  CGPoint prevC, prevD;
  CGPoint prevG;
  CGPoint prevI;
  float overdraw;

  CCRenderTexture *renderTexture;
  BOOL finishingLine;
}

- (id)init
{
  self = [super init];
  if (self) {
      
    points = [NSMutableArray array];
    velocities = [NSMutableArray array];
    circlesPoints = [NSMutableArray array];

    shaderProgram_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
    overdraw = 3.0f;

    renderTexture = [[CCRenderTexture alloc] initWithWidth:(int)self.contentSize.width height:(int)self.contentSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    renderTexture.anchorPoint = ccp(0, 0);
    renderTexture.position = ccp(1024 * 0.5f, 768 * 0.5f);
    [renderTexture clear:1.0f g:1.0f b:1.0f a:0];
    [self addChild:renderTexture];

    //self.isTouchEnabled = YES;
      
    CGSize s = [CCDirector sharedDirector].winSize;
      NSLog(@"win size x %0.0f y %0.0f", s.width, s.height);

    /*
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPressGestureRecognizer];
     
    */
      trackableList = [[NSMutableDictionary alloc] init];
      [self run];
  }
  return self;
}

#pragma mark - Handling points
- (void)startNewLineFrom:(CGPoint)newPoint withSize:(CGFloat)aSize
{
  connectingLine = NO;
  [self addPoint:newPoint withSize:aSize];
}

- (void)endLineAt:(CGPoint)aEndPoint withSize:(CGFloat)aSize
{
  [self addPoint:aEndPoint withSize:aSize];
  finishingLine = YES;
}

- (void)addPoint:(CGPoint)newPoint withSize:(CGFloat)size
{
    
    LinePoint *point = [[LinePoint alloc] init];
    point.pos = newPoint;
    point.width = size;
    [points addObject:point];
}

#pragma mark - Drawing

#define ADD_TRIANGLE(A, B, C, Z) vertices[index].pos = A, vertices[index++].z = Z, vertices[index].pos = B, vertices[index++].z = Z, vertices[index].pos = C, vertices[index++].z = Z

- (void)drawLines:(NSArray *)linePoints withColor:(ccColor4F)color
{
  unsigned int numberOfVertices = ([linePoints count] - 1) * 18;
      
  LineVertex *vertices = (LineVertex *)calloc(sizeof(LineVertex), numberOfVertices);

  CGPoint prevPoint = [(LinePoint *)[linePoints objectAtIndex:0] pos];
  float prevValue = [(LinePoint *)[linePoints objectAtIndex:0] width];
  float curValue;
  int index = 0;
  for (int i = 1; i < [linePoints count]; ++i) {
    LinePoint *pointValue = [linePoints objectAtIndex:i];
    CGPoint curPoint = [pointValue pos];
    curValue = [pointValue width];

    //! equal points, skip them
    if (ccpFuzzyEqual(curPoint, prevPoint, 0.0001f)) {
      continue;
    }

    CGPoint dir = ccpSub(curPoint, prevPoint);
    CGPoint perpendicular = ccpNormalize(ccpPerp(dir));
    CGPoint A = ccpAdd(prevPoint, ccpMult(perpendicular, prevValue / 2));
    CGPoint B = ccpSub(prevPoint, ccpMult(perpendicular, prevValue / 2));
    CGPoint C = ccpAdd(curPoint, ccpMult(perpendicular, curValue / 2));
    CGPoint D = ccpSub(curPoint, ccpMult(perpendicular, curValue / 2));

    //! continuing line
    if (connectingLine || index > 0) {
      A = prevC;
      B = prevD;
    } else if (index == 0) {
      //! circle at start of line, revert direction
      [circlesPoints addObject:pointValue];
      [circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
    }

    ADD_TRIANGLE(A, B, C, 1.0f);
    ADD_TRIANGLE(B, C, D, 1.0f);

    prevD = D;
    prevC = C;
    if (finishingLine && (i == [linePoints count] - 1)) {
      [circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
      [circlesPoints addObject:pointValue];
      finishingLine = NO;
    }
    prevPoint = curPoint;
    prevValue = curValue;

    //! Add overdraw
    CGPoint F = ccpAdd(A, ccpMult(perpendicular, overdraw));
    CGPoint G = ccpAdd(C, ccpMult(perpendicular, overdraw));
    CGPoint H = ccpSub(B, ccpMult(perpendicular, overdraw));
    CGPoint I = ccpSub(D, ccpMult(perpendicular, overdraw));

    //! end vertices of last line are the start of this one, also for the overdraw
    if (connectingLine || index > 6) {
      F = prevG;
      H = prevI;
    }

    prevG = G;
    prevI = I;

    ADD_TRIANGLE(F, A, G, 2.0f);
    ADD_TRIANGLE(A, G, C, 2.0f);
    ADD_TRIANGLE(B, H, D, 2.0f);
    ADD_TRIANGLE(H, D, I, 2.0f);
  }
  [self fillLineTriangles:vertices count:index withColor:color];
    

  if (index > 0) {
    connectingLine = YES;
  }

  free(vertices);
}

- (void)fillLineEndPointAt:(CGPoint)center direction:(CGPoint)aLineDir radius:(CGFloat)radius andColor:(ccColor4F)color
{
  int numberOfSegments = 32;
  LineVertex *vertices = (LineVertex *)malloc(sizeof(LineVertex) * numberOfSegments * 9);
  float anglePerSegment = (float)(M_PI / (numberOfSegments - 1));

  //! we need to cover M_PI from this, dot product of normalized vectors is equal to cos angle between them... and if you include rightVec dot you get to know the correct direction :)
  CGPoint perpendicular = ccpPerp(aLineDir);
  float angle = acosf(ccpDot(perpendicular, CGPointMake(0, 1)));
  float rightDot = ccpDot(perpendicular, CGPointMake(1, 0));
  if (rightDot < 0.0f) {
    angle *= -1;
  }

  CGPoint prevPoint = center;
  CGPoint prevDir = ccp(sinf(0), cosf(0));
  for (unsigned int i = 0; i < numberOfSegments; ++i) {
    CGPoint dir = ccp(sinf(angle), cosf(angle));
    CGPoint curPoint = ccp(center.x + radius * dir.x, center.y + radius * dir.y);
    vertices[i * 9 + 0].pos = center;
    vertices[i * 9 + 1].pos = prevPoint;
    vertices[i * 9 + 2].pos = curPoint;

    //! fill rest of vertex data
    for (unsigned int j = 0; j < 9; ++j) {
      vertices[i * 9 + j].z = j < 3 ? 1.0f : 2.0f;
      vertices[i * 9 + j].color = color;
    }

    //! add overdraw
    vertices[i * 9 + 3].pos = ccpAdd(prevPoint, ccpMult(prevDir, overdraw));
    vertices[i * 9 + 3].color.a = 0;
    vertices[i * 9 + 4].pos = prevPoint;
    vertices[i * 9 + 5].pos = ccpAdd(curPoint, ccpMult(dir, overdraw));
    vertices[i * 9 + 5].color.a = 0;

    vertices[i * 9 + 6].pos = prevPoint;
    vertices[i * 9 + 7].pos = curPoint;
    vertices[i * 9 + 8].pos = ccpAdd(curPoint, ccpMult(dir, overdraw));
    vertices[i * 9 + 8].color.a = 0;

    prevPoint = curPoint;
    prevDir = dir;
    angle += anglePerSegment;
  }

  glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].pos);
  glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].color);
  glDrawArrays(GL_TRIANGLES, 0, numberOfSegments * 9);

  free(vertices);
}

- (void)fillLineTriangles:(LineVertex *)vertices count:(NSUInteger)count withColor:(ccColor4F)color
{
  [shaderProgram_ use];
  [shaderProgram_ setUniformForModelViewProjectionMatrix];

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);

  ccColor4F fullColor = color;
  ccColor4F fadeOutColor = color;
  fadeOutColor.a = 0;

  for (int i = 0; i < count / 18; ++i) {
    for (int j = 0; j < 6; ++j) {
      vertices[i * 18 + j].color = color;
    }

    //! FAG
    vertices[i * 18 + 6].color = fadeOutColor;
    vertices[i * 18 + 7].color = fullColor;
    vertices[i * 18 + 8].color = fadeOutColor;

    //! AGD
    vertices[i * 18 + 9].color = fullColor;
    vertices[i * 18 + 10].color = fadeOutColor;
    vertices[i * 18 + 11].color = fullColor;

    //! BHC
    vertices[i * 18 + 12].color = fullColor;
    vertices[i * 18 + 13].color = fadeOutColor;
    vertices[i * 18 + 14].color = fullColor;

    //! HCI
    vertices[i * 18 + 15].color = fadeOutColor;
    vertices[i * 18 + 16].color = fullColor;
    vertices[i * 18 + 17].color = fadeOutColor;
  }

  glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].pos);
  glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].color);


  glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  glDrawArrays(GL_TRIANGLES, 0, (GLsizei)count);

  for (unsigned int i = 0; i < [circlesPoints count] / 2; ++i) {
    LinePoint *prevPoint = [circlesPoints objectAtIndex:i * 2];
    LinePoint *curPoint = [circlesPoints objectAtIndex:i * 2 + 1];
    CGPoint dirVector = ccpNormalize(ccpSub(curPoint.pos, prevPoint.pos));

    [self fillLineEndPointAt:curPoint.pos direction:dirVector radius:curPoint.width * 0.5f andColor:color];
  }
  [circlesPoints removeAllObjects];
}

- (NSMutableArray *)calculateSmoothLinePoints
{
  if ([points count] > 2) {
    NSMutableArray *smoothedPoints = [NSMutableArray array];
    for (unsigned int i = 2; i < [points count]; ++i) {
      LinePoint *prev2 = [points objectAtIndex:i - 2];
      LinePoint *prev1 = [points objectAtIndex:i - 1];
      LinePoint *cur = [points objectAtIndex:i];

      CGPoint midPoint1 = ccpMult(ccpAdd(prev1.pos, prev2.pos), 0.5f);
      CGPoint midPoint2 = ccpMult(ccpAdd(cur.pos, prev1.pos), 0.5f);

      int segmentDistance = 2;
      float distance = ccpDistance(midPoint1, midPoint2);
      int numberOfSegments = MIN(128, MAX(floorf(distance / segmentDistance), 32));

      float t = 0.0f;
      float step = 1.0f / numberOfSegments;
      for (NSUInteger j = 0; j < numberOfSegments; j++) {
        LinePoint *newPoint = [[LinePoint alloc] init];
        newPoint.pos = ccpAdd(ccpAdd(ccpMult(midPoint1, powf(1 - t, 2)), ccpMult(prev1.pos, 2.0f * (1 - t) * t)), ccpMult(midPoint2, t * t));
        newPoint.width = powf(1 - t, 2) * ((prev1.width + prev2.width) * 0.5f) + 2.0f * (1 - t) * t * prev1.width + t * t * ((cur.width + prev1.width) * 0.5f);

        [smoothedPoints addObject:newPoint];
        t += step;
      }
      LinePoint *finalPoint = [[LinePoint alloc] init];
      finalPoint.pos = midPoint2;
      finalPoint.width = (cur.width + prev1.width) * 0.5f;
      [smoothedPoints addObject:finalPoint];
    }
    //! we need to leave last 2 points for next draw
    [points removeObjectsInRange:NSMakeRange(0, [points count] - 2)];
    return smoothedPoints;
      
  } else {
    return nil;
  }
}

- (void)draw
{
  ccColor4F color = {0, 0, 0, 1};
  [renderTexture begin];

  NSMutableArray *smoothedPoints = [self calculateSmoothLinePoints];
  if (smoothedPoints) {
    [self drawLines:smoothedPoints withColor:color];
  }
  [renderTexture end];
}

#pragma mark - Math

#pragma mark - GestureRecognizers

- (float)extractSize:(float)vel
{
    
  //! result of trial & error

    float size = vel / 166.0f;
    size = clampf(size, 1, 40);

    if ([velocities count] > 1) {
      size = size * 0.2f + [[velocities objectAtIndex:[velocities count] - 1] floatValue] * 0.8f;
    }
    [velocities addObject:[NSNumber numberWithFloat:size]];
    
    return size;
    
}
/*

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    
  const CGPoint point = [[CCDirector sharedDirector] convertToGL:[panGestureRecognizer locationInView:panGestureRecognizer.view]];
    
    //Begins
  if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
      
      //
    [points removeAllObjects];
    [velocities removeAllObjects];

    float size = [self extractSize:panGestureRecognizer];

    [self startNewLineFrom:point withSize:size];
    [self addPoint:point withSize:size];
    [self addPoint:point withSize:size];
  }
    
    //Moved

  if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    //! skip points that are too close
    float eps = 1.5f;
    if ([points count] > 0) {
      float length = ccpLength(ccpSub([(LinePoint *)[points lastObject] pos], point));

      if (length < eps) {
        return;
      } else {
      }
    }
    float size = [self extractSize:panGestureRecognizer];
    [self addPoint:point withSize:size];
  }
    //ended

  if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    float size = [self extractSize:panGestureRecognizer];
    [self endLineAt:point withSize:size];
  }
    
    
}
 */
//Long press
/*
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
  [renderTexture beginWithClear:1.0 g:1.0 b:1.0 a:0];
  [renderTexture end];
}*/


- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addDelegate:self];
    NSLog(@"running");
}

#pragma mark - SampleDelegate Callbacks

- (void)onInit:(LeapController *)aController
{
    NSLog(@"Initialized");
}

- (void)onConnect:(LeapController *)aController
{
    NSLog(@"Connected");
}

- (void)onDisconnect:(LeapController *)aController
{
    NSLog(@"Disconnected");
}

- (void)onExit:(LeapController *)aController
{
    NSLog(@"Exited");
}

- (void)onFrame:(LeapController *)aController
{
    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];
    /*
     NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, fingers: %ld, tools: %ld",
     [frame id], [frame timestamp], [[frame hands] count],
     [[frame fingers] count], [[frame tools] count]);
     
     */
    if ([[frame hands] count] != 0) {
        // Get the first hand
        LeapHand *hand = [[frame hands] objectAtIndex:0];
        
        
        // Check if the hand has any fingers
        NSArray *fingers = [hand fingers];
        
        if ([fingers count] != 0) {
            
            // Calculate the hand's average finger tip position
            LeapVector *avgPos = [[LeapVector alloc] init];
            for (int i = 0; i < [fingers count]; i++) {
                LeapFinger *finger = [fingers objectAtIndex:i];
                avgPos = [avgPos plus:[finger tipPosition]];
                
                if (avgPos.z < 0){
                    NSString* fingerID = [NSString stringWithFormat:@"%d", finger.id];
                    
                    //Check if the Finger ID exists in the list already
                    if ([trackableList objectForKey:fingerID]) {
                        
                        //If it does exist update the position on the screen
                        TrackedFinger* sprite = [trackableList objectForKey:fingerID];
                        sprite.position = [self covertLeapCoordinates:CGPointMake(finger.tipPosition.x, finger.tipPosition.y)];
                        sprite.updated = TRUE;
                        
                        //CCMotionStreak* streak = [self getMotionStreak:[sprite.fingerID intValue] withSprite:sprite];
                        //streak.position = sprite.position;
                        
                        const CGPoint point = sprite.position;
                        ///
                        float eps = 1.5f;
                        if ([points count] > 0) {
                            float length = ccpLength(ccpSub([(LinePoint *)[points lastObject] pos], point));
                            
                            if (length < eps) {
                                //NSLog(@"Return");
                                //return;
                                
                            } else {
                                
                                float magnitude = [self calcMagnitude:finger];
                                float size = [self extractSize:magnitude];
                                NSLog(@"mag: %0.0f size %0.0f", magnitude, size);
                                NSLog(@"x %0.0f y %0.0f ", point.x, point.y);
                                [self addPoint:point withSize:size];

                                
                            }
                        }
                        
                        
                        
                    }else{
                        
                        //NSLog(@"x %0.0f y %0.0f z %0.0f", finger.tipPosition.x, finger.tipPosition.y, finger.tipPosition.z);

                        //Add it to the dictionary
                        //RedDot* redDot = [self addRedDot:CGPointMake(finger.tipPosition.x, finger.tipPosition.y) finger:fingerID];
                        TrackedFinger* trackedFinger = [[TrackedFinger alloc] initWithID:fingerID withPosition:[self covertLeapCoordinates:CGPointMake(finger.tipPosition.x, finger.tipPosition.y)]];
                        [trackableList setObject:trackedFinger forKey:fingerID];
                        
                        //
                        [points removeAllObjects];
                        [velocities removeAllObjects];
                        
                        const CGPoint point = trackedFinger.position;
                        float size = [self extractSize:[self calcMagnitude:finger]];
                        
                        [self startNewLineFrom:point withSize:size];
                        [self addPoint:point withSize:size];
                        [self addPoint:point withSize:size];
                    }
                }
                
            }
            
            avgPos = [avgPos divide:[fingers count]];
            
            //NSLog(@"Hand has %ld fingers, average finger tip position %@", [fingers count], avgPos);
            for (LeapFinger* finger in fingers){
                
                //NSLog(@"Finger ID %d %ld", finger.id, (unsigned long)[finger hash]);
            }
            
        }
        
        //
        [self checkFingerExists];
        
        // Get the hand's sphere radius and palm position
        /*
         NSLog(@"Hand sphere radius: %f mm, palm position: %@",
         [hand sphereRadius], [hand palmPosition]);
         */
        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];
        
        /*
         // Calculate the hand's pitch, roll, and yaw angles
         NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
         [direction pitch] * LEAP_RAD_TO_DEG,
         [normal roll] * LEAP_RAD_TO_DEG,
         [direction yaw] * LEAP_RAD_TO_DEG);
         */
    }
}

//Calculate the magintude of the finger movign
- (float)calcMagnitude:(LeapFinger*)finger{
    //Simple Pathag theroem
    return sqrtf((finger.tipVelocity.x * finger.tipVelocity.x) + (finger.tipVelocity.y * finger.tipVelocity.y));
}

//Cycle through all the trackable dots and check if the fingers still exist.
//If they don't, delete them.
- (void)checkFingerExists{
    
    for (id key in [trackableList allKeys]) {
        TrackedFinger* sprite = [trackableList objectForKey:key];
        if (sprite.updated) {
            sprite.updated = FALSE;

        }else{
            //CCNode *parent = [self getChildByTag:kTagParentNode];
            [trackableList removeObjectForKey:key];
            //[parent removeChild:sprite cleanup:YES];
            //Get rid of the motion streak
            //[self removeMotionStreak:[sprite.fingerID intValue]];
            
        }
    }
}

- (CGPoint)covertLeapCoordinates:(CGPoint)p{
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    float screenCenter = 0.0f;
    float xScale = 1.75f;
    float yScale = 1.25f;
    return CGPointMake((s.width/2)+ (( p.x - screenCenter) * xScale), p.y * yScale);
}
@end