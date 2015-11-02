//
//  DSData.h
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 11..
//
//  Class to work with every minute data.

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DSData : NSObject

+(id)data;
- (void) setCountAndInitialize:(NSUInteger)count;

@end
