//
//  BWData.m
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 11..
//
//  For the purpose of storing data every minute to device.

#import "BWData.h"

#import "BWBlueBean.h"

@interface BWData()

@property (nonatomic, strong) NSMutableArray *lastMinuteData;
@property (assign, nonatomic) NSUInteger *counter;
@property (assign, nonatomic) NSUInteger numberOfSensors;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BWData

+ (id)data{
    static BWData *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}

- (id) init {
    self.counter = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"finishedProcessingData"
                                               object:nil];
    return self;
}

- (void) setCountAndInitialize:(NSUInteger)count {
    self.numberOfSensors = count;
    self.lastMinuteData = [[NSMutableArray alloc] initWithCapacity:self.numberOfSensors];
    for (int i=0; i<self.numberOfSensors; i++) {
        [self.lastMinuteData addObject:[NSNumber numberWithFloat:0.0]];
    }
    
    //Wait until next full minute
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate:[NSDate date]];
    NSInteger second = [components second];
    NSInteger tillNextMinute = (60 - second) % 60;
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:tillNextMinute];
}

- (void)startTimer {
    [self storeData:nil];
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(storeData:) userInfo:nil repeats:YES];
}

- (void) receivedNotification:(NSNotification *)notification {
    NSLog(@"Spawning new serial thread");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        if ([[notification name] isEqualToString:@"finishedProcessingData"]) {
            [self aggregateData:[notification object]];
        }
    });
}

- (void) aggregateData:(NSMutableArray*)array {
    @synchronized (self.lastMinuteData) {
        NSLog(@"Updating data array");
        for (int i=0; i<[self.lastMinuteData count]; i++) {
            float oldNumber = [[self.lastMinuteData objectAtIndex:i] floatValue];
            float newNumber = oldNumber + [[array objectAtIndex:i] floatValue];
            [self.lastMinuteData replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newNumber]];
        }
        self.counter++;
        NSLog(@"Finished updating data array");
    }
}

- (void) storeData:(NSTimer *)timer {
    BWBlueBean *blueBean = [BWBlueBean bean];
    if (blueBean.bean != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            @synchronized (self.lastMinuteData) {
                NSLog(@"Saving data.");
                // TODO Actually save data.
                [self.lastMinuteData removeAllObjects];
                for (int i=0; i<self.numberOfSensors; i++) {
                    [self.lastMinuteData addObject:[NSNumber numberWithFloat:0.0]];
                }
                self.counter = 0;
            }
        });
    }
}


@end
