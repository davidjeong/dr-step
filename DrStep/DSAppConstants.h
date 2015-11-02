//
//  DSAppConstants.h
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import <Foundation/Foundation.h>

@class PTDBean;

// NSString
static NSString* const DELIMITER_COMMA = @",";
static NSString* const DELIMITER_EOM = @"EOM";
static NSString* const DELIMITER_COLON = @":";

static NSString* const STATUS_LOW_BATTERY = @"lowBattery";
static NSString* const STATUS_RECEIVED_BATTERY = @"receivedBattery";

// Number
static const float MAXIMUM_VOLTAGE = 2.8;

@interface DSAppConstants : NSObject

@property (assign, nonatomic) BOOL notifiedLowBattery;
@property (strong, nonatomic) NSArray *coordinates;
@property (strong, nonatomic) NSNumber *heatMapBoost;
@property (nonatomic, strong) PTDBean *bean;

+ (id) constants;

@end
