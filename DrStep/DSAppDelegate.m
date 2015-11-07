//
//  AppDelegate.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>

#import "DSAppDelegate.h"
#import "DSAppConstants.h"
#import "DSData.h"
#import "DSLoginViewController.h"
#import "DSSymptom.h"
#import "LFHeatMap.h"

@interface DSAppDelegate ()

@end

@implementation DSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Parse/Facebook initialization
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"BgxsphIgSYDkELFFb0Da8EJKgUBgHKP574ZU2hT8"
                  clientKey:@"YTmzwHxuZqYBAPUznBAc20pYqDfO1XtLXLutGE0O"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // App tint color is orange.
    // App background color is HEX: #FFF6E9, or RGB(255, 246, 233).
    [self.window setTintColor:[UIColor orangeColor]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Set color for page control.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // Read Coordinates from file to memory.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Coordinates" ofType:@"plist"];
    NSArray *arrayFromFile = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *mutableCoordinates = [[NSMutableArray alloc] initWithCapacity:[arrayFromFile count]];
    for (int i=0; i<[arrayFromFile count]; i++) {
        CGPoint point = CGPointMake([[[arrayFromFile objectAtIndex:i] objectAtIndex:0] integerValue], [[[arrayFromFile objectAtIndex:i] objectAtIndex:1] integerValue]);
        [mutableCoordinates addObject:[NSValue valueWithCGPoint:point]];
    }
    
    DSAppConstants *constants = [DSAppConstants constants];
    constants.coordinates = [[NSArray alloc] initWithArray:mutableCoordinates];
    
    // Set the settings.
    PFQuery *query = [PFQuery queryWithClassName:@"Setting"];
    [query fromLocalDatastore];
    [query whereKey:@"key" equalTo:@"heatMapBoost"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *setting, NSError *error) {
        if (error) {
            NSLog(@"Error while trying to get settings.");
        }
        if (setting == nil) {
            constants.heatMapBoost = [NSNumber numberWithFloat:1.0f];
            PFObject *setting = [PFObject objectWithClassName:@"Setting"];
            setting[@"key"] = @"heatMapBoost";
            setting[@"value"] = [NSNumber numberWithFloat:1.0f];
            [setting pinInBackground];
        } else {
            constants.heatMapBoost = [NSNumber numberWithFloat:[[setting valueForKey:@"value"] floatValue]];
        }
    }];
    
    DSData *data = [DSData data];
    [data setCountAndInitialize:[arrayFromFile count]];
    
    if ([PFUser currentUser] || // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        // Load main app screen
        UIViewController *initialViewController =[storyboard instantiateInitialViewController];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
    } else {
        // Load Login/Signup View Controller
        UINavigationController *loginNavigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"DSLoginNavigationController"];
        self.window.rootViewController = loginNavigationController;
        [self.window makeKeyAndVisible];
    }
    
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
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Alert the user that by terminating the application, the motion will not be logged.
    DSAppConstants *constants = [DSAppConstants constants];
    if (constants.bean != nil) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate date];
        localNotification.alertBody = @"The application has been terminated. Please restart to continue monitoring.";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[notification alertTitle] message:[notification alertBody] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    self.window.rootViewController = alertController;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
