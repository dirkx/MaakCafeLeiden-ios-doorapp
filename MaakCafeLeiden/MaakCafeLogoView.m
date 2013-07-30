//
//  MaakCafeLogoView.m
//  MaakCafeLeiden
//
//
// Copyright © 2013 Dirk-Willem van Gulik <dirkx@webweaving.org>, all rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//


#import "MaakCafeLogoView.h"

@interface MaakCafeLogoView ()
@property (strong,nonatomic)     NSTimer * rotationUpdateTimer;
@end

@implementation MaakCafeLogoView

#define N (250)
#define step ((M_PI * 2.f) / N)

-(id)completeInit {
    angle = 0.f;
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self)
        return nil;
    
    return [self completeInit];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    return [self completeInit];
}

-(void)setRotationsPerMinute:(float)rotationsPerMinute
{    
    [self performSelectorOnMainThread:@selector(setRotationsPerMinuteObj:)
                           withObject:[NSNumber numberWithFloat:rotationsPerMinute]
                        waitUntilDone:NO];
}

-(void)setRotationsPerMinuteObj:(NSNumber *)rotationsPerMinuteAsObj
{
    _rotationsPerMinute = [rotationsPerMinuteAsObj floatValue];
    
    [self.rotationUpdateTimer invalidate];
    
    if (_rotationsPerMinute < 0.01) {
        angle = 0.0;
        return;
    };

    NSTimeInterval interval = 60.0 /_rotationsPerMinute / N;
    
    self.rotationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                           target:self
                                                              selector:@selector(_tock:)
                                                         userInfo:nil
                                                          repeats:YES];

    [self setNeedsDisplay];
}

-(void)_tock:(NSTimer *)aTimer {    
    angle += step;
    [self setNeedsDisplay];
}

-(float)rotationsPerMinute {
    return _rotationsPerMinute;
}

