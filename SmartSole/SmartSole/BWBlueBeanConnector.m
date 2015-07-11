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
    self.dataString = [[NSMutableString alloc] init];
    
    
    return self;
}

#pragma mark - PTDBeanDelegate



- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data {
    NSString *fragment = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.dataString appendString:fragment];
    if ([fragment rangeOfString:@"end"].location != NSNotFound) {
        NSLog(@"%@", self.dataString);
        [self.dataString setString:@""];
    }
}



@end
