//
//  AppDelegate.m
//  ice lolly
//
//  Created by Ian Meyer on 9/20/14.
//  Copyright (c) 2014 frijole. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Prevent the screen from dimming while we're running.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

@end
