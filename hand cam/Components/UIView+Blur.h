//
//  UIView+Blur.h
//  lollipop parts
//
//  Created by Ian Meyer on 7/19/14.
//  Copyright (c) 2014 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Blur)

- (UIImage *)snapshot;
- (UIImage *)blurredSnapshot;

@end

@interface UIImage (ImageEffects)

- (UIImage *)cropToRect:(CGRect)rect;

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
