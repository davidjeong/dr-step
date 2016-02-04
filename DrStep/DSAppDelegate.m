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

#import <sys/utsname.h>

#import "DSAppDelegate.h"
#import "DSAppConstants.h"
#import "DSDataParser.h"
#import "DSLoginViewController.h"
#import "DSSymptom.h"

@interface DSAppDelegate()

@end

@implementation DSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Parse/Facebook initialization
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"BgxsphIgSYDkELFFb0Da8EJKgUBgHKP574ZU2hT8"
                  clientKey:@"YTmzwHxuZqYBAPUznBAc20pYqDfO1XtLXLutGE0O"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // App background color is HEX: #FFFAF6, or RGB(255, 250, 246).
    // App Tint and Tab color is HEX: #4CBEA0, or RGB(76, 190, 160).
    [self.window setTintColor:[UIColor colorWithRed:76/255.0f green:216/255.0f blue:190/255.0f alpha:1.0f]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Set color for page control.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // Set the fetch frequency.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    DSAppConstants *constants = [DSAppConstants constants];
    
    // Get the coordinates.
    PFQuery *query = [PFQuery queryWithClassName:@"PressureCoordinates"];
    struct utsname systemInfo;
    uname(&systemInfo);
    [query whereKey:@"platformString" equalTo:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            if ([array count] == 1) {
                NSArray *coordinates = [[array valueForKey:@"coordinates"] objectAtIndex:0];
                NSMutableArray *coordinateBuilder = [[NSMutableArray alloc] init];
                for (int i = 0; i < coordinates.count; ++i) {
                    NSArray *xyPair = [coordinates objectAtIndex:i];
                    double x = [[xyPair objectAtIndex:0] floatValue];
                    double y = [[xyPair objectAtIndex:1] floatValue];
                    CGPoint point = CGPointMake(x, y);
                    [coordinateBuilder addObject:[NSValue valueWithCGPoint:point]];
                }
                constants.coordinates = [NSArray arrayWithArray:coordinateBuilder];
            } else {
                NSLog(@"Not supported device for realtime.");
            }
        }
    }];
    // Set the settings.
    
    query = [PFQuery queryWithClassName:@"Setting"];
    [query fromLocalDatastore];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            NSLog(@"Error trying to get count of settings.");
        }
        if (number == 0) {
            PFObject *setting = [PFObject objectWithClassName:@"Setting"];
            setting[@"heatMapBoost"] = [NSNumber numberWithFloat:1.0f];
            [setting pinInBackground];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:setting[@"heatMapBoost"] forKey:@"heatMapBoost"];
            constants.settings = [NSDictionary dictionaryWithDictionary:dict];
        } else {
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *setting, NSError *error) {
                if (error) {
                    NSLog(@"Error while trying to get settings");
                } else {
                    DSAppConstants *constants = [DSAppConstants constants];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:setting[@"heatMapBoost"] forKey:@"heatMapBoost"];
                    constants.settings = [NSDictionary dictionaryWithDictionary:dict];
                }
            }];
        }
    }];
    
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
