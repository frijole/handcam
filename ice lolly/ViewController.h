//
//  ViewController.h
//  ice lolly
//
//  Created by Ian Meyer on 9/20/14.
//  Copyright (c) 2014 frijole. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AAPLPreviewView.h"

#import "LPCButton.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet AAPLPreviewView *previewView;

@property (nonatomic, weak) IBOutlet UIView *isoContainer;
@property (nonatomic, weak) IBOutlet UIImageView *isoIcon;
@property (nonatomic, weak) IBOutlet UILabel *isoLabel;

@property (nonatomic, weak) IBOutlet LPCButton *shutterButton;
-(IBAction)shutterButtonPressed:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *shutterContainer;
@property (nonatomic, weak) IBOutlet UIImageView *shutterIcon;
@property (nonatomic, weak) IBOutlet UILabel *shutterLabel;

@property (nonatomic, weak) IBOutlet UIView *focusContainer;
@property (nonatomic, weak) IBOutlet UIView *focusLockView;
@property (nonatomic, weak) IBOutlet UIImageView *lockIcon;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *focusLockTopSpaceConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *viewfinderFrame;
@property (nonatomic, weak) IBOutlet UIImageView *topPoint;
@property (nonatomic, weak) IBOutlet UIImageView *leftPoint;
@property (nonatomic, weak) IBOutlet UIImageView *rightPoint;
@property (nonatomic, weak) IBOutlet UIImageView *bottomPoint;

@property (nonatomic, weak) IBOutlet UIImageView *macroIcon;
@property (nonatomic, weak) IBOutlet UISlider *focusSlider;
@property (nonatomic, weak) IBOutlet UIImageView *distanceIcon;

@property (nonatomic, weak) IBOutlet UIView *thumbnailContainer;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@property (nonatomic, weak) IBOutlet UIView *videoSwitchContainer;
@property (nonatomic, weak) IBOutlet UIImageView *videoSwitch;

@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeUpRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) NSArray *swipeRecognizers;

- (IBAction)swipeUp:(id)sender;
- (IBAction)swipeDown:(id)sender;
- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeRight:(id)sender;

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;

- (IBAction)tapGestureRecognizerFired:(UITapGestureRecognizer *)tapRecognizer;
- (IBAction)longPressGestureRecognizerFired:(UILongPressGestureRecognizer *)longPressRecognizer;

@end

