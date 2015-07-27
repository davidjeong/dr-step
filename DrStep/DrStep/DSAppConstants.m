//
//  DSAppConstants.m
//  BioWear
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
    self.notifiedLowBattery = NO;
    self.coordinates = [[NSArray alloc] init];
    self.symptoms = [[NSArray alloc] init];
    self.heatMapBoost = [NSNumber numberWithFloat:1.0f];
    self.infoFontSize = [NSNumber numberWithInt:15];
    return self;
}

@end
