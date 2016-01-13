//
//  DSAppConstants.m
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 17..
//
//  Singleton class to take care of global constants.

#import "DSAppConstants.h"

@implementation DSAppConstants

+ (id) constants {
    static DSAppConstants *constants = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constants = [[self alloc] init];
    });
    return constants;
}

- (id) init {
    self.coordinates = [[NSArray alloc] init];
    return self;
}

@end
