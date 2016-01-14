//
//  DSBlueBeanConnector.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "DSBlueBeanConnector.h"

#import "DSAppConstants.h"
#import "DSDataParser.h"

@interface DSBlueBeanConnector()

@end

@implementation DSBlueBeanConnector

// Singleton class to handle the connection manager.
+ (id) connector {
    static DSBlueBeanConnector *connector = nil;
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


#pragma mark - PTDBeanDelegate

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data {
    NSString *serialData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DSDataParser *parser = [DSDataParser parser];
    [parser processJSONIntoDictionary:serialData];
}

@end