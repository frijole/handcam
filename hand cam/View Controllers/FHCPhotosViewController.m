//
//  ViewController.m
//  obliquilator
//
//  Created by Ian Meyer on 11/12/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import "FHCPhotosViewController.h"

#import <Photos/Photos.h>
#import "FHCPhotoManager.h"

@interface FHCPhotosViewController ()

@property (nonatomic, strong) UIPanGestureRecognizer *currentPhotoPanRecognizer;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation FHCPhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // one-time nib cleanup of the next card
    if ( self.nextPhoto ) {
        [self.nextPhoto setTransform:CGAffineTransformMakeScale(0.95f, 0.95f)];
    }

    // general prep
    [self prepareCurrentPhoto];
    [self prepareNextPhoto];

    // ooh shiny
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)presentNextPhoto
{
    if ( !self.nextPhoto ) {
        // time to die
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // bump it up
                         [self.nextPhoto setBackgroundColor:[UIColor whiteColor]];
                         [self.nextPhoto setAlpha:1.0F];
                         [self.nextPhoto setTransform:CGAffineTransformIdentity];
                         
                         // shuffle things around
                         [self setCurrentPhoto:self.nextPhoto];
                         [self setNextPhoto:nil];
                         
                         // increment the index
                         [self setCurrentIndex:self.currentIndex+1];
                         
                         // and reset
                         [self prepareCurrentPhoto];
                         [self prepareNextPhoto];
                     }];
}

- (void)prepareCurrentPhoto
{
    if ( !self.currentPhoto ) {
        // TODD: create current card if necessary
        [self setCurrentPhoto:[PhotoView new]];
        [self.currentPhoto setAutoresizingMask:UIViewAutoresizingNone];
        [self.currentPhoto setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:self.currentPhoto];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPhoto attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-20.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPhoto attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.currentPhoto attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPhoto attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPhoto attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }
    
    // TODO: prepare current photo!
    if ( self.currentIndex < [[FHCPhotoManager defaultManager] cameraRoll].count ) {
        [self.currentPhoto.imageView setImage:[[[FHCPhotoManager defaultManager] cameraRoll] objectAtIndex:self.currentIndex]];
    } else {
        NSLog(@"no image to display?!");
    }
    
    if ( self.currentPhotoPanRecognizer.view ) {
        [self.currentPhotoPanRecognizer.view removeGestureRecognizer:self.currentPhotoPanRecognizer];
    }
    
    [self.currentPhoto setGestureRecognizers:@[self.currentPhotoPanRecognizer]];
}

- (void)prepareNextPhoto
{
    if ( self.currentIndex+1 >= [[[FHCPhotoManager defaultManager] cameraRoll] count] ) {
        // TODO: do something better to indicate the end
        return;
    }

    if ( !self.nextPhoto ) {
        // create next card if necessary
        [self setNextPhoto:[PhotoView new]];
        [self.nextPhoto setBackgroundColor:[UIColor whiteColor]];
        [self.nextPhoto setAutoresizingMask:UIViewAutoresizingNone];
        [self.nextPhoto setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view insertSubview:self.nextPhoto belowSubview:self.currentPhoto];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextPhoto attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoContainer attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-5.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextPhoto attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.nextPhoto attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextPhoto attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.photoContainer attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextPhoto attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.photoContainer attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }

    // update photo on card
    UIImage *tmpImage = [[[FHCPhotoManager defaultManager] cameraRoll] objectAtIndex:self.currentIndex+1];
    [self.nextPhoto.imageView setImage:tmpImage];
    
    [UIView performWithoutAnimation:^{
        [self.nextPhoto setAlpha:0.75f];
        [self.nextPhoto setTransform:CGAffineTransformMakeScale(0.95f, 0.95f)];
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
        
        CGFloat tmpXTranslation = fabsf(self.currentPhoto.center.x - startCenter.x);
        CGFloat tmpYTranslation = fabsf(self.currentPhoto.center.y - startCenter.y);
        
        CGFloat tmpLabelAlpha = 1.0f;
        if ( tmpXTranslation < 50.0f && tmpYTranslation < 50.0f ) { // velocity.x < 100.0f && velocity.y < 100.0f ) {
            // wut
        } else {
            tmpLabelAlpha = 0.25f;
        }
        
        if ( self.currentPhoto.label.alpha != tmpLabelAlpha ) {
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.currentPhoto.label setAlpha:tmpLabelAlpha];
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
        
        CGFloat tmpXTranslation = fabsf(self.currentPhoto.center.x - startCenter.x);
        CGFloat tmpYTranslation = fabsf(self.currentPhoto.center.y - startCenter.y);
        
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
                
                [self presentNextPhoto];
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

- (void)previewViewTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareButtonPressed:(id)sender
{
    NSArray *tmpActivityItems = @[self.currentPhoto.label.text, self.currentPhoto.imageView.image];
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
