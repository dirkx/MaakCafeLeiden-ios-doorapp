//
//  ShakingImageView.h
//  MaakCafeLeiden
//
//  Created by Dirk-Willem van Gulik on 29-07-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ShakingImageView : UIImageView <AVAudioPlayerDelegate>

-(void)setSoundResource:(NSString *)name;
-(void)shake;
@end
