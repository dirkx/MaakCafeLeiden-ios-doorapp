//
//  ShakingImageView.m
//  MaakCafeLeiden
//
//  Created by Dirk-Willem van Gulik on 29-07-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
//

#import "ShakingImageView.h"
#import "AppDelegate.h"

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (colourMappings)
- (UIImage *)imageWithColourGradientFromColor:(CIColor *)color toColor:(CIColor *)bgColor;
@end

@implementation UIImage (colourMappings)
- (UIImage *)imageWithColourGradientFromColor:(CIColor *)color toColor:(CIColor *)bgColor;
{
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CIImage *ciInput = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor"];
    
    [filter setValue:bgColor forKey:@"inputColor1"];
    [filter setValue:color forKey:@"inputColor0"];
    
    [filter setValue:ciInput forKey:kCIInputImageKey];
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    // remove edge effects of applied filter by simply slicing
    // of the outmost pixes.
    //
    CGRect cropRect = CGRectInset([ciInput extent],1,1);
    CGImageRef result = [ciContext createCGImage:outImage fromRect:cropRect];
    
    return [UIImage imageWithCGImage:result];
}
@end

@interface ShakingImageView () {
    CGPoint realCenter;
    int state;
    NSTimer * timer;
    SystemSoundID sound;
    AVAudioPlayer *player;
}

@property (strong, nonatomic) UIImage * posImage, * negImage;
@end
@implementation ShakingImageView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return [self completeInit];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self completeInit];
}

-(void)setSoundResource:(NSString *)name {    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:name withExtension:@"wav"];
#if 0
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &sound);
#endif
    NSError * error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:&error];
    if (!player) {
        NSLog(@"Error loading %@: %@", audioPath, [error description]);
        return;
    }
    player.delegate = self;

}

-(id)completeInit {
    realCenter = self.center;
    
    self.posImage = [self.image imageWithColourGradientFromColor:[CIColor colorWithCGColor:[[UIColor yellowColor] CGColor]]
                                                            toColor:[CIColor colorWithCGColor:[[UIColor colorWithWhite:0.25 alpha:1] CGColor]]];
    
    self.negImage = [self.image imageWithColourGradientFromColor:[CIColor colorWithCGColor:[[UIColor blackColor] CGColor]]
                                                         toColor:[CIColor colorWithCGColor:[[UIColor colorWithWhite:0.25 alpha:1] CGColor]]];
    self.image = self.negImage;
    
    // [self performSelector:@selector(shake) withObject:nil afterDelay:3+rand() % 7];
    return self;
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)aPlayer {
    [player stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (state != 21)
        return;
    
    state = 0;
    [self tock:nil];
}

-(void)shake {
    if (state)
        state = 2;
    else
        state = 1;
    
    [self tock:nil];
}

-(void)tock:(NSTimer *)aTimer {
    switch(state) {
        case 21:
            self.center = realCenter;
            
            if ([player isPlaying]) {
                self.image = self.posImage;
                return;
            }
            // fall through to stop.
        case 0:
            state = 0;
            [timer invalidate];
            
            self.center = realCenter;
            self.image = self.negImage;
            
            return;
            
            break;
            
        case 1: self.backgroundColor = [UIColor yellowColor];
            if (player && configActivitySoundOn) {
                if (![player isPlaying])
                    [player play];
            }
            break;
        default:
            self.image = state % 2 ? self.posImage : self.negImage;
            self.center = CGPointMake(realCenter.x + rand() % 3 - 1, realCenter.y + rand() % 3 - 1);
            break;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01+(rand()%10)/200.
                                             target:self
                                           selector:@selector(tock:)
                                           userInfo:nil
                                            repeats:NO];
    state++;
}
@end
