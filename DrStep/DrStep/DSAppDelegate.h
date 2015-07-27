//
//  AppDelegate.h
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>

@interface DSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

