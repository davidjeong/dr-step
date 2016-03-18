//
//  DSAppConstants.h
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import <Foundation/Foundation.h>

@class PTDBean;

@interface DSAppConstants : NSObject

@property (assign, nonatomic) NSUInteger metricsPerRequest;
@property (strong, nonatomic) NSDictionary *settings;
@property (atomic) NSDictionary *symptomToSimilarity;
@property (strong, nonatomic) NSArray *coordinates;
@property (nonatomic, strong) PTDBean *bean;

+ (id) constants;

@end
