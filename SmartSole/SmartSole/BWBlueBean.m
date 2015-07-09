//
//  BWBlueBean.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 9..
//
//  Accessor and mutator for global static variables.

#import "BWBlueBean.h"

@implementation BWBlueBean

+ (PTDBean *)getBean {
    return applicationBean;
}

+ (void) setBean:(PTDBean *)bean {
    applicationBean = bean;
}

+ (NSString *) getBeanName {
    return applicationBeanName;
}

+ (void) setBeanName:(NSString *) beanName {
    applicationBeanName = beanName;
}

@end
