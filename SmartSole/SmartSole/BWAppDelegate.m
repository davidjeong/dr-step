//
//  AppDelegate.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "BWAppDelegate.h"

@interface BWAppDelegate ()

@end

@implementation BWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set color for page control.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // Read Coordinates from file to memory.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Coordinates" ofType:@"plist"];
    NSArray *arrayFromFile = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *mutableCoordinates = [[NSMutableArray alloc] initWithCapacity:[arrayFromFile count]];
    for (int i=0; i<arrayFromFile.count; i++) {
        BWCoordinate *coordinate = [[BWCoordinate alloc] init];
        coordinate.x = [[[arrayFromFile objectAtIndex:i] objectAtIndex:0] integerValue];
        coordinate.y = [[[arrayFromFile objectAtIndex:i] objectAtIndex:1] integerValue];
        [mutableCoordinates addObject:coordinate];
    }
    BWAppConstants *constants = [BWAppConstants constants];
    constants.sensorCoordinates = [[NSArray alloc] initWithArray:mutableCoordinates];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^ {
        [application endBackgroundTask: self.backgroundTask]; //Tell the system that we are done with the tasks
        self.backgroundTask = UIBackgroundTaskInvalid; //Set the task to be invalid
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Alert the user that by terminating the application, the motion will not be logged.
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = @"The application has been terminated. Please restart to continue monitoring.";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
