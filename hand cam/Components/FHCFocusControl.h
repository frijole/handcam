//
//  FHCFocusControl.h
//  hand cam
//
//  Created by Ian Meyer on 2/14/15.
//  Copyright (c) 2015 frijole. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHCFocusControl : UIControl

@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat maximumValue;

@property (nonatomic) NSInteger numberOfLines; // notches

@property (nonatomic) CGFloat value;

@property (nonatomic, weak, readonly) UIRotationGestureRecognizer *rotationRecognizer;

@end
