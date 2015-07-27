//
//  AppDelegate.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "DSAppDelegate.h"

#import "DSAppConstants.h"
#import "DSData.h"
#import "DSSymptom.h"
#import "LFHeatMap.h"

@interface DSAppDelegate ()

@end

@implementation DSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window setTintColor:[UIColor orangeColor]];
    
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

    path = [[NSBundle mainBundle] pathForResource:@"Symptoms" ofType:@"plist"];
    arrayFromFile = [[NSArray alloc] initWithContentsOfFile:path];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"scientificName" ascending:YES];
    NSMutableArray *mutableSymptoms = [[NSMutableArray alloc] init];
    for (int i=0; i<[arrayFromFile count]; i++) {
        DSSymptom *symptom = [[DSSymptom alloc] init];
        [symptom setScientificName:[[arrayFromFile objectAtIndex:i] objectForKey:@"scientificName"]];
        [symptom setCommonName:[[arrayFromFile objectAtIndex:i] objectForKey:@"commonName"]];
        [symptom setSymptomDescription:[[arrayFromFile objectAtIndex:i] objectForKey:@"description"]];
        [symptom setDiagnosis:[[arrayFromFile objectAtIndex:i] objectForKey:@"diagnosis"]];
        [mutableSymptoms addObject:symptom];
    }
    
    
    DSAppConstants *constants = [DSAppConstants constants];
    constants.coordinates = [[NSArray alloc] initWithArray:mutableCoordinates];
    constants.symptoms = [mutableSymptoms sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    
    // Start the thread to parse every minute collection into data.
    
    DSData *data = [DSData data];
    [data setCountAndInitialize:[arrayFromFile count]];
    
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[notification alertTitle] message:[notification alertBody] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
