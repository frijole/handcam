//
//  ViewController.m
//  obliquilator
//
//  Created by Ian Meyer on 11/12/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import "PhotosViewController.h"

#import <Photos/Photos.h>

@interface PhotosViewController ()

@property (nonatomic, strong) UIPanGestureRecognizer *currentPhotoPanRecognizer;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self prepareCurrentCard];
    [self prepareNextCard];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)presentNextCard
{
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // bump it up
                         [self.nextCard setBackgroundColor:[UIColor whiteColor]];
                         [self.nextCard setTransform:CGAffineTransformIdentity];
                         
                         // shuffle things around
                         [self setCurrentCard:self.nextCard];
                         [self setNextCard:nil];
                         
                         // stash the current strategy
                         [[NSUserDefaults standardUserDefaults] setObject:self.currentCard.label.text forKey:@"lastStrategy"];
                         
                         // and reset
                         [self prepareCurrentCard];
                         [self prepareNextCard];
                     }];
}

- (void)prepareCurrentCard
{
    if ( !self.currentCard ) {
        // wut
    }
    
    // TODO: prepare current photo!
    
    if ( self.currentPhotoPanRecognizer.view ) {
        [self.currentPhotoPanRecognizer.view removeGestureRecognizer:self.currentPhotoPanRecognizer];
    }
    
    [self.currentCard setGestureRecognizers:@[self.currentPhotoPanRecognizer]];
}

- (void)prepareNextCard
{
    if ( !self.nextCard ) {
        // TODO: create next card if necessary
        [self setNextCard:[PhotoView new]];
        [self.nextCard setAutoresizingMask:UIViewAutoresizingNone];
        [self.nextCard setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view insertSubview:self.nextCard belowSubview:self.currentCard];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextCard attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-20.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextCard attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:-20.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextCard attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextCard attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }

    // TODO: update photo on card!
    
    [UIView performWithoutAnimation:^{
        [self.nextCard setBackgroundColor:[UIColor lightGrayColor]];
        [self.nextCard setTransform:CGAffineTransformMakeScale(0.95f, 0.95f)];
        [self.view layoutIfNeeded];
    }];
}

- (UIPanGestureRecognizer *)currentPhotoPanRecognizer
{
    if ( !_currentPhotoPanRecognizer ) {
        _currentPhotoPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    
    return _currentPhotoPanRecognizer;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static UIAttachmentBehavior *attachment;
    static CGPoint               startCenter;
    
    // variables for calculating angular velocity
    
    static CFAbsoluteTime        lastTime;
    static CGFloat               lastAngle;
    static CGFloat               angularVelocity;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self.animator removeAllBehaviors];
        
        startCenter = gesture.view.center;
        
        // calculate the center offset and anchor point
        
        CGPoint pointWithinAnimatedView = [gesture locationInView:gesture.view];
        
        UIOffset offset = UIOffsetMake(pointWithinAnimatedView.x - gesture.view.bounds.size.width / 2.0,
                                       pointWithinAnimatedView.y - gesture.view.bounds.size.height / 2.0);
        
        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        
        // create attachment behavior
        
        attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view
                                               offsetFromCenter:offset
                                               attachedToAnchor:anchor];
        
        // code to calculate angular velocity (seems curious that I have to calculate this myself, but I can if I have to)
        
        lastTime = CFAbsoluteTimeGetCurrent();
        lastAngle = [self angleOfView:gesture.view];
        
        attachment.action = ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            CGFloat angle = [self angleOfView:gesture.view];
            if (time > lastTime) {
                angularVelocity = (angle - lastAngle) / (time - lastTime);
                lastTime = time;
                lastAngle = angle;
            }
        };
        
        // add attachment behavior
        
        [self.animator addBehavior:attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate
        
        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        attachment.anchorPoint = anchor;
        
        CGFloat tmpXTranslation = fabsf(self.currentCard.center.x - startCenter.x);
        CGFloat tmpYTranslation = fabsf(self.currentCard.center.y - startCenter.y);
        
        CGFloat tmpLabelAlpha = 1.0f;
        if ( tmpXTranslation < 50.0f && tmpYTranslation < 50.0f ) { // velocity.x < 100.0f && velocity.y < 100.0f ) {
            // wut
        } else {
            tmpLabelAlpha = 0.25f;
        }
        
        if ( self.currentCard.label.alpha != tmpLabelAlpha ) {
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.currentCard.label setAlpha:tmpLabelAlpha];
                             }
                             completion:nil];
            
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self.animator removeAllBehaviors];
        
        CGPoint velocity = [gesture velocityInView:gesture.view.superview];
        
        // NSLog(@"current card's position: %@", NSStringFromCGRect(self.currentCard.frame));
        // NSLog(@"current card's visible rect: %@", NSStringFromCGRect(CGRectIntersection([self.view bounds], [self.currentCard frame])));
        
        CGFloat tmpXTranslation = fabsf(self.currentCard.center.x - startCenter.x);
        CGFloat tmpYTranslation = fabsf(self.currentCard.center.y - startCenter.y);
        
        if ( tmpXTranslation < 50.0f && tmpYTranslation < 50.0f ) { // velocity.x < 100.0f && velocity.y < 100.0f ) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];
            
            return;
        }
        
        /*
        // if we aren't dragging it down, just snap it back and quit
        if (fabs(atan2(velocity.y, velocity.x) - M_PI_2) > M_PI_4) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];
            
            return;
        }
         */
        
        // otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)
        
        UIDynamicItemBehavior *dynamic = [[UIDynamicItemBehavior alloc] initWithItems:@[gesture.view]];
        [dynamic addLinearVelocity:velocity forItem:gesture.view];
        [dynamic addAngularVelocity:angularVelocity forItem:gesture.view];
        [dynamic setAngularResistance:2];
        
        // when the view no longer intersects with its superview, go ahead and remove it
        
        dynamic.action = ^{
            if (!CGRectIntersectsRect(gesture.view.superview.bounds, gesture.view.frame)) {
                [self.animator removeAllBehaviors];
                [gesture.view removeFromSuperview];
                
                [self presentNextCard];
            }
        };

        [self.animator addBehavior:dynamic];
        
        // add a little gravity so it accelerates off the screen (in case user gesture was slow)
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        gravity.magnitude = 0.7;
        [self.animator addBehavior:gravity];
    }
}

- (CGFloat)angleOfView:(UIView *)view
{
    // http://stackoverflow.com/a/2051861/1271826
    return atan2(view.transform.b, view.transform.a);
}

- (void)tapRecognizerPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareButtonPressed:(id)sender
{
    NSArray *tmpActivityItems = @[self.currentCard.label.text, self.currentCard.imageView.image];
    UIActivityViewController *tmpActivityViewController = [[UIActivityViewController alloc] initWithActivityItems:tmpActivityItems applicationActivities:nil];
    [self presentViewController:tmpActivityViewController animated:YES completion:nil];
}

@end




@implementation PhotoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configure];
}

- (instancetype)init
{
    if ( self = [super init] ) {
        [self configure];
    }
    
    return self;
}

- (void)configure
{
    if ( !self.label ) {
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:tmpLabel];
        
        [tmpLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [tmpLabel setTextAlignment:NSTextAlignmentCenter];
        [tmpLabel setNumberOfLines:0];
        [tmpLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        // [tmpLabel setText:@"wut"];
        
        [self setLabel:tmpLabel];
    }
    
    [self.layer setCornerRadius:4.0f];
    [self setClipsToBounds:YES];
}

@end
