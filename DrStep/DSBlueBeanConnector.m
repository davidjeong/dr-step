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

@property (strong, nonatomic) DSDataParser *dataParser;

@end

@implementation DSBlueBeanConnector

#pragma mark - Lifecycle

- (id) init {
    // Initialize the bean dictionary and the bean manager.
    self.beans = [[NSMutableDictionary alloc] init];
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    self.dataParser = [[DSDataParser alloc] init];
    return self;
}

#pragma mark - Custom Accessor

+ (id) connector {
    static DSBlueBeanConnector *connector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connector = [[self alloc] init];
    });
    return connector;
}

#pragma mark - PTDBeanDelegate

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data {
    NSString *serialData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // When the data is received, parse the data.
    [self.dataParser processJSONIntoDictionary:serialData];
}

@end