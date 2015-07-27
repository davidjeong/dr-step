//
//  DSBlueBeanConnector.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "DSBlueBeanConnector.h"

#import "DSAppConstants.h"

@interface DSBlueBeanConnector()

@property (retain, nonatomic) NSMutableString *dataString;

@end

@implementation DSBlueBeanConnector

// Singleton class to handle the connection manager.
+ (id)connector {
    static DSBlueBeanConnector *connector = nil;
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
    DSAppConstants* constants = [DSAppConstants constants];
    NSArray *analogData = [dataString componentsSeparatedByString:commaDelim];
    if ([analogData count] == [constants.coordinates count]) {
        // Do further processing. As in put in a data structure and show fancy shmancy.
        NSLog(@"Array size looks beautiful by default: %lu.", [analogData count]);
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSString *string in analogData) {
            NSArray *splitData = [string componentsSeparatedByString:separatorDelim];
            if ([splitData count] == 2) {
                [tempArray addObject:[splitData objectAtIndex:1]];
            }
        }
        if ([tempArray count] == [constants.coordinates count]) {
            NSLog(@"Valid data.");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"finishedProcessingData"
             object:tempArray];
        }
    } else {
        NSLog(@"Corrupt data... discarding.");
    }
}

#pragma mark - PTDBeanDelegate

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self.dataString) {
            NSString *fragment = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DSAppConstants *constants = [DSAppConstants constants];
            if (!constants.notifiedLowBattery && [fragment rangeOfString:statusBattery].location != NSNotFound) {
                NSLog(@"Battery level is low.");
                UILocalNotification *batteryNotification = [[UILocalNotification alloc] init];
                batteryNotification.fireDate = [NSDate date];
                batteryNotification.alertBody = @"The battery level is low. Please replace battery to ensure optimal performance.";
                batteryNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:batteryNotification];
                constants.notifiedLowBattery = YES;
                [constants.bean sendSerialData:[receivedBatteryStatus dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [self.dataString appendString:fragment];
            if ([self.dataString rangeOfString:EOM].location != NSNotFound) {
                [self.dataString deleteCharactersInRange:NSMakeRange([self.dataString length] - 3, 3)];
                NSLog(@"%@", self.dataString);
                [self processStringIntoArray:self.dataString];
                [self.dataString setString:@""];
            }
        }
    });
}

@end
