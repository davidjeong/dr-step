//
//  BWBlueBeanConnector.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWBlueBeanConnector.h"

@implementation BWBlueBeanConnector

+ (id)connector {
    static BWBlueBeanConnector *connector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connector = [[self alloc] init];
    });
    return connector;
}

- (id) init {
    self.beans = [[NSMutableDictionary alloc] init];
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    
    return self;
}

@end
