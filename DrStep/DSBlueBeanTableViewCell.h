//
//  DSBeanTableViewCell.h
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>

@class PTDBean;

@interface DSBlueBeanTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, assign) BeanState state;
@property (nonatomic, strong) NSString *voltage;

@end
