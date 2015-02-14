//
//  UIImage+Colors.h
//  Icepack
//
//  Created by Ian Meyer on 1/11/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Colors)

+ (UIImage *)imageWithColor:(UIColor *)imageColor andSize:(CGSize)imageSize;
+ (UIImage *)imageWithColor:(UIColor *)imageColor;

@end
