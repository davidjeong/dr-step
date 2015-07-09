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

@interface BWBlueBeanConnector : NSObject <PTDBeanManagerDelegate, PTDBeanDelegate>

@property (nonatomic, strong) PTDBeanManager *beanManager;
@property (nonatomic, strong) NSMutableDictionary *beans;

+ (id)connector;

@end
