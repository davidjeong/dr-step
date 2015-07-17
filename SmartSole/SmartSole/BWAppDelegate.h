//
//  AppDelegate.h
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>

#import "BWAppConstants.h"
#import "BWCoordinate.h"

@interface BWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

