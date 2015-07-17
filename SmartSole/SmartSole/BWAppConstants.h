//
//  BWAppConstants.h
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import <Foundation/Foundation.h>


// NSString
static NSString* const commaDelim = @",";
static NSString* const EOM = @"EOM";
static NSString* const separatorDelim = @":";
static NSString* const statusBattery = @"battery_";

// Number
static const NSUInteger circleRadius = 30;
static const float maximumVoltage = 2.8;
static const NSUInteger numberOfSensors = 12;

@interface BWAppConstants : NSObject

@property (assign, nonatomic) BOOL notifiedLowBattery;
@property (strong, nonatomic) NSArray *sensorCoordinates;

+ (id) constants;

@end
