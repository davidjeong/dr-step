//
//  DSBlueBeanConnector.h
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//  This is a singleton class to hold manager and beans.
//

#import <Foundation/Foundation.h>
#import <PTDBean.h>
#import <PTDBeanManager.h>

@interface DSBlueBeanConnector : NSObject <PTDBeanDelegate, PTDBeanManagerDelegate>

@property (nonatomic, strong) PTDBeanManager *beanManager;
@property (nonatomic, strong) NSMutableDictionary *beans;

+ (id) connector;

@end