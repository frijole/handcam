//
//  LPCFocusView.m
//  lollipop parts
//
//  Created by Ian Meyer on 7/19/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import "LPCFocusView.h"

#import "UIView+Blur.h"

#define LINE_COLOR [UIColor colorWithHue:(180.0f/360.0f) saturation:1.0f brightness:1.0f alpha:0.5f]

@interface LPCFocusView ()

@property (nonatomic, strong ) UIImageView *lockView;

@end

@implementation LPCFocusView

- (instancetype)initWithFrame:(CGRect)frame {
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
    UIView *tmpCircle = [[UIView alloc] initWithFrame:self.bounds];
    tmpCircle.layer.cornerRadius = 5.0f;
    tmpCircle.layer.borderColor = LINE_COLOR.CGColor;
    tmpCircle.layer.borderWidth = 1.0f;
    tmpCircle.clipsToBounds = YES;
    [self addSubview:tmpCircle];
    
    CGRect tmpBounds = self.bounds;
    CGFloat tmpInset = 10.0f;
    
    UIView *tmpLine = [[UIView alloc] initWithFrame:CGRectMake(floorf(tmpBounds.size.width/2.0f),
                                                               1.0f,
                                                               1.0f,
                                                               tmpInset)];
    [tmpLine setBackgroundColor:LINE_COLOR];
    [self addSubview:tmpLine];
    
    tmpLine = [[UIView alloc] initWithFrame:CGRectMake(floorf(tmpBounds.size.width/2.0f),
                                                       tmpBounds.size.height-tmpInset-1.0f,
                                                       1.0f,
                                                       tmpInset)];
    [tmpLine setBackgroundColor:LINE_COLOR];
    [self addSubview:tmpLine];
    
    tmpLine = [[UIView alloc] initWithFrame:CGRectMake(1.0f,
                                                       floorf(tmpBounds.size.height/2.0f),
                                                       tmpInset,
                                                       1.0f)];
    [tmpLine setBackgroundColor:LINE_COLOR];
    [self addSubview:tmpLine];

    tmpLine = [[UIView alloc] initWithFrame:CGRectMake(tmpBounds.size.width-tmpInset-1.0f,
                                                       floorf(tmpBounds.size.height/2.0f),
                                                       tmpInset,
                                                       1.0f)];
    [tmpLine setBackgroundColor:LINE_COLOR];
    [self addSubview:tmpLine];
}

- (void)setLocked:(BOOL)locked{
    _locked = locked;
    
    // wut
}

- (UIImageView *)lockView
{
    if ( !_lockView ) {
        _lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lockIcon"]];

    }
    
    return _lockView;
}

@end
