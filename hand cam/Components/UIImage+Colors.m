//
//  UIImage+Colors.m
//  Icepack
//
//  Created by Ian Meyer on 1/11/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import "UIImage+Colors.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Colors)

+ (UIImage *)imageWithColor:(UIColor *)imageColor andSize:(CGSize)imageSize
{
    UIImage *rtnImage = nil;
    
    CGRect tmpImageRect = CGRectMake(0.0f, 0.f, imageSize.width, imageSize.height);

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, imageColor.CGColor);
    CGContextFillRect(context, tmpImageRect);
    
    rtnImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rtnImage;
}

+ (UIImage *)imageWithColor:(UIColor *)imageColor
{
    return [[self class] imageWithColor:imageColor andSize:CGSizeMake(1.0f, 1.0f)];
}

@end