- (void)drawRect:(CGRect)rect
{
    const CGSize native = CGSizeMake(500,300);
    CGContextRef context = UIGraphicsGetCurrentContext();

    float scale = MIN(self.bounds.size.width/native.width,
                      self.bounds.size.height/native.height);
    
    CGContextTranslateCTM(context,
                          (self.bounds.size.width - scale * native.width)/2.,
                          (self.bounds.size.height - scale * native.height)/2.);
    CGContextScaleCTM(context, scale, scale);
    
    UIColor* flagWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* flagRed = [UIColor colorWithRed: 1 green: 0.114 blue: 0.114 alpha: 1];
    UIColor* spannerRed = [UIColor colorWithRed: 1 green: 0.114 blue: 0.114 alpha: 1.0];
    
    // flag
    {
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:
                                       CGRectMake(0, 0*native.height/3, native.width, native.height/3)];
        [flagRed setFill];
        [rectanglePath fill];
        
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect:
                                        CGRectMake(0, 1*native.height/3, native.width, native.height/3)];
        [flagWhite setFill];
        [rectangle2Path fill];
        
        
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect:
                                        CGRectMake(0, 2*native.height/3, native.width, native.height/3)];
        [flagRed setFill];
        [rectangle3Path fill];
    }
    // Leiden circle
    {
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(50, 69, 160, 160)];
        [flagWhite setFill];
        [ovalPath fill];
        
        [flagRed setStroke];
        ovalPath.lineWidth = 15;
        [flagRed setStroke];
        [ovalPath stroke];
    }
    

    // Draw *two* spanners - at 90 degree angle to each other; and
    // naturally at the 10:30 and 1:30 O'clock positions.
    //
    CGContextSaveGState(context);
    for(int i = 0; i<2; i++)
    {
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        
        CGPoint centre = CGPointMake(130,148);
                
        if (i) {
            CGContextTranslateCTM(context,centre.x, centre.y);
            CGContextRotateCTM(context, M_PI/2.0 -M_PI_2/2.0 + angle*1.8);
            CGContextScaleCTM(context, 1, -1);
            CGContextTranslateCTM(context,-centre.x,-centre.y);
        } else {
            CGContextTranslateCTM(context,centre.x, centre.y);
            CGContextRotateCTM(context, M_PI/2.0 +M_PI_2/2.0 + angle);
            CGContextTranslateCTM(context,-centre.x,-centre.y);
        }
        

        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
#if 0
        // Spanner - setting screw
        //
        [bezierPath moveToPoint: CGPointMake(103.59, 152.69)];
        [bezierPath addLineToPoint: CGPointMake(99.63, 153.23)];
        [bezierPath addLineToPoint: CGPointMake(98.41, 144.31)];
        [bezierPath addLineToPoint: CGPointMake(102.37, 143.77)];
        [bezierPath addLineToPoint: CGPointMake(103.59, 152.69)];
        [bezierPath closePath];
        
        [bezierPath moveToPoint: CGPointMake(103.23, 142.65)];
        [bezierPath addLineToPoint: CGPointMake(97.29, 143.45)];
        [bezierPath addLineToPoint: CGPointMake(98.77, 154.35)];
        [bezierPath addLineToPoint: CGPointMake(104.71, 153.55)];
        [bezierPath addLineToPoint: CGPointMake(103.23, 142.65)];
        [bezierPath closePath];
#endif
        
        // Spanner - hole at the end.
        //
        [bezierPath moveToPoint: CGPointMake(174.62, 145.72)];
        [bezierPath addCurveToPoint: CGPointMake(170.68, 149.64) controlPoint1: CGPointMake(172.45, 145.72) controlPoint2: CGPointMake(170.68, 147.48)];
        [bezierPath addCurveToPoint: CGPointMake(174.62, 153.55) controlPoint1: CGPointMake(170.68, 151.8) controlPoint2: CGPointMake(172.45, 153.55)];
        [bezierPath addCurveToPoint: CGPointMake(178.58, 149.64) controlPoint1: CGPointMake(176.8, 153.55) controlPoint2: CGPointMake(178.58, 151.8)];
        [bezierPath addCurveToPoint: CGPointMake(174.62, 145.72) controlPoint1: CGPointMake(178.58, 147.48) controlPoint2: CGPointMake(176.8, 145.72)];
        [bezierPath closePath];

        // Spanner - main body
        //
        [bezierPath moveToPoint: CGPointMake(92.95, 133.2)];
        [bezierPath addCurveToPoint: CGPointMake(89.43, 134.28) controlPoint1: CGPointMake(92.22, 133.2) controlPoint2: CGPointMake(90.52, 133.68)];
        [bezierPath addCurveToPoint: CGPointMake(86.27, 136.45) controlPoint1: CGPointMake(88.34, 134.88) controlPoint2: CGPointMake(86.27, 136.45)];
        [bezierPath addCurveToPoint: CGPointMake(80.93, 142.59) controlPoint1: CGPointMake(86.27, 136.45) controlPoint2: CGPointMake(81.41, 141.62)];
        [bezierPath addCurveToPoint: CGPointMake(80.2, 145.61) controlPoint1: CGPointMake(80.44, 143.55) controlPoint2: CGPointMake(80.2, 145.61)];
        [bezierPath addCurveToPoint: CGPointMake(91.5, 142.84) controlPoint1: CGPointMake(80.2, 145.61) controlPoint2: CGPointMake(90.77, 142.6)];
        [bezierPath addCurveToPoint: CGPointMake(92.71, 144.76) controlPoint1: CGPointMake(92.23, 143.08) controlPoint2: CGPointMake(92.71, 144.76)];
        [bezierPath addLineToPoint: CGPointMake(97.69, 163.91)];
        [bezierPath addCurveToPoint: CGPointMake(100.37, 163.19) controlPoint1: CGPointMake(97.69, 163.91) controlPoint2: CGPointMake(100, 163.43)];
        [bezierPath addCurveToPoint: CGPointMake(102.43, 160.66) controlPoint1: CGPointMake(100.73, 162.95) controlPoint2: CGPointMake(102.43, 160.66)];
        [bezierPath addCurveToPoint: CGPointMake(108.38, 156.81) controlPoint1: CGPointMake(102.43, 160.66) controlPoint2: CGPointMake(107.05, 157.53)];
        [bezierPath addCurveToPoint: CGPointMake(114.57, 154.4) controlPoint1: CGPointMake(109.72, 156.09) controlPoint2: CGPointMake(112.99, 154.76)];
        [bezierPath addCurveToPoint: CGPointMake(117.49, 154.04) controlPoint1: CGPointMake(116.15, 154.04) controlPoint2: CGPointMake(117.49, 154.04)];
        [bezierPath addLineToPoint: CGPointMake(176.15, 155.48)];
        [bezierPath addCurveToPoint: CGPointMake(180.64, 149.82) controlPoint1: CGPointMake(176.15, 155.48) controlPoint2: CGPointMake(180.88, 153.79)];
        [bezierPath addCurveToPoint: CGPointMake(175.3, 143.32) controlPoint1: CGPointMake(180.27, 143.8) controlPoint2: CGPointMake(175.3, 143.32)];
        [bezierPath addLineToPoint: CGPointMake(127.57, 143.79)];
        [bezierPath addCurveToPoint: CGPointMake(117.61, 143.92) controlPoint1: CGPointMake(127.81, 143.67) controlPoint2: CGPointMake(118.58, 143.92)];
        [bezierPath addCurveToPoint: CGPointMake(108.02, 141.38) controlPoint1: CGPointMake(116.64, 143.92) controlPoint2: CGPointMake(109.6, 141.62)];
        [bezierPath addCurveToPoint: CGPointMake(98.05, 135.84) controlPoint1: CGPointMake(106.44, 141.14) controlPoint2: CGPointMake(98.53, 135.96)];
        [bezierPath addCurveToPoint: CGPointMake(92.95, 133.2) controlPoint1: CGPointMake(97.56, 135.72) controlPoint2: CGPointMake(93.68, 133.2)];
        [bezierPath closePath];
#if 0
        [bezierPath moveToPoint: CGPointMake(174.62, 145.72)];
        [bezierPath addCurveToPoint: CGPointMake(178.58, 149.64) controlPoint1: CGPointMake(176.8, 145.72) controlPoint2: CGPointMake(178.58, 147.48)];
        [bezierPath addCurveToPoint: CGPointMake(174.62, 153.55) controlPoint1: CGPointMake(178.58, 151.8) controlPoint2: CGPointMake(176.8, 153.55)];
        [bezierPath addCurveToPoint: CGPointMake(170.68, 149.64) controlPoint1: CGPointMake(172.45, 153.55) controlPoint2: CGPointMake(170.68, 151.8)];
        [bezierPath addCurveToPoint: CGPointMake(174.62, 145.72) controlPoint1: CGPointMake(170.68, 147.48) controlPoint2: CGPointMake(172.45, 145.72)];
        [bezierPath closePath];
#endif
        
        bezierPath.miterLimit = 4;
        bezierPath.usesEvenOddFillRule = YES;
        
        [spannerRed setFill];
        [bezierPath fill];
        
        
        // Spanner - mobable claw at roughly 1/3.
        //
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        [bezier2Path moveToPoint: CGPointMake(96.9, 161.02)];
        [bezier2Path addCurveToPoint: CGPointMake(88.4, 158.85) controlPoint1: CGPointMake(96.9, 161.02) controlPoint2: CGPointMake(90.71, 159.94)];
        [bezier2Path addCurveToPoint: CGPointMake(83.63, 156.03) controlPoint1: CGPointMake(87.08, 158.23) controlPoint2: CGPointMake(84.89, 157.04)];
        [bezier2Path addCurveToPoint: CGPointMake(82.45, 154.58) controlPoint1: CGPointMake(82.69, 155.28) controlPoint2: CGPointMake(82.45, 154.58)];
        [bezier2Path addLineToPoint: CGPointMake(94.35, 151.26)];
        [bezier2Path addLineToPoint: CGPointMake(96.9, 161.02)];
        [bezier2Path closePath];
        bezier2Path.miterLimit = 4;
        
        bezier2Path.usesEvenOddFillRule = YES;
        
        [spannerRed setFill];
        [bezier2Path fill];
    }
    CGContextRestoreGState(context);

}

@end
