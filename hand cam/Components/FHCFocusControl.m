//
//  FHCFocusControl.m
//  hand cam
//
//  Created by Ian Meyer on 2/14/15.
//  Copyright (c) 2015 frijole. All rights reserved.
//

#import "FHCFocusControl.h"

@interface FHCFocusControl ()

@property (nonatomic, strong) NSArray *lines;
@property (nonatomic) BOOL shouldClearLines; // set before calling configure to update line display
@property (nonatomic, strong) UIView *indicator;

@property (nonatomic, weak, readwrite) UIRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic) CGFloat rotationRecognizerStartingValue;
- (void)rotationRecognizerDidFire:(UIGestureRecognizer *)rotationRecognizer;

@end

@implementation FHCFocusControl

@synthesize numberOfLines=_numberOfLines, minimumValue=_minimumValue, maximumValue=_maximumValue;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self updateDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self updateDisplay];
    }
    return self;
}

- (void)updateDisplay
{
    // TODO: lay out display
    if ( !self.lines || self.shouldClearLines ) {
        [self setShouldClearLines:NO];

        // clear existing lines
        [self.lines makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setLines:nil];
        
        // lay out fresh lines
        CGFloat tmpRadius = self.frame.size.width<self.frame.size.height?self.frame.size.width:self.frame.size.height; // smaller dimension
        tmpRadius -= 10.0f; // inset from the sides a bit
        tmpRadius = tmpRadius/2.0f; // half it for the radius
        
        CGFloat tmpAngle = -1*(M_PI*1.2f); // a pleasent portion of the distance around
        CGFloat tmpAngleInterval = (M_PI*1.4f)/self.numberOfLines;
        
        NSArray *tmpLineArray = @[];
        
        for ( int i=0; i<=self.numberOfLines; i++ ) {
            // create a line
            UIView *tmpLine = [[UIView alloc] initWithFrame:CGRectZero];
            [tmpLine setTranslatesAutoresizingMaskIntoConstraints:NO];
            [tmpLine setBackgroundColor:[UIColor blueColor]];
            [self addSubview:tmpLine];
            tmpLineArray = [tmpLineArray arrayByAddingObject:tmpLine];
            
            // layout
            NSDictionary *tmpViews = NSDictionaryOfVariableBindings(tmpLine);
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[tmpLine(5)]" options:0 metrics:nil views:tmpViews]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tmpLine(5)]"  options:0 metrics:nil views:tmpViews]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tmpLine attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tmpLine attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
            
            [tmpLine.layer setCornerRadius:2.5f];
            [tmpLine setClipsToBounds:YES];
            
            [tmpLine.layer setBorderColor:[UIColor blackColor].CGColor];
            [tmpLine.layer setBorderWidth:1.0f];
            [tmpLine setBackgroundColor:[UIColor whiteColor]];
            
            // and transform
            [tmpLine.layer setAnchorPoint:CGPointMake((-1.0f*(tmpRadius/5.0f))+0.5f, 0.5f)];
            CGAffineTransform tmpTransform = CGAffineTransformMakeRotation(tmpAngle);
            [tmpLine setTransform:tmpTransform];
            
            // [tmpLine setAlpha:1.0f-(0.1f*i)]; // to check the direction
            
            // update the angle
            tmpAngle+=tmpAngleInterval;
        }
        
        [self setLines:tmpLineArray];
    }
    
    // update value indicator
    if ( !self.indicator ) {
        // set up indicator
        UIView *tmpIndicator = [[UIView alloc] initWithFrame:CGRectZero];
        [tmpIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [tmpIndicator setBackgroundColor:[UIColor redColor]];
        [self addSubview:tmpIndicator];
        
        [self sendSubviewToBack:tmpIndicator];
        
        [self setIndicator:tmpIndicator];
        
        NSDictionary *tmpViews = NSDictionaryOfVariableBindings(tmpIndicator);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[tmpIndicator(9)]" options:0 metrics:nil views:tmpViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tmpIndicator(9)]"  options:0 metrics:nil views:tmpViews]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:tmpIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:tmpIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        [tmpIndicator.layer setCornerRadius:4.5f];
        [tmpIndicator setClipsToBounds:YES];
    }

    // position indicator
    CGFloat tmpStartingAngle = -1*(M_PI*1.2f);
    CGFloat tmpNormalizedValue = (self.value-self.minimumValue)/(self.maximumValue-self.minimumValue);
    CGFloat tmpAngleForValue = tmpStartingAngle+((M_PI*1.4f)*tmpNormalizedValue); // adjust it
    CGFloat tmpRadius = self.frame.size.width<self.frame.size.height?self.frame.size.width:self.frame.size.height; // smaller dimension
    [self.indicator.layer setAnchorPoint:CGPointMake((-1.0f*(tmpRadius/18.0f))+1.0f, 0.5f)]; // will move it
    CGAffineTransform tmpTransform = CGAffineTransformMakeRotation(tmpAngleForValue); // now rotate it
    [self.indicator setTransform:tmpTransform]; // and apply it
    
    // check rotation recognizer
    if ( !self.rotationRecognizer ) {
        UIRotationGestureRecognizer *tmpRotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationRecognizerDidFire:)];
        [self addGestureRecognizer:tmpRotationRecognizer];
        [self setRotationRecognizer:tmpRotationRecognizer];
    }
    
    [self setUserInteractionEnabled:YES];
}

- (void)rotationRecognizerDidFire:(UIRotationGestureRecognizer *)rotationRecognizer
{
    // TODO: update!
    // NSLog(@"rotation: %@", @(rotationRecognizer.rotation));

    if ( rotationRecognizer.state == UIGestureRecognizerStateBegan ) {
        // reset the starting value
        [self setRotationRecognizerStartingValue:self.value];
    }
    
    CGFloat tmpValueChange = rotationRecognizer.rotation/(M_PI*1.4f); // normalized over the rotation's range
    tmpValueChange = (tmpValueChange*(self.maximumValue-self.minimumValue)); // applied to the control's range
    
    CGFloat tmpNewValue = self.rotationRecognizerStartingValue+tmpValueChange;

    // NSLog(@"rotated %.2f radians, value was %@ change is %@", rotationRecognizer.rotation, @(self.value), @(tmpNewValue));
    
    [self setValue:tmpNewValue];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    if ( _numberOfLines != numberOfLines ) {
        _numberOfLines = numberOfLines;
        self.shouldClearLines = YES;
        [self updateDisplay];
    }
}

- (NSInteger)numberOfLines
{
    return _numberOfLines?:10.0f;
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
    if ( _minimumValue != minimumValue ) {
        _minimumValue = minimumValue;
        self.shouldClearLines = YES;
        [self updateDisplay];
    }
}

- (void)setValue:(CGFloat)value
{
    if ( value < self.minimumValue ) {
        value = self.minimumValue;
    }
    else if ( value > self.maximumValue ) {
        value = self.maximumValue;
    }
    
    _value = value;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [self updateDisplay];
}

- (CGFloat)minimumValue
{
    return _minimumValue?:0.0f;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    if ( _maximumValue != maximumValue ) {
        _maximumValue = maximumValue;
        self.shouldClearLines = YES;
        [self updateDisplay];
    }
}

- (CGFloat)maximumValue
{
    return _maximumValue?:1.0f;
}

@end
