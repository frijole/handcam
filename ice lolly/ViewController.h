//
//  ViewController.h
//  ice lolly
//
//  Created by Ian Meyer on 9/20/14.
//  Copyright (c) 2014 frijole. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AAPLPreviewView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet AAPLPreviewView *previewView;

@property (nonatomic, weak) IBOutlet UIView *isoContainer;
@property (nonatomic, weak) IBOutlet UIImageView *isoIcon;
@property (nonatomic, weak) IBOutlet UILabel *isoLabel;

@property (nonatomic, weak) IBOutlet UIView *shutterContainer;
@property (nonatomic, weak) IBOutlet UIImageView *shutterIcon;
@property (nonatomic, weak) IBOutlet UILabel *shutterLabel;

@property (nonatomic, weak) IBOutlet UIImageView *viewfinderFrame;
@property (nonatomic, weak) IBOutlet UIImageView *topPoint;
@property (nonatomic, weak) IBOutlet UIImageView *leftPoint;
@property (nonatomic, weak) IBOutlet UIImageView *rightPoint;
@property (nonatomic, weak) IBOutlet UIImageView *bottomPoint;

- (IBAction)swipeUp:(id)sender;
- (IBAction)swipeDown:(id)sender;
- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeRight:(id)sender;

@end

