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

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Parse/Facebook initialization
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"BgxsphIgSYDkELFFb0Da8EJKgUBgHKP574ZU2hT8"
                  clientKey:@"YTmzwHxuZqYBAPUznBAc20pYqDfO1XtLXLutGE0O"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    // App Tint and Tab color is HEX: #4CBEA0, or RGB(76, 190, 160).
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    
    // Fetch the coordinates from Parse.
    // The coordinates differ based on iPhone device Id.
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
    
    
    // Load settings from local data store.
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
    
    // Check if user is cached
    if ([PFUser currentUser] ||
        // Check if user is linked to Facebook
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Load main app screen if current user is logged in to the application.
        UIViewController *initialViewController =[storyboard instantiateInitialViewController];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
    } else {
        // Load LoginView Controller
        UINavigationController *loginNavigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"DSLoginNavigationController"];
        self.window.rootViewController = loginNavigationController;
        [self.window makeKeyAndVisible];
    }
    
    return YES;
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Local Notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[notification alertTitle] message:[notification alertBody] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    self.window.rootViewController = alertController;
    [self.window makeKeyAndVisible];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initialViewController =[storyboard instantiateInitialViewController];
    self.window.rootViewController = initialViewController;
    [self.window makeKeyAndVisible];
}

@end
