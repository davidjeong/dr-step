//
//  BWBlueBeanConnector.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWBlueBeanConnector.h"

@implementation BWBlueBeanConnector

// Singleton class to handle the connection manager.
+ (id)connector {
    static BWBlueBeanConnector *connector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connector = [[self alloc] init];
    });
    return connector;
}

- (id) init {
    // Initialize the bean dictionary and the bean manager.
    self.beans = [[NSMutableDictionary alloc] init];
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    
    return self;
}

@end
