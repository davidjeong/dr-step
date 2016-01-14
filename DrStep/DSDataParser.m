//
//  DSDataParser.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "DSDataParser.h"

#import <Parse/Parse.h>

#import "DSAppConstants.h"

@interface DSDataParser()

@property (retain, nonatomic) NSMutableString *json;
@property (strong, nonatomic) NSMutableArray *objects;

@end

@implementation DSDataParser

// Singleton class to handle the connection manager.
+ (id) parser {
    static DSDataParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[self alloc] init];
    });
    return parser;
}

- (id) init {
    self.objects = [[NSMutableArray alloc] init];
    self.json = [[NSMutableString alloc] init];
    return self;
}

- (void) processJSONIntoDictionary:(NSString *) jsonString {
    [self.json appendString:jsonString];
    if (![jsonString isEqualToString:@"}"]) {
        return;
    }
    NSError *error;
    NSData *jsonData = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"Corrupt data... discarding.");
    } else {
        if ([jsonObject objectForKey:@"accelerationX"] != nil &&
            [jsonObject objectForKey:@"accelerationY"] != nil &&
            [jsonObject objectForKey:@"accelerationZ"] != nil &&
            [jsonObject objectForKey:@"data"] != nil) {
            NSLog(@"Successful conversion into dictionary");
            NSArray *dataArray = [jsonObject valueForKey:@"data"];
            if ([dataArray count] == 12) {
                PFObject *object = [PFObject objectWithClassName:@"RecentMetric"];
                object[@"user"] = [PFUser currentUser];
                object[@"pressure"] = dataArray;
                object[@"accelerationX"] = [jsonObject valueForKey:@"accelerationX"];
                object[@"accelerationY"] = [jsonObject valueForKey:@"accelerationY"];
                object[@"accelerationZ"] = [jsonObject valueForKey:@"accelerationZ"];
                [self.objects addObject:object];
                // Send every 100 points
                DSAppConstants *constants = [DSAppConstants constants];
                if ([self.objects count] == constants.metricsPerRequest) {
                    [PFObject saveAllInBackground:self.objects block:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"%@", error);
                        } else {
                            if (succeeded) {
                                NSLog(@"Successfully logged the data in parse.");
                            }
                            [self.objects removeAllObjects];
                        }
                    }];
                }
            }
        }
    }
    [self.json setString:@""];
}

@end
