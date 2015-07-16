//
//  BWBlueBeanConnector.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWBlueBeanConnector.h"

static NSString *commaDelim = @",";

@implementation BWBlueBeanConnector

// Singleton class to handle the connection manager.
+ (id)connector {
    static BWBlueBeanConnector *connector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connector = [[self alloc] init];
    });
    return connector;
}

- (id) init {
    // Initialize the bean dictionary and the bean manager.
    self.beans = [[NSMutableDictionary alloc] init];
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    self.dataString = [[NSMutableString alloc] init];
    
    return self;
}

- (void) processStringIntoArray:(NSString *) dataString {
    NSArray *analogData = [dataString componentsSeparatedByString:commaDelim];
    if (analogData.count == numberOfSensors) {
        // Do further processing. As in put in a data structure and show fancy shmancy.
        NSLog(@"Array size looks beautiful by default: %lu.", analogData.count);
    } else {
        NSLog(@"O comon. Throw it out.");
    }
}

#pragma mark - PTDBeanDelegate

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *fragment = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!notifiedLowBattery && [fragment rangeOfString:@"battery_"].location != NSNotFound) {
        NSLog(@"Battery level is low.");
        UILocalNotification *batteryNotification = [[UILocalNotification alloc] init];
        batteryNotification.fireDate = [NSDate date];
        batteryNotification.alertBody = @"The battery level is low. Please replace battery to ensure optimal performance.";
        batteryNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:batteryNotification];
        notifiedLowBattery = YES;
    }
    
    [self.dataString appendString:fragment];
    if ([self.dataString rangeOfString:@"EOM"].location != NSNotFound) {
        [self.dataString deleteCharactersInRange:NSMakeRange([self.dataString length] - 3, 3)];
        NSLog(@"%@", self.dataString);
        [self processStringIntoArray:self.dataString];
        [self.dataString setString:@""];
    }
    });
}



@end
