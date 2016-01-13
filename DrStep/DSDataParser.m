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

@end

@implementation DSDataParser

- (void) processJSONIntoDictionary:(NSString *) jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
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
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                    } else {
                        if (succeeded) {
                            NSLog(@"Successfully logged the data in parse.");
                        }
                    }
                }];
            }
        }
    }
}

@end
