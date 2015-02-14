//
//  ViewController.h
//  obliquilator
//
//  Created by Ian Meyer on 11/12/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoView;

@interface PhotosViewController : UIViewController

@property (nonatomic, strong) IBOutlet PhotoView *currentCard;
@property (nonatomic, strong) IBOutlet PhotoView *nextCard;

@property (nonatomic, weak) IBOutlet UIButton *shareButton;

- (IBAction)tapRecognizerPressed:(id)sender;

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
