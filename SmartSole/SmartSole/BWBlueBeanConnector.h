//
//  BWBlueBeanConnector.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//  This is a singleton class to hold manager and beans.
//

#import <Foundation/Foundation.h>
#import <PTDBeanManager.h>

#import "BWAppConstants.h"
#import "BWBlueBean.h"

@interface BWBlueBeanConnector : NSObject <PTDBeanDelegate, PTDBeanManagerDelegate>

@property (nonatomic, strong) PTDBeanManager *beanManager;
@property (nonatomic, strong) NSMutableDictionary *beans;
@property (retain, nonatomic) NSMutableString *dataString;

+ (id)connector;


@end
