//
//  FHCPhotoManager.h
//  hand cam
//
//  Created by Ian Meyer on 2/14/15.
//  Copyright (c) 2015 frijole. All rights reserved.
//
//  Used to fetch the camera roll and keep a local cache for display.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kFHCPhotoManagerCameraRollUpdatedNotification;

@interface FHCPhotoManager : NSObject

+ (FHCPhotoManager *)defaultManager;

@property (nonatomic, readonly) NSArray *cameraRoll;

- (void)startCameraRollUpdates;
- (void)stopCameraRollUpdates;

@end
