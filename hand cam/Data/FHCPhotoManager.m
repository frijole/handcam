//
//  FHCPhotoManager.m
//  hand cam
//
//  Created by Ian Meyer on 2/14/15.
//  Copyright (c) 2015 frijole. All rights reserved.
//

#import "FHCPhotoManager.h"
#import <Photos/Photos.h>


NSString * const kFHCPhotoManagerCameraRollUpdatedNotification = @"cameraRollUpdated";


@interface FHCPhotoManager ()

@property (nonatomic, strong, readwrite) NSArray *cameraRoll;

@end


static FHCPhotoManager *_defaultManager = nil;


@implementation FHCPhotoManager

+ (FHCPhotoManager *)defaultManager
{
    if ( !_defaultManager ) {
        _defaultManager = [FHCPhotoManager new];
    }
    
    return _defaultManager;
}

- (NSArray *)cameraRoll
{
    if ( !_cameraRoll ) {
        // update it!
        [self updateCameraRoll];
    }
    
    return _cameraRoll;
}

- (void)updateCameraRoll
{
    // fetch the camera roll images
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    // create a dictionary to stash the photos in, along with their indicies, to sort after.
    __block NSMutableDictionary *tmpPhotoDictionary = [NSMutableDictionary dictionary];
    
    // set aside the screen size to target the images
    CGSize tmpTargetSize = [[UIScreen mainScreen] bounds].size;

    dispatch_group_t tmpGroup = dispatch_group_create();
    [fetchResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[PHAsset class]] ) {
            PHAsset *tmpAsset = (PHAsset *)obj;
            if ( tmpAsset.mediaType == PHAssetMediaTypeImage ) {
                PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
                [imageRequestOptions setResizeMode:PHImageRequestOptionsResizeModeFast];
                [imageRequestOptions setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
                dispatch_group_enter(tmpGroup);
                [[PHImageManager defaultManager] requestImageForAsset:tmpAsset targetSize:tmpTargetSize contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                    [tmpPhotoDictionary setObject:result forKey:@(idx)];
                    dispatch_group_leave(tmpGroup);
                }];
            }
        }
        
        if ( idx > 10 ) {
            *stop = YES;
        }
    }];
    
    dispatch_group_notify(tmpGroup, dispatch_get_main_queue(), ^{
        //  NSLog(@"updated all items (%@)", @(tmpItems.count));
        NSArray *tmpItems = @[];
        for ( int i=0; i < 10; i++ ) {
            NSObject *tmpPhoto = [tmpPhotoDictionary objectForKey:@(i)];
            // make sure we don't try to add nil to the array
            if ( tmpPhoto ) {
                tmpItems = [tmpItems arrayByAddingObject:tmpPhoto];
            }
        }
        [self setCameraRoll:tmpItems];

        [[NSNotificationCenter defaultCenter] postNotificationName:kFHCPhotoManagerCameraRollUpdatedNotification object:self.cameraRoll];
    });
}

- (void)startCameraRollUpdates
{
    // TODO: lol
}

- (void)stopCameraRollUpdates
{
    // TODO: wut
}


@end
