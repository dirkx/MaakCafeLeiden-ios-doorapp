//
//  BadgeView.m
//  MaakCafeLeiden
//
//  Created by Dirk-Willem van Gulik on 31-07-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
//

#import "BadgeView.h"
#import <QuartzCore/QuartzCore.h>

@interface BadgeView () {
    NSInteger _badge;
}
@end

@implementation BadgeView

-(id)initWithCoder:(NSCoder *)aDecoder {
    return [[super initWithCoder:aDecoder] completeInit];
}
- (id)initWithFrame:(CGRect)frame
{
    return [[super initWithFrame:frame] completeInit];
}

-(id)completeInit {
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.layer setShadowOpacity:1];
    [self.layer setShadowRadius:2.0];
    
    return self;
}

-(void)setBadge:(NSInteger)badge {
    _badge = badge;
    [self setNeedsDisplay];
}

-(NSInteger)badge {
    return _badge;
}

- (void)drawRect:(CGRect)rect
{
    if (_badge == 0)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextSetShadow(context, CGSizeMake(-15, 20), 5);
    
    UIColor* flagWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* flagRed = [UIColor colorWithRed: 1 green: 0.114 blue: 0.114 alpha: 1];
    UIColor* flagBlack = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];

    CGContextSetFillColorWithColor(context, flagWhite.CGColor);
    CGContextFillEllipseInRect(context, self.bounds);
    
    CGFloat lineWidth =  self.bounds.size.width/7.5;
    
    CGContextSetStrokeColorWithColor(context, flagRed.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, lineWidth/2, lineWidth/2));

    NSString * badgeStr = [NSString stringWithFormat:@"%d",_badge];
    
    UIFont * font = [UIFont boldSystemFontOfSize:self.bounds.size.width * 0.66];

    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (self.bounds.size.height - fontHeight - 5) / 2.0;
    
    CGRect textRect = CGRectMake(0, yOffset, self.bounds.size.width - 2, fontHeight);
    
    CGContextSetFillColorWithColor(context, flagBlack.CGColor);
    [badgeStr drawInRect: textRect
                withFont: font
           lineBreakMode: UILineBreakModeClip
               alignment: UITextAlignmentCenter];
}
@end
