//
//  LPCButton.m
//  lollipop parts
//
//  Created by Ian Meyer on 7/7/14.
//  Copyright (c) 2014 Ian Meyer All rights reserved.
//

#import "FHCShutterButton.h"

#import "UIImage+Colors.h"

@implementation FHCShutterButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configure];
}

- (void)configure
{
    self.layer.cornerRadius = CGRectGetWidth(self.frame)/2.0f;
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor clearColor];

    CGRect tmpOverlayFrame = self.bounds;
    UIView *tmpOverlay = [[UIView alloc] initWithFrame:tmpOverlayFrame];
    [tmpOverlay setBackgroundColor:[UIColor clearColor]];
    [tmpOverlay.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [tmpOverlay.layer setBorderWidth:6.0f];
    [tmpOverlay.layer setCornerRadius:CGRectGetWidth(tmpOverlay.frame)/2.0f];
    [tmpOverlay setUserInteractionEnabled:NO];
    [self addSubview:tmpOverlay];

    tmpOverlayFrame = self.bounds;
    tmpOverlay = [[UIView alloc] initWithFrame:tmpOverlayFrame];
    [tmpOverlay setBackgroundColor:[UIColor clearColor]];
    [tmpOverlay.layer setBorderColor:[UIColor whiteColor].CGColor];
    [tmpOverlay.layer setBorderWidth:4.0f];
    [tmpOverlay.layer setCornerRadius:CGRectGetWidth(tmpOverlay.frame)/2.0f];
    [tmpOverlay setUserInteractionEnabled:NO];
    [self addSubview:tmpOverlay];
    
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor darkGrayColor]] forState:UIControlStateHighlighted];
    [self setAdjustsImageWhenHighlighted:NO];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect tmpRelativeFrame = self.bounds;
    UIEdgeInsets tmpHitTestEdgeInsets = UIEdgeInsetsMake(-20.0f, -20.0f, -20.0f, -20.0f);
    CGRect tmpHitFrame = UIEdgeInsetsInsetRect(tmpRelativeFrame, tmpHitTestEdgeInsets);
    return CGRectContainsPoint(tmpHitFrame, point);
}

@end
