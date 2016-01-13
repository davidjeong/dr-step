//
//  DSAppConstants.h
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import <Foundation/Foundation.h>

@class PTDBean;

// Number
static const float MAXIMUM_VOLTAGE = 2.8;

@interface DSAppConstants : NSObject

@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) NSArray *coordinates;
@property (nonatomic, strong) PTDBean *bean;

+ (id) constants;

@end
