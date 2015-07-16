//
//  BWBlueBean.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 9..
//
//  Singleton to hold global bean.

#import <Foundation/Foundation.h>
#import <PTDBean.h>

@interface BWBlueBean : NSObject

@property (nonatomic, strong) PTDBean *bean;
@property (nonatomic, assign) NSString *beanName;

+ (id) bean;

@end
