//
//  BWBlueBean.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 9..
//
//  Global static variable holding bean information.

#import <Foundation/Foundation.h>
#import <PTDBean.h>


static PTDBean *applicationBean;
static NSString *applicationBeanName;

@interface BWBlueBean : NSObject

+ (PTDBean *) getBean;
+ (void) setBean:(PTDBean *)bean;

+ (NSString *) getBeanName;
+ (void) setBeanName:(NSString *) beanName;

@end
