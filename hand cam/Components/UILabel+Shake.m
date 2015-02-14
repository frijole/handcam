//
//  UILabel+Shake.m
//  ice lolly
//
//  Created by Ian Meyer on 9/21/14.
//  Copyright (c) 2014 frijole. All rights reserved.
//

#import "UILabel+Shake.h"

@implementation UILabel (Shake)

- (void)shakeLeft
{
    [UIView animateKeyframesWithDuration:0.6f
                                   delay:0.0f
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(-3.0f, 0.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(3.0f, 0.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(-3.0f, 0.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformIdentity;
                                  }];
                              } completion:nil];
}

- (void)shakeRight
{
    [UIView animateKeyframesWithDuration:0.6f
                                   delay:0.0f
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(3.0f, 0.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(-3.0f, 0.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(3.0f, 0.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformIdentity;
                                  }];
                              } completion:nil];
}

- (void)shakeUp
{
    [UIView animateKeyframesWithDuration:0.6f
                                   delay:0.0f
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(0.0f, 3.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(0.0f, -3.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(0.0f, 3.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformIdentity;
                                  }];
                              } completion:nil];
}

- (void)shakeDown
{
    [UIView animateKeyframesWithDuration:0.6f
                                   delay:0.0f
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(0.0f, -3.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(0.0f, 3.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.2 animations:^{
                                      self.transform = CGAffineTransformMakeTranslation(0.0f, -3.0f);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.1 animations:^{
                                      self.transform = CGAffineTransformIdentity;
                                  }];
                              } completion:nil];
}


@end
