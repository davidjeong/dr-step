//
//  BWBlueBean.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 9..
//
//  Singleton to hold global bean.

#import "BWBlueBean.h"

@implementation BWBlueBean

// Singleton class to handle the connection manager.
+ (id) bean {
    static BWBlueBean *blueBean = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blueBean = [[self alloc] init];
    });
    return blueBean;
}

@end
