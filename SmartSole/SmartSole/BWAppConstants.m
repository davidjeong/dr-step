//
//  BWAppConstants.m
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import "BWAppConstants.h"

@implementation BWAppConstants

+ (id) constants {
    static BWAppConstants *constants = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constants = [[self alloc] init];
    });
    return constants;
}

- (id) init {
    self.notifiedLowBattery = NO;
    self.coordinates = [[NSArray alloc] init];
    return self;
}

@end
