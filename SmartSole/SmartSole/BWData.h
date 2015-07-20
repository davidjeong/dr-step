//
//  BWData.h
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 11..
//
//  Class to work with every minute data.

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BWData : NSObject

@property (nonatomic, strong) NSMutableArray *lastMinuteData;
@property (assign, nonatomic) NSUInteger *counter;
@property (assign, nonatomic) NSUInteger numberOfSensors;

@property (nonatomic, strong) NSTimer *timer;

+(id)data;
- (void) setCountAndInitialize:(NSUInteger)count;

@end
