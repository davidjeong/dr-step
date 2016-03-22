//
//  DSAppConstants.m
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import "DSAppConstants.h"

@implementation DSAppConstants

#pragma mark - Lifecycle

- (id) init {
    self.metricsPerRequest = (NSUInteger)100;
    self.coordinates = [[NSArray alloc] init];
    self.analyticsThreshold = (NSUInteger)1000;
    return self;
}

#pragma mark - Custom Accessor

+ (id) constants {
    static DSAppConstants *constants = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constants = [[self alloc] init];
    });
    return constants;
}

@end
