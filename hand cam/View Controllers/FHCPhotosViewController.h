//
//  ViewController.h
//  obliquilator
//
//  Created by Ian Meyer on 11/12/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAPLPreviewView.h"

@class PhotoView;

@interface FHCPhotosViewController : UIViewController

@property (nonatomic) NSInteger currentIndex; // which photo are we showing?

@property (nonatomic, weak) IBOutlet UIView *photoContainer;
@property (nonatomic, strong) IBOutlet PhotoView *currentPhoto;
@property (nonatomic, strong) IBOutlet PhotoView *nextPhoto;

@property (nonatomic, weak) IBOutlet AAPLPreviewView *previewView;
- (IBAction)previewViewTapped:(id)sender;

@property (nonatomic, weak) IBOutlet UIButton *shareButton;
- (IBAction)shareButtonPressed:(id)sender;

@end


@interface PhotoView : UIView

// legacy
@property (nonatomic, weak) IBOutlet UILabel *label;

// new
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIButton *detailButton;

@property (nonatomic, weak) IBOutlet UIView *detailOverlay;
// more details tbd

@end
